#!/usr/bin/env bash

set -euo pipefail

if [[ $# -ne 1 ]]; then
  echo "Usage: $0 cli-v<pubspec-version>" >&2
  exit 64
fi

repository_root="$(cd "$(dirname "${BASH_SOURCE[0]}")/.." && pwd)"
pubspec="$repository_root/configurator/pubspec.yaml"
release_tag="$1"
canonical_repository="camrongiuliani/configurator"

if [[ "${GITHUB_ACTIONS:-}" == "true" && "${GITHUB_REPOSITORY:-}" != "$canonical_repository" ]]; then
  echo "CLI release validation failed: publishing is restricted to $canonical_repository." >&2
  exit 1
fi

if [[ ! -f "$pubspec" ]]; then
  echo "CLI release validation failed: missing configurator/pubspec.yaml." >&2
  exit 1
fi

package_version="$(
  awk '
    /^[[:space:]]*version:[[:space:]]*/ {
      value = $0
      sub(/^[[:space:]]*version:[[:space:]]*/, "", value)
      sub(/[[:space:]#].*$/, "", value)
      print value
      exit
    }
  ' "$pubspec"
)"

if [[ -z "$package_version" ]]; then
  echo "CLI release validation failed: configurator/pubspec.yaml has no version." >&2
  exit 1
fi

semver_pattern='^(0|[1-9][0-9]*)\.(0|[1-9][0-9]*)\.(0|[1-9][0-9]*)(-[0-9A-Za-z-]+(\.[0-9A-Za-z-]+)*)?(\+[0-9A-Za-z-]+(\.[0-9A-Za-z-]+)*)?$'
if [[ ! "$package_version" =~ $semver_pattern ]]; then
  echo "CLI release validation failed: '$package_version' is not a valid semantic version." >&2
  exit 1
fi

core_and_prerelease="${package_version%%+*}"
if [[ "$core_and_prerelease" == *-* ]]; then
  prerelease="${core_and_prerelease#*-}"
  IFS='.' read -r -a prerelease_identifiers <<< "$prerelease"
  for identifier in "${prerelease_identifiers[@]}"; do
    if [[ "$identifier" =~ ^[0-9]+$ && ${#identifier} -gt 1 && "$identifier" == 0* ]]; then
      echo "CLI release validation failed: numeric prerelease identifiers cannot have leading zeroes." >&2
      exit 1
    fi
  done
fi

expected_tag="cli-v${package_version}"
if [[ "$release_tag" != "$expected_tag" ]]; then
  echo "CLI release validation failed: expected tag '$expected_tag', got '$release_tag'." >&2
  exit 1
fi

license_files=(
  "$repository_root/LICENSE"
  "$repository_root/configurator/LICENSE"
  "$repository_root/configurator_flutter/LICENSE"
  "$repository_root/configurator_python/LICENSE"
  "$repository_root/configurator_typescript/LICENSE"
)

blocked_licenses=()
for license_file in "${license_files[@]}"; do
  if [[ ! -f "$license_file" ]]; then
    echo "CLI release validation failed: missing ${license_file#"$repository_root"/}." >&2
    exit 1
  fi
  if grep -Fq "No License Granted" "$license_file"; then
    blocked_licenses+=("${license_file#"$repository_root"/}")
  fi
done

if [[ ${#blocked_licenses[@]} -gt 0 ]]; then
  echo "CLI release blocked: replace 'No License Granted' in these LICENSE files:" >&2
  printf '  - %s\n' "${blocked_licenses[@]}" >&2
  exit 1
fi

echo "Validated CLI release $release_tag for configurator $package_version."
