## Unreleased

* Add Python and TypeScript generation targets while preserving Dart as the
  default.
* Normalize `strings` and `i18n` into one portable translation collection.
* Make part overrides deterministic by semantic key.
* Align scope mutation, defaults, and image-list behavior across runtimes.
* Validate part graphs, load transitive parts for filtered roots, and report
  missing parts, repeated IDs, and cycles before generation.
* Resolve external definitions in memory across portable configuration shapes
  without rewriting source YAML.
* Validate CLI options and replace multi-target outputs as a recoverable batch.
* Fix cross-locale translation merging and add executable Python/TypeScript
  conformance coverage.
* Remove unused Flutter-only and generator dependencies from the core package.

## 1.0.20

* Existing Dart runtime and YAML generator release.

## 0.0.1

* TODO: Describe initial release.
