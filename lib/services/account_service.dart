import 'package:shared_preferences/shared_preferences.dart';

const _accountDisabledKey = 'yadeli_account_disabled';
const _accountDisabledUserIdKey = 'yadeli_account_disabled_user_id';
const _proProfileKey = 'yadeli_has_pro_profile';

/// Gestion du compte : désactivation, suppression, profil pro
class AccountService {
  static Future<bool> isAccountDisabled([String? userId]) async {
    final prefs = await SharedPreferences.getInstance();
    if (!(prefs.getBool(_accountDisabledKey) ?? false)) return false;
    if (userId != null) {
      final storedId = prefs.getString(_accountDisabledUserIdKey);
      return storedId == userId;
    }
    return true;
  }

  static Future<void> setAccountDisabled(bool disabled, {String? userId}) async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.setBool(_accountDisabledKey, disabled);
    if (userId != null) await prefs.setString(_accountDisabledUserIdKey, userId);
    if (!disabled) await prefs.remove(_accountDisabledUserIdKey);
  }

  static Future<bool> hasProProfile() async {
    final prefs = await SharedPreferences.getInstance();
    return prefs.getBool(_proProfileKey) ?? false;
  }

  static Future<void> setHasProProfile(bool has) async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.setBool(_proProfileKey, has);
  }

  static Future<void> deleteProProfile() async {
    await setHasProProfile(false);
    final prefs = await SharedPreferences.getInstance();
    await prefs.remove('yadeli_pro_company');
    await prefs.remove('yadeli_pro_siret');
    await prefs.remove('yadeli_pro_address');
  }

  static Future<void> clearAllUserData() async {
    final prefs = await SharedPreferences.getInstance();
    final keysToKeep = ['yadeli_locale'];
    final keys = prefs.getKeys().where((k) => k.startsWith('yadeli_') && !keysToKeep.contains(k)).toList();
    for (final k in keys) await prefs.remove(k);
  }
}
