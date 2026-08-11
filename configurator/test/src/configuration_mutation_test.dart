import 'package:configurator/configurator.dart';
import 'package:test/test.dart';

void main() {
  group('Configuration mutation contract', () {
    test('removing every scope preserves the non-empty invariant', () async {
      final first = ProxyScope(name: 'first');
      final second = ProxyScope(name: 'second');
      final config = Configuration(scopes: [first, second]);
      final changed = config.watch().first;

      await config.removeScopeWhere((_) => true);
      await changed;

      expect(config.scopes, hasLength(1));
      expect(config.currentScopeName, isNot(anyOf('first', 'second')));
    });

    test('list image lookup returns strings and publishes an access event',
        () async {
      final scope = ProxyScope(
        name: 'images',
        images: const {
          'galleryImages': ['one.png', 'two.png'],
        },
      );
      final config = Configuration(scopes: [scope]);
      final access = config.accessStream.first;

      expect(
        config.imageList('galleryImages'),
        equals(['one.png', 'two.png']),
      );

      final event = await access;
      expect(event.type, KeyType.image);
      expect(event.scope, same(scope));
      expect(event.key, 'galleryImages');
      expect(event.value, equals(['one.png', 'two.png']));
    });
  });
}
