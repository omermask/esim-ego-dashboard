import 'package:flutter/material.dart';
import 'package:flutter_svg/flutter_svg.dart';
import '../theme/app_theme_ext.dart';

class ScreenShell extends StatelessWidget {
  final String title;
  final Widget body;
  final List<Widget>? actions;
  final Widget? fab;
  final bool showBack;
  final double titleFontSize;
  final bool resizeToAvoidBottomInset;
  final GlobalKey<ScaffoldState>? scaffoldKey;
  final Widget? leading;
  final bool hideAppBar;
  final Widget? bottomNavigationBar;
  final bool embedded;

  const ScreenShell({
    super.key,
    required this.title,
    required this.body,
    this.actions,
    this.fab,
    this.showBack = true,
    this.titleFontSize = 17,
    this.resizeToAvoidBottomInset = false,
    this.scaffoldKey,
    this.leading,
    this.hideAppBar = false,
    this.bottomNavigationBar,
    this.embedded = false,
  });

  @override
  Widget build(BuildContext context) {
    final dc = context.dialogColors;
    final sc = context.screenColors;

    if (embedded) return body;

    return Scaffold(
      key: scaffoldKey,
      backgroundColor: sc.bg,
      resizeToAvoidBottomInset: resizeToAvoidBottomInset,
      appBar: hideAppBar ? null : AppBar(
        leading: leading ?? (showBack
            ? GestureDetector(
                onTap: () => Navigator.of(context).pop(),
                child: Padding(
                  padding: const EdgeInsets.all(12),
                  child: SvgPicture.asset(
                    'assets/icons/arrow_back_chevron_direction_left_navigation_right_icon_123223.svg',
                    width: 24, height: 24,
                    colorFilter: ColorFilter.mode(dc.textPrimary, BlendMode.srcIn),
                  ),
                ),
              )
            : null),
        title: Text(
          title,
          style: TextStyle(
            fontSize: titleFontSize,
            fontWeight: FontWeight.w600,
            color: dc.textPrimary,
          ),
        ),
        centerTitle: true,
        backgroundColor: Colors.transparent,
        elevation: 0,
        iconTheme: IconThemeData(color: dc.textPrimary),
        actions: [...?actions],
      ),
      floatingActionButton: fab,
      bottomNavigationBar: bottomNavigationBar,
      body: hideAppBar
          ? SafeArea(top: true, bottom: bottomNavigationBar == null, child: body)
          : body,
    );
  }
}
