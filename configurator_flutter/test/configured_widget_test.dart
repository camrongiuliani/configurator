import 'dart:async';

import 'package:configurator_flutter/configurator_flutter.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter_test/flutter_test.dart';


void main() {

  group( 'ConfiguredWidget Tests', () {

    testWidgets('Config.of Test', (tester) async {

      await tester.pumpWidget(
        ConfigurationProvider(
          config: Configuration(),
          child: ConfiguredWidget(
            builder: ( _ ) =>  Container() ,
          ),
        ),
      );

      expect(
            () => Config.of(tester.element(find.byType(Container))),
        isNotNull,
        reason: 'Configuration should not be null.',
      );
    });

    testWidgets('Add Scope Rebuilds Test', (tester) async {

      Completer<Configuration> completer = Completer();

      int hitCount = 0;

      await tester.pumpWidget(
        ConfigurationProvider(
          config: Configuration(),
          child: ConfiguredWidget(
            builder: ( config ) {
              hitCount++;

              if ( hitCount == 1 ) {
                var s1 = ProxyScope(name: 'test');
                config.pushScope( s1 );
              } else if ( hitCount == 2 ) {
                completer.complete( config );
              } else {
                throw Exception( 'Should not be hit a 3rd time.' );
              }

              return Container();
            },
          ),
        ),
      );

      await tester.pumpAndSettle();

      await expectLater( completer.future, completion( isNotNull ) ).timeout( const Duration( seconds: 1 ) );

    });
  });
}