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

## Registry automation and fork safety

The publishing workflows hard-code `camrongiuliani/configurator` as the only
repository allowed to upload a package or create a release. Pull requests,
manual runs, and tags in `david-k-williams/configurator` can build and inspect
artifacts, but they cannot enter an OIDC publishing job. This repository check
is not a workflow input and cannot be enabled from the fork.

| Distribution | Workflow | Required tag | Protected environment |
| --- | --- | --- | --- |
| PyPI `configurator-python` | **Python Package** | `python-v<version>` | `pypi` |
| npm `configurator-typescript` | **npm Package** | `typescript-v<version>` | `npm-publish` |
| pub.dev `configurator` | **Publish configurator to pub.dev** | `configurator-v<version>` | `pub.dev-configurator` |
| pub.dev `configurator_flutter` | **Publish configurator_flutter to pub.dev** | `configurator_flutter-v<version>` | `pub.dev-configurator-flutter` |
| Native CLI | **CLI Release** | `cli-v<version>` | `cli-release` |

The Python and npm workflows run their complete test, package, metadata, and
external-consumer checks on the fork and upload the resulting wheel/sdist or
`.tgz` as short-lived Actions artifacts. **Pub package checks** runs the Dart
and Flutter publish dry-runs from isolated staging copies, leaving the tracked
`publish_to: none` safeguards intact.

### One-time upstream and registry setup

As of August 11, 2026, all four intended registry names return `404`; recheck
availability immediately before the first release. After this work is merged
into the canonical upstream repository:

1. Resolve the license review, finalize the versioned changelog entries, and
   remove only the technical gate for the package being released.
2. Create each protected environment listed above with required reviewers and
   deployment rules. Add repository rulesets restricting creation, updates,
   and deletion of every corresponding tag pattern to release maintainers.
3. For PyPI, create a pending Trusted Publisher for project
   `configurator-python`, owner `camrongiuliani`, repository `configurator`,
   workflow `python-publish.yml`, and environment `pypi`. A pending publisher
   can create the project on first use, but does not reserve the name.
4. For npm, bootstrap ownership of `configurator-typescript` from the canonical
   repository, then configure its GitHub Actions Trusted Publisher for workflow
   `npm-publish.yml`, environment `npm-publish`, and the `npm publish` action.
   The workflow uses Node 24 and a pinned OIDC-capable npm client; it stores no
   npm token. After verification, disallow traditional automation tokens in
   the package settings.
5. Pub.dev automation works only for an existing package. Publish the first
   `configurator` and `configurator_flutter` versions interactively from the
   canonical repository, then enable GitHub Actions publishing for repository
   `camrongiuliani/configurator` with tag patterns
   `configurator-v{{version}}` and `configurator_flutter-v{{version}}`.
6. Publish `configurator` before `configurator_flutter`. Remove
   `configurator_flutter/pubspec_overrides.yaml` and verify the Flutter package
   against the hosted core dependency before creating the Flutter tag.

Registry setup references:

- [PyPI pending Trusted Publishers](https://docs.pypi.org/trusted-publishers/creating-a-project-through-oidc/)
- [npm Trusted Publishing](https://docs.npmjs.com/trusted-publishers/)
- [pub.dev automated publishing](https://dart.dev/tools/pub/automated-publishing)

Every publishing preflight also requires an exact tag/version match, a tagged
commit reachable from upstream `develop`, canonical package metadata, complete
root and package licenses, and finalized release notes. Prerelease npm versions
use the `next` distribution tag instead of `latest`.

## Native CLI release pipeline

The Dart compiler can be shipped as a native executable for users who do not
have Dart installed. To build one locally from the repository root:

```sh
cd configurator
dart pub get --enforce-lockfile
dart compile exe \
  -DCONFIGURATOR_VERSION=local \
  bin/configurator.dart \
  -o ../configurator-cli
../configurator-cli --version
../configurator-cli --help
```

The compiled executable includes the Dart runtime. It is specific to the host
operating system and CPU architecture; it does not make generated Python or
TypeScript modules independent of their corresponding runtime packages.

### GitHub Actions builds

The **CLI Release** workflow covers three paths:

- A relevant pull request builds and smoke-tests the Linux x64 executable.
- **Run workflow** in the GitHub Actions UI builds the downloadable platform
  archives without creating a GitHub Release. Use this path to validate the
  complete pipeline before tagging.
- A tag matching `cli-v<version>` builds every supported archive and generates
  `SHA256SUMS`. Only the canonical upstream repository can attest those files
  and attach them to a GitHub Release. The tag version must exactly match
  `version` in `configurator/pubspec.yaml`; for example, package version
  `1.0.20` requires tag `cli-v1.0.20`.

For a manual build, open **Actions > CLI Release**, choose **Run workflow** on
`develop`, and download the five `configurator-*` platform artifacts plus the
`configurator-cli-checksums` artifact from the completed run.

Every platform build checks `--help` and `--version` and uses the compiled
executable to generate Python and TypeScript output from a fixture before it is
packaged. Tagged releases also publish GitHub build-provenance attestations for
the downloadable artifacts. Release builds pin Dart `3.12.2` and resolve the
tracked `configurator/pubspec.lock` with `dart pub get --enforce-lockfile` so
all platform jobs compile against the same dependency graph.

A tagged release contains:

- `configurator-macos-arm64.tar.gz`
- `configurator-macos-x64.tar.gz`
- `configurator-linux-arm64.tar.gz`
- `configurator-linux-x64.tar.gz`
- `configurator-windows-x64.zip`
- `SHA256SUMS`

Manual workflow artifacts are for maintainer validation while the licensing
gate remains in place. Do not redistribute them as public releases until that
gate is resolved.

### Tagged release procedure

1. Set `configurator/pubspec.yaml` to the intended CLI version and complete the
   required checks below.
2. Resolve the repository licensing gate and confirm that no package still
   contains the **No License Granted** notice.
3. In `camrongiuliani/configurator`, confirm the release commit is on `develop`,
   then create and push the matching tag, such as `cli-v1.0.20`. The release job
   rejects a tag whose commit is not contained in upstream `develop`; the same
   tag on a fork can only produce validation artifacts.
4. Approve the deployment through the protected `cli-release` GitHub
   environment when prompted.
5. Confirm that every archive passed its command and generation smoke tests,
   the GitHub Release contains all six assets above, the reported version
   matches the tag, and the provenance attestations exist.

Before the first tagged release, a repository administrator must create the
`cli-release` environment under **Settings > Environments** and configure its
required reviewers and deployment rules. Referencing the environment in the
workflow does not itself add those repository protection settings. The
administrator must also add a repository ruleset that restricts creation,
updates, and deletion of tags matching `cli-v*` to release maintainers, then
enable **Release immutability** under **Settings > General > Releases**. The
release job creates a draft, uploads and verifies all assets, and only then
publishes the immutable release.

The workflow deliberately fails a tagged release while any **No License
Granted** notice remains. The current repository is therefore ready to test
with manual workflow runs, but it is not ready to publish a CLI release.

### Verify a download

Download `SHA256SUMS` and all release archives into the same directory, then
verify them before extracting:

```sh
# Linux
sha256sum --check SHA256SUMS

# macOS
shasum --algorithm 256 --check SHA256SUMS
```

For a single Windows archive, calculate its digest in PowerShell and compare it
with the `configurator-windows-x64.zip` entry in `SHA256SUMS`:

```powershell
Get-FileHash .\configurator-windows-x64.zip -Algorithm SHA256
```

When the GitHub CLI is available, also verify the release artifact's provenance
against this repository:

```sh
gh attestation verify configurator-linux-x64.tar.gz \
  --repo camrongiuliani/configurator
```

These archives are not code-signed, notarized, or covered by a platform trust
certificate. macOS Gatekeeper and Windows SmartScreen may warn before launch.
Checksums detect a changed download but do not replace code signing; only run a
binary obtained from a trusted repository release.

## Required checks

Run the same checks as CI from the repository root:

```sh
cd configurator
dart pub get --enforce-lockfile
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

1. Python with `python-v<version>` and TypeScript with
   `typescript-v<version>`.
2. Dart compiler/runtime with `configurator-v<version>` and compatible runtime
   versions in the release notes.
3. Flutter with `configurator_flutter-v<version>` after the matching hosted Dart
   runtime is available and the local override has been removed.
4. The native CLI with `cli-v<version>` when a matching executable release is
   wanted.

Tag releases explicitly per package rather than assuming every package shares
the same version.
