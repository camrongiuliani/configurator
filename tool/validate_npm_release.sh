#!/usr/bin/env bash

set -euo pipefail

if [[ $# -ne 1 ]]; then
  echo "Usage: $0 typescript-v<package-version>" >&2
  exit 64
fi

repository_root="$(cd "$(dirname "${BASH_SOURCE[0]}")/.." && pwd)"
package_file="$repository_root/configurator_typescript/package.json"
changelog_file="$repository_root/configurator_typescript/CHANGELOG.md"
release_tag="$1"
canonical_repository="camrongiuliani/configurator"
canonical_url="git+https://github.com/${canonical_repository}.git"

if [[ -n "${GITHUB_REPOSITORY:-}" && "$GITHUB_REPOSITORY" != "$canonical_repository" ]]; then
  echo "npm release blocked: publishing is only permitted from $canonical_repository, not $GITHUB_REPOSITORY." >&2
  exit 1
fi

if [[ ! -f "$package_file" ]]; then
  echo "npm release validation failed: missing configurator_typescript/package.json." >&2
  exit 1
fi

read_package_field() {
  local field="$1"
  node -e '
    const fs = require("node:fs");
    const packageFile = process.argv[1];
    const path = process.argv[2].split(".");
    let value = JSON.parse(fs.readFileSync(packageFile, "utf8"));
    for (const key of path) value = value?.[key];
    if (value !== undefined) process.stdout.write(String(value));
  ' "$package_file" "$field"
}

package_name="$(read_package_field name)"
package_version="$(read_package_field version)"
package_private="$(read_package_field private)"
package_license="$(read_package_field license)"
repository_type="$(read_package_field repository.type)"
repository_url="$(read_package_field repository.url)"
repository_directory="$(read_package_field repository.directory)"
package_homepage="$(read_package_field homepage)"
package_bugs_url="$(read_package_field bugs.url)"
publish_access="$(read_package_field publishConfig.access)"
publish_provenance="$(read_package_field publishConfig.provenance)"

if [[ "$package_name" != "configurator-typescript" ]]; then
  echo "npm release validation failed: expected package name 'configurator-typescript', got '$package_name'." >&2
  exit 1
fi

semver_pattern='^(0|[1-9][0-9]*)\.(0|[1-9][0-9]*)\.(0|[1-9][0-9]*)(-[0-9A-Za-z-]+(\.[0-9A-Za-z-]+)*)?(\+[0-9A-Za-z-]+(\.[0-9A-Za-z-]+)*)?$'
if [[ ! "$package_version" =~ $semver_pattern ]]; then
  echo "npm release validation failed: '$package_version' is not a valid semantic version." >&2
  exit 1
fi

core_and_prerelease="${package_version%%+*}"
if [[ "$core_and_prerelease" == *-* ]]; then
  prerelease="${core_and_prerelease#*-}"
  IFS='.' read -r -a prerelease_identifiers <<< "$prerelease"
  for identifier in "${prerelease_identifiers[@]}"; do
    if [[ "$identifier" =~ ^[0-9]+$ && ${#identifier} -gt 1 && "$identifier" == 0* ]]; then
      echo "npm release validation failed: numeric prerelease identifiers cannot have leading zeroes." >&2
      exit 1
    fi
  done
fi

expected_tag="typescript-v${package_version}"
if [[ "$release_tag" != "$expected_tag" ]]; then
  echo "npm release validation failed: expected tag '$expected_tag', got '$release_tag'." >&2
  exit 1
fi

if [[ "$repository_type" != "git" || "$repository_url" != "$canonical_url" || "$repository_directory" != "configurator_typescript" ]]; then
  echo "npm release blocked: package repository metadata must point to ${canonical_url}#configurator_typescript." >&2
  exit 1
fi

if [[ "$package_homepage" != "https://github.com/${canonical_repository}#readme" ]]; then
  echo "npm release blocked: package homepage must point to the canonical upstream repository." >&2
  exit 1
fi

if [[ "$package_bugs_url" != "https://github.com/${canonical_repository}/issues" ]]; then
  echo "npm release blocked: package bugs URL must point to the canonical upstream repository." >&2
  exit 1
fi

if [[ "$publish_access" != "public" || "$publish_provenance" != "true" ]]; then
  echo "npm release blocked: publishConfig must enable public access and provenance." >&2
  exit 1
fi

if [[ ! -s "$changelog_file" ]]; then
  echo "npm release validation failed: missing or empty configurator_typescript/CHANGELOG.md." >&2
  exit 1
fi

changelog_heading_count="$(
  awk -v version="$package_version" '$1 == "##" && $2 == version { count += 1 } END { print count + 0 }' "$changelog_file"
)"
if [[ "$changelog_heading_count" -ne 1 ]]; then
  echo "npm release blocked: CHANGELOG.md must contain exactly one heading for version $package_version." >&2
  exit 1
fi
changelog_heading="$(
  awk -v version="$package_version" '$1 == "##" && $2 == version { print; exit }' "$changelog_file"
)"
if grep -Eiq 'unreleased' <<< "$changelog_heading"; then
  echo "npm release blocked: finalize the $package_version changelog entry before publishing." >&2
  exit 1
fi

if [[ "$package_private" == "true" ]]; then
  echo "npm release blocked: remove 'private: true' from configurator_typescript/package.json after licensing is resolved." >&2
  exit 1
fi

if [[ -z "$package_license" || "$package_license" == "UNLICENSED" ]]; then
  echo "npm release blocked: replace the UNLICENSED package metadata with the approved SPDX license identifier." >&2
  exit 1
fi

license_files=(
  "$repository_root/LICENSE"
  "$repository_root/configurator_typescript/LICENSE"
)

for license_file in "${license_files[@]}"; do
  if [[ ! -s "$license_file" ]]; then
    echo "npm release validation failed: missing or empty ${license_file#"$repository_root"/}." >&2
    exit 1
  fi
  if grep -Fq "No License Granted" "$license_file"; then
    echo "npm release blocked: replace 'No License Granted' in ${license_file#"$repository_root"/}." >&2
    exit 1
  fi
done

echo "Validated npm release $release_tag for $package_name $package_version."
