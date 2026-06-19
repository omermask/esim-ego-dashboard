import 'package:flutter/material.dart';
import 'package:flutter_svg/flutter_svg.dart';
import '../utils/translation.dart';

class LanguageSelectionDialog extends StatefulWidget {
  final String initialCode;

  const LanguageSelectionDialog({super.key, this.initialCode = 'ar'});

  @override
  State<LanguageSelectionDialog> createState() =>
      _LanguageSelectionDialogState();
}

class _LanguageSelectionDialogState extends State<LanguageSelectionDialog> {
  late String _selectedCode;

  @override
  void initState() {
    super.initState();
    _selectedCode = widget.initialCode;
  }

  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;
    final bg = isDark ? const Color(0xFF2A2A2C) : const Color(0xFFE2ECE6);
    final accent = isDark ? const Color(0xFFFFB28B) : const Color(0xFFED6A46);
    final iconBox = isDark ? const Color(0xFF333333) : const Color(0xFFD0DDD6);
    final textPrimary = isDark ? Colors.white : const Color(0xFF111111);

    final primaryBtn = isDark ? const Color(0xFFA5CDBF) : const Color(0xFF185A46);
    final inputField = isDark ? const Color(0xFF383838) : const Color(0xFFD0DDD6);
    final borderColor = isDark ? const Color(0xFF3F3F46) : const Color(0xFFB6C6BC);
    final selectionBtn = isDark ? const Color(0xFFA5CDBF) : const Color(0xFF185A46);

    return Container(
      padding: const EdgeInsets.all(24),
      decoration: BoxDecoration(
        color: bg,
        borderRadius: BorderRadius.circular(24),
      ),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          Container(
            width: 48,
            height: 48,
            decoration: BoxDecoration(
              shape: BoxShape.circle,
              color: iconBox,
            ),
            child: SvgPicture.asset(
              'assets/icons/language_121815.svg',
              width: 24, height: 24,
              colorFilter: ColorFilter.mode(accent, BlendMode.srcIn),
            ),
          ),
          const SizedBox(height: 16),
          Text(
            trans(context, 'App Language'),
            style: TextStyle(
              fontSize: 18,
              fontWeight: FontWeight.w700,
              color: textPrimary,
            ),
            textAlign: TextAlign.center,
          ),
          const SizedBox(height: 24),
          _LanguageOptionTile(
            label: '\u0627\u0644\u0639\u0631\u0628\u064a\u0629',
            isSelected: _selectedCode == 'ar',
            onTap: () => setState(() => _selectedCode = 'ar'),
            textPrimary: textPrimary,
            inputField: inputField,
            borderColor: borderColor,
            selectionBtn: selectionBtn,
          ),
          const SizedBox(height: 20),
          _LanguageOptionTile(
            label: 'English',
            isSelected: _selectedCode == 'en',
            onTap: () => setState(() => _selectedCode = 'en'),
            textPrimary: textPrimary,
            inputField: inputField,
            borderColor: borderColor,
            selectionBtn: selectionBtn,
          ),
          const SizedBox(height: 24),
          SizedBox(
            width: double.infinity,
            height: 48,
            child: ElevatedButton(
              onPressed: () => Navigator.pop(context, _selectedCode),
              style: ElevatedButton.styleFrom(
                backgroundColor: primaryBtn,
                foregroundColor: Colors.white,
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(20),
                ),
                elevation: 0,
              ),
              child: Text(
                trans(context, 'Confirm'),
                style: const TextStyle(
                  fontSize: 16,
                  fontWeight: FontWeight.w600,
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }
}

class _LanguageOptionTile extends StatelessWidget {
  final String label;
  final bool isSelected;
  final VoidCallback onTap;
  final Color textPrimary;
  final Color inputField;
  final Color borderColor;
  final Color selectionBtn;

  const _LanguageOptionTile({
    required this.label,
    required this.isSelected,
    required this.onTap,
    required this.textPrimary,
    required this.inputField,
    required this.borderColor,
    required this.selectionBtn,
  });

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: onTap,
      child: Container(
        padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 14),
        decoration: BoxDecoration(
          color: inputField,
          borderRadius: BorderRadius.circular(16),
        ),
        child: Row(
          textDirection: TextDirection.ltr,
          children: [
            Container(
              width: 22,
              height: 22,
              decoration: BoxDecoration(
                shape: BoxShape.circle,
                color: isSelected ? selectionBtn : Colors.transparent,
                border: isSelected
                    ? null
                    : Border.all(
                        color: borderColor,
                        width: 1.5,
                      ),
              ),
              child: isSelected
                  ? Center(
                      child: SvgPicture.asset(
                        'assets/icons/tick_circle_icon_241974.svg',
                        width: 14, height: 14,
                        colorFilter: const ColorFilter.mode(Colors.white, BlendMode.srcIn),
                      ),
                    )
                  : null,
            ),
            const SizedBox(width: 12),
            Expanded(
              child: Text(
                label,
                style: TextStyle(
                  fontSize: 16,
                  fontWeight: FontWeight.w500,
                  color: textPrimary,
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
