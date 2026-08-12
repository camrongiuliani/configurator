# Configurator agent plugin

This skills-only plugin helps Codex and Claude create, update, diagnose, and
compile shared Configurator YAML into type-safe Dart, Python, and TypeScript.
It uses the same `use-configurator` skill in both products.

The Configurator CLI must already be available as a compiled executable or an
intentional Dart project dependency. The skill does not download tools, install
packages, or fabricate generated modules.

## Use

Example requests:

- Create shared configuration YAML for a FastAPI backend and TypeScript client.
- Split repeated values into definitions and ordered parts, then regenerate all
  three targets.
- Diagnose a missing part or native identifier collision without editing
  generated code.

In Codex, invoke `$use-configurator`. In Claude Code, invoke
`/configurator:use-configurator` or ask a request matching the skill
description.

See the repository's `docs/agent-plugins.md` for local installation,
marketplace testing, validation, and eventual public submission.

## Distribution status

The current `LICENSE` is an explicit no-distribution release gate. Keep this
plugin local to authorized development until the maintainers confirm rights and
replace the notice with the approved license.
