# Configurator agent plugins

The repository contains one shared, skills-only Configurator plugin that works
with Codex and Claude Code:

```text
.agents/plugins/marketplace.json       # Codex marketplace
.claude-plugin/marketplace.json        # Claude marketplace
plugins/configurator/
├── .codex-plugin/plugin.json
├── .claude-plugin/plugin.json
└── skills/use-configurator/            # shared Agent Skill
```

The skill edits language-neutral `*.config.yaml` and `*.defs.yaml`, invokes the
real Configurator CLI, and verifies requested Dart, Python, and TypeScript
outputs. It never installs the CLI or fabricates generated code.

## Test from this checkout

Validate the shared package first:

```bash
python3 tool/validate_agent_plugins.py
```

The public-release check intentionally fails until licensing is resolved:

```bash
python3 tool/validate_agent_plugins.py --release
```

Add this checkout as a Codex marketplace and install the plugin:

```bash
codex plugin marketplace add /absolute/path/to/configurator
codex plugin add configurator@configurator-tools
```

Start a new Codex task and ask it to use `$use-configurator`.

With Claude Code installed, validate and test the same directory:

```bash
claude plugin validate ./plugins/configurator --strict
claude plugin validate .
claude plugin marketplace add . --scope local
claude plugin install configurator@configurator-tools --scope local
```

Invoke `/configurator:use-configurator` or ask a request matching its
description. A direct development session can use:

```bash
claude --plugin-dir ./plugins/configurator
```

## Install after the upstream merge

The upstream repository itself can serve both marketplace catalogs:

```bash
codex plugin marketplace add camrongiuliani/configurator --ref develop
codex plugin add configurator@configurator-tools

claude plugin marketplace add camrongiuliani/configurator@develop
claude plugin install configurator@configurator-tools
```

Claude users must add the Git repository rather than a direct URL to only
`marketplace.json`, because the relative `./plugins/configurator` source needs
the rest of the checkout.

## Public marketplace release

Before public submission:

1. Confirm rights to the upstream work and replace the root and plugin
   `No License Granted` notices.
2. Add the approved SPDX `license` to both plugin manifests.
3. Bump the plugin version consistently in both manifests and the Claude
   marketplace catalog.
4. Run the development validator, the `--release` validator, the GitHub Actions
   plugin check, and both product-native validators.
5. Test installation and representative YAML generation in fresh sessions.

Codex can use the repository marketplace directly and the same skills-only
plugin can later be submitted to the OpenAI universal plugin directory. Claude
can use the self-hosted GitHub marketplace directly and can later be submitted
to Anthropic's community marketplace. Public-directory submission is a manual,
reviewed operation; this repository does not auto-submit either plugin.
