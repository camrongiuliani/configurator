class YamlI18n {

  final String name;
  final String locale;
  final dynamic value;

  YamlI18n( this.name, this.locale, this.value );

  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      other is YamlI18n &&
          runtimeType == other.runtimeType &&
          name == other.name &&
          locale == other.locale &&
          value == other.value;

  @override
  int get hashCode => name.hashCode ^ locale.hashCode ^ value.hashCode;
}