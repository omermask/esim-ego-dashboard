import 'package:flutter/material.dart';
import 'package:flutter_svg/flutter_svg.dart';

class VirtualCard extends StatelessWidget {
  /// البيانات القادمة من السيرفر (API)
  final String cardName; // اسم البطاقة (مثال: بطاقة دفع خارجية)
  final String backgroundImageUrl; // رابط صورة الخلفية
  final String? iconUrl; // رابط أيقونة البطاقة (ماستر كارد، فيزا، الخ)

  const VirtualCard({
    super.key,
    required this.cardName,
    required this.backgroundImageUrl,
    this.iconUrl,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      width: double.infinity,
      height: 200, // 🔒 الهيكل ثابت: ارتفاع البطاقة لن يتغير أبداً
      decoration: BoxDecoration(
        borderRadius: BorderRadius.circular(20), // 🔒 الهيكل ثابت: انحناء الزوايا
        // لون خلفية احتياطي في حال كان هناك تأخير في جلب الصورة من السيرفر
        color: Theme.of(context).colorScheme.surface, 
      ),
      // ClipRRect يجبر أي محتوى داخله على احترام انحناء الزوايا وعدم الخروج عنها
      child: ClipRRect(
        borderRadius: BorderRadius.circular(20),
        child: Stack(
          children: [
            // 1. صورة الخلفية (من السيرفر)
            Positioned.fill(
              child: Image.network(
                backgroundImageUrl,
                fit: BoxFit.cover, // يجبر الصورة على تعبئة المساحة بالكامل بدون تشوه
                errorBuilder: (context, error, stackTrace) {
                  // في حال فشل السيرفر في إرسال الصورة أو انقطع الإنترنت، يظهر لون بديل
                  return Container(
                    color: const Color(0xFF2A4543),
                  );
                },
              ),
            ),
            
            // 2. طبقة تظليل خفيفة جداً (اختيارية، لضمان أن النص الأبيض سيكون مقروءاً دائماً مهما كانت صورة السيرفر فاتحة)
            Positioned.fill(
              child: Container(
                color: Colors.black.withValues(alpha: 0.15),
              ),
            ),

            // 3. المحتويات (التي تطفو فوق الصورة)
            Padding(
              padding: const EdgeInsets.all(24), // 🔒 الهيكل ثابت: المسافة الداخلية
              child: Stack(
                children: [
                  // الاسم (من السيرفر) في أعلى اليسار
                  Align(
                    alignment: Alignment.topLeft,
                    child: Text(
                      cardName,
                      style: const TextStyle(
                        color: Colors.white,
                        fontSize: 18,
                        fontWeight: FontWeight.bold,
                        fontFamily: 'Inter',
                      ),
                    ),
                  ),
                  
                  // أيقونة الدفع عن بعد (ثابتة في التصميم) في أعلى اليمين
                  Align(
                    alignment: Alignment.topRight,
                    child: SvgPicture.asset(
                      'assets/icons/wifi_icon_242024.svg',
                      width: 28, height: 28,
                      colorFilter: const ColorFilter.mode(Colors.white, BlendMode.srcIn),
                    ),
                  ),
                  
                  // الأيقونة (من السيرفر) - مثلاً لوجو Visa أو Mastercard
                  if (iconUrl != null)
                    Align(
                      alignment: Alignment.centerRight, // أو أسفل اليمين حسب المكان الدقيق
                      child: Image.network(
                        iconUrl!,
                        height: 32, // 🔒 إجبار الأيقونة على حجم ثابت كي لا تكسر التصميم
                        fit: BoxFit.contain,
                        errorBuilder: (context, error, stackTrace) => const SizedBox(),
                      ),
                    ),

                  // رسم أيقونة الشريحة (Chip) بشكل ثابت في يسار الوسط
                  Align(
                    alignment: Alignment.centerLeft,
                    child: Container(
                      margin: const EdgeInsets.only(top: 20),
                      width: 40,
                      height: 30,
                      decoration: BoxDecoration(
                        border: Border.all(color: Colors.white.withValues(alpha: 0.5), width: 1.5),
                        borderRadius: BorderRadius.circular(6),
                      ),
                      child: Center(
                        child: Container(
                          width: 20,
                          height: 15,
                          decoration: BoxDecoration(
                            border: Border.all(color: Colors.white.withValues(alpha: 0.5), width: 1),
                            borderRadius: BorderRadius.circular(4),
                          ),
                        ),
                      ),
                    ),
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }
}
