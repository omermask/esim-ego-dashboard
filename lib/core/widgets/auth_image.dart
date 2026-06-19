import 'package:flutter/material.dart';
import 'package:flutter_svg/flutter_svg.dart';
import '../theme/app_colors.dart';

class AuthImage extends StatelessWidget {
  final String imageUrl;
  final double? width;
  final double? height;
  final BoxFit fit;
  final BorderRadius? borderRadius;
  final Widget? placeholder;
  final Widget? errorWidget;
  final String? cacheKey;

  const AuthImage({
    super.key,
    required this.imageUrl,
    this.width,
    this.height,
    this.fit = BoxFit.cover,
    this.borderRadius,
    this.placeholder,
    this.errorWidget,
    this.cacheKey,
  });

  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;

    return ClipRRect(
      borderRadius: borderRadius ?? BorderRadius.zero,
      child: imageUrl.endsWith('.svg')
          ? _buildSvgImage(isDark)
          : _buildNetworkImage(isDark),
    );
  }

  Widget _buildNetworkImage(bool isDark) {
    return Image.network(
      imageUrl,
      width: width,
      height: height,
      fit: fit,
      loadingBuilder: (context, child, loadingProgress) {
        if (loadingProgress == null) return child;
        return _defaultPlaceholder(isDark);
      },
      errorBuilder: (context, error, stackTrace) =>
          errorWidget ?? _defaultError(isDark),
    );
  }

  Widget _buildSvgImage(bool isDark) {
    return SvgPicture.network(
      imageUrl,
      width: width,
      height: height,
      fit: fit,
      placeholderBuilder: (context) =>
          placeholder ?? _defaultPlaceholder(isDark),
      errorBuilder: (context, error, stackTrace) =>
          errorWidget ?? _defaultError(isDark),
    );
  }

  Widget _defaultPlaceholder(bool isDark) {
    return Container(
      width: width,
      height: height,
      color: isDark ? AppColorsDark.bgSecondary : AppColors.bgSecondary,
      child: const Center(
        child: CircularProgressIndicator(
          strokeWidth: 2,
          valueColor: AlwaysStoppedAnimation<Color>(AppColors.cornflowerBlue),
        ),
      ),
    );
  }

  Widget _defaultError(bool isDark) {
    return Container(
      width: width,
      height: height,
      color: isDark ? AppColorsDark.bgSecondary : AppColors.bgSecondary,
      child: Center(
        child: SvgPicture.asset(
          'assets/icons/image_icon_184009.svg',
          width: 24, height: 24,
          colorFilter: ColorFilter.mode(
            isDark ? AppColorsDark.textSecondary : AppColors.textSecondary,
            BlendMode.srcIn,
          ),
        ),
      ),
    );
  }
}
