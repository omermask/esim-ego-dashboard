import 'package:flutter/material.dart';
import '../utils/responsive_size.dart';
import '../utils/button_outline_style.dart';
import 'ripple_button.dart';

class ButtonOutline extends StatelessWidget {
  final Widget? icon;
  final String? title;
  final VoidCallback? onPress;
  final bool disabled;
  final Color? bgColor;
  final Color? color;
  final Color? borderColor;
  final BoxDecoration? style;

  const ButtonOutline({
    super.key,
    this.icon,
    this.title,
    this.onPress,
    this.disabled = false,
    this.bgColor,
    this.color,
    this.borderColor,
    this.style,
  });

  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;
    final btnOutlineStyle = ButtonOutlineStyle(
      context: context,
      isDark: isDark,
      bgColor: bgColor,
      color: color,
      borderColor: borderColor,
      disabled: disabled,
      icon: icon,
      title: title,
    );

    Widget buttonWidget = RippleButton(
      style: btnOutlineStyle.btnOutlineCont,
      onTap: disabled ? null : onPress,
      children: Opacity(
        opacity: disabled ? 0.5 : 1.0,
        child: SizedBox(
          height: rs(context, 40),
          child: Row(
            mainAxisAlignment: MainAxisAlignment.center,
            crossAxisAlignment: CrossAxisAlignment.center,
            children: [
              ?icon,
              if (title != null)
                Padding(
                  padding: btnOutlineStyle.btnOutlineTextMargin,
                  child: Text(
                    title!,
                    style: btnOutlineStyle.btnOutlineText,
                  ),
                ),
            ],
          ),
        ),
      ),
    );

    return Container(
      width: double.infinity,
      decoration: style,
      child: style == null
          ? Padding(
              padding: btnOutlineStyle.btnOutlineContPadding,
              child: buttonWidget,
            )
          : buttonWidget,
    );
  }
}
