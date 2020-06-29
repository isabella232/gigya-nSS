import 'package:gigya_native_screensets_engine/models/routing.dart';
import 'package:gigya_native_screensets_engine/models/screen.dart';
import 'package:json_annotation/json_annotation.dart';

part 'markup.g.dart';

@JsonSerializable(anyMap: true)
class Markup {
  @JsonKey(defaultValue: false)
  bool platformAware;
  Map<String, Screen> screens;
  Routing routing;
  Map<String, dynamic> theme;
  @JsonKey(defaultValue: '_default')
  String lang;
  @JsonKey(name: 'i18n')
  Map<String, dynamic> localiation;
  @JsonKey(defaultValue: false)
  bool useSchemaValidations;

  Markup({this.platformAware, this.screens, this.routing, this.theme, this.useSchemaValidations});

  factory Markup.fromJson(Map<String, dynamic> json) => _$MarkupFromJson(json);

  Map<String, dynamic> toJson() => _$MarkupToJson(this);
}
