import 'package:flutter/material.dart';
import '../utils/actions_card_style.dart';
import 'ripple_button.dart';

class ActionsCard extends StatelessWidget {
  final Color? bg;
  final Widget? icon;
  final String? text;
  final Color? textColor;
  final Color? borderColor;
  final bool last;
  final VoidCallback? onPress;
  final double? fixedWidth;

  const ActionsCard({
    super.key,
    this.bg,
    this.icon,
    this.text,
    this.textColor,
    this.borderColor,
    this.last = false,
    this.onPress,
    this.fixedWidth,
  });

  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;
    final style = ActionsCardStyle(
      context: context,
      isDark: isDark,
      bg: bg,
      textColor: textColor,
      borderColor: borderColor,
      last: last,
      fixedWidth: fixedWidth,
    );

    return Container(
      margin: style.containerMargin,
      decoration: style.container,
      child: RippleButton(
        style: style.card,
        onTap: onPress,
        children: Container(
          width: style.cardWidth,
          height: style.cardHeight,
          padding: style.cardPadding,
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            crossAxisAlignment: CrossAxisAlignment.center,
            mainAxisSize: MainAxisSize.min,
            children: [
              ?icon,
              if (text != null)
                Padding(
                  padding: style.textSMargin,
                  child: Text(
                    text!,
                    style: style.textS,
                    textAlign: TextAlign.center,
                    maxLines: 2,
                    overflow: TextOverflow.ellipsis,
                  ),
                ),
            ],
          ),
        ),
      ),
    );
  }
}

