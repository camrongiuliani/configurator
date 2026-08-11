# configurator-typescript

Browser-safe TypeScript runtime for configuration scopes generated from a
Configurator YAML file. It has no runtime dependencies and does not parse YAML;
the Configurator compiler emits calls to `defineScope`, and this package applies
the same scope behavior in Node.js or a browser.

## Install and build

Until the package is published, build the local checkout first:

```sh
cd /path/to/configurator/configurator_typescript
npm ci
npm run compile
cd /path/to/your/consumer
npm install /path/to/configurator/configurator_typescript
```

For runtime development inside the package:

```sh
npm install
npm run compile
npm test
```

Published builds are ESM-only and require Node.js 20 or newer for Node usage.
The runtime itself does not import Node APIs.

## Generated scope shape

```ts
import { Configuration, defineScope } from "configurator-typescript";

const base = defineScope({
  name: "base",
  weight: 0,
  flags: { checkoutEnabled: true },
  colors: { primary: "#2364aa" },
  images: {
    hero: "/assets/hero.webp",
    gallery: ["/assets/one.webp", "/assets/two.webp"],
  },
  routes: new Map([[1, "/"]]),
  sizes: { body: 16 },
  paddings: { card: 12 },
  margins: { page: 24 },
  misc: { retryCount: 3 },
  textStyles: { title: { fontSize: 24, fontWeight: 700 } },
  translations: {
    greeting: { en: "Hello", de: "Hallo" },
  },
});

const config = new Configuration([base]);

config.flag("checkoutEnabled"); // true
config.route(1);                // "/"
config.imageList("gallery");   // readonly string[]
```

Higher-weight scopes override lower-weight scopes. If weights tie, the scope
inserted later wins. Missing values use the Dart runtime defaults:

| Getter | Missing value |
| --- | --- |
| `flag` | `false` |
| `color`, `image`, `route` | `""` |
| `imageList` | `[]` |
| `size` | `14` |
| `padding`, `margin` | `0` |
| `misc` | `null` |
| `textStyle`, `translations` | `{}` |

`translations(key)` returns the entire translation map from the winning scope,
matching the Dart `currentTranslations` behavior.

## Scope changes and access events

Subscriptions return an unsubscribe callback and run synchronously:

```ts
const stopChanges = config.subscribe((current) => {
  console.log(current.currentScopeName);
});

const stopAccess = config.subscribeAccess((event) => {
  console.log(event.type, event.scope.name, event.key, event.value);
});

config.pushScope(defineScope({
  name: "experiment",
  weight: 10,
  flags: { checkoutEnabled: false },
}));

stopChanges();
stopAccess();
```

Only successful key lookups emit access events. `popScope` preserves the final
scope; removing every scope installs a fresh empty fallback so a Configuration
always remains usable.

## Release status

This package is currently `UNLICENSED` and marked `private` pending confirmation
of rights to the upstream Configurator work. Do not remove those gates until the
repository license review has been resolved.
