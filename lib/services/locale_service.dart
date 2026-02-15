import 'package:flutter/material.dart';
import 'package:shared_preferences/shared_preferences.dart';
import '../l10n/app_localizations.dart';

const _localeKey = 'yadeli_locale';
const _contrastKey = 'yadeli_contrast';

class LocaleService extends ChangeNotifier {
  static LocaleService? _instance;
  static LocaleService get instance => _instance ??= LocaleService();

  AppLocale _locale = AppLocale.fr;

  AppLocale get locale => _locale;
  Locale get flutterLocale => Locale(_locale.code);

  static Future<void> init() async {
    final prefs = await SharedPreferences.getInstance();
    final code = prefs.getString(_localeKey);
    if (code != null) instance._locale = AppLocale.fromCode(code);
    await _loadContrast();
  }

  Future<void> setLocale(AppLocale loc) async {
    if (_locale == loc) return;
    _locale = loc;
    final prefs = await SharedPreferences.getInstance();
    await prefs.setString(_localeKey, loc.code);
    notifyListeners();
  }

  double _contrast = 1.0;
  double get contrast => _contrast;

  static Future<void> _loadContrast() async {
    final prefs = await SharedPreferences.getInstance();
    instance._contrast = prefs.getDouble(_contrastKey) ?? 1.0;
  }

  Future<void> setContrast(double value) async {
    _contrast = value.clamp(0.5, 2.0);
    final prefs = await SharedPreferences.getInstance();
    await prefs.setDouble(_contrastKey, _contrast);
    notifyListeners();
  }
}
