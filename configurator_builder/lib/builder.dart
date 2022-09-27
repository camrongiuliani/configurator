library configurator_builder;

import 'package:build/build.dart';
import 'src/generator.dart';
import 'package:source_gen/source_gen.dart';

Builder frameworkBuilder(final BuilderOptions _) =>
    SharedPartBuilder([ConfiguratorGenerator()], 'config');