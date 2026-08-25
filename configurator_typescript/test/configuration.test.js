import assert from "node:assert/strict";
import test from "node:test";

import {
  Configuration,
  KeyType,
  defineScope,
} from "../dist/index.js";

test("defineScope normalizes and detaches generated data", () => {
  const colors = { primary: "#112233" };
  const routes = new Map([[1, "/home"]]);
  const scope = defineScope({ name: "base", colors, routes });

  colors.primary = "#ffffff";
  routes.set(1, "/changed");

  assert.equal(scope.weight, 0);
  assert.equal(scope.colors.primary, "#112233");
  assert.equal(scope.routes.get(1), "/home");
  assert.deepEqual(scope.flags, {});
  assert.deepEqual(scope.images, {});
  assert.deepEqual(scope.paddings, {});
  assert.deepEqual(scope.translations, {});
});

test("higher weight wins and later insertion wins equal-weight ties", () => {
  const base = defineScope({
    name: "base",
    weight: 0,
    flags: { feature: false },
    colors: { primary: "base", accent: "base" },
  });
  const high = defineScope({
    name: "high",
    weight: 10,
    colors: { primary: "high" },
  });
  const lateLow = defineScope({
    name: "late-low",
    weight: 0,
    colors: { primary: "late-low", accent: "late-low" },
    flags: { feature: true },
  });
  const config = new Configuration([base, high, lateLow]);

  assert.equal(config.color("primary"), "high");
  assert.equal(config.color("accent"), "late-low");
  assert.equal(config.flag("feature"), true);

  const latestTie = defineScope({
    name: "latest-tie",
    weight: 10,
    colors: { primary: "latest-tie" },
  });
  config.pushScope(latestTie);
  assert.equal(config.color("primary"), "latest-tie");
});

test("all runtime sections resolve with Dart-compatible defaults", () => {
  const translations = {
    greeting: { en: "Hello", de: "Hallo" },
    farewell: { en: "Goodbye" },
  };
  const config = new Configuration({
    scopes: [defineScope({
      name: "complete",
      flags: { enabled: true },
      colors: { primary: "#abcdef" },
      images: {
        hero: "hero.png",
        gallery: ["one.png", "two.png"],
      },
      routes: new Map([[7, "/detail"]]),
      sizes: { body: 16 },
      paddings: { card: 12 },
      margins: { page: 24 },
      misc: { retries: 3 },
      textStyles: { title: { fontSize: 20, fontWeight: 700 } },
      translations,
    })],
  });

  assert.equal(config.flag("enabled"), true);
  assert.equal(config.color("primary"), "#abcdef");
  assert.equal(config.image("hero"), "hero.png");
  assert.deepEqual(config.imageList("hero"), ["hero.png"]);
  assert.deepEqual(config.imageList("gallery"), ["one.png", "two.png"]);
  assert.equal(config.route(7), "/detail");
  assert.equal(config.size("body"), 16);
  assert.equal(config.padding("card"), 12);
  assert.equal(config.margin("page"), 24);
  assert.equal(config.misc("retries"), 3);
  assert.deepEqual(config.textStyle("title"), {
    fontSize: 20,
    fontWeight: 700,
  });
  assert.deepEqual(config.translations("greeting"), translations);
  assert.deepEqual(config.currentTranslations("greeting"), translations);

  assert.equal(config.flag("missing"), false);
  assert.equal(config.color("missing"), "");
  assert.equal(config.image("missing"), "");
  assert.deepEqual(config.imageList("missing"), []);
  assert.equal(config.route(999), "");
  assert.equal(config.size("missing"), 14);
  assert.equal(config.padding("missing"), 0);
  assert.equal(config.margin("missing"), 0);
  assert.equal(config.misc("missing"), null);
  assert.deepEqual(config.textStyle("missing"), {});
  assert.deepEqual(config.translations("missing"), {});
});

test("change subscriptions cover push, pop, and remove and can unsubscribe", () => {
  const base = defineScope({ name: "base" });
  const middle = defineScope({ name: "middle" });
  const top = defineScope({ name: "top" });
  const config = new Configuration([base]);
  const snapshots = [];
  const unsubscribe = config.subscribe((current) => {
    snapshots.push(current.scopes.map((scope) => scope.name));
  });

  assert.equal(config.pushScope(middle), true);
  assert.equal(config.pushScope(middle), false);
  assert.equal(config.pushScope(top, { notify: false }), true);
  assert.equal(config.popScope()?.name, "top");
  assert.equal(config.removeScope("middle")?.name, "middle");
  assert.deepEqual(snapshots, [
    ["base", "middle"],
    ["base", "middle"],
    ["base"],
  ]);

  unsubscribe();
  config.pushScope(top);
  assert.equal(snapshots.length, 3);
});

test("bulk removal keeps Configuration usable with a fresh fallback", () => {
  const config = new Configuration([
    defineScope({ name: "one" }),
    defineScope({ name: "two" }),
  ]);

  const removed = config.removeScopeWhere(() => true);
  assert.deepEqual(removed.map((scope) => scope.name), ["one", "two"]);
  assert.equal(config.scopes.length, 1);
  assert.match(config.currentScopeName, /^default-/);
  assert.equal(config.color("missing"), "");
  assert.equal(config.popScope(), undefined);
});

test("access subscriptions emit successful, typed lookups and can unsubscribe", () => {
  const base = defineScope({
    name: "base",
    weight: 1,
    flags: { enabled: false },
    images: { gallery: ["one.png"] },
    paddings: { card: 8 },
    translations: { greeting: { en: "Hello" } },
  });
  const config = new Configuration([base]);
  const events = [];
  const unsubscribe = config.subscribeAccess((event) => events.push(event));

  config.flag("enabled");
  config.imageList("gallery");
  config.padding("card");
  config.translations("greeting");
  config.color("missing");

  assert.deepEqual(events.map((event) => event.type), [
    KeyType.Flag,
    KeyType.ImageList,
    KeyType.Padding,
    KeyType.Translation,
  ]);
  assert.equal(KeyType.Translation, "string");
  assert.equal(KeyType.String, "string");
  assert.ok(events.every((event) => event.scope === base));
  assert.equal(events[0].key, "enabled");
  assert.equal(events[0].value, false);
  assert.deepEqual(events[1].value, ["one.png"]);
  assert.deepEqual(events[3].value, { greeting: { en: "Hello" } });

  unsubscribe();
  config.flag("enabled");
  assert.equal(events.length, 4);
});
