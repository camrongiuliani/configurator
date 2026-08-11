import { defineScope } from "./scope.js";
import type {
  ConfigImage,
  ConfigScope,
  ConfigTextStyle,
  ConfigTranslations,
} from "./scope.js";

/** Runtime key categories emitted by configuration access subscriptions. */
export const KeyType = Object.freeze({
  Flag: "flag",
  Color: "color",
  Image: "image",
  ImageList: "imageList",
  Route: "route",
  Size: "size",
  Padding: "padding",
  Margin: "margin",
  Misc: "misc",
  TextStyle: "textStyle",
  // Keep the descriptive alias while serializing the event exactly as Dart.
  Translation: "string",
  String: "string",
} as const);

export type KeyType = (typeof KeyType)[keyof typeof KeyType];

interface AccessEvent<TType extends KeyType, TKey, TValue> {
  readonly type: TType;
  readonly scope: ConfigScope;
  readonly key: TKey;
  readonly value: TValue;
}

/** A discriminated event emitted after a configuration value is found. */
export type ConfigAccessEvent =
  | AccessEvent<typeof KeyType.Flag, string, boolean>
  | AccessEvent<typeof KeyType.Color, string, string>
  | AccessEvent<typeof KeyType.Image, string, string>
  | AccessEvent<typeof KeyType.ImageList, string, readonly string[]>
  | AccessEvent<typeof KeyType.Route, number, string>
  | AccessEvent<typeof KeyType.Size, string, number>
  | AccessEvent<typeof KeyType.Padding, string, number>
  | AccessEvent<typeof KeyType.Margin, string, number>
  | AccessEvent<typeof KeyType.Misc, string, unknown>
  | AccessEvent<typeof KeyType.TextStyle, string, ConfigTextStyle>
  | AccessEvent<typeof KeyType.Translation, string, ConfigTranslations>;

/** Dart-compatible name for configuration access events. */
export type ConfigKeyLog = ConfigAccessEvent;

export type Unsubscribe = () => void;
export type ConfigurationListener = (configuration: Configuration) => void;
export type AccessListener = (event: ConfigAccessEvent) => void;
export type ScopePredicate = (scope: ConfigScope) => boolean;

export interface ConfigurationOptions {
  readonly scopes?: readonly ConfigScope[];
}

export interface MutationOptions {
  readonly notify?: boolean;
}

export interface PushScopeOptions extends MutationOptions {
  /** Skip a push when the exact same scope is already current. */
  readonly checkEquality?: boolean;
}

interface LookupResult<T> {
  readonly scope: ConfigScope;
  readonly value: T;
}

const EMPTY_TEXT_STYLE: ConfigTextStyle = Object.freeze({});
const EMPTY_TRANSLATIONS: ConfigTranslations = Object.freeze({});
const EMPTY_IMAGE_LIST: readonly string[] = Object.freeze([]);

let defaultScopeSequence = 0;

function createDefaultScope(): ConfigScope {
  defaultScopeSequence += 1;
  return defineScope({
    name: `default-${Date.now()}-${defaultScopeSequence}`,
  });
}

function isScopeArray(
  value: readonly ConfigScope[] | ConfigurationOptions,
): value is readonly ConfigScope[] {
  return Array.isArray(value);
}

/**
 * Resolves generated configuration scopes using weight and stack order.
 *
 * Higher weights win. When two matching scopes have the same weight, the
 * scope inserted later wins.
 */
export class Configuration {
  private scopesValue: ConfigScope[];
  private readonly changeListeners = new Set<ConfigurationListener>();
  private readonly accessListeners = new Set<AccessListener>();

  public constructor(
    scopesOrOptions: readonly ConfigScope[] | ConfigurationOptions = [],
  ) {
    const scopes = isScopeArray(scopesOrOptions)
      ? scopesOrOptions
      : (scopesOrOptions.scopes ?? []);

    this.scopesValue = scopes.length > 0 ? [...scopes] : [createDefaultScope()];
  }

  /** A detached snapshot in insertion order. */
  public get scopes(): readonly ConfigScope[] {
    return [...this.scopesValue];
  }

  /** The most recently inserted scope, independent of its weight. */
  public get currentScopeName(): string {
    return this.scopesValue[this.scopesValue.length - 1]!.name;
  }

  /** Subscribe to scope-stack changes. The callback is not invoked immediately. */
  public subscribe(listener: ConfigurationListener): Unsubscribe {
    this.changeListeners.add(listener);
    return () => {
      this.changeListeners.delete(listener);
    };
  }

  /** Subscribe to successful key lookups. Missing keys do not emit events. */
  public subscribeAccess(listener: AccessListener): Unsubscribe {
    this.accessListeners.add(listener);
    return () => {
      this.accessListeners.delete(listener);
    };
  }

  /** Push a scope and return whether the stack changed. */
  public pushScope(
    scope: ConfigScope,
    options: PushScopeOptions = {},
  ): boolean {
    const checkEquality = options.checkEquality ?? true;
    const current = this.scopesValue[this.scopesValue.length - 1];

    if (checkEquality && current === scope) {
      return false;
    }

    this.scopesValue.push(scope);
    this.emitChange(options.notify ?? true);
    return true;
  }

  /** Pop the current scope without ever removing the final fallback scope. */
  public popScope(options: MutationOptions = {}): ConfigScope | undefined {
    if (this.scopesValue.length <= 1) {
      return undefined;
    }

    const removed = this.scopesValue.pop();
    this.emitChange(options.notify ?? true);
    return removed;
  }

  /** Pop scopes until the current scope satisfies `predicate`. */
  public popScopeUntil(
    predicate: ScopePredicate,
    options: MutationOptions = {},
  ): readonly ConfigScope[] {
    const removed: ConfigScope[] = [];

    while (
      this.scopesValue.length > 1
      && !predicate(this.scopesValue[this.scopesValue.length - 1]!)
    ) {
      removed.push(this.scopesValue.pop()!);
    }

    if (removed.length > 0) {
      this.emitChange(options.notify ?? true);
    }

    return removed;
  }

  /** Remove every matching scope, installing a fresh fallback if none remain. */
  public removeScopeWhere(
    predicate: ScopePredicate,
    options: MutationOptions = {},
  ): readonly ConfigScope[] {
    const kept: ConfigScope[] = [];
    const removed: ConfigScope[] = [];

    for (const scope of this.scopesValue) {
      (predicate(scope) ? removed : kept).push(scope);
    }

    if (removed.length === 0) {
      return removed;
    }

    this.scopesValue = kept.length > 0 ? kept : [createDefaultScope()];
    this.emitChange(options.notify ?? true);
    return removed;
  }

  /** Remove the most recently inserted matching scope. */
  public removeLastScopeWhere(
    predicate: ScopePredicate,
    options: MutationOptions = {},
  ): ConfigScope | undefined {
    for (let index = this.scopesValue.length - 1; index >= 0; index -= 1) {
      const scope = this.scopesValue[index]!;
      if (!predicate(scope)) {
        continue;
      }

      this.scopesValue.splice(index, 1);
      if (this.scopesValue.length === 0) {
        this.scopesValue.push(createDefaultScope());
      }
      this.emitChange(options.notify ?? true);
      return scope;
    }

    return undefined;
  }

  /** Remove the last scope with a matching name or object identity. */
  public removeScope(
    scopeOrName: ConfigScope | string,
    options: MutationOptions = {},
  ): ConfigScope | undefined {
    return this.removeLastScopeWhere(
      typeof scopeOrName === "string"
        ? (scope) => scope.name === scopeOrName
        : (scope) => scope === scopeOrName,
      options,
    );
  }

  public flag(key: string): boolean {
    const result = this.findRecordValue((scope) => scope.flags, key);
    if (result === undefined) {
      return false;
    }

    this.emitAccess({ type: KeyType.Flag, ...result, key });
    return result.value;
  }

  public color(key: string): string {
    const result = this.findRecordValue((scope) => scope.colors, key);
    if (result === undefined) {
      return "";
    }

    this.emitAccess({ type: KeyType.Color, ...result, key });
    return result.value;
  }

  public image(key: string): string {
    const result = this.findRecordValue((scope) => scope.images, key);
    if (result === undefined || typeof result.value !== "string") {
      return "";
    }

    const value = result.value;
    this.emitAccess({ type: KeyType.Image, scope: result.scope, key, value });
    return value;
  }

  public imageList(key: string): readonly string[] {
    const result = this.findRecordValue((scope) => scope.images, key);
    if (result === undefined) {
      return EMPTY_IMAGE_LIST;
    }

    const value = typeof result.value === "string"
      ? Object.freeze([result.value])
      : Object.freeze([...result.value]);

    this.emitAccess({
      type: KeyType.ImageList,
      scope: result.scope,
      key,
      value,
    });
    return value;
  }

  public route(key: number): string {
    const result = this.findRoute(key);
    if (result === undefined) {
      return "";
    }

    this.emitAccess({ type: KeyType.Route, ...result, key });
    return result.value;
  }

  public size(key: string): number {
    const result = this.findRecordValue((scope) => scope.sizes, key);
    if (result === undefined) {
      return 14;
    }

    this.emitAccess({ type: KeyType.Size, ...result, key });
    return result.value;
  }

  public padding(key: string): number {
    const result = this.findRecordValue((scope) => scope.paddings, key);
    if (result === undefined) {
      return 0;
    }

    this.emitAccess({ type: KeyType.Padding, ...result, key });
    return result.value;
  }

  public margin(key: string): number {
    const result = this.findRecordValue((scope) => scope.margins, key);
    if (result === undefined) {
      return 0;
    }

    this.emitAccess({ type: KeyType.Margin, ...result, key });
    return result.value;
  }

  public misc(key: string): unknown | null {
    const result = this.findRecordValue((scope) => scope.misc, key);
    if (result === undefined) {
      return null;
    }

    this.emitAccess({ type: KeyType.Misc, ...result, key });
    return result.value;
  }

  public textStyle(key: string): ConfigTextStyle {
    const result = this.findRecordValue((scope) => scope.textStyles, key);
    if (result === undefined) {
      return EMPTY_TEXT_STYLE;
    }

    this.emitAccess({ type: KeyType.TextStyle, ...result, key });
    return result.value;
  }

  /**
   * Return the full translation map from the winning scope that contains key.
   * This intentionally retains the Dart runtime's currentTranslations contract.
   */
  public translations(key: string): ConfigTranslations {
    const result = this.findRecordValue((scope) => scope.translations, key);
    if (result === undefined) {
      return EMPTY_TRANSLATIONS;
    }

    const value = result.scope.translations;
    this.emitAccess({
      type: KeyType.Translation,
      scope: result.scope,
      key,
      value,
    });
    return value;
  }

  /** Dart-compatible alias for {@link translations}. */
  public currentTranslations(key: string): ConfigTranslations {
    return this.translations(key);
  }

  /** Clear all subscriptions held by this configuration instance. */
  public dispose(): void {
    this.changeListeners.clear();
    this.accessListeners.clear();
  }

  private findRecordValue<T>(
    select: (scope: ConfigScope) => Readonly<Record<string, T>>,
    key: string,
  ): LookupResult<T> | undefined {
    let winner: LookupResult<T> | undefined;

    for (const scope of this.scopesValue) {
      const values = select(scope);
      if (!Object.hasOwn(values, key)) {
        continue;
      }

      if (winner === undefined || scope.weight >= winner.scope.weight) {
        winner = { scope, value: values[key]! };
      }
    }

    return winner;
  }

  private findRoute(key: number): LookupResult<string> | undefined {
    let winner: LookupResult<string> | undefined;

    for (const scope of this.scopesValue) {
      if (!scope.routes.has(key)) {
        continue;
      }

      if (winner === undefined || scope.weight >= winner.scope.weight) {
        winner = { scope, value: scope.routes.get(key)! };
      }
    }

    return winner;
  }

  private emitChange(notify: boolean): void {
    if (!notify) {
      return;
    }

    for (const listener of [...this.changeListeners]) {
      listener(this);
    }
  }

  private emitAccess(event: ConfigAccessEvent): void {
    const immutableEvent = Object.freeze(event);
    for (const listener of [...this.accessListeners]) {
      listener(immutableEvent);
    }
  }
}
