#!/usr/bin/env bash

set -euo pipefail

if [[ $# -ne 1 ]]; then
  echo "Usage: $0 python-v<package-version>" >&2
  exit 64
fi

repository_root="$(cd "$(dirname "${BASH_SOURCE[0]}")/.." && pwd)"
pyproject="$repository_root/configurator_python/pyproject.toml"
changelog="$repository_root/configurator_python/CHANGELOG.md"
release_tag="$1"
canonical_repository="camrongiuliani/configurator"

if [[ "${GITHUB_ACTIONS:-}" == "true" && "${GITHUB_REPOSITORY:-}" != "$canonical_repository" ]]; then
  echo "Python release validation failed: publishing is restricted to $canonical_repository." >&2
  exit 1
fi

if [[ ! -f "$pyproject" ]]; then
  echo "Python release validation failed: missing configurator_python/pyproject.toml." >&2
  exit 1
fi

package_version="$(
  awk '
    /^\[project\][[:space:]]*$/ { in_project = 1; next }
    /^\[/ { if (in_project) exit; next }
    in_project && /^[[:space:]]*version[[:space:]]*=/ {
      value = $0
      sub(/^[^"]*"/, "", value)
      sub(/".*$/, "", value)
      print value
      exit
    }
  ' "$pyproject"
)"

if [[ -z "$package_version" ]]; then
  echo "Python release validation failed: pyproject.toml has no static project version." >&2
  exit 1
fi

if [[ ! "$package_version" =~ ^[0-9][0-9A-Za-z.!+_-]*$ ]]; then
  echo "Python release validation failed: '$package_version' is not a supported package version." >&2
  exit 1
fi

expected_tag="python-v${package_version}"
if [[ "$release_tag" != "$expected_tag" ]]; then
  echo "Python release validation failed: expected tag '$expected_tag', got '$release_tag'." >&2
  exit 1
fi

if [[ ! -f "$changelog" ]]; then
  echo "Python release validation failed: missing configurator_python/CHANGELOG.md." >&2
  exit 1
fi

changelog_status="$(
  awk -v version="$package_version" '
    /^##[[:space:]]+/ {
      heading = $0
      sub(/^##[[:space:]]+/, "", heading)
      split(heading, fields, /[[:space:]]+-[[:space:]]+/)
      if (fields[1] == version) {
        normalized = tolower($0)
        print normalized ~ /unreleased/ ? "unreleased" : "ready"
        exit
      }
    }
  ' "$changelog"
)"

if [[ -z "$changelog_status" ]]; then
  echo "Python release blocked: CHANGELOG.md has no heading for version $package_version." >&2
  exit 1
fi

if [[ "$changelog_status" == "unreleased" ]]; then
  echo "Python release blocked: finalize the $package_version changelog heading before publishing." >&2
  exit 1
fi

if grep -Fq "Private :: Do Not Upload" "$pyproject"; then
  echo "Python release blocked: remove the 'Private :: Do Not Upload' classifier after the license review." >&2
  exit 1
fi

if grep -Fq "david-k-williams/configurator" "$pyproject"; then
  echo "Python release blocked: package URLs must not point to the development fork." >&2
  exit 1
fi

if ! grep -Fq "github.com/$canonical_repository" "$pyproject"; then
  echo "Python release blocked: package URLs must identify $canonical_repository." >&2
  exit 1
fi

license_files=(
  "$repository_root/LICENSE"
  "$repository_root/configurator_python/LICENSE"
)

blocked_licenses=()
for license_file in "${license_files[@]}"; do
  if [[ ! -s "$license_file" ]]; then
    echo "Python release validation failed: missing or empty ${license_file#"$repository_root"/}." >&2
    exit 1
  fi
  if grep -Fq "No License Granted" "$license_file"; then
    blocked_licenses+=("${license_file#"$repository_root"/}")
  fi
done

if [[ ${#blocked_licenses[@]} -gt 0 ]]; then
  echo "Python release blocked: replace 'No License Granted' in these LICENSE files:" >&2
  printf '  - %s\n' "${blocked_licenses[@]}" >&2
  exit 1
fi

echo "Validated Python release $release_tag for configurator-python $package_version."
