# Configurator CLI and verification

## Locate the generator

Prefer an official compiled `configurator` executable already on `PATH`:

```sh
configurator --version
configurator --help
```

When the project intentionally uses the Dart package instead, run the package
entry point already declared by that project, commonly:

```sh
dart run configurator --help
```

In a Configurator source checkout, run from the `configurator` package with:

```sh
dart run bin/configurator.dart --help
```

Do not install globally or download a binary unless the user explicitly asks.
If no supported command is available, leave YAML and generated files unchanged
and report that generation could not be completed.

## Generate

Run from the narrowest directory that still contains the complete configuration
and definitions catalog:

```sh
configurator --id-filter=app --targets=dart,python,typescript
```

For `app.config.yaml`, target filenames are:

| Target | Output |
| --- | --- |
| Dart | `app.config.dart` |
| Python | `app_config.py` |
| TypeScript | `app.config.ts` |

Dart is the default when no target option is supplied. Use
`--targets=dart,python,typescript` for multiple outputs or repeat
`--target=<language>`. `py` and `ts` aliases are accepted.

Other options:

- `--id-filter=app,admin`: emit matching filename basenames. Supply this flag
  at most once.
- `--pure-dart`: omit Flutter theme generation from the Dart target.
- `--watch` or `-w`: keep regenerating after YAML changes; use only when asked.
- `--recursive`: discover nested Dart/Flutter package roots; use only when
  asked.
- `--version`, `--help`: inspect the executable without scanning YAML.

There is no dry-run or output-directory option. Configurator discovers files
recursively below the current directory, resolves definitions in memory, and
atomically replaces the requested sibling outputs after the catalog validates.
All discovered configurations and the full ID/parts graph are validated even
when output is filtered.

## Verify

First inspect source and generated changes:

```sh
git diff -- app.config.yaml app.config.dart app_config.py app.config.ts
```

Then use the consuming repository's established checks. Typical focused checks
are:

```sh
dart analyze
PYTHONDONTWRITEBYTECODE=1 python3 -m py_compile app_config.py
npx tsc --noEmit
```

Generated Python and TypeScript modules import their Configurator runtime
packages, so import/compile checks require those dependencies in the consumer.
Adapt commands to the repository rather than installing missing dependencies
without approval.

Expected option-usage failures exit with code 64. YAML, definition, part, and
generation failures exit with code 65. Diagnose the source catalog; do not patch
generated output around the error.
