import 'dart:math';
import 'package:configurator_flutter/configurator_flutter.dart';
import 'package:example/src/config/example1.config.dart';
import 'package:example/src/test_scope.dart';
import 'package:flutter/material.dart';
import 'package:v_widgets/v_widgets.dart';

class MyHomePage extends StatefulWidget {

  final String title;

  const MyHomePage({ required this.title, Key? key, }) : super( key: key );

  @override
  State<MyHomePage> createState() => _MyHomePageState();
}

class _MyHomePageState extends State<MyHomePage> {

  Random random = Random();

  bool translate = false;

  String colorToString(Color color) {
    var r = color.red;
    var g = color.green;
    var b = color.blue;
    var o = color.opacity;
    return 'rgba($r,$g,$b,$o)';
  }

  String get randomColor => colorToString( Color.fromRGBO(
    random.nextInt(255),
    random.nextInt(255),
    random.nextInt(255),
    1,
  ));


  void _push( BuildContext context ) {

    Configuration config = ConfigurationProvider.of( context, listen: false ).config;

    if ( config.scopes.length < 2 ) {
      config.pushScope( TestScope1() );
    } else if ( config.scopes.length < 3 ) {

      DefaultAssetBundle.of(context).loadString('example2.yaml').then((value) {
        config.pushScope( ConfigScope.fromYaml( value ) );
      });

    } else {
      config.pushScope(ProxyScope(
        name: 'RandomScope_${config.scopes.length - 2}',
        colors: {
          AppScopeConfigKeys.colors.primary: randomColor,
          AppScopeConfigKeys.colors.secondary: randomColor,
          AppScopeConfigKeys.colors.tertiary: randomColor,
        },
        sizes: {
          AppScopeConfigKeys.sizes.detailTitleSize: max(random.nextInt( 24 ).toDouble(), 10)
        },
        flags: {
          AppScopeConfigKeys.flags.showTitle: random.nextBool(),
        }
      ));
    }
  }

  void _pop( BuildContext context ) {
    ConfigurationProvider.of(context, listen: false).config.popScope();
  }

  @override
  Widget build(BuildContext context) {

    final gen = Theme.of(context).extension<AppScopeGeneratedThemeExtension>()!;

    Configuration config = Config.of( context, listen: false );

    return Scaffold(
      appBar: AppBar(
        title: Vif(
          test: () => config.flags.showTitle,
          ifTrue: () => Text( widget.title ),
        ),
      ),
      body: Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: <Widget>[
            Text(
              '${config.strings.currentScope}:',
            ),
            Text(
              config.currentScopeName,
              style: Theme.of(context).textTheme.headline4?.copyWith(
                color: config.colors.primary,
              ),
            ),
            Expanded(
              child: ListView.builder(
                itemCount: config.scopes.length,
                shrinkWrap: true,
                itemBuilder: ( c, i ) {
                  return SizedBox(
                    width: 75.0,
                    height: 75.0,
                    child: GestureDetector(
                      onTap: () {
                        config.popScopeUntil( ( scope ) {
                          return scope == config.scopes[i];
                        });
                      },
                      child: Card(
                        child: Padding(
                          padding: const EdgeInsets.all( 16.0 ),
                          child: Text(
                            config.scopes[i].name,
                            textAlign: TextAlign.center,
                            style: Theme.of(context).textTheme.bodyLarge?.copyWith(
                              color: gen.tertiary,
                              fontSize: config.sizes.detailTitleSize,
                            ),
                          ),
                        ),
                      ),
                    ),
                  );
                },
              ),
            ),
          ],
        ),
      ),
      floatingActionButton: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          FloatingActionButton(
            onPressed: () {
              _pop( context );
            },
            tooltip: 'Decrement',
            foregroundColor: gen.secondary,
            backgroundColor: gen.primary,
            child: const Icon(Icons.remove),
          ),
          FloatingActionButton(
            onPressed: () {

              if ( translate ) {
                translate = false;
                LocaleSettings.setLocale( AppLocale.en );
              } else {
                translate = true;
                LocaleSettings.setLocale( AppLocale.de );
              }

              _push( context );
            },
            tooltip: 'Increment',
            child: const Icon(Icons.add),
          ),
        ].map((e) {
          return Padding(
            padding: const EdgeInsets.all( 4.0 ),
            child: e,
          );
        }).toList(),
      ),
    );
  }
}
