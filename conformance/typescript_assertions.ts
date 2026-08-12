import {
  Configuration,
  defineScope,
} from "configurator-typescript";
import {
  ConformanceRootConfig,
  generatedConformanceRoot,
} from "./conformance_root.config.js";

function assert(condition: boolean, message: string): asserts condition {
  if (!condition) {
    throw new Error(message);
  }
}

function equal<T>(actual: T, expected: T, label: string): void {
  assert(
    Object.is(actual, expected),
    `${label}: expected ${String(expected)}, got ${String(actual)}`,
  );
}

function deepEqual(actual: unknown, expected: unknown, label: string): void {
  const actualJson = JSON.stringify(actual);
  const expectedJson = JSON.stringify(expected);
  assert(
    actualJson === expectedJson,
    `${label}: expected ${expectedJson}, got ${actualJson}`,
  );
}

function verifyGeneratedConfiguration(): void {
  equal(generatedConformanceRoot.weight, 7, "generated scope weight");
  const runtime = new Configuration([generatedConformanceRoot]);
  const config = new ConformanceRootConfig(runtime);

  // Values from the root survive the part merge.
  equal(config.flags.enabledSearch, true, "root flag");
  equal(runtime.color("rootOnly"), "AABBCC", "root color");
  equal(config.images.logo, "assets/root-logo.svg", "root image");
  deepEqual(
    config.images.gallery,
    ["assets/one.png", "assets/two.png"],
    "image list",
  );
  equal(runtime.route(2), "/root-only", "root route");
  equal(config.paddings.screen, 8, "padding");
  equal(config.margins.screen, 4, "margin");
  equal(config.misc.retryCount, 3, "misc number");
  deepEqual(config.misc.labels, ["alpha", "beta"], "misc list");
  const headerTypeface = config.textStyles.header["typeface"];
  assert(
    typeof headerTypeface === "object" && headerTypeface !== null,
    "text-style typeface",
  );
  equal(
    (headerTypeface as Readonly<Record<string, unknown>>)["family"],
    "Inter",
    "font family",
  );

  // The deepest part wins for duplicate semantic keys.
  equal(config.flags.sharedFlag, true, "overridden flag");
  equal(config.flags.baseOnly, true, "base flag");
  equal(config.flags.deepestOnly, true, "deepest flag");
  equal(config.colors.primary, "708090", "overridden color");
  equal(runtime.route(1), "/override", "overridden route");
  equal(config.sizes.cardWidth, 24, "overridden size");
  equal(config.misc.rolloutStage, "override", "overridden misc");

  // `strings` and `i18n` produce one normalized translation map. Identical
  // aliases are accepted and the deepest part overrides the root locale.
  const translations = config.translations.greeting;
  deepEqual(
    translations["greeting"],
    { en: "Override hello", es: "Hola" },
    "translation merge",
  );
  deepEqual(
    runtime.currentTranslations("status")["status"],
    { en: "Ready" },
    "translation alias",
  );
  deepEqual(translations["rootOnly"], { en: "Root only" }, "root translation");
}

function verifyRuntimePrecedence(): void {
  const low = defineScope({ name: "low", weight: 1, flags: { choice: false } });
  const high = defineScope({ name: "high", weight: 5, flags: { choice: true } });
  const laterTie = defineScope({
    name: "later-tie",
    weight: 5,
    flags: { choice: false },
  });

  const runtime = new Configuration([low, high]);
  equal(runtime.flag("choice"), true, "higher weight");
  runtime.pushScope(laterTie);
  equal(runtime.flag("choice"), false, "later equal-weight scope");
}

verifyGeneratedConfiguration();
verifyRuntimePrecedence();
