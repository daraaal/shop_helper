
import 'package:flutter/material.dart';
import 'package:shared_preferences/shared_preferences.dart';

class ThemeProvider with ChangeNotifier {
  bool _isDarkMode = false;

  bool get isDarkMode => _isDarkMode;

  ThemeProvider() {
    loadTheme();
  }

  // Метод для зміни теми
  void toggleTheme() async {
    _isDarkMode = !_isDarkMode;
    await _saveTheme(); 
    notifyListeners();
  }

  // Метод для завантаження теми з SharedPreferences
  Future<void> loadTheme() async {
    try {
    final prefs = await SharedPreferences.getInstance();
    _isDarkMode = prefs.getBool('isDarkMode') ?? false;
    } catch (e) {
      // Якщо сталася помилка, все одно продовжуємо
      print("Помилка завантаження теми: $e");
      _isDarkMode = false;
    } 
  }

  // Метод для збереження теми в SharedPreferences
  Future<void> _saveTheme() async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.setBool('isDarkMode', _isDarkMode);
  }
}