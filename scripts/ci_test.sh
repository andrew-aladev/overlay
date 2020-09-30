#!/bin/bash
set -e

# Disabling CI and coverage flags.
unset CI
unset COVERAGE

OVERLAY_NAME="andrew-aladev"
NOT_IMPORTANT_USES=(
  "abi_*"
  "noman"
  "ruby_targets_*"
  "static*"
  "test"
)

# List available package names with versions.
mapfile -t package_names < <(eix --in-overlay "$OVERLAY_NAME" --format '<availableversions:EQNAMEVERSION>' --pure-packages)

for package_name in "${package_names[@]}"; do
  package="${package_name}::${OVERLAY_NAME}"

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
      use_value=$((1 << $use_index))

      if [[ $(($combination & $use_value)) -eq $use_value ]]; then
        current_uses+=("$use")
      else
        current_uses+=("-${use}")
      fi
    done

    echo "Testing package: \"${package}\", uses: \"${current_uses[@]}\""

    # Current uses may be invalid for package.
    if USE="${current_uses[@]}" build.sh -pv1 "$package"; then
      FEATURES="test" USE="${current_uses[@]}" build.sh -v1 "$package"
    fi
  done
done
