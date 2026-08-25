import 'package:configurator/src/models/processed_config.dart';
import 'package:test/test.dart';

import 'generator_fixture.dart';

void main() {
  test('pure-Dart output keeps color and text-style accessors framework free',
      () async {
    final output = await ProcessedConfig(
      'AppScope',
      generatorFixture(),
    ).write(true) as String;

    expect(
      output,
      contains("import 'package:configurator/configurator.dart';"),
    );
    expect(output, isNot(contains("import 'dart:ui';")));
    expect(output, isNot(contains('package:flutter/material.dart')));
    expect(output, isNot(contains('package:configurator_flutter/')));

    expect(
      output,
      contains(
        'String get brandPrimary => _config.color("brand.primary");',
      ),
    );
    expect(output, isNot(contains('Color get brandPrimary')));
    expect(output, isNot(contains('colorValue(')));

    expect(output, contains('Map<String, dynamic> get heroTitle'));
    expect(
      output,
      contains('return _config.textStyle("hero.title");'),
    );
    expect(output, isNot(contains('TextStyleParser')));
  });
}
