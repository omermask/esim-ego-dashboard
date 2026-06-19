import 'package:flutter/material.dart';

/// Widget wrapper لإخفاء الكيبورد عند الضغط خارج حقل الكتابة
/// وتحسين سرعة فتح وإغلاق الكيبورد
class KeyboardDismissWrapper extends StatelessWidget {
  final Widget child;
  final bool behavior;

  const KeyboardDismissWrapper({
    super.key,
    required this.child,
    this.behavior = true,
  });

  @override
  Widget build(BuildContext context) {
    if (!behavior) return child;

    return GestureDetector(
      // إخفاء الكيبورد عند الضغط في أي مكان خارج حقل الكتابة
      onTap: () {
        // استخدام unfocus مباشرة لسرعة أكبر - لا حاجة للتحقق من الحالة
        FocusScope.of(context).unfocus();
      },
      // السماح للأطفال بالتفاعل مع اللمس
      // استخدام translucent بدلاً من opaque لتحسين الأداء
      behavior: HitTestBehavior.translucent,
      child: child,
    );
  }
}

