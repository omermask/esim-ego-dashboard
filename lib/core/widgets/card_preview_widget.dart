import 'package:flutter/material.dart';
import 'dart:io';
import '../utils/responsive_size.dart';
import '../theme/app_colors.dart';
import '../../core/core/app_config.dart';

class CardPreviewWidget extends StatelessWidget {
  final String? backgroundImageUrl;
  final File? backgroundImageFile;
  final String companyName;
  final String cardNumber;
  final String cardHolderName;
  final String expiryDate;
  final String cvv;
  final Color? textColor;
  final Color? companyNameColor;
  final Map<String, dynamic>? designSettings;
  final bool? showCardNumbers;

  const CardPreviewWidget({
    super.key,
    this.backgroundImageUrl,
    this.backgroundImageFile,
    this.companyName = 'Company Name',
    this.cardNumber = '1234 5678 9012 3456',
    this.cardHolderName = 'CARD HOLDER',
    this.expiryDate = '12/25',
    this.cvv = '123',
    this.textColor,
    this.companyNameColor,
    this.designSettings,
    this.showCardNumbers,
  });

  @override
  Widget build(BuildContext context) {
    final defaultTextColor = textColor ?? AppColors.white;
    final defaultCompanyColor = companyNameColor ?? AppColors.white;
    final shouldShowCardNumbers =
        showCardNumbers ?? designSettings?['show_card_numbers'] ?? true;

    return Container(
      width: double.infinity,
      height: rs(context, 220),
      decoration: BoxDecoration(
        borderRadius: BorderRadius.circular(rs(context, 16)),
        border: Border.all(
          color: AppColors.borderPrimary.withValues(alpha: 0.3),
          width: 1,
        ),
      ),
      child: ClipRRect(
        borderRadius: BorderRadius.circular(rs(context, 16)),
        child: Stack(
          children: [
            if (backgroundImageFile != null)
              Image.file(
                backgroundImageFile!,
                width: double.infinity,
                height: double.infinity,
                fit: BoxFit.cover,
              )
            else if (backgroundImageUrl != null)
              Image.network(
                '${AppConfig.baseUrl}$backgroundImageUrl',
                width: double.infinity,
                height: double.infinity,
                fit: BoxFit.cover,
                errorBuilder: (context, error, stackTrace) {
                  return _buildDefaultBackground();
                },
                loadingBuilder: (context, child, loadingProgress) {
                  if (loadingProgress == null) return child;
                  return _buildDefaultBackground();
                },
              )
            else
              _buildDefaultBackground(),

            Container(
              decoration: BoxDecoration(
                gradient: LinearGradient(
                  begin: Alignment.topCenter,
                  end: Alignment.bottomCenter,
                  colors: [
                    Colors.black.withValues(alpha: 0.2),
                    Colors.black.withValues(alpha: 0.05),
                  ],
                ),
              ),
            ),

            Padding(
              padding: EdgeInsets.all(rs(context, 20)),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Align(
                    alignment: Alignment.topLeft,
                    child: Text(
                      companyName,
                      style: TextStyle(
                        fontFamily: 'Gilroy-Bold',
                        fontSize: rs(context, 18),
                        color: defaultCompanyColor,
                      ),
                    ),
                  ),
                  const Spacer(),
                  Center(
                    child: Text(
                      shouldShowCardNumbers
                          ? _formatCardNumber(cardNumber)
                          : '•••• •••• •••• ••••',
                      style: TextStyle(
                        fontFamily: 'Gilroy-Bold',
                        fontSize: rs(context, 20),
                        color: defaultTextColor,
                        letterSpacing: 3,
                      ),
                    ),
                  ),
                  SizedBox(height: rs(context, 16)),
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    crossAxisAlignment: CrossAxisAlignment.end,
                    children: [
                      Expanded(
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Text(
                              'CARD HOLDER',
                              style: TextStyle(
                                fontFamily: 'Gilroy-Medium',
                                fontSize: rs(context, 9),
                                color: defaultTextColor.withValues(alpha: 0.7),
                                letterSpacing: 1,
                              ),
                            ),
                            SizedBox(height: rs(context, 4)),
                            Text(
                              cardHolderName,
                              style: TextStyle(
                                fontFamily: 'Gilroy-Bold',
                                fontSize: rs(context, 14),
                                color: defaultTextColor,
                                letterSpacing: 1,
                              ),
                            ),
                          ],
                        ),
                      ),
                      SizedBox(width: rs(context, 16)),
                      Column(
                        crossAxisAlignment: CrossAxisAlignment.end,
                        children: [
                          Text(
                            'EXPIRES',
                            style: TextStyle(
                              fontFamily: 'Gilroy-Medium',
                              fontSize: rs(context, 9),
                              color: defaultTextColor.withValues(alpha: 0.7),
                              letterSpacing: 1,
                            ),
                          ),
                          SizedBox(height: rs(context, 4)),
                          Text(
                            expiryDate,
                            style: TextStyle(
                              fontFamily: 'Gilroy-Bold',
                              fontSize: rs(context, 14),
                              color: defaultTextColor,
                              letterSpacing: 1,
                            ),
                          ),
                        ],
                      ),
                    ],
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildDefaultBackground() {
    return Container(
      decoration: BoxDecoration(
        gradient: LinearGradient(
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
          colors: [
            AppColors.cornflowerBlue,
            AppColors.cornflowerBlue.withValues(alpha: 0.7),
          ],
        ),
      ),
    );
  }

  String _formatCardNumber(String number) {
    final cleaned = number.replaceAll(' ', '');
    final buffer = StringBuffer();
    for (int i = 0; i < cleaned.length; i++) {
      if (i > 0 && i % 4 == 0) {
        buffer.write(' ');
      }
      buffer.write(cleaned[i]);
    }
    return buffer.toString();
  }
}
