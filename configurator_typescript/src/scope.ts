/** A scalar image path or a generated list of image paths. */
export type ConfigImage = string | readonly string[];

/** Framework-neutral text-style properties. */
export type ConfigTextStyle = Readonly<Record<string, unknown>>;

/** Locale-to-value translations for one generated translation key. */
export type ConfigTranslationValues = Readonly<Record<string, string>>;

/** Generated translation keys mapped to their locale-specific values. */
export type ConfigTranslations = Readonly<
  Record<string, ConfigTranslationValues>
>;

/**
 * Language-neutral data accepted by {@link defineScope}.
 *
 * Every collection is optional so generators only need to emit sections that
 * are present in the source YAML file. Routes deliberately use a ReadonlyMap
 * because YAML route identifiers are numeric.
 */
export interface ConfigScopeData {
  readonly name: string;
  readonly weight?: number;
  readonly partFiles?: readonly string[];
  readonly flags?: Readonly<Record<string, boolean>>;
  readonly colors?: Readonly<Record<string, string>>;
  readonly images?: Readonly<Record<string, ConfigImage>>;
  readonly routes?: ReadonlyMap<number, string>;
  readonly sizes?: Readonly<Record<string, number>>;
  readonly paddings?: Readonly<Record<string, number>>;
  readonly margins?: Readonly<Record<string, number>>;
  readonly misc?: Readonly<Record<string, unknown>>;
  readonly textStyles?: Readonly<Record<string, ConfigTextStyle>>;
  readonly translations?: ConfigTranslations;
}

/** A normalized configuration scope consumed by {@link Configuration}. */
export interface ConfigScope {
  readonly name: string;
  readonly weight: number;
  readonly partFiles: readonly string[];
  readonly flags: Readonly<Record<string, boolean>>;
  readonly colors: Readonly<Record<string, string>>;
  readonly images: Readonly<Record<string, ConfigImage>>;
  readonly routes: ReadonlyMap<number, string>;
  readonly sizes: Readonly<Record<string, number>>;
  readonly paddings: Readonly<Record<string, number>>;
  readonly margins: Readonly<Record<string, number>>;
  readonly misc: Readonly<Record<string, unknown>>;
  readonly textStyles: Readonly<Record<string, ConfigTextStyle>>;
  readonly translations: ConfigTranslations;
}

function freezeRecord<T>(
  value: Readonly<Record<string, T>> | undefined,
): Readonly<Record<string, T>> {
  return Object.freeze({ ...(value ?? {}) });
}

function freezeImages(
  images: Readonly<Record<string, ConfigImage>> | undefined,
): Readonly<Record<string, ConfigImage>> {
  const copy: Record<string, ConfigImage> = {};

  for (const [key, value] of Object.entries(images ?? {})) {
    copy[key] = Array.isArray(value)
      ? Object.freeze([...value])
      : value;
  }

  return Object.freeze(copy);
}

function freezeTextStyles(
  textStyles: Readonly<Record<string, ConfigTextStyle>> | undefined,
): Readonly<Record<string, ConfigTextStyle>> {
  const copy: Record<string, ConfigTextStyle> = {};

  for (const [key, value] of Object.entries(textStyles ?? {})) {
    copy[key] = Object.freeze({ ...value });
  }

  return Object.freeze(copy);
}

function freezeTranslations(
  translations: ConfigTranslations | undefined,
): ConfigTranslations {
  const copy: Record<string, ConfigTranslationValues> = {};

  for (const [key, value] of Object.entries(translations ?? {})) {
    copy[key] = Object.freeze({ ...value });
  }

  return Object.freeze(copy);
}

/**
 * Normalizes generated scope data and detaches its collections from mutable
 * input objects. The returned shape has defaults for every YAML section.
 */
export function defineScope<const T extends ConfigScopeData>(
  data: T,
): ConfigScope {
  return Object.freeze({
    name: data.name,
    weight: data.weight ?? 0,
    partFiles: Object.freeze([...(data.partFiles ?? [])]),
    flags: freezeRecord(data.flags),
    colors: freezeRecord(data.colors),
    images: freezeImages(data.images),
    routes: new Map(data.routes ?? []),
    sizes: freezeRecord(data.sizes),
    paddings: freezeRecord(data.paddings),
    margins: freezeRecord(data.margins),
    misc: freezeRecord(data.misc),
    textStyles: freezeTextStyles(data.textStyles),
    translations: freezeTranslations(data.translations),
  });
}

// Imported only for the documentation link above. TypeScript resolves the
// symbol through the package barrel without introducing a runtime dependency.
import type { Configuration } from "./configuration.js";

