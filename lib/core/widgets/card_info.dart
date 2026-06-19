import 'package:flutter/material.dart';
import 'package:flutter_svg/flutter_svg.dart';
import '../utils/card_info_style.dart';
import '../utils/toaster.dart';
import '../utils/translation.dart';
import '../utils/responsive_size.dart';
import '../utils/clipboard_utils.dart';
import '../theme/app_colors.dart';

class CardInfo extends StatefulWidget {
  final String title;
  final String text;
  final bool copy;
  final bool last;
  final Color? statusColor;
  final double? paddingH;

  const CardInfo({
    super.key,
    this.title = '',
    this.text = '',
    this.copy = false,
    this.last = false,
    this.statusColor,
    this.paddingH,
  });

  @override
  State<CardInfo> createState() => _CardInfoState();
}

class _CardInfoState extends State<CardInfo> {
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
    final style = CardInfoStyle(
      context: context,
      isDark: isDark,
      successColor: widget.statusColor,
      paddingH: widget.paddingH,
      layout: _layoutWidth,
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
            crossAxisAlignment: CrossAxisAlignment.center,
            children: [
              if (widget.title.isNotEmpty)
                Flexible(
                  flex: 2,
                  child: Text(
                    widget.title,
                    maxLines: 1,
                    overflow: TextOverflow.ellipsis,
                    style: style.title,
                  ),
                ),
              if (widget.copy)
                Expanded(
                  flex: 3,
                  child: GestureDetector(
                    behavior: HitTestBehavior.opaque,
                    onTap: () => _copyToClipboard(widget.text),
                    child: Row(
                      mainAxisAlignment: MainAxisAlignment.end,
                      crossAxisAlignment: CrossAxisAlignment.center,
                      children: [
                        SvgPicture.asset(
                          'assets/icons/copy.svg',
                          width: rs(context, 14),
                          height: rs(context, 14),
                          colorFilter: ColorFilter.mode(
                            isDark
                                ? AppColorsDark.textOctonaryVariant
                                : AppColors.textOctonaryVariant,
                            BlendMode.srcIn,
                          ),
                        ),
                        Flexible(
                          child: Padding(
                            padding: style.textMargin,
                            child: Text(
                              widget.text,
                              style: style.text,
                              textAlign: TextAlign.right,
                              maxLines: 1,
                              overflow: TextOverflow.ellipsis,
                            ),
                          ),
                        ),
                      ],
                    ),
                  ),
                )
              else
                Expanded(
                  flex: 3,
                  child: Row(
                    mainAxisAlignment: MainAxisAlignment.end,
                    crossAxisAlignment: CrossAxisAlignment.center,
                    children: [
                      Flexible(
                        child: Text(
                          widget.text,
                          style: style.text,
                          textAlign: TextAlign.right,
                          maxLines: 1,
                          overflow: TextOverflow.ellipsis,
                        ),
                      ),
                    ],
                  ),
                ),
            ],
          ),
        );
      },
    );
  }
}
