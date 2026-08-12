---
name: use-configurator
description: Create, update, diagnose, and compile Configurator *.config.yaml and *.defs.yaml files into type-safe Dart, Python, and TypeScript modules. Use when working with Configurator YAML, configuration parts or definitions, multi-target generation, generated Configurator accessors, or Configurator CLI errors.
---

# Use Configurator

Treat the YAML as the source of truth. Change generated modules only by changing
their YAML and running the real Configurator generator.

## Workflow

1. Inspect the narrowest relevant directory for `*.config.yaml` and
   `*.defs.yaml` files, package manifests, existing generated siblings, and
   repository instructions.
2. Confirm the requested output targets. Use Dart when the user does not name a
   target because Dart is the CLI default.
3. Read [references/yaml-contract.md](references/yaml-contract.md) before
   creating or changing YAML, parts, definitions, routes, translations, or text
   styles.
4. Preserve the current catalog structure. Do not flatten parts, duplicate
   resolved values into a root, reorder parts, or rename IDs unless requested.
5. Read [references/cli-and-verification.md](references/cli-and-verification.md)
   before running generation or diagnosing a CLI failure.
6. Run from the narrowest directory containing the complete configuration
   catalog. Prefer one targeted invocation with every requested target.
7. Inspect the generated siblings and run the consumer project's native checks.
8. Report the YAML changed, outputs generated, checks run, and any verification
   that remains.

## Guardrails

- Never hand-write or patch generated Dart, Python, or TypeScript modules.
- Never claim generation succeeded unless Configurator exited successfully and
  the expected files exist.
- If Configurator is unavailable, perform bounded local checks, report the
  missing prerequisite, and stop. Do not invent output or install/download a
  tool unless the user authorizes it.
- Do not put secrets, credentials, or environment-specific secret values in
  configuration YAML.
- Do not use `--watch` or `--recursive` unless the user explicitly requests the
  long-running or multi-package behavior.
- Review existing user changes before generation because Configurator replaces
  sibling outputs and has no dry-run or output-directory option.
- Use `--id-filter` with the filename basename, not the YAML `id`.
- Remember that all discovered files are parsed and the full parts graph is
  validated even during filtered generation.

## Expected handoff

Keep the final response compact. Name the source YAML, generated targets,
verification results, and blockers. When a prerequisite is missing, give the
next command the user can run after installing or providing the official CLI;
do not manufacture generated code as a substitute.
