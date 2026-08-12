#!/usr/bin/env bash

set -euo pipefail

readonly canonical_repository="camrongiuliani/configurator"

fail() {
  echo "pub.dev release validation failed: $*" >&2
  exit 1
}

if [[ $# -ne 2 ]]; then
  echo "Usage: $0 <configurator|configurator_flutter> <package-v<version>>" >&2
  exit 64
fi

readonly package_name="$1"
readonly release_tag="$2"
readonly repository_root="$(cd "$(dirname "${BASH_SOURCE[0]}")/.." && pwd)"

case "$package_name" in
  configurator)
    readonly package_directory="$repository_root/configurator"
    ;;
  configurator_flutter)
    readonly package_directory="$repository_root/configurator_flutter"
    ;;
  *)
    fail "unsupported package '$package_name'."
    ;;
esac

readonly pubspec="$package_directory/pubspec.yaml"
readonly changelog="$package_directory/CHANGELOG.md"

if [[ "${GITHUB_ACTIONS:-}" == "true" ]]; then
  [[ "${GITHUB_REPOSITORY:-}" == "$canonical_repository" ]] || \
    fail "publishing is allowed only from $canonical_repository, never ${GITHUB_REPOSITORY:-an unknown repository}."
  [[ "${GITHUB_EVENT_NAME:-}" == "push" ]] || \
    fail "publishing requires a tag push event."
  [[ "${GITHUB_REF_TYPE:-}" == "tag" ]] || \
    fail "publishing requires a tag ref."
  [[ "${GITHUB_REF_NAME:-}" == "$release_tag" ]] || \
    fail "GITHUB_REF_NAME does not match '$release_tag'."
fi

read_top_level_scalar() {
  local key="$1"
  local file="$2"
  awk -v key="$key" '
    $1 == key ":" {
      value = $0
      sub("^[^:]+:[[:space:]]*", "", value)
      sub("[[:space:]#].*$", "", value)
      gsub(/^['\"']|['\"']$/, "", value)
      print value
      exit
    }
  ' "$file"
}

[[ -f "$pubspec" ]] || fail "missing ${pubspec#"$repository_root/"}."
[[ -f "$changelog" ]] || fail "missing ${changelog#"$repository_root/"}."

readonly declared_name="$(read_top_level_scalar name "$pubspec")"
readonly package_version="$(read_top_level_scalar version "$pubspec")"
readonly homepage="$(read_top_level_scalar homepage "$pubspec")"
readonly repository="$(read_top_level_scalar repository "$pubspec")"
readonly issue_tracker="$(read_top_level_scalar issue_tracker "$pubspec")"
readonly publish_to="$(read_top_level_scalar publish_to "$pubspec")"

[[ "$declared_name" == "$package_name" ]] || \
  fail "${pubspec#"$repository_root/"} declares name '$declared_name'."

readonly semver_pattern='^(0|[1-9][0-9]*)\.(0|[1-9][0-9]*)\.(0|[1-9][0-9]*)(-[0-9A-Za-z-]+(\.[0-9A-Za-z-]+)*)?(\+[0-9A-Za-z-]+(\.[0-9A-Za-z-]+)*)?$'
[[ "$package_version" =~ $semver_pattern ]] || \
  fail "'$package_version' is not a valid semantic version."

core_and_prerelease="${package_version%%+*}"
if [[ "$core_and_prerelease" == *-* ]]; then
  prerelease="${core_and_prerelease#*-}"
  IFS='.' read -r -a prerelease_identifiers <<< "$prerelease"
  for identifier in "${prerelease_identifiers[@]}"; do
    if [[ "$identifier" =~ ^[0-9]+$ && ${#identifier} -gt 1 && "$identifier" == 0* ]]; then
      fail "numeric prerelease identifiers cannot have leading zeroes."
    fi
  done
fi

readonly expected_tag="${package_name}-v${package_version}"
[[ "$release_tag" == "$expected_tag" ]] || \
  fail "expected tag '$expected_tag', got '$release_tag'."

[[ "$homepage" == "https://github.com/$canonical_repository" ]] || \
  fail "homepage must point to the canonical upstream repository."
[[ "$repository" == "https://github.com/$canonical_repository/tree/develop/$package_name" ]] || \
  fail "repository must point to the package in canonical upstream develop."
[[ "$issue_tracker" == "https://github.com/$canonical_repository/issues" ]] || \
  fail "issue_tracker must point to canonical upstream."

if [[ -n "$publish_to" && "$publish_to" != "https://pub.dev" ]]; then
  fail "publish_to must be omitted or set to https://pub.dev, not '$publish_to'."
fi

license_files=(
  "$repository_root/LICENSE"
  "$package_directory/LICENSE"
)
for license_file in "${license_files[@]}"; do
  [[ -f "$license_file" ]] || fail "missing ${license_file#"$repository_root/"}."
  if grep -Eq 'No License Granted|release gate, not an open-source license' "$license_file"; then
    fail "replace the placeholder in ${license_file#"$repository_root/"} with the approved license."
  fi
  if [[ ! -s "$license_file" || $(wc -c < "$license_file") -lt 200 ]]; then
    fail "${license_file#"$repository_root/"} does not contain a complete license."
  fi
done

if ! awk -v heading="## $package_version" '
  $0 == heading { found = 1 }
  END { exit(found ? 0 : 1) }
' "$changelog"; then
  fail "${changelog#"$repository_root/"} has no exact '## $package_version' release entry."
fi

if awk '
  /^## Unreleased[[:space:]]*$/ { in_unreleased = 1; next }
  in_unreleased && /^##[[:space:]]/ { exit }
  in_unreleased && $0 !~ /^[[:space:]]*$/ { has_changes = 1 }
  END { exit(has_changes ? 0 : 1) }
' "$changelog"; then
  fail "move every Unreleased changelog entry into '## $package_version' before tagging."
fi

if grep -Eq '^dependency_overrides:' "$pubspec"; then
  fail "release pubspecs cannot contain dependency_overrides."
fi

if [[ "$package_name" == "configurator_flutter" ]]; then
  readonly override_file="$package_directory/pubspec_overrides.yaml"
  [[ ! -e "$override_file" ]] || \
    fail "remove configurator_flutter/pubspec_overrides.yaml before tagging; the release must resolve hosted configurator first."

  readonly core_pubspec="$repository_root/configurator/pubspec.yaml"
  readonly core_version="$(read_top_level_scalar version "$core_pubspec")"
  readonly core_constraint="$(
    awk '
      /^  configurator:[[:space:]]*/ {
        value = $0
        sub(/^  configurator:[[:space:]]*/, "", value)
        sub(/[[:space:]#].*$/, "", value)
        gsub(/^['\"']|['\"']$/, "", value)
        print value
        exit
      }
    ' "$pubspec"
  )"
  [[ "$core_constraint" == "^$core_version" ]] || \
    fail "configurator_flutter must use the hosted constraint 'configurator: ^$core_version'; found '$core_constraint'."
fi

echo "Validated $package_name $package_version for canonical tag $release_tag."
