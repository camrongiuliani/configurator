#!/usr/bin/env python3
"""Validate the shared Codex and Claude Configurator skill package."""

from __future__ import annotations

import argparse
import json
import re
import sys
from pathlib import Path
from typing import Any


ROOT = Path(__file__).resolve().parents[1]
PLUGIN = ROOT / "plugins" / "configurator"
SKILL = PLUGIN / "skills" / "use-configurator"
SEMVER = re.compile(
    r"^(0|[1-9]\d*)\.(0|[1-9]\d*)\.(0|[1-9]\d*)"
    r"(?:-[0-9A-Za-z-]+(?:\.[0-9A-Za-z-]+)*)?"
    r"(?:\+[0-9A-Za-z-]+(?:\.[0-9A-Za-z-]+)*)?$"
)


def load_json(path: Path, errors: list[str]) -> dict[str, Any]:
    try:
        value = json.loads(path.read_text(encoding="utf-8"))
    except FileNotFoundError:
        errors.append(f"missing {path.relative_to(ROOT)}")
        return {}
    except json.JSONDecodeError as error:
        errors.append(f"invalid JSON in {path.relative_to(ROOT)}: {error}")
        return {}

    if not isinstance(value, dict):
        errors.append(f"{path.relative_to(ROOT)} must contain a JSON object")
        return {}
    return value


def require(condition: bool, message: str, errors: list[str]) -> None:
    if not condition:
        errors.append(message)


def validate_skill(errors: list[str]) -> None:
    skill_file = SKILL / "SKILL.md"
    try:
        text = skill_file.read_text(encoding="utf-8")
    except FileNotFoundError:
        errors.append(f"missing {skill_file.relative_to(ROOT)}")
        return

    match = re.match(r"\A---\n(.*?)\n---\n", text, flags=re.DOTALL)
    require(match is not None, "SKILL.md must start with YAML frontmatter", errors)
    if match is not None:
        frontmatter = match.group(1)
        fields = {
            line.split(":", 1)[0].strip()
            for line in frontmatter.splitlines()
            if ":" in line
        }
        require(
            fields == {"name", "description"},
            "SKILL.md frontmatter must contain only name and description",
            errors,
        )
        require(
            "name: use-configurator" in frontmatter,
            "SKILL.md name must be use-configurator",
            errors,
        )
        require(
            "Configurator" in frontmatter and "*.config.yaml" in frontmatter,
            "SKILL.md description must state its Configurator YAML triggers",
            errors,
        )

    for relative in (
        "references/yaml-contract.md",
        "references/cli-and-verification.md",
        "agents/openai.yaml",
    ):
        path = SKILL / relative
        require(path.is_file(), f"missing {path.relative_to(ROOT)}", errors)
        require(
            relative in text or relative == "agents/openai.yaml",
            f"SKILL.md must reference {relative}",
            errors,
        )

    openai_yaml = (SKILL / "agents" / "openai.yaml").read_text(encoding="utf-8")
    require(
        "$use-configurator" in openai_yaml,
        "agents/openai.yaml default_prompt must invoke $use-configurator",
        errors,
    )


def validate_manifests(errors: list[str]) -> str:
    codex = load_json(PLUGIN / ".codex-plugin" / "plugin.json", errors)
    claude = load_json(PLUGIN / ".claude-plugin" / "plugin.json", errors)
    codex_market = load_json(
        ROOT / ".agents" / "plugins" / "marketplace.json", errors
    )
    claude_market = load_json(ROOT / ".claude-plugin" / "marketplace.json", errors)

    versions = {
        codex.get("version"),
        claude.get("version"),
        claude_market.get("version"),
    }
    versions.discard(None)
    require(len(versions) == 1, "plugin and marketplace versions must match", errors)
    version = next(iter(versions), "")
    require(
        bool(SEMVER.fullmatch(version)),
        f"invalid plugin semantic version: {version!r}",
        errors,
    )

    for label, manifest in (("Codex", codex), ("Claude", claude)):
        require(
            manifest.get("name") == "configurator",
            f"{label} plugin name must be configurator",
            errors,
        )
        require(
            bool(manifest.get("description")),
            f"{label} plugin needs a description",
            errors,
        )
        author = manifest.get("author")
        require(
            isinstance(author, dict) and bool(author.get("name")),
            f"{label} plugin needs author.name",
            errors,
        )
    require(
        codex.get("skills") == "./skills/",
        "Codex plugin must expose ./skills/",
        errors,
    )

    for label, market in (("Codex", codex_market), ("Claude", claude_market)):
        require(
            market.get("name") == "configurator-tools",
            f"{label} marketplace name must be configurator-tools",
            errors,
        )
        plugins = market.get("plugins")
        require(
            isinstance(plugins, list) and len(plugins) == 1,
            f"{label} marketplace must list exactly one plugin",
            errors,
        )
        if (
            isinstance(plugins, list)
            and len(plugins) == 1
            and isinstance(plugins[0], dict)
        ):
            entry = plugins[0]
            require(
                entry.get("name") == "configurator",
                f"{label} marketplace plugin name must be configurator",
                errors,
            )
            source = entry.get("source")
            if label == "Codex":
                require(
                    isinstance(source, dict)
                    and source.get("source") == "local"
                    and source.get("path") == "./plugins/configurator",
                    "Codex marketplace must use the local "
                    "./plugins/configurator source",
                    errors,
                )
            else:
                require(
                    source == "./plugins/configurator",
                    "Claude marketplace must use ./plugins/configurator",
                    errors,
                )
                require(
                    entry.get("version") == version,
                    "Claude marketplace entry version must match the plugin",
                    errors,
                )

    return version


def validate_release(errors: list[str], version: str) -> None:
    for path in (ROOT / "LICENSE", PLUGIN / "LICENSE"):
        try:
            text = path.read_text(encoding="utf-8")
        except FileNotFoundError:
            errors.append(f"missing {path.relative_to(ROOT)}")
            continue
        if "No License Granted" in text:
            errors.append(
                f"replace the release-gate notice in {path.relative_to(ROOT)}"
            )

    codex = load_json(PLUGIN / ".codex-plugin" / "plugin.json", errors)
    claude = load_json(PLUGIN / ".claude-plugin" / "plugin.json", errors)
    require(
        bool(codex.get("license")),
        "Codex plugin needs an approved SPDX license before release",
        errors,
    )
    require(
        bool(claude.get("license")),
        "Claude plugin needs an approved SPDX license before release",
        errors,
    )
    require(bool(version), "plugin version is required for release", errors)


def main() -> int:
    parser = argparse.ArgumentParser(description=__doc__)
    parser.add_argument(
        "--release",
        action="store_true",
        help="also enforce public marketplace release gates",
    )
    args = parser.parse_args()

    errors: list[str] = []
    validate_skill(errors)
    version = validate_manifests(errors)

    for path in PLUGIN.rglob("*"):
        if path.is_file() and "[TODO:" in path.read_text(
            encoding="utf-8", errors="ignore"
        ):
            errors.append(f"placeholder remains in {path.relative_to(ROOT)}")

    if args.release:
        validate_release(errors, version)

    if errors:
        for error in errors:
            print(f"error: {error}", file=sys.stderr)
        return 1

    mode = "release" if args.release else "development"
    print(f"Validated Configurator agent plugin {version} for {mode} use.")
    return 0


if __name__ == "__main__":
    raise SystemExit(main())
