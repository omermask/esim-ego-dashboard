import 'package:flutter/foundation.dart';
import 'package:shared_preferences/shared_preferences.dart';

class LocaleProvider extends ChangeNotifier {
  String _languageCode = 'ar';
  String get languageCode => _languageCode;

  Future<void> init() async {
    final p = await SharedPreferences.getInstance();
    _languageCode = p.getString('locale') ?? 'ar';
    notifyListeners();
  }

  Future<void> setLanguage(String code) async {
    _languageCode = code;
    final p = await SharedPreferences.getInstance();
    await p.setString('locale', code);
    notifyListeners();
  }
}
