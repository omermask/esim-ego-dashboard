import 'package:flutter/material.dart';
import '../utils/custom_document_picker_style.dart';

class CustomDocumentPicker extends StatefulWidget {
  final String? label;
  final BoxDecoration? style;
  final VoidCallback? onPress;
  final Widget? icon;
  final dynamic value;
  final String? title;
  final String? error;
  final bool isError;
  final String? info;

  const CustomDocumentPicker({
    super.key,
    this.label,
    this.style,
    this.onPress,
    this.icon,
    this.value,
    this.title,
    this.error,
    this.isError = false,
    this.info,
  });

  @override
  State<CustomDocumentPicker> createState() => _CustomDocumentPickerState();
}

class _CustomDocumentPickerState extends State<CustomDocumentPicker> {
  double? _layoutWidth;

  String _formatFileName(String fileName) {
    if (fileName.length > 30) {
      final parts = fileName.split('.');
      if (parts.length > 1) {
        final name = parts[0];
        final extension = parts.last;
        final truncatedName =
            name.length > 12 ? '${name.substring(0, 12)}...' : name;
        return '$truncatedName.$extension';
      }
    }
    return fileName;
  }

  String _getDisplayText() {
    if (widget.value != null) {
      if (widget.value is List) {
        final list = widget.value as List;
        if (list.isNotEmpty) {
          final fileNames = list.map((item) {
            if (item is Map && item.containsKey('name')) {
              return _formatFileName(item['name'].toString());
            } else if (item is String) {
              return _formatFileName(item);
            }
            return item.toString();
          }).join(', ');
          return fileNames;
        }
      } else if (widget.value is String) {
        return _formatFileName(widget.value);
      }
    }
    return widget.title ?? '';
  }

  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;

    final documentPickerStyle = CustomDocumentPickerStyle(
      context: context,
      isDark: isDark,
      value: widget.value,
      isError: widget.isError,
      layoutWidth: _layoutWidth,
    );

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        if (widget.label != null && widget.label!.isNotEmpty)
          Container(
            margin: documentPickerStyle.labelMargin,
            child: Text(
              widget.label!,
              style: TextStyle(
                fontFamily: 'Gilroy-Semibold',
                fontSize: documentPickerStyle.labelFontSize,
                height: documentPickerStyle.labelLineHeight /
                    documentPickerStyle.labelFontSize,
                color: documentPickerStyle.labelColor,
              ),
            ),
          ),
        GestureDetector(
          onTap: widget.onPress,
          child: LayoutBuilder(
            builder: (context, constraints) {
              if (_layoutWidth == null) {
                WidgetsBinding.instance.addPostFrameCallback((_) {
                  if (mounted) {
                    setState(() {
                      _layoutWidth = constraints.maxWidth;
                    });
                  }
                });
              }

              return Container(
                height: documentPickerStyle.documentPickerContHeight,
                decoration: (widget.style ??
                        BoxDecoration(
                          border: Border.all(
                            color: documentPickerStyle
                                .documentPickerContBorderColor,
                            width: documentPickerStyle
                                .documentPickerContBorderWidth,
                          ),
                          color: documentPickerStyle
                              .documentPickerContBackgroundColor,
                          borderRadius: BorderRadius.circular(
                              documentPickerStyle
                                  .documentPickerContBorderRadius),
                        ))
                    .copyWith(
                  border: Border.all(
                    color: documentPickerStyle.documentPickerContBorderColor,
                    width: documentPickerStyle.documentPickerContBorderWidth,
                  ),
                  color: documentPickerStyle.documentPickerContBackgroundColor,
                  borderRadius: BorderRadius.circular(
                      documentPickerStyle.documentPickerContBorderRadius),
                ),
                padding: documentPickerStyle.documentPickerContPadding,
                child: Row(
                  children: [
                    if (widget.icon != null) widget.icon!,
                    if (widget.icon != null)
                      Container(
                        height: documentPickerStyle.verticalLineHeight,
                        width: documentPickerStyle.verticalLineWidth,
                        margin: documentPickerStyle.verticalLineMargin,
                        color: documentPickerStyle.verticalLineBackgroundColor,
                      ),
                    Expanded(
                      child: Text(
                        _getDisplayText(),
                        style: TextStyle(
                          color: documentPickerStyle.documentPickerTextColor,
                          fontFamily: 'Gilroy-Semibold',
                          fontSize:
                              documentPickerStyle.documentPickerTextFontSize,
                        ),
                        maxLines: 1,
                        overflow: TextOverflow.ellipsis,
                      ),
                    ),
                  ],
                ),
              );
            },
          ),
        ),
        if (widget.error != null && widget.error!.trim().isNotEmpty)
          Container(
            margin: documentPickerStyle.errorMargin,
            width: documentPickerStyle.errorWidth,
            child: Text(
              widget.error!.trim(),
              style: TextStyle(
                color: documentPickerStyle.errorColor,
                fontFamily: 'Gilroy-Medium',
                fontSize: documentPickerStyle.errorFontSize,
                height: documentPickerStyle.errorLineHeight /
                    documentPickerStyle.errorFontSize,
              ),
            ),
          ),
        if (widget.info != null &&
            widget.info!.trim().isNotEmpty &&
            (widget.error == null || widget.error!.trim().isEmpty))
          Container(
            margin: documentPickerStyle.infoMargin,
            width: documentPickerStyle.infoWidth,
            child: Text(
              widget.info!.trim(),
              style: TextStyle(
                color: documentPickerStyle.infoColor,
                fontFamily: 'Gilroy-Medium',
                fontSize: documentPickerStyle.infoFontSize,
                height: documentPickerStyle.infoLineHeight /
                    documentPickerStyle.infoFontSize,
              ),
            ),
          ),
      ],
    );
  }
}
