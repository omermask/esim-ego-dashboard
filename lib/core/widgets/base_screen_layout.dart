import 'package:flutter/material.dart';
import 'package:flutter_svg/flutter_svg.dart';

class BaseScreenLayout extends StatelessWidget {
  /// محتوى الشاشة (عادة ما يكون SingleChildScrollView أو Column)
  final Widget body;
  
  /// عنوان الشاشة في البار العلوي (إذا كان null لن يظهر العنوان)
  final String? title;
  
  /// هل تريد إظهار البار العلوي؟ (اجعله false في شاشة الداشبورد)
  final bool showAppBar;
  
  /// أيقونات إضافية في الجهة المعاكسة لزر الرجوع (مثل زر التصفية أو الإشعارات)
  final List<Widget>? actions;
  
  /// شريط التنقل السفلي (إن وجد)
  final Widget? bottomNavigationBar;
  
  /// المسافات الجانبية للشاشة (افتراضياً 20 من اليمين واليسار)
  final EdgeInsetsGeometry? padding;
  
  /// لمنع الشاشة من الانضغاط عند ظهور الكيبورد (مفيدة في بعض الحالات)
  final bool resizeToAvoidBottomInset;

  const BaseScreenLayout({
    super.key,
    required this.body,
    this.title,
    this.showAppBar = true,
    this.actions,
    this.bottomNavigationBar,
    this.padding,
    this.resizeToAvoidBottomInset = true,
  });

  @override
  Widget build(BuildContext context) {
    // GestureDetector لإخفاء الكيبورد تلقائياً عند النقر في أي مكان فارغ بالشاشة
    return GestureDetector(
      onTap: () => FocusScope.of(context).unfocus(),
      child: Scaffold(
        // لون الخلفية يأتي تلقائياً من الثيم (Dark أو Light)
        backgroundColor: Theme.of(context).scaffoldBackgroundColor,
        resizeToAvoidBottomInset: resizeToAvoidBottomInset,
        
        // بناء البار العلوي بذكاء
        appBar: showAppBar
            ? AppBar(
                title: title != null ? Text(title!) : null,
                // استدعاء زر الرجوع المخصص (المربع ذو الحواف الدائرية)
                leading: _buildCustomBackButton(context),
                actions: actions,
                // مسافة بسيطة لزر الرجوع لكي لا يلتصق بحافة الشاشة تماماً
                leadingWidth: 64, 
              )
            : null,
            
        // المنطقة الآمنة لكي لا يتداخل المحتوى مع كاميرا الهاتف أو شريط السحب السفلي
        body: SafeArea(
          child: Padding(
            padding: padding ?? const EdgeInsets.symmetric(horizontal: 20.0),
            child: body,
          ),
        ),
        
        bottomNavigationBar: bottomNavigationBar,
      ),
    );
  }

  /// هندسة زر الرجوع المخصص ليطابق التصميم 1,000,000%
  Widget? _buildCustomBackButton(BuildContext context) {
    // التأكد أولاً أن الشاشة يمكن الرجوع منها (ليست الشاشة الأولى في الـ Stack)
    final ModalRoute<dynamic>? parentRoute = ModalRoute.of(context);
    final bool canPop = parentRoute?.canPop ?? false;

    if (!canPop) return null;

    return Padding(
      padding: const EdgeInsets.only(right: 20.0, top: 8.0, bottom: 8.0), // محاذاة دقيقة لـ RTL
      child: InkWell(
        borderRadius: BorderRadius.circular(12),
        onTap: () => Navigator.of(context).pop(),
        child: Container(
          decoration: BoxDecoration(
            color: Theme.of(context).colorScheme.surface, // لون الكارت (يتغير بين الفاتح والداكن)
            borderRadius: BorderRadius.circular(12), // انحناء المربع
            border: Border.all(
              color: Theme.of(context).dividerTheme.color ?? Colors.grey.withValues(alpha: 0.2),
              width: 0.5, // تحديد خفيف جداً يطابق التصميم
            ),
          ),
          child: Transform(
            alignment: Alignment.center,
            transform: Directionality.of(context) == TextDirection.rtl
                ? (Matrix4.identity()..setEntry(0, 0, -1.0))
                : Matrix4.identity(),
            child: SvgPicture.asset(
              'assets/images/arrow_left_icon.svg',
              width: 22,
              height: 22,
              colorFilter: ColorFilter.mode(
                Theme.of(context).colorScheme.onSurface,
                BlendMode.srcIn,
              ),
            ),
          ),
        ),
      ),
    );
  }
}
