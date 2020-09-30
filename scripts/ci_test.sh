#!/bin/bash
set -e

OVERLAY_NAME="andrew-aladev"
NOT_IMPORTANT_USES=(
  "abi_*"
  "noman"
  "ruby_targets_*"
  "static*"
  "test"
)

# List available packages with versions.
mapfile -t packages < <(eix --in-overlay "$OVERLAY_NAME" --format '<availableversions:EQNAMEVERSION>' --pure-packages)

for package in "${packages[@]}"; do
  # List available uses for package.
  mapfile -t uses < <(equery --quiet uses "$package" | sed "s/^[+-]//")

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

  for ((combination = 0; combination < $combinations_length; combination++)); do
    current_uses=()

    for use_index in "${!important_uses[@]}"; do
      use="${important_uses[$use_index]}"
      use_value=$((1 << ($use_index - 1)))

      if [[ $(($combination & $use_value)) -eq $use_value ]]; then
        current_uses+=("$use")
      else
        current_uses+=("-${use}")
      fi
    done

    FEATURES="test" USE="${current_uses[@]}" build.sh -v1 "$package"
  done
done
