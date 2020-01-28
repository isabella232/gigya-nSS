import 'package:gigya_native_screensets_engine/ui/rendering.dart';
import 'package:gigya_native_screensets_engine/ui/widget_factory.dart';
import 'package:json_annotation/json_annotation.dart';

part 'widget.g.dart';
@JsonSerializable(anyMap: true)

class NSSWidget {
  WidgetType type;
  String textKey;
  NSSAlignment stack;
  List<NSSWidget> children;

  NSSWidget(this.type, this.textKey, { this.children , this.stack });

  factory NSSWidget.fromJson(Map<String, dynamic> json) => _$NSSWidgetFromJson(json);
  Map<String, dynamic> toJson() => _$NSSWidgetToJson(this);

}