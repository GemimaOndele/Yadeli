import 'package:shared_preferences/shared_preferences.dart';
import 'package:supabase_flutter/supabase_flutter.dart';

const _userNameKey = 'yadeli_user_name';
const _userPhoneKey = 'yadeli_user_phone';
const _userGenderKey = 'yadeli_user_gender';
const _userLanguagesKey = 'yadeli_user_languages';
const _userEmailKey = 'yadeli_user_email';

class UserService {
  static Future<void> saveUser({required String name, required String phone, required String gender, String? email, List<String>? languages}) async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.setString(_userNameKey, name);
    await prefs.setString(_userPhoneKey, phone);
    await prefs.setString(_userGenderKey, gender);
    if (email != null) await prefs.setString(_userEmailKey, email);
    if (languages != null) await prefs.setStringList(_userLanguagesKey, languages);
  }

  static Future<String?> getUserEmail() async {
    final prefs = await SharedPreferences.getInstance();
    return prefs.getString(_userEmailKey);
  }

  static Future<String> getUserName() async {
    final prefs = await SharedPreferences.getInstance();
    return prefs.getString(_userNameKey) ?? 'Utilisateur Yadeli';
  }

  static Future<String> getUserPhone() async {
    final prefs = await SharedPreferences.getInstance();
    return prefs.getString(_userPhoneKey) ?? '+242 06 444 22 11';
  }

  static Future<String> getUserGender() async {
    final prefs = await SharedPreferences.getInstance();
    return prefs.getString(_userGenderKey) ?? 'homme';
  }

  static Future<List<String>> getUserLanguages() async {
    final prefs = await SharedPreferences.getInstance();
    return prefs.getStringList(_userLanguagesKey) ?? ['FR'];
  }

  /// Charge le profil depuis Supabase (table profiles) après connexion
  static Future<void> loadFromSupabase(String userId) async {
    try {
      final res = await Supabase.instance.client
          .from('profiles')
          .select('name, phone, email, gender, languages')
          .eq('id', userId)
          .maybeSingle();
      if (res != null) {
        final prefs = await SharedPreferences.getInstance();
        if (res['name'] != null) await prefs.setString(_userNameKey, res['name'].toString());
        if (res['phone'] != null) await prefs.setString(_userPhoneKey, res['phone'].toString());
        if (res['email'] != null) await prefs.setString(_userEmailKey, res['email'].toString());
        if (res['gender'] != null) await prefs.setString(_userGenderKey, res['gender'].toString());
        if (res['languages'] != null && res['languages'] is List) {
          await prefs.setStringList(_userLanguagesKey, (res['languages'] as List).map((e) => e.toString()).toList());
        }
      }
    } catch (_) {
      // Table profiles peut ne pas exister — on garde les données locales
    }
  }
}
