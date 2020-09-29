#!/bin/bash
set -e

OVERLAY_NAME="andrew-aladev"
IGNORE_USES=(
  "abi_*"
  "noman"
  "ruby_targets_*"
  "test"
)

# List available packages with versions.
mapfile -t packages < <(eix --in-overlay "$OVERLAY_NAME" --format '<availableversions:EQNAMEVERSION>' --pure-packages)

for package in "${packages[@]}"; do
  # List available uses for package.
  mapfile -t uses < <(equery --quiet uses "$package" | sed "s/^[+-]//")

  # Ignoring several uses.
  filtered_uses=()

  for use in "${uses[@]}"; do
    is_use_valid=true

    for IGNORE_USE in "${IGNORE_USES[@]}"; do
      if [[ "$use" == $IGNORE_USE ]]; then
        is_use_valid=false
        break
      fi
    done

    if [ "$is_use_valid" = true ]; then
      filtered_uses+=("$use")
    fi
  done

  # Emerging package with all possible use combinations.
  filtered_uses_length="${#filtered_uses[*]}"
  combinations_length=$((1 << $filtered_uses_length))

  for ((combination = 0; combination < $combinations_length; combination++)); do
    current_uses=()

    for use_index in "${!filtered_uses[@]}"; do
      use="${filtered_uses[$use_index]}"
      use_value=$((1 << ($use_index - 1)))

      if [[ $(($combination & $use_value)) -eq $use_value ]]; then
        current_uses+=("+${use}")
      else
        current_uses+=("-${use}")
      fi
    done

    echo "Testing package: \"$package\", uses: \"${current_uses[@]}\""
    FEATURES="test" USE="${current_uses[@]}" build.sh -v1 "$package"
  done
done
