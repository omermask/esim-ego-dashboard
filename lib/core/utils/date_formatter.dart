import 'package:intl/intl.dart';

class DateFormatter {
  // نضيف متغير لنوع اللغة ليكون التطبيق مرناً
  static String formatDate(DateTime date, {String locale = 'ar_IQ'}) { // الافتراضي عربي عراقي
    return DateFormat('dd MMM yyyy', locale).format(date);
  }

  static String formatDateShort(DateTime date, {String locale = 'ar_IQ'}) {
    return DateFormat('dd/MM/yyyy', locale).format(date);
  }

  // التنسيق الذي رأيناه في فيديوهاتك (التاريخ) يحتاج لدقة
  static String formatRelativeTime(DateTime date, {String locale = 'ar_IQ'}) {
    final difference = DateTime.now().difference(date);
    
    // يمكنك استخدام حزمة مثل 'timeago' لتوفير كود أنظف وأدعم للغات
    if (difference.inSeconds < 60) return 'الآن';
    if (difference.inMinutes < 60) return '${difference.inMinutes} دقيقة مضت';
    if (difference.inHours < 24) return '${difference.inHours} ساعة مضت';
    if (difference.inDays == 1) return 'أمس';
    if (difference.inDays < 7) return '${difference.inDays} أيام مضت';
    
    return formatDate(date, locale: locale);
  }
}
