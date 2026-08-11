import 'dart:convert';

import 'package:configurator/configurator.dart';

import 'conformance_root.config.dart';

void main() {
  _verifyGeneratedConfiguration();
  _verifyRuntimePrecedence();
  print('Dart conformance passed');
}

void _verifyGeneratedConfiguration() {
  const generated = GeneratedConformanceRoot();
  _equal(generated.weight, 7, 'generated scope weight');

  final runtime = Configuration(scopes: [generated]);

  // Values from the root survive the part merge.
  _equal(runtime.flag('enabledSearch'), true, 'root flag');
  _equal(runtime.color('rootOnly'), 'AABBCC', 'root color');
  _equal(runtime.image('logo'), 'assets/root-logo.svg', 'root image');
  _deepEqual(runtime.imageList('gallery'), [
    'assets/one.png',
    'assets/two.png',
  ], 'image list');
  _equal(runtime.route(2), '/root-only', 'root route');
  _equal(runtime.padding('screen'), 8, 'padding');
  _equal(runtime.margin('screen'), 4, 'margin');
  _equal(runtime.misc('retryCount'), 3, 'misc number');
  _deepEqual(runtime.misc('labels'), ['alpha', 'beta'], 'misc list');
  _equal(
    runtime.textStyle('header')['typeface']['family'],
    'Inter',
    'font family',
  );

  // The deepest part wins for duplicate semantic keys.
  _equal(runtime.flag('sharedFlag'), true, 'overridden flag');
  _equal(runtime.flag('baseOnly'), true, 'base flag');
  _equal(runtime.flag('deepestOnly'), true, 'deepest flag');
  _equal(runtime.color('primary'), '708090', 'overridden color');
  _equal(runtime.route(1), '/override', 'overridden route');
  _equal(runtime.size('cardWidth'), 24, 'overridden size');
  _equal(runtime.misc('rolloutStage'), 'override', 'overridden misc');

  // `strings` and `i18n` produce one normalized translation map.
  final translations = runtime.currentTranslations('greeting');
  _deepEqual(translations['greeting'], {
    'en': 'Override hello',
    'es': 'Hola',
  }, 'translation merge');
  _deepEqual(runtime.currentTranslations('status')['status'], {
    'en': 'Ready',
  }, 'translation alias');
  _deepEqual(translations['rootOnly'], {'en': 'Root only'}, 'root translation');
}

void _verifyRuntimePrecedence() {
  final low = ProxyScope(
    name: 'low',
    weight: 1,
    flags: const {'choice': false},
  );
  final high = ProxyScope(
    name: 'high',
    weight: 5,
    flags: const {'choice': true},
  );
  final laterTie = ProxyScope(
    name: 'later-tie',
    weight: 5,
    flags: const {'choice': false},
  );

  final runtime = Configuration(scopes: [low, high]);
  _equal(runtime.flag('choice'), true, 'higher weight');
  runtime.pushScope(laterTie);
  _equal(runtime.flag('choice'), false, 'later equal-weight scope');
}

void _equal(Object? actual, Object? expected, String label) {
  if (actual != expected) {
    throw StateError('$label: expected $expected, got $actual');
  }
}

void _deepEqual(Object? actual, Object? expected, String label) {
  final actualJson = jsonEncode(actual);
  final expectedJson = jsonEncode(expected);
  if (actualJson != expectedJson) {
    throw StateError('$label: expected $expectedJson, got $actualJson');
  }
}
