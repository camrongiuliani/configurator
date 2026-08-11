# Cross-language conformance

This fixture is compiled by the real Dart CLI and then consumed through the
generated Dart configuration and the local Python and TypeScript runtime
packages. It covers:

- root, nested part, and deepest-part precedence;
- external definitions resolved to YAML anchors without changing the source;
- flags, colors, images, routes, sizes, spacing, miscellaneous values, and
  framework-neutral text styles;
- normalization and override behavior across both `strings` and `i18n`;
- weighted runtime scopes, including the later-scope tie break.

Run it from the repository root:

```bash
./tool/run_conformance.sh
```

The harness works in a temporary directory, executes the generated Dart,
installs the packed npm runtime as an external consumer, strictly compiles the
generated TypeScript, imports the generated Python, and removes all temporary
output when it exits.

For failure investigation, set `CONFIGURATOR_KEEP_CONFORMANCE_TEMP=1` to keep
the generated consumer workspace and print its location.
