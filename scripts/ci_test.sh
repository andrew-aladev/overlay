#!/usr/bin/env bash
set -e

# We are testing only best versions in slots by default.
# It is possible to test all available versions by passing "all" as first argument.
if [ "$1" == "all" ]; then
  target_versions="availableversions"
else
  target_versions="bestslotversions"
fi

# Disabling CI and coverage flags.
unset CI
unset COVERAGE

# Overlay specific constants.
OVERLAY_NAME="andrew-aladev"
NOT_IMPORTANT_USES=(
  "abi_*"
  "noman"
  "ruby_targets_*"
  "static*"
)

# List available package names with versions.
mapfile -t package_names < <(eix \
  --in-overlay "$OVERLAY_NAME" \
  --format "<${target_versions}:EQNAMEVERSION>" \
  --pure-packages \
)

mkdir -p /etc/portage/{env,package.env,package.use}
echo "FEATURES=\"test\"" > /etc/portage/env/test.conf

for package_name in "${package_names[@]}"; do
  package="${package_name}::${OVERLAY_NAME}"

  # List available uses for package.
  mapfile -t uses < <(equery --quiet uses $package | sed "s/^[+-]//")

  # Ignoring not important uses.
  important_uses=()

  for use in "${uses[@]}"; do
    is_use_important=true

    for NOT_IMPORTANT_USE in "${NOT_IMPORTANT_USES[@]}"; do
      if [[ "$use" == $NOT_IMPORTANT_USE ]]; then
        is_use_important=false
        break
      fi
    done

    if [ "$is_use_important" = true ]; then
      important_uses+=("$use")
    fi
  done

  # Emerging package with all possible use combinations.
  important_uses_length="${#important_uses[*]}"
  combinations_length=$((1 << $important_uses_length))

  some_test_passed=false

  for ((combination = 0; combination < $combinations_length; combination++)); do
    current_uses=()
    has_test_use=false

    for use_index in "${!important_uses[@]}"; do
      use="${important_uses[$use_index]}"
      use_value=$((1 << $use_index))

      if [[ $(($combination & $use_value)) -eq $use_value ]]; then
        current_uses+=("$use")
        if [[ "$use" == "test" ]]; then
          has_test_use=true
        fi
      else
        current_uses+=("-${use}")
      fi
    done

    echo "Testing package: ${package}, uses: \"${current_uses[@]}\""

    if [ "$has_test_use" = true ]; then
       echo "${package} test.conf" > /etc/portage/package.env/current_package
    else
       rm -f /etc/portage/package.env/current_package
    fi

    echo "${package} ${current_uses[@]}" > /etc/portage/package.use/current_package

    command="build.sh -v1 ${package}"

    # Ignoring invalid uses for package.
    if bash -cl "${command} --pretend"; then
      bash -cl "$command"
      some_test_passed=true
    else
      echo "Current uses are invalid for package"
    fi
  done

  if [ "$some_test_passed" = false ]; then
    >&2 echo "At least one test should pass for package: ${package}"
    exit 1
  fi
done
