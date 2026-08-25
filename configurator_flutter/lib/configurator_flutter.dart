/// A Flutter package that provides configuration management and UI components.
///
/// This package extends the core [configurator] package with Flutter-specific
/// functionality, including:
/// * Widgets for configuration-aware UI components
/// * Providers for accessing configuration in the widget tree
/// * Theme support for Flutter applications
/// * Utilities for parsing and handling Flutter-specific types
/// * Extensions for working with configuration in Flutter
///
/// Example usage:
/// ```dart
/// import 'package:configurator_flutter/configurator_flutter.dart';
///
/// void main() {
///   runApp(ConfigProvider(
///     configuration: myConfiguration,
///     child: MyApp(),
///   ));
/// }
/// ```
library configurator_flutter;

export 'src/widgets/configured_widget.dart';
export 'src/provider/config_provider.dart';
export 'src/theme/base.dart';
export 'src/utils/font_weight_parser.dart';
export 'src/utils/color_parser.dart';
export 'src/utils/text_style_parser.dart';
export 'src/utils/localize_util.dart';
export 'src/utils/interpolate_string.dart';
export 'src/extensions/config_listenable.dart';
export 'src/extensions/config_of.dart';
export 'src/extensions/config_theme.dart';
export 'package:configurator/configurator.dart';
export 'package:slang_flutter/slang_flutter.dart';
export 'package:i18n_extension/default.i18n.dart' show Localization;
export 'package:i18n_extension/i18n_extension.dart' show I18nMainExtension;
