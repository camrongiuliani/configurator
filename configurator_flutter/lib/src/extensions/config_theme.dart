import 'package:collection/collection.dart';
import 'package:configurator/configurator.dart';
import 'package:flutter/material.dart';
import 'package:parse_color/parse_color.dart';

typedef ThemeExtensionBuilder = ThemeExtension Function( Configuration );

extension ThemeF on Configuration {

  List<ConfigScope> get _scopesSorted =>
      scopes.sorted((a, b) => a.weight.compareTo(b.weight));

  ThemeData buildTheme({
    ThemeData? baseTheme,
    List<ThemeExtension> extensions = const [],
    List<ThemeExtensionBuilder> extensionBuilders = const [],
  }) {
    return ( baseTheme ?? ThemeData() ).copyWith(
      extensions: [
        ...extensionBuilders.map((e) => e( this )),
        ...extensions,
      ],
    );
  }

  Color colorValue( String id ) {
    final ConfigScope? scope = _scopesSorted.reversed.firstWhereOrNull((s) {
      return s.colors.containsKey( id );
    });

    final value = scope?.colors[ id ];

    if (scope != null) {
      publisher.sink.add(
        ConfigKeyLog(KeyType.flag, scope, id, value),
      );
    }

    return UIColor( value ?? const Color( 0xFF000000 ) );
  }

}