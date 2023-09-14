<img src="https://raw.githubusercontent.com/camrongiuliani/configurator/1fc199ce30803e86226cb7fb975f352372a6280e/configurator/badge.svg">

# Integrating Configurator with flutter_modular: a simple use case
This will walk you through a simple setup to get started with the Configurator.
This integration assumes the use of flutter_modular, but should work with other setups as well.

## Getting Started
First, add the configurator and configurator_flutter dependencies.
Note: these packages are not yet available on pub.dev so we'll need to use git to add them.

```yaml
dependencies:
  configurator:
    git:
      url: git@github.com:camrongiuliani/configurator.git
      path: configurator
      ref: 0.0.42

  configurator_flutter:
    git:
      url: git@github.com:camrongiuliani/configurator.git
      path: configurator_flutter
      ref: 0.0.42
```
Make sure to set up an SSH key in your github account as well.

you'll also want to add the following dependencies:
```yaml
intl: ^0.18.1
flutter_localizations:
  sdk: flutter
flutter_modular: ^5.0.3
google_fonts: ^5.1.0
i18n_extension: ^9.0.2
```

## Base Setup
Before you get too involved, create the following file (or one similar to it):

config_mixin.dart:
```dart
import 'package:configurator_flutter/configurator_flutter.dart';

mixin ConfigMixin {
  final List<ConfigScope> scopes = [];

  Configuration? _config;

  Configuration get config => _config ??= Configuration(scopes: scopes);

  void initConfiguration([List<ConfigScope> scopes = const []]) {
    if (_config == null) {
      _config = Configuration(scopes: scopes);
    } else {
      for (ConfigScope scope in scopes) {
        config.pushScope(scope);
      }
    }
  }
}
```

Next, create an abstract class to use as the Base of each module.
This will be used to handle the configuration scoping.

module_base.dart:
```dart
import 'package:configurator_flutter/configurator_flutter.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter_modular/flutter_modular.dart';
import 'package:integrate_configurator/config_mixin.dart';

abstract class ModuleBase extends Module with ConfigMixin {
  ModuleBase([List<ConfigScope> scopes = const []]) {
    this.scopes.addAll(scopes);

    initConfiguration([
      ...configurations,
      ...this.scopes,
    ]);
  }

  List<ConfigScope> get configurations => [];

  List<Bind> get dependencies => [];

  @override
  @protected
  @visibleForTesting
  List<Bind> get binds => [
        ...dependencies,
        Bind.lazySingleton<Configuration>((_) => config),
        //TODO: add other setup items, repo, etc.
      ];
}
```

Next, create a top-level directory, config, and add two yaml files:
- app.defs.yaml
- app_scope.config.yaml

app.defs.yaml:
This is where you can define any colors that should be used throughout the project.
They will be added to the config.yaml files when you run ```flutter pub run configurator```.
```yaml
id: app_defs
definitions:
  colors:
    primary: &primary '0000FF'
    secondary: &secondary '008000'
    textLight: &textLight 'FFFFFF'
    textDark: &textDark '000000'
```
Explanation:
- id: this is the id for this defs.yaml file. Will be used by config.yaml files to decide which defs.yaml file to get definitions from.
- definitions: which defs we want to add.

app_scope.config.yaml:
This is where you'll put any app level overrides.
The individual modules' configs will handle most of this, but you can change them via keys here.
```yaml
id: app_scope
weight: 1
def_source: app_defs
parts:
definitions:
  colors:

configuration:
  i18n:
    en_us:
      common:
        test: 'Test'
```
Explanation:
- id: the id for this config.yaml file
- weight: basically decides which config values have precedence
- parts: any sub-configs. These are compiled into the top-level config.dart file.
- def_source: the id of the defs.yaml file that the definitions should be grabbed from
- definitions: the mapping of any definitions, you'll need the key name of any defs to generate them, i.e. colors:
```yaml
definitions:
  colors:
```

Next, create a top-level directory, modules, and add two subdirectories:
- module_a
- module_b

To each submodule, add a config directory with a related config.yaml file.
Also, add a screens directory to each module, complete with their own config-related content.
Once done you should have something resembling the following:

- lib
    - config
        - app.defs.yaml
        - app_scope.config.yaml
    - modules
        - module_a
            - config
                - module_a.config.yaml
            - screens
                - screen_a
                    - config
                        - screen_a.config.yaml
        - module_b
            - config
                - module_b.config.yaml
                - // you can also put a module_b.defs.yaml here
            - screens
                - screen_b
                    - config
                        - screen_b.config.yaml



Now, all of the module-related configurations should be added to the
respective config.yaml files. For example, let's update module_a.config.yaml:
```yaml
id: module_a_scope
def_source: app_defs
parts:
definitions:
  colors:

configuration:
  i18n:
    en_us:
      common:
        test: 'Test'
```
Let's stop and run the terminal command:
```flutter pub run configurator```
This will add the color defs to each config.yaml file for us, giving us the following in module_a.config.yaml:
```yaml
id: module_a_scope
def_source: app_defs
parts:
definitions:
  colors:
    primary: &primary "0000FF"
    secondary: &secondary "008000"
    textLight: &textLight "FFFFFF"
    textDark: &textDark "000000"

configuration:
  i18n:
    en_us:
      common:
        test: 'Test'
```

Once this has been done for all modules, let's move on to the screens. These are good candidates to create parts.
Define screen_a.config.yaml:
```yaml
id: screen_a
namespace: screenA
def_source: app_defs

definitions:
  colors:
    
configuration:
  i18n:
    en_us:
      common:
        test: 'Test'
```
Explanation:
- id: the id of this config.yaml. This is what will be used to add this config to another as a part
- namespace: the name used when referencing this config in dart code
- def_source: the id of the defs.yaml file that should be used for this config's definitions
- everything else, same as before

Let's add this screen as a part to the module_a.config.yaml:
```yaml
id: module_a_scope
def_source: app_defs
parts:
  - screen_a
```
Any config ids listed under parts will be added to the generated config.dart file for the top-level configuration.
Run the configurator again.

## Utilizing the configurator
First, let's set up the base app_module. In the lib directory (or wherever), create app_module.dart:
```dart
import 'package:configurator_flutter/configurator_flutter.dart';
import 'package:flutter_modular/flutter_modular.dart';
import 'package:integrate_configurator/config/app_scope.config.dart';
import 'package:integrate_configurator/module_base.dart';

class AppModule extends ModuleBase {
  AppModule([List<ConfigScope> scopes = const []]) {
    initConfiguration([
      ...scopes,
    ]);
  }

  @override
  List<ConfigScope> get configurations => [
    const GeneratedAppScope(),
  ];

  @override
  List<Bind> get binds => [
    Bind.singleton<Configuration>((_) => config),
  ];
  
  @override
  List<ParallelRoute> get routes => [];
}
```

Now, let's setup the base app widget to use the configurator. Open up main.dart.
In the main function, we want to setup our AppModule and add it to a ModularApp.
We are then going to wrap the main widget in both a Configurator and I18n Widget:
```dart
import 'package:configurator_flutter/configurator_flutter.dart';
import 'package:flutter/material.dart';
import 'package:flutter_modular/flutter_modular.dart';
import 'package:i18n_extension/i18n_widget.dart';
import 'package:integrate_configurator/app_module.dart';

void main() {
  WidgetsFlutterBinding.ensureInitialized();
  final appModule = AppModule();
  
  runApp(
    ModularApp(
      module: appModule,
      child: I18n(
        child: Configurator(
          config: appModule.config,
          builder: (_, __) => const MyApp(),
        ),
      ),
    ),
  );
}
```

Next, we will setup the main app widget itself to use MaterialApp.router and the localization delegates, etc.
Again, in main.dart:
```dart
final rootNavigator = GlobalKey<NavigatorState>();

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  @override
  Widget build(BuildContext context) {
    final config = Config.of(context);
    Modular.setNavigatorKey(rootNavigator);

    return MaterialApp.router(
      title: 'Configurator App',
      debugShowCheckedModeBanner: false,
      routeInformationParser: Modular.routeInformationParser,
      routerDelegate: Modular.routerDelegate,
      localizationsDelegates: const [
        GlobalCupertinoLocalizations.delegate,
        GlobalMaterialLocalizations.delegate,
        GlobalWidgetsLocalizations.delegate,
      ],
      supportedLocales: const [
        Locale('en', 'US'),
      ],
      theme: config.buildTheme(
        baseTheme: MyTheme.of(context),
        extensions: [
          GeneratedAppScopeThemeExtension(
            themeMap: config.themeMap,
          ),
        ],
      ),
    );
  }
}
```
Replace MyTheme with whatever predefined Theme you want (Theme.of(context) works fine) as this is the fallback theming for the project.

Now, let's set up a module. In the module_a directory, create module_a.dart:
```dart
import 'package:configurator_flutter/configurator_flutter.dart';
import 'package:flutter_modular/flutter_modular.dart';
import 'package:integrate_configurator/module_base.dart';
import 'package:integrate_configurator/modules/module_a/config/module_a.config.dart';

class ModuleA extends ModuleBase {
  ModuleA([super.scopes]);

  @override
  List<ConfigScope> get configurations => [
        const GeneratedModuleAScope(),
      ];

  @override
  List<Bind> get dependencies => [
        // Bind any dependencies, i.e. Blocs, etc.
      ];

  @override
  List<ModularRoute> get routes => [
        // Set up any routes
      ];
}
```
Explanation:
- Constructor: passing the scopes from the parent (this is how we maintain proper scoping of our configurations for sub modules/scopes)
- configurations: Just pass the top-level scope that was generated for this module
- dependencies: This is where any Blocs, etc. should be added for this module
- routes: The routes for this module

Set up module_b in the same way.

Now, back in app_module.dart, add the two modules to the binds getter (Don't forget to import them as well!):
```dart
@override
  List<Bind> get binds => [
    Bind.singleton<Configuration>((_) => config),
    Bind.singleton<ModuleA>((_) => ModuleA()),
    Bind.singleton<ModuleB>((_) => ModuleB()),
  ];
```
and add the Modules to the routes:
```dart
@override
  List<ParallelRoute> get routes => [
    ModuleRoute('/', module: Modular.get<ModuleA>()),
    ModuleRoute('/', module: Modular.get<ModuleB>()),
  ];
```

Let's take a moment and setup two simple screens, one for each module:
- screen_a.dart
- screen_b.dart
  in their respective directories:

```dart
import 'package:configurator_flutter/configurator_flutter.dart';
import 'package:flutter/material.dart';
import 'package:integrate_configurator/config/app_scope.config.dart';

class ScreenA extends StatelessWidget {
  const ScreenA({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    final config = Config.of(context);
    return Scaffold(
      appBar: AppBar(
        title: const Text('Screen A'),
      ),
      body: Center(
        child: Text(
          config.strings.common.test,
        ),
      ),
    );
  }
}
```
Explanation:
Get an instance of the Configuration via the context, ```Config.of(context)```,
and using dot syntax, locate the strings, then the common section, and finally
the test value we created earlier.

An instance of the Configuration can also be obtained via Modular.get<Configuration>().
However, there can be scoping issues when dealing with things such as dialogs, etc. so
using Config.of(context) tends to be the better of the two options when the context is
available.

Let's pause and dive into the values from the config...

## Config Values
In a given config.yaml file, we can define a handful of top-level elements, or keys.
These keys include:
- flags: bool
- images: String image path
- colors: Color
- sizes: double
- padding: double
- margins: double
- misc: dynamic
- textStyles: TextStyle
- routes: String route
- i18n: more on this momentarily

For each of these keys, we can create any sort of nested mapping we need.
For example:
```yaml
configuration:
  flags:
    callStartupFunction:
      api1: false
      api2: true
```
This will generate two bools that can be accessed via:
```dart
@override
Widget build(BuildContext context) {
  final config = Config.of(context);
  final callApi1 = config.flags.callStartupFunctionApi1;
  final callApi2 = config.flags.callStartupFunctionApi2;
  //...
}
```

For strings, we need to nest the translations under the i18n key:
```yaml
configuration:
  i18n:
    en_us:
      title: Some Title
      common: 
        continueButton: 'Continue'
        ok: OK
```
Which will generate the translation Strings for the en_us locale. Note that quotes are optional.
These can be accessed via the config dot syntax as well:
```dart
@override
Widget build(BuildContext context) {
  final config = Config.of(context);
  String title = config.strings.title;
  String continueButton = config.strings.common.continueButton;
  String ok = config.strings.common.ok;
  //...
}
```
If you define any module-specific configurations, just be sure to import the correct module scope config.dart file.

## Setup Navigation
Let's define the routes for module_a. Open module_a.config.yaml and add the routes key:
```yaml
configuration:
  routes:
    - id: 101
      path: /screen-a
```
Re-run the configurator and jump to module_a.dart. Let's add the route for screen a:
```dart
@override
List<ModularRoute> get routes => [
      // Set up any routes
      RedirectRoute(
        '/',
        to: config.routes.screenA,
      ),
      ChildRoute(
        config.routes.screenA,
        child: (_, __) => const ScreenA(),
      ),
    ];
```

Now, if we run the project, ScreenA should launch. Navigation can be done as is common for a flutter_modular app.

