import 'package:flutter/material.dart';
import 'package:flutter_svg/flutter_svg.dart';
import '../utils/bottom_info_style.dart';
import '../utils/toaster.dart';
import '../utils/translation.dart';
import '../utils/responsive_size.dart';
import '../utils/clipboard_utils.dart';
import '../theme/app_colors.dart';

class BottomInfo extends StatefulWidget {
  final String title;
  final String text;
  final bool copy;
  final bool last;
  final String email;
  final Color? statusColor;
  final bool note;

  const BottomInfo({
    super.key,
    this.title = '',
    this.text = '',
    this.copy = false,
    this.last = false,
    this.email = '',
    this.statusColor,
    this.note = false,
  });

  @override
  State<BottomInfo> createState() => _BottomInfoState();
}

class _BottomInfoState extends State<BottomInfo> {
  double? _layoutWidth;

  void _copyToClipboard(String text) {
    secureCopy(context, text);
    handleToaster(
      context,
      trans(context, 'copiedToClipboard'),
      'copied',
    );
  }

  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;
    final style = BottomInfoStyle(
      context: context,
      isDark: isDark,
      success: widget.statusColor,
      note: widget.note,
      layout: _layoutWidth,
      text: widget.text,
      last: widget.last,
      copy: widget.copy,
    );

    final titleStyle = BottomInfoStyle(
      context: context,
      isDark: isDark,
      success: widget.statusColor,
      note: widget.note,
      layout: _layoutWidth != null ? _layoutWidth! * 0.5 - rs(context, 25) : null,
      text: widget.text,
      last: widget.last,
      copy: widget.copy,
    );

    final textContParentStyle = BottomInfoStyle(
      context: context,
      isDark: isDark,
      success: widget.statusColor,
      note: widget.note,
      layout: _layoutWidth != null ? _layoutWidth! * 0.5 : null,
      text: widget.text,
      last: widget.last,
      copy: widget.copy,
    );

    return LayoutBuilder(
      builder: (context, constraints) {
        if (_layoutWidth == null && constraints.maxWidth > 0) {
          WidgetsBinding.instance.addPostFrameCallback((_) {
            if (mounted) {
              setState(() {
                _layoutWidth = constraints.maxWidth;
              });
            }
          });
        }

        return Container(
          padding: style.infoCont,
          decoration: style.infoContBorder,
          child: Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              if (widget.title.isNotEmpty)
                Flexible(
                  flex: 2,
                  child: SizedBox(
                    width: titleStyle.titleWidth,
                    child: Text(
                      widget.title,
                      style: titleStyle.title,
                    ),
                  ),
                ),
              Expanded(
                flex: 3,
                child: SizedBox(
                  width: textContParentStyle.textContParentWidth,
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.end,
                    children: [
                      if (widget.text.isNotEmpty)
                        widget.copy
                            ? GestureDetector(
                                behavior: HitTestBehavior.opaque,
                                onTap: () => _copyToClipboard(widget.text),
                                child: Row(
                                  mainAxisAlignment: MainAxisAlignment.end,
                                  crossAxisAlignment: CrossAxisAlignment.center,
                                  mainAxisSize: MainAxisSize.min,
                                  children: [
                                    SvgPicture.asset(
                                      'assets/icons/copy.svg',
                                      width: rs(context, 16),
                                      height: rs(context, 16),
                                      colorFilter: ColorFilter.mode(
                                        isDark ? AppColorsDark.copyPrimary : AppColors.copyPrimary,
                                        BlendMode.srcIn,
                                      ),
                                    ),
                                    Flexible(
                                      child: Padding(
                                        padding: style.textMargin,
                                        child: Text(
                                          widget.text,
                                          style: style.textStyle,
                                          textAlign: TextAlign.right,
                                          overflow: TextOverflow.ellipsis,
                                          maxLines: 2,
                                        ),
                                      ),
                                    ),
                                  ],
                                ),
                              )
                            : Row(
                                mainAxisAlignment: MainAxisAlignment.end,
                                crossAxisAlignment: CrossAxisAlignment.center,
                                children: [
                                  if (widget.copy)
                                    SvgPicture.asset(
                                      'assets/icons/copy.svg',
                                      width: rs(context, 14),
                                      height: rs(context, 14),
                                      colorFilter: ColorFilter.mode(
                                        isDark ? AppColorsDark.copyPrimary : AppColors.copyPrimary,
                                        BlendMode.srcIn,
                                      ),
                                    ),
                                  Padding(
                                    padding: style.textMargin,
                                    child: Text(
                                      widget.text,
                                      style: style.textStyle,
                                      textAlign: TextAlign.right,
                                    ),
                                  ),
                                ],
                              ),
                      if (widget.email.isNotEmpty)
                        Padding(
                          padding: style.emailTextPadding,
                          child: Text(
                            widget.email,
                            style: style.emailText,
                            textAlign: TextAlign.right,
                          ),
                        ),
                    ],
                  ),
                ),
              ),
            ],
          ),
        );
      },
    );
  }
}

