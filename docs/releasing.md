# Releasing Configurator packages

Configurator ships four packages from one repository:

- `configurator`: Dart runtime and the shared YAML compiler.
- `configurator_flutter`: Flutter-specific adapters.
- `configurator-python`: Python runtime and optional Pydantic integration.
- `configurator-typescript`: ESM runtime for Node.js and browsers.

## Release gate: licensing

Do not publish any package while its `LICENSE` file says **No License
Granted**. The upstream repository used a placeholder instead of an
open-source license, so maintainers must first confirm the rights to the
upstream work and select the intended license with the relevant copyright
holders. Replace every package notice with the complete approved license text
and update the Python and npm license metadata before continuing. Then remove
`publish_to: none` from both Dart pubspecs, `private: true` from the npm
package, and `Private :: Do Not Upload` from the Python classifiers. These
technical gates protect against an accidental release.

## Versioning

Each package is versioned independently. Use semantic versioning for public API
changes and record user-visible changes in that package's changelog. A compiler
release must state the minimum compatible Python and TypeScript runtime
versions whenever the generated contract changes.

## Required checks

Run the same checks as CI from the repository root:

```sh
cd configurator
dart format --output=none --set-exit-if-changed lib bin test
dart analyze
dart test

cd ../configurator_flutter
flutter pub get
flutter analyze
flutter test

cd ../configurator_python
python3 -m unittest discover -s tests -v
python3 -m pip install -e ".[test]" build twine
python3 -m unittest discover -s tests -v
python3 -m build
python3 -m twine check dist/*

cd ../configurator_typescript
npm ci
npm test
npm pack --dry-run

cd ..
CONFIGURATOR_CONFORMANCE_USE_WHEEL=1 bash tool/run_conformance.sh
```

Run the cross-language conformance test after those package-local checks. It
must generate from the shared YAML fixture, import the Python output, compile
and execute the TypeScript output, and compare resolved values.

## Consumer smoke tests

Test artifacts outside the source tree before publishing:

1. Install the Python wheel into a fresh virtual environment and import both
   the runtime and generated fixture.
2. Install the npm tarball into an empty ESM project and compile the generated
   TypeScript fixture using only the package's published declarations.
3. Run `dart pub publish --dry-run` for each Dart package.
4. Confirm no generated machine-local Flutter files, build directories, caches,
   or unpacked artifacts are included.

`configurator_flutter/pubspec_overrides.yaml` keeps local development and CI
on the sibling Dart package while `configurator` is unavailable from the
registry; `.pubignore` excludes it from the archive. After publishing the Dart
package, remove or temporarily disable that override and repeat `flutter pub
get` plus the Flutter dry run. This verifies the adapter against the hosted
dependency that consumers will actually resolve.

## Publish order

When generated contracts change, publish in this order:

1. Python and TypeScript runtimes.
2. Dart compiler/runtime with compatible runtime versions in the release notes.
3. Flutter adapter after the matching Dart runtime is available.

Tag releases explicitly per package rather than assuming every package shares
the same version.
