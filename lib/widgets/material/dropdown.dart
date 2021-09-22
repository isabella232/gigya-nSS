import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:gigya_native_screensets_engine/models/widget.dart';
import 'package:gigya_native_screensets_engine/providers/binding_provider.dart';
import 'package:gigya_native_screensets_engine/providers/screen_provider.dart';
import 'package:gigya_native_screensets_engine/style/decoration_mixins.dart';
import 'package:gigya_native_screensets_engine/style/styling_mixins.dart';
import 'package:gigya_native_screensets_engine/utils/accessibility.dart';
import 'package:gigya_native_screensets_engine/utils/extensions.dart';
import 'package:gigya_native_screensets_engine/utils/localization.dart';
import 'package:gigya_native_screensets_engine/utils/logging.dart';
import 'package:gigya_native_screensets_engine/utils/validation.dart';
import 'package:provider/provider.dart';

/// Dropdown group UI selection component.
class DropDownButtonWidget extends StatefulWidget {
  final NssWidgetData data;

  const DropDownButtonWidget({Key key, this.data}) : super(key: key);

  @override
  _DropDownButtonWidgetState createState() => _DropDownButtonWidgetState();
}

class _DropDownButtonWidgetState extends State<DropDownButtonWidget>
    with DecorationMixin, BindingMixin, StyleMixin, LocalizationMixin, ValidationMixin {
  String _dropdownValue;
  List<String> _dropdownItems = [];
  String _placeholder;

  @override
  void initState() {
    _placeholder = widget.data.placeholder ?? null;
    super.initState();
  }

  int indexFromDisplayValue(String value) {
    int index = 0;
    for (var i = 0; i < _dropdownItems.length; i++) {
      if (_dropdownItems[i] == value) {
        return i;
      }
    }
    return index;
  }

  int indexFromValue(String value) {
    int index = 0;
    for (var i = 0; i < widget.data.options.length; i++) {
      if (widget.data.options[i].value == value) {
        return i;
      }
    }
    return index;
  }

  @override
  Widget build(BuildContext context) {
    return Consumer2<ScreenViewModel, BindingModel>(builder: (context, viewModel, bindings, child) {
      _dropdownItems.clear();

      BindingValue bindingValue = getBindingText(widget.data, bindings, asArray: widget.data.storeAsArray);

      if (bindingValue.error && !kReleaseMode) {
        return showBindingDoesNotMatchError(widget.data.bind, errorText: bindingValue.errorText);
      }

      var bindValue = bindingValue.value;
      var defaultValue;
      widget.data.options.forEach((option) {
        _dropdownItems.add(localizedStringFor(option.textKey));
        if (option.defaultValue != null && option.defaultValue) {
          defaultValue = option.value;
        }
      });

      if (bindingValue.value == null && _placeholder != null) {
        _dropdownValue = null;
        debugPrint('No binding value for dropdown -> will display placeholder');
      } else if (defaultValue != null) {
        _dropdownValue = _dropdownItems[indexFromValue(defaultValue)];
        debugPrint('No binding value for dropdown -> default value will be displayed');
      } else {
        _dropdownValue = _dropdownItems[indexFromValue(bindValue)];
        debugPrint('Binding value available for dropdown and will be displayed');
      }

      var borderSize = getStyle(Styles.borderSize, data: widget.data);
      var borderRadius = getStyle(Styles.cornerRadius, data: widget.data);
      var borderColor = getStyle(Styles.borderColor, data: widget.data, themeProperty: 'disabledColor');
      final Color color = getStyle(Styles.fontColor, data: widget.data, themeProperty: 'textColor');

      return SemanticsWrapperWidget(
        accessibility: widget.data.accessibility,
        child: Visibility(
          visible: isVisible(viewModel, widget.data.showIf),
          child: Opacity(
            opacity: getStyle(Styles.opacity, data: widget.data),
            child: Padding(
              padding: getStyle(Styles.margin, data: widget.data),
              child: Container(
                decoration: BoxDecoration(
                    color: getStyle(Styles.background, data: widget.data),
                    borderRadius: borderRadius == 0 ? null : BorderRadius.circular(borderRadius),
                    border: borderRadius >= 1
                        ? Border.all(color: borderColor, width: borderSize)
                        : Border(bottom: BorderSide(width: borderSize, color: borderColor))),
                child: NssCustomSizeWidget(
                  data: widget.data,
                  child: IgnorePointer(
                    ignoring: widget.data.disabled,
                    child: Padding(
                      padding: const EdgeInsets.symmetric(horizontal: 12),
                      child: DropdownButton<String>(
                        isExpanded: true,
                        underline: Container(),
                        style: TextStyle(
                            color: widget.data.disabled ? color.withOpacity(0.3) : color,
                            fontSize: getStyle(Styles.fontSize, data: widget.data),
                            fontWeight: getStyle(Styles.fontWeight, data: widget.data)),
                        hint: Text(
                          localizedStringFor(_placeholder) ?? '',
                          style: TextStyle(
                            color: widget.data.disabled
                                ? getStyle(Styles.placeholderColor, data: widget.data, themeProperty: 'disabledColor')
                                    .withOpacity(0.3)
                                : getStyle(Styles.placeholderColor, data: widget.data, themeProperty: 'textColor')
                                    .withOpacity(0.5),
                          ),
                        ),
                        dropdownColor: getStyle(Styles.background, data: widget.data),
                        value: _dropdownValue,
                        icon: Icon(
                          Icons.arrow_drop_down,
                          color: widget.data.disabled
                              ? getThemeColor('disabledColor').withOpacity(0.3)
                              : getStyle(Styles.borderColor, data: widget.data, themeProperty: 'primaryColor'),
                        ),
                        elevation: 4,
                        onChanged: (String newValue) {
                          if (widget.data.disabled) {
                            return;
                          }
                          setState(() {
                            var index = indexFromDisplayValue(newValue);
                            var updated = widget.data.options[index].value;

                            // Value needs to be parsed before form can be submitted.
                            if (widget.data.parseAs != null) {
                              // Markup parsing applies.
                              var parsed = parseAs(updated, widget.data.parseAs);
                              if (parsed == null) {
                                engineLogger.e('parseAs field is not compatible with provided input');
                              }
                              bindings.save<String>(widget.data.bind, parsed, saveAs: widget.data.sendAs);
                              return;
                            }
                            // If parseAs field is not available try to parse according to schema.
                            var parsed = parseUsingSchema(updated, widget.data.bind);
                            if (parsed == null) {
                              engineLogger.e('Schema type is not compatible with provided input');
                            }
                            bindings.save<String>(widget.data.bind, parsed, saveAs: widget.data.sendAs);
                          });
                        },
                        items: _dropdownItems.map<DropdownMenuItem<String>>((String value) {
                          TextAlign align = getStyle(Styles.textAlign, data: widget.data) ?? TextAlign.start;
                          return DropdownMenuItem<String>(
                            value: value,
                            child: Align(
                              alignment: align.toAlignment(widget.data.type),
                              child: Text(value,
                                  style: TextStyle(
                                    color: widget.data.disabled
                                        ? getThemeColor('disabledColor').withOpacity(0.3)
                                        : getStyle(Styles.fontColor, data: widget.data, themeProperty: 'textColor'),
                                    fontSize: getStyle(Styles.fontSize, data: widget.data),
                                    fontWeight: getStyle(Styles.fontWeight, data: widget.data),
                                  )),
                            ),
                          );
                        }).toList(),
                      ),
                    ),
                  ),
                ),
              ),
            ),
          ),
        ),
      );
    });
  }
}
