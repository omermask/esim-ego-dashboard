import 'dart:io' show Platform;
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'core/theme/app_theme.dart';
import 'data/services/api_service.dart';
import 'data/providers/theme_provider.dart';
import 'data/providers/locale_provider.dart';
import 'data/providers/auth_provider.dart';
import 'data/providers/plans_provider.dart';
import 'data/providers/dashboard_provider.dart';
import 'data/providers/analytics_provider.dart';
import 'data/providers/settings_provider.dart';
import 'data/providers/exchange_rate_provider.dart';
import 'data/providers/orders_provider.dart';
import 'data/providers/payments_provider.dart';
import 'data/providers/users_provider.dart';
import 'data/providers/support_provider.dart';
import 'data/providers/coupon_provider.dart';
import 'data/providers/tax_rate_provider.dart';
import 'data/providers/refund_provider.dart';
import 'data/providers/freeze_provider.dart';
import 'data/providers/inventory_provider.dart';
import 'data/providers/referral_provider.dart';
import 'data/providers/report_provider.dart';
import 'data/providers/backup_provider.dart';
import 'data/providers/audit_log_provider.dart';
import 'data/providers/twofa_provider.dart';
import 'screens/login/phone_entry_screen.dart';
import 'screens/dashboard/dashboard_screen.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();
  final api = ApiService();
  await api.init();
  ApiException.locale = Platform.localeName.split('_').first;
  runApp(ESIMAdminApp(api: api));
}

class ESIMAdminApp extends StatelessWidget {
  final ApiService api;
  const ESIMAdminApp({super.key, required this.api});

  @override
  Widget build(BuildContext context) {
    return MultiProvider(
      providers: [
        Provider<ApiService>.value(value: api),
        ChangeNotifierProvider(create: (_) => ThemeProvider()..init()),
        ChangeNotifierProvider(create: (_) => LocaleProvider()..init()),
        ChangeNotifierProvider(create: (_) => AuthProvider(api)..init()),
        ChangeNotifierProvider(create: (_) => DashboardProvider(api)),
        ChangeNotifierProvider(create: (_) => AnalyticsProvider(api)),
        ChangeNotifierProvider(create: (_) => PlansProvider(api)),
        ChangeNotifierProvider(create: (_) => SettingsProvider(api)),
        ChangeNotifierProvider(create: (_) => ExchangeRateProvider(api)),
        ChangeNotifierProvider(create: (_) => OrdersProvider(api)),
        ChangeNotifierProvider(create: (_) => PaymentsProvider(api)),
        ChangeNotifierProvider(create: (_) => UsersProvider(api)),
        ChangeNotifierProvider(create: (_) => SupportProvider(api)),
        ChangeNotifierProvider(create: (_) => CouponProvider(api)),
        ChangeNotifierProvider(create: (_) => TaxRateProvider(api)),
        ChangeNotifierProvider(create: (_) => RefundProvider(api)),
        ChangeNotifierProvider(create: (_) => FreezeProvider(api)),
        ChangeNotifierProvider(create: (_) => InventoryProvider(api)),
        ChangeNotifierProvider(create: (_) => ReferralProvider(api)),
        ChangeNotifierProvider(create: (_) => ReportProvider(api)),
        ChangeNotifierProvider(create: (_) => BackupProvider(api)),
        ChangeNotifierProvider(create: (_) => AuditLogProvider(api)),
        ChangeNotifierProvider(create: (_) => TwoFAProvider(api)),
      ],
      child: Consumer2<ThemeProvider, LocaleProvider>(
        builder: (_, tp, lp, _) => MaterialApp(
          title: 'eSIM E-Go Admin',
          debugShowCheckedModeBanner: false,
          locale: Locale(lp.languageCode),
          theme: AppTheme.light,
          darkTheme: AppTheme.dark,
          themeMode: tp.isDark ? ThemeMode.dark : ThemeMode.light,
          builder: (context, child) {
            final auth = context.watch<AuthProvider>();
            if (!auth.initialized) {
              return Scaffold(
                backgroundColor: Theme.of(context).scaffoldBackgroundColor,
                body: Center(
                  child: CircularProgressIndicator(),
                ),
              );
            }
            return child!;
          },
          home: Builder(
            builder: (context) {
              final auth = context.watch<AuthProvider>();
              if (!auth.initialized) {
                return Scaffold(
                  backgroundColor: Theme.of(context).scaffoldBackgroundColor,
                  body: Center(
                    child: CircularProgressIndicator(),
                  ),
                );
              }
              if (auth.authed) {
                return DashboardScreen();
              }
              return PhoneEntryScreen();
            },
          ),
        ),
      ),
    );
  }
}
