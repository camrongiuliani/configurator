# Configurator YAML contract

Use `*.config.yaml` for configurations and parts. Use `*.defs.yaml` for reusable
definitions. Keep the YAML language-neutral.

## Root document

Every configuration needs a string `id` and a `configuration` map:

```yaml
id: app_scope
weight: 10
configuration: {}
```

Optional root fields:

- `namespace`: generated namespace grouping.
- `weight`: integer precedence; higher-weight scopes win at runtime.
- `def_source`: ID of one discovered definitions document.
- `parts`: ordered list of configuration IDs to compose.

`parts` contains YAML IDs, while `--id-filter` uses filename basenames. Parts
are applied in declared order. Later parts override earlier parts, and composed
part values override values already present on the root. Part-only files are
not emitted as roots. Missing parts, duplicate IDs, repeated parts, and cycles
are fatal.

## Portable configuration sections

```yaml
configuration:
  flags:
    checkoutEnabled: true
  colors:
    brandPrimary: "3366FF"
  images:
    logo: assets/logo.svg
    gallery:
      - assets/one.png
      - assets/two.png
  routes:
    - id: 1
      path: /checkout
  sizes:
    bodySize: 16
  paddings:
    screen: 8
  margins:
    card: 4
  misc:
    retryCount: 3
    labels:
      - alpha
      - beta
  textStyles:
    heading:
      color: FFFFFF
      size: 24
      weight: 700
      height: 1
      typeface:
        family: Inter
        style: normal
  strings:
    en:
      title: Checkout
    es:
      title: Pagar
```

Use boolean flag leaves, string color/image/path leaves, numeric size/spacing
leaves, unique integer route IDs, and portable YAML scalars/lists/maps in
`misc`. Use the plural key `paddings`.

`i18n` is accepted as an alias for `strings`. Both fields merge by
`(locale, key)`. Identical duplicates are allowed; conflicting duplicates are
fatal. Slang rich text, plurals, and Flutter `InlineSpan` behavior are
Dart-specific rather than portable Python/TypeScript features.

Prefer clean alphanumeric camel-case keys. Configurator rejects native
identifier collisions, duplicate route IDs, and Python members reserved by
Pydantic.

## Definitions

Definitions provide reusable YAML anchors without rewriting source files:

```yaml
# shared.defs.yaml
id: shared
definitions:
  colors:
    brandPrimary: "3366FF"
  flags:
    searchDefault: false
  sizes:
    bodySize: 16
  routes:
    homePath: /
```

Select that document from each configuration or part that uses its anchors:

```yaml
# base.config.yaml
id: base
def_source: shared
configuration:
  flags:
    searchEnabled: *searchDefault
  colors:
    primary: *brandPrimary
  sizes:
    body: *bodySize
  routes:
    - id: 1
      path: *homePath
```

Each part is resolved as its own document, so each part using anchors must
declare `def_source` even when it selects the same definitions ID as the root.

## Composed root example

```yaml
# app.config.yaml
id: app_scope
weight: 10
def_source: shared
parts:
  - base
configuration:
  flags:
    checkoutEnabled: true
  strings:
    en:
      title: Checkout
```

For this file, generated class/export names derive from `app_scope`, while
output filenames and `--id-filter=app` derive from `app.config.yaml`.
