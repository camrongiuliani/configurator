#!/usr/bin/env bash

set -euo pipefail

repository_root="$(cd "$(dirname "${BASH_SOURCE[0]}")/.." && pwd)"
dart_package="$repository_root/configurator"
python_package="$repository_root/configurator_python"
typescript_package="$repository_root/configurator_typescript"
fixture_source="$repository_root/conformance/fixtures"

for command_name in dart python3 node npm; do
  if ! command -v "$command_name" >/dev/null 2>&1; then
    echo "Missing required command: $command_name" >&2
    exit 1
  fi
done

if [[ ! -f "$dart_package/.dart_tool/package_config.json" ]]; then
  (cd "$dart_package" && dart pub get)
fi

if [[ ! -x "$typescript_package/node_modules/.bin/tsc" ]]; then
  (cd "$typescript_package" && npm ci)
fi

temporary_root="$(mktemp -d "${TMPDIR:-/tmp}/configurator-conformance.XXXXXX")"
if [[ "${CONFIGURATOR_KEEP_CONFORMANCE_TEMP:-0}" == "1" ]]; then
  echo "Keeping conformance workspace at $temporary_root"
else
  trap 'rm -rf "$temporary_root"' EXIT
fi

generated_dir="$temporary_root/generated"
consumer_dir="$temporary_root/typescript-consumer"
package_dir="$temporary_root/package"
mkdir -p "$generated_dir" "$consumer_dir" "$package_dir"
cp "$fixture_source"/*.yaml "$generated_dir/"

(
  cd "$generated_dir"
  dart \
    --packages="$dart_package/.dart_tool/package_config.json" \
    "$dart_package/bin/configurator.dart" \
    --id-filter=conformance_root \
    --targets=dart,python,typescript \
    --pure-dart
)

dart_output="$generated_dir/conformance_root.config.dart"
python_output="$generated_dir/conformance_root_config.py"
typescript_output="$generated_dir/conformance_root.config.ts"

if [[ ! -f "$dart_output" \
  || ! -f "$python_output" \
  || ! -f "$typescript_output" ]]; then
  echo "The compiler did not emit all three conformance targets." >&2
  exit 1
fi

if [[ -e "$generated_dir/conformance_base.config.dart" \
  || -e "$generated_dir/conformance_override.config.dart" \
  || -e "$generated_dir/conformance_base_config.py" \
  || -e "$generated_dir/conformance_override_config.py" \
  || -e "$generated_dir/conformance_base.config.ts" \
  || -e "$generated_dir/conformance_override.config.ts" ]]; then
  echo "Part files were emitted as independent root configurations." >&2
  exit 1
fi

cp "$repository_root/conformance/dart_assertions.dart" \
  "$generated_dir/dart_assertions.dart"
dart \
  --packages="$dart_package/.dart_tool/package_config.json" \
  "$generated_dir/dart_assertions.dart"

python_runtime="python3"
python_path="$python_package/src:$generated_dir"
if [[ "${CONFIGURATOR_CONFORMANCE_USE_WHEEL:-0}" == "1" ]]; then
  python_wheel_dir="$package_dir/python"
  python_consumer_dir="$temporary_root/python-consumer"
  mkdir -p "$python_wheel_dir"
  python3 -m build --wheel --outdir "$python_wheel_dir" "$python_package"
  python_wheels=("$python_wheel_dir"/*.whl)
  if [[ ${#python_wheels[@]} -ne 1 || ! -f "${python_wheels[0]}" ]]; then
    echo "Expected exactly one packed Python runtime wheel." >&2
    exit 1
  fi
  python3 -m venv "$python_consumer_dir"
  "$python_consumer_dir/bin/python" -m pip install \
    --no-deps \
    "${python_wheels[0]}"
  python_runtime="$python_consumer_dir/bin/python"
  python_path="$generated_dir"
fi

PYTHONDONTWRITEBYTECODE=1 \
PYTHONPATH="$python_path" \
  "$python_runtime" "$repository_root/conformance/python_assertions.py"

(cd "$typescript_package" && npm run compile)
(
  cd "$typescript_package"
  npm pack --silent --pack-destination "$package_dir" >/dev/null
)
package_archives=("$package_dir"/*.tgz)
if [[ ${#package_archives[@]} -ne 1 || ! -f "${package_archives[0]}" ]]; then
  echo "Expected exactly one packed TypeScript runtime archive." >&2
  exit 1
fi

cp "$typescript_output" "$consumer_dir/conformance_root.config.ts"
cp "$repository_root/conformance/typescript_assertions.ts" "$consumer_dir/assertions.ts"
cp "$repository_root/conformance/tsconfig.json" "$consumer_dir/tsconfig.json"
cp "$repository_root/conformance/package.json" "$consumer_dir/package.json"

npm install \
  --prefix "$consumer_dir" \
  --ignore-scripts \
  --no-audit \
  --no-fund \
  "${package_archives[0]}"

"$typescript_package/node_modules/.bin/tsc" --project "$consumer_dir/tsconfig.json"
node "$consumer_dir/dist/assertions.js"

echo "Cross-language conformance passed"
