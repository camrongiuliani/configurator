# MASTER PLAN — `configurator` API-Preserving Track (Option "a")

## 1. Goal & API-Preservation Guarantee
Reduce generated `.config.dart` size/complexity and fix latent generation bugs **without removing, renaming, or changing the signature/semantics of any public symbol** in the generated output (downstream imports it; README documents it). Every step below is output-preserving for existing fixtures except where explicitly adding new, escaped values. The pureDart `Color`/`colorValue` break is pre-existing and explicitly OUT OF SCOPE; #2 must not regress it.

## 2. Ordered Steps
- **#0 Golden harness (first).** Add `--golden` flag to `bin/configurator.dart`. On `--golden`, write `<name>.config.dart.golden` (or update if missing); normal runs write `<name>.config.dart.actual` and byte-diff vs committed `.golden`, failing on mismatch, never overwriting golden.
- **#2 Consolidate writers.** Replace `flag_writer`, `color_writer`, `image_writer`, `size_writer`, `padding_writer`, `margin_writer`, `misc_writer`, `route_writer` with one generic `AccessorWriter` (8 files). `text_style_writer` stays SEPARATE (it has `_buildTypefaceGetter` + non-lambda bodies) — only its line 56 key is canonicalized, plus the `key_writer.dart:49` companion. Fix 7 raw→canonical key mismatches by changing the runtime lookup in each getter body from `${e.name}` → `${e.name.canonicalize}` (color,image,size,padding,margin,misc,textStyle). `flag` (`e.name`↔`e.name`) and `route` (`e.id`↔`e.id`) are already correct — leave them. Delete the 8 files.
- **Companion edits.** `key_writer.dart:49` → `_buildField(e.key.canonicalize)`; `text_style_writer.dart:56` → `...textStyles.${e.key.canonicalize}`.
- **#4 Collapse banners.** In `title_writer.dart:43-54`, replace the 5-line `// ****` banner with a single `// <Header>` line (see §4a). Special-case `ignore_for_file: type=lint` → emit verbatim (R2).
- **#7 Literal safety.** `configuration_writer.dart`: delete `:307` `.replaceAll('\\\\','\\')`, delete dead `:375`, add `replaceAll(r'$', r'\$')` to `:307` and `:373` (see §4b,§4c). Per **R3 decision**, ALSO escape `\`/`$` on scalar emissions at `:186` (images), `:209` (colors), `:287` (misc) — see §4d.
- Verify all with #0 harness.

## 3. Test-Value Additions (`test/assets/test_1.config.yaml`)
Add a `misc:` block under `configuration:` (currently absent) exercising **both** scalar and List paths:
```yaml
  misc:
    backslashStr: path\to\file
    dollarStr: price $10
    listStr:
      - a\b
      - cost $5
```
This is safe: new keys only (no existing golden regresses), and it directly exercises the R3 scalar fix plus the #7 List fix.

## 4. Exact Snippets
**(a) TitleWriter special-case (`title_writer.dart`):**
```dart
String writeHeader(String header) {
  if (header == 'ignore_for_file: type=lint') {
    return '\n\n// $header\n\n'; // verbatim, no banner (R2)
  }
  return '\n\n// <$header>\n\n';
}
```
**(b) #7 translations (`:373-377`):**
```dart
var data = jsonEncode(translations).replaceAll(r'$', r'\$');
return 'const $data'; // line 375 deleted
```
**(c) #7 misc-List (`:307`):**
```dart
return jsonEncode(v).replaceAll(r'$', r'\$'); // un-escape removed
```
**(d) Scalar `\`/`$` escaping (`:287`, and `:186`,`:209`):**
```dart
return '\'${f.value.replaceAll(r'\', r'\\').replaceAll(r'$', r'\$')}\'';
```

## 5. Risk Register (ranked)
1. **R1 — accessor class-name fidelity.** Consolidation may rename `_FlagAccessor` etc. *Mitigation:* `AccessorWriter` derives the class name exactly as today (`name.canonicalize.capitalized`/`capitalized.capitalized`); assert via golden diff = 0 for fixtures lacking special keys.
2. **dart_style normalization masking diffs.** *Mitigation:* golden harness byte-diffs post-`dart format`; run formatter in both before/after to expose true semantic changes only.
3. **R2 — ignore_for_file corruption.** Banner collapse must not touch the lint directive. *Mitigation:* §4a verbatim branch; golden check on the `// ignore_for_file` line.
4. **R3 — scalar literal corruption.** Unescaped `\`/`$` in scalar strings mis-generate. *Mitigation:* §3 test value + §4d escaping; output-preserving for existing values.
5. **pureDart out-of-scope regression.** *Mitigation:* add a pureDart smoke assertion that output is byte-identical except intended changes; #2 only canonicalizes lookup keys, leaving `colorValue` path untouched.

## 6. Pre-Flight Checklist
- `cd configurator && dart analyze`
- `dart run bin/configurator.dart --golden` (bootstrap any missing goldens)
- `dart test` — harness diffs `.actual` vs `.golden`, must pass
- `git diff --stat` — confirm only intended writers deleted + edits
- Manual: confirm `ignore_for_file` line unchanged; confirm `misc` escapes present in `test_1.config.dart.golden`.

## 7. Expected Golden Diff Summary
- **#4:** every generated `.config.dart` (all `act/*`, `test_1`, `test_1_array`, `parts/base`) re-flows `// ****` banners → `// <Header>`; `// ignore_for_file` line unchanged.
- **#2:** zero diff for fixtures whose raw keys == canonical (all current fixtures); future special-char keys benefit from correct lookup.
- **#7:** `test_1.config.dart` gains escaped `misc` map (`path\\to\\file`, `price \$10`, list `[...a\\b..., cost \$5...]`). Other assets unchanged unless they already contain `\`/`$` in misc/translations.
- No public symbol removed/renamed anywhere.
