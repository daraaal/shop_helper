
import 'package:flutter/material.dart';
import 'package:shared_preferences/shared_preferences.dart';

enum SortOption { byDate, byName }

class SortProvider with ChangeNotifier {
  SortOption _sortOption = SortOption.byDate;

  SortOption get sortOption => _sortOption;

  SortProvider() {
    loadSortPreference();
  }

  // Метод для зміни сортування
  void setSortOption(SortOption newOption) async {
    if (_sortOption == newOption) return;
    
    _sortOption = newOption;
    await _saveSortPreference();
    notifyListeners();
  }

  // Метод для завантаження налаштувань
  Future<void> loadSortPreference() async {
    try {
      final prefs = await SharedPreferences.getInstance();
      final String sortString = prefs.getString('sort_preference') ?? 'byDate';
      _sortOption = (sortString == 'byName') ? SortOption.byName : SortOption.byDate;
      notifyListeners();
    } catch (e) {
      print("Помилка завантаження налаштувань сортування: $e");
    }
  }

  // Метод для збереження налаштувань
  Future<void> _saveSortPreference() async {
    final prefs = await SharedPreferences.getInstance();
    final String sortString = (_sortOption == SortOption.byName) ? 'byName' : 'byDate';
    await prefs.setString('sort_preference', sortString);
  }
}