import 'package:flutter/material.dart';
import '../utils/card_button_style.dart';
import 'ripple_button.dart';

class CardButton extends StatelessWidget {
  final VoidCallback? onPress;
  final bool disabled;
  final String? title;
  final Widget? rightIcon;
  final Color? textColor;

  const CardButton({
    super.key,
    this.onPress,
    this.disabled = false,
    this.title,
    this.rightIcon,
    this.textColor,
  });

  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;
    final opnSheetBtnStyle = CardButtonStyle(
      context: context,
      isDark: isDark,
      textColor: textColor,
    );

    return RippleButton(
        onTap: disabled ? null : onPress,
        children: Opacity(
          opacity: disabled ? 0.5 : 1.0,
          child: Row(
          crossAxisAlignment: CrossAxisAlignment.center,
          children: [
            if (title != null)
              Padding(
                padding: opnSheetBtnStyle.titleMargin,
                child: Text(
                  title!,
                  style: opnSheetBtnStyle.title,
                ),
              ),
            ?rightIcon,
          ],
        ),
      ),
    );
  }
}
