import 'package:configurator/configurator.dart';

YamlConfiguration generatorFixture({bool reversed = false}) {
  List<T> ordered<T>(List<T> values) {
    return reversed ? values.reversed.toList() : values;
  }

  return YamlConfiguration(
    name: 'source_config',
    weight: 42,
    flags: ordered([
      YamlSetting('zetaFlag', false),
      YamlSetting('class', true),
      YamlSetting('feature.enabled', true),
    ]),
    colors: ordered([
      YamlSetting('brand.primary', '#12"34\n'),
      YamlSetting('accentColor', '00FF00'),
    ]),
    images: ordered([
      YamlSetting('hero.logo', 'assets/"hero".png'),
      YamlSetting('footerImages', ['a.svg', 'b\\c.svg']),
    ]),
    routes: ordered([
      YamlRoute(2, '/details/:id', const []),
      YamlRoute(1, '/', const []),
    ]),
    sizes: ordered([
      YamlSetting('heading.large', 24.0),
      YamlSetting('baseSize', 8),
    ]),
    padding: ordered([
      YamlSetting('card.horizontal', 12.0),
    ]),
    margins: ordered([
      YamlSetting('page.top', 16.0),
    ]),
    misc: ordered([
      YamlSetting('retryCount', 3),
      YamlSetting('labels', ['alpha', 'beta']),
      YamlSetting('payload', {
        'dollar': r'${value}',
        'quote': 'say "hi"\nnext',
      }),
    ]),
    textStyles: ordered([
      YamlTextStyle(
        key: 'hero.title',
        color: 'FFFFFF',
        size: 28,
        weight: 700,
        height: 1,
        typeface: const {'family': 'A "Font"', 'style': 'normal'},
      ),
    ]),
    strings: ordered([
      YamlI18n('welcome.message', 'en_us', r'Hello ${name}'),
    ]),
    i18n: ordered([
      YamlI18n('welcome.message', 'es', 'Hola'),
    ]),
  );
}

YamlConfiguration routeCollisionFixture() {
  return YamlConfiguration(
    name: 'collision',
    routes: [
      YamlRoute(1, '/foo-bar', const []),
      YamlRoute(2, '/foo_bar', const []),
    ],
  );
}
