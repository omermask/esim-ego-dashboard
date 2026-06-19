import 'package:flutter/material.dart';
import '../utils/bottom_button_style.dart';
import '../utils/responsive_size.dart';

class BottomButton extends StatelessWidget {
  final String no;
  final dynamic yes;
  final VoidCallback? onPress;
  final bool disable;

  const BottomButton({super.key, required this.no, required this.yes, this.onPress, this.disable = false});

  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;
    final style = BottomButtonStyle(context: context, isDark: isDark, disable: disable);

    return Container(
      padding: EdgeInsets.only(left: rs(context, 16), right: rs(context, 16), top: rs(context, 12), bottom: rs(context, 16)),
      decoration: BoxDecoration(
        color: isDark ? const Color(0xFF2A2A2C) : const Color(0xFFE2ECE6),
        borderRadius: BorderRadius.circular(rs(context, 16)),
        boxShadow: [BoxShadow(color: Colors.black.withValues(alpha: 0.06), blurRadius: 12, offset: const Offset(0, -2))],
      ),
      child: Row(children: [
        Expanded(
          child: GestureDetector(
            onTap: () => Navigator.of(context).pop(),
            child: Center(child: Text(no, style: style.cancelBtn, overflow: TextOverflow.ellipsis, maxLines: 1)),
          ),
        ),
        SizedBox(width: rs(context, 10)),
        Expanded(
          flex: 2,
          child: ElevatedButton(
            onPressed: disable ? null : onPress,
            style: ElevatedButton.styleFrom(
              backgroundColor: style.depositNowBtnBackgroundColor,
              foregroundColor: style.btnTextColor,
              elevation: 0,
              padding: EdgeInsets.zero,
              minimumSize: Size(0, rs(context, 40)),
              shape: RoundedRectangleBorder(borderRadius: style.depositNowBtnBorderRadius),
            ),
            child: yes is String
                ? Text(yes, style: TextStyle(fontFamily: 'Gilroy-Semibold', fontSize: style.cancelBtn.fontSize, color: style.btnTextColor), overflow: TextOverflow.ellipsis, maxLines: 1)
                : yes as Widget,
          ),
        ),
      ]),
    );
  }
}
