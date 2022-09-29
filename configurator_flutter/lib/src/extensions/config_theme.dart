import 'package:collection/collection.dart';
import 'package:configurator/configurator.dart';
import 'package:flutter/material.dart';
import 'package:parse_color/parse_color.dart';

typedef ThemeExtensionBuilder = ThemeExtension Function( Configuration );

extension ThemeF on Configuration {

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
    String? colorValue = scopes.reversed.firstWhereOrNull( ( s ) {
      return s.colors.containsKey( id );
    })?.colors[ id ];

    return UIColor( colorValue ?? const Color( 0xFF000000 ) );
  }

}