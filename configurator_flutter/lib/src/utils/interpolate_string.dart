import 'package:i18n_extension/default.i18n.dart';

extension InterpolateExt on String {
  String interpolate(List<String> params) {
    try {
      return fill(params);
    } catch (e) {
      return this;
    }
  }
}