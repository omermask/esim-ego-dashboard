import 'package:flutter/material.dart';
import '../utils/error_message_style.dart';
import '../utils/translation.dart';

class ErrorMessage extends StatelessWidget {
  final String message;
  final TextStyle? style;
  final Color? bg;

  const ErrorMessage({
    super.key,
    required this.message,
    this.style,
    this.bg,
  });

  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;
    final errorStyle = ErrorMessageStyle(
      context: context,
      bg: bg,
      isDark: isDark,
    );

    return Container(
      padding: errorStyle.padding,
      decoration: BoxDecoration(
        color: errorStyle.backgroundColor,
      ),
      child: Text(
        trans(context, message),
        style: errorStyle.textStyle
            .copyWith(
              backgroundColor: Colors.transparent,
            )
            .merge(style),
        textAlign: errorStyle.textAlign,
      ),
    );
  }
}
