import 'dart:math';
import 'package:configurator_annotations/configurator_annotations.dart';
import 'package:configurator_flutter/configurator_flutter.dart';
import 'package:example/src/app.config.dart';
import 'package:example/src/test_scope.dart';
import 'package:flutter/material.dart';
import 'package:v_widgets/v_widgets.dart';

@ConfiguratorApp(
  yaml: [
    './assets/example2.yaml',
  ],
)
class MyHomePage extends StatefulWidget {

  final String title;

  const MyHomePage({ required this.title, Key? key, }) : super( key: key );

  @override
  State<MyHomePage> createState() => _MyHomePageState();
}

class _MyHomePageState extends State<MyHomePage> {

  Random random = Random();

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
          ConfigKeys.colors.primary: randomColor,
          ConfigKeys.colors.secondary: randomColor,
          ConfigKeys.colors.tertiary: randomColor,
        },
        sizes: {
          ConfigKeys.sizes.detailTitleSize: max(random.nextInt( 24 ).toDouble(), 10)
        },
        flags: {
          ConfigKeys.flags.showTitle: random.nextBool(),
        }
      ));
    }
  }

  void _pop( BuildContext context ) {
    ConfigurationProvider.of(context, listen: false).config.popScope();
  }

  @override
  Widget build(BuildContext context) {

    final gen = Theme.of(context).extension<MyAppGeneratedThemeExtension>()!;

    Configuration config = ConfigurationProvider.of( context, listen: false ).config;

    Color c = config.colorValue( ConfigKeys.colors.primary );
    
    double s = config.size( ConfigKeys.sizes.detailTitleSize );
    // config.flag(id)

    return Scaffold(
      appBar: AppBar(
        title: Vif(
          test: () => config.flag( ConfigKeys.flags.showTitle ),
          ifTrue: () => Text( widget.title ),
        ),
      ),
      body: Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: <Widget>[
            const Text(
              'Current Scope:',
            ),
            Text(
              config.currentScopeName,
              style: Theme.of(context).textTheme.headline4?.copyWith(
                color: c,
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
                        config.popScopeUntil( i );
                      },
                      child: Card(
                        child: Padding(
                          padding: const EdgeInsets.all( 16.0 ),
                          child: Text(
                            config.scopes[i].name,
                            textAlign: TextAlign.center,
                            style: Theme.of(context).textTheme.bodyLarge?.copyWith(
                              color: gen.tertiary,
                              fontSize: s,
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
