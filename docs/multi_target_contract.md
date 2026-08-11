# Multi-target configuration contract

Configurator treats YAML as the language-neutral source of truth. The CLI
discovers and parses configuration files, resolves their parts and definitions,
and then passes the same resolved `YamlConfiguration` to every selected output
generator.

## Initial targets

- Dart: `<basename>.config.dart`
- Python: `<basename>_config.py`
- TypeScript: `<basename>.config.ts`

Dart is selected when no target argument is supplied. Multiple targets are
selected with `--targets=dart,python,typescript` or repeatable `--target` flags.

## Runtime semantics

- Higher scope weights override lower weights.
- A later scope wins when weights are equal.
- Missing flags return `false`.
- Missing colors, images, and routes return an empty string.
- Missing image lists return an empty list.
- Missing sizes return `14.0`; padding and margins return `0.0`.
- Missing miscellaneous values return `null`/`None`.
- Successful lookups may publish access events.

## Translations

Both `configuration.strings` and `configuration.i18n` are accepted and merged
into one resolved translation collection. An identical `(locale, name)` entry
may occur in both fields. Conflicting values are rejected so different output
languages cannot silently generate different translations.

Slang-specific rich text, plural, and Flutter `InlineSpan` generation remain a
Dart adapter concern and are not part of the first Python or TypeScript runtime.

## Generated identifiers

Canonical configuration keys remain unchanged in every runtime. Python exposes
safe `snake_case` properties and TypeScript exposes safe JavaScript identifiers.
Generators must reject collisions where two canonical keys would produce the
same native identifier.
