import 'package:flutter/material.dart';
import 'package:shared_preferences/shared_preferences.dart';

class AppProvider extends ChangeNotifier {
  Locale currentLanguage = Locale("en");

  Locale get currentLang => currentLanguage;

  AppProvider() {
    getLanguage();
  }

  Future<void> getLanguage() async {
    final prefs = await SharedPreferences.getInstance();
    final storedLanguage = prefs.getString("language");
    if (storedLanguage != null) {
      currentLanguage = Locale(storedLanguage);
      notifyListeners();
    }
  }

  Future<void> changeLanguage(String newLanguage) async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.setString("language", newLanguage);
    currentLanguage = Locale(newLanguage);
    notifyListeners();
  }
}
