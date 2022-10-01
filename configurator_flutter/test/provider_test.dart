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

    testWidgets('Config Exists Test', (tester) async {

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
  });
}