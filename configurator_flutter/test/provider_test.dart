import 'dart:async';

import 'package:configurator_flutter/configurator_flutter.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter_test/flutter_test.dart';


void main() {

  group( 'ConfigurationProvider Tests', () {

    testWidgets('ConfigurationProvider Update Should Notify Test', (tester) async {
      await tester.pumpWidget(
        Configurator(
          config: Configuration(),
          builder: ( context, config ) => Container(),
        ),
      );

      var e = tester.element( find.byType( ConfigurationProvider ) );
      expect( e.widget, isA<ConfigurationProvider>() );
      var cp = e.widget as ConfigurationProvider;

      expect( cp.updateShouldNotify( cp ), isTrue );
    });

    testWidgets('Config.of Test', (tester) async {

      await tester.pumpWidget(
        Configurator(
          config: Configuration(),
          builder: ( context, config ) => Container(),
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

      var config = Configuration();

      int hitCount = 0;

      await tester.pumpWidget(
        Configurator(
          config: config,
          builder: ( context, config ) {
            hitCount++;

            if ( hitCount == 1 ) {
              var s1 = ProxyScope(name: 'test');
              config.pushScope( s1 );
            } else if ( hitCount == 2 ) {
              completer.complete( config );
            }

            return Container();
          }
        ),
      );

      await tester.pumpAndSettle();

      await expectLater( completer.future, completion( isNotNull ) ).timeout( const Duration( seconds: 1 ) );

    });
  });
}