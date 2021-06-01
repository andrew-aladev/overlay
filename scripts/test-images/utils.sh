#!/usr/bin/env bash
set -e

XDG_RUNTIME_DIR="/tmp/buildah-runtime"
mkdir -p "$XDG_RUNTIME_DIR"

tool () {
  XDG_RUNTIME_DIR="$XDG_RUNTIME_DIR" buildah unshare -- buildah "$@"
}

# -- wrappers --

bud () {
  tool bud \
    --cap-add=CAP_SETFCAP \
    --cap-add=CAP_SYS_PTRACE \
    --security-opt="seccomp=unconfined" \
    --isolation="rootless" \
    "$@"
}

from () {
  tool from \
    --cap-add=CAP_SETFCAP \
    --cap-add=CAP_SYS_PTRACE \
    --security-opt="seccomp=unconfined" \
    --isolation="rootless" \
    "$1"
}

run () {
  tool run \
    --cap-add=CAP_SETFCAP \
    --cap-add=CAP_SYS_PTRACE \
    --isolation="rootless" \
    "$@"
}

mount () {
  tool mount "$1"
}

unmount () {
  tool unmount "$1"
}

copy () {
  tool copy "$1" "$2" "$3"
}

remove () {
  tool rm "$1"
}

# -- utils --

build () {
  args=()

  for arg_name in $IMAGE_BUILD_ARGS; do
    args+=(--build-arg ${arg_name}="${!arg_name}")
  done

  # Layers are enabled by default.
  layers=${IMAGE_LAYERS:-"true"}

  bud \
    "${args[@]}" \
    --tag "$IMAGE_NAME" \
    --platform="$IMAGE_PLATFORM" \
    --label maintainer="$MAINTAINER" \
    --layers="$layers" \
    "$@" \
    "."
}

push () {
  docker_image_name="docker://${DOCKER_HOST}/${DOCKER_USERNAME}/${IMAGE_NAME}"

  logged_docker_username=$(tool login --get-login "$DOCKER_HOST" || :)
  if [ "$logged_docker_username" != "$DOCKER_USERNAME" ]; then
    tool login --username "$DOCKER_USERNAME" "$DOCKER_HOST"
  fi

  tool push "$IMAGE_NAME" "$docker_image_name"
}

pull () {
  docker_image_name="docker://${DOCKER_HOST}/${DOCKER_USERNAME}/${IMAGE_NAME}"

  tool pull "$docker_image_name"
  tool tag "$docker_image_name" "$IMAGE_NAME"
}

run_image () {
  container=$(from "$IMAGE_NAME")

  run $CONTAINER_OPTIONS "$container" "$@" || error=$?

  remove "$container" || :

  if [ ! -z "$error" ]; then
    exit "$error"
  fi
}

# -- portage --

with_portage () {
  processor="$1"
  shift 1

  portage=$(from "${DOCKER_HOST}/${DOCKER_USERNAME}/test_portage")
  portage_root=$(mount "$portage") || error=$?

  PORTAGE_OPTIONS="${CONTAINER_OPTIONS} --volume ${portage_root}/var/db/repos/gentoo:/var/db/repos/gentoo"

  if [ "$processor" == "run_image" ]; then
    CONTAINER_OPTIONS="$PORTAGE_OPTIONS" run_image "$@" || error=$?
  else
    $processor $PORTAGE_OPTIONS "$@" || error=$?
  fi

  unmount "$portage" || :
  remove "$portage" || :

  if [ ! -z "$error" ]; then
    exit "$error"
  fi
}

build_with_portage () {
  with_portage "build" "$@"
}

run_image_with_portage () {
  with_portage "run_image" "$@"
}
