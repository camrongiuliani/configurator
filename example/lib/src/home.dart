import 'dart:math';
import 'package:configurator/configurator.dart';
import 'package:example/src/app.config.dart';
import 'package:example/src/test_scope.dart';
import 'package:flutter/material.dart';
import 'package:v_widgets/v_widgets.dart';

class MyHomePage extends StatefulWidget {
  const MyHomePage({Key? key, required this.title}) : super(key: key);

  final String title;

  @override
  State<MyHomePage> createState() => _MyHomePageState();
}

class _MyHomePageState extends State<MyHomePage> {

  Random random = Random();


  void _push( BuildContext context ) {
    if ( Configuration.of(context).scopes.length < 3 ) {
      Configuration.of(context).pushScope( TestScope1() );
    } else {
      Configuration.of(context).pushScope( ProxyScope(
        name: 'RandomScope_${Configuration.of(context).scopes.length - 2}',
        theme: {
          'colors': {
            ConfigKeys.theme.color.primary: ColorUtil.colorToString( Color.fromRGBO(
              random.nextInt(255),
              random.nextInt(255),
              random.nextInt(255),
              1,
            ) ),
            ConfigKeys.theme.color.secondary: ColorUtil.colorToString( Color.fromRGBO(
              random.nextInt(255),
              random.nextInt(255),
              random.nextInt(255),
              1,
            ) ),
            ConfigKeys.theme.color.tertiary: ColorUtil.colorToString( Color.fromRGBO(
              random.nextInt(255),
              random.nextInt(255),
              random.nextInt(255),
              1,
            ) ),
          },
          'sizes': {
            ConfigKeys.theme.size.detailTitleSize: random.nextInt( 24 )
          }
        },
        flags: {
          ConfigKeys.flags.showTitle: random.nextBool(),
        }
      ) );
    }
  }

  void _pop( BuildContext context ) {
    Configuration.of(context).popScope();
  }

  @override
  Widget build(BuildContext context) {

    final gen = Theme.of(context).extension<GeneratedConfigTheme>()!;

    return Scaffold(
      appBar: AppBar(
        title: ConfiguredWidget(
          builder: ( config ) => Vif(
            test: () => config.flag( ConfigKeys.flags.showTitle ),
            ifTrue: () => Text( widget.title ),
          ),
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
              Configuration.of(context).currentScopeName,
              style: Theme.of(context).textTheme.headline4?.copyWith(
                color: gen.secondary,
              ),
            ),
            Expanded(
              child: ListView.builder(
                itemCount: Configuration.of(context).scopes.length,
                shrinkWrap: true,
                itemBuilder: ( c, i ) {
                  return SizedBox(
                    width: 75.0,
                    height: 75.0,
                    child: GestureDetector(
                      onTap: () {
                        Configuration.of(context).popScopeUntil( i );
                      },
                      child: Card(
                        child: Padding(
                          padding: const EdgeInsets.all( 16.0 ),
                          child: Text(
                            Configuration.of(context).scopes[i].name,
                            textAlign: TextAlign.center,
                            style: Theme.of(context).textTheme.bodyLarge?.copyWith(
                              color: gen.tertiary,
                              fontSize: gen.detailTitleSize,
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
          ConfiguredWidget(
            builder: ( _ ) => FloatingActionButton(
              onPressed: () {
                _pop( context );
              },
              tooltip: 'Decrement',
              foregroundColor: gen.secondary,
              backgroundColor: gen.primary,
              child: const Icon(Icons.remove),
            ),
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
