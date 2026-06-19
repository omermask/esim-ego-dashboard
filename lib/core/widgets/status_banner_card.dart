import 'package:flutter/material.dart';
import '../theme/app_colors_unified.dart'; // تأكد من مسار ملف الألوان

class StatusBannerCard extends StatelessWidget {
  final String title;
  final String description;
  final String expectedTime;
  final IconData topIcon;

  const StatusBannerCard({
    super.key,
    required this.title,
    required this.description,
    required this.expectedTime,
    required this.topIcon,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        color: AppColors.primaryMint, // اللون الأخضر المميز من ملف الألوان
        borderRadius: BorderRadius.circular(24), // انحناء كبير مطابق للفيديو
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // الأيقونة الدائرية في الأعلى
          Container(
            padding: const EdgeInsets.all(8),
            decoration: const BoxDecoration(
              color: Colors.white, // خلفية بيضاء للأيقونة
              shape: BoxShape.circle,
            ),
            child: Icon(topIcon, color: Colors.black87, size: 20),
          ),
          const SizedBox(height: 16),
          // العنوان
          Text(
            title,
            style: const TextStyle(
              color: Colors.white,
              fontSize: 20,
              fontWeight: FontWeight.bold,
              fontFamily: 'Inter',
            ),
          ),
          const SizedBox(height: 8),
          // الوصف
          Text(
            description,
            style: TextStyle(
              color: Colors.white.withValues(alpha: 0.9),
              fontSize: 14,
              fontFamily: 'Inter',
            ),
          ),
          const SizedBox(height: 16),
          // الخط الفاصل الخفيف
          Divider(color: Colors.white.withValues(alpha: 0.3), thickness: 1),
          const SizedBox(height: 12),
          // نقطة الوقت المتوقع
          Row(
            children: [
              Container(
                width: 6,
                height: 6,
                decoration: const BoxDecoration(
                  color: Colors.white,
                  shape: BoxShape.circle,
                ),
              ),
              const SizedBox(width: 8),
              Text(
                expectedTime,
                style: TextStyle(
                  color: Colors.white.withValues(alpha: 0.9),
                  fontSize: 12,
                  fontFamily: 'Inter',
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }
}
