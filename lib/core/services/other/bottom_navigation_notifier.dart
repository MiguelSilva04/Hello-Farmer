import 'package:flutter/material.dart';

class BottomNavigationNotifier extends ChangeNotifier {
  int _currentIndex = 0;
  String? _selectedCategory;

  int get currentIndex => _currentIndex;
  String? get selectedCategory => _selectedCategory;

  void setIndex(int index) {
    if (_currentIndex != index) {
      _currentIndex = index;
      notifyListeners();
    }
  }

  void setIndexAndCategory(int index, String? category) {
    _currentIndex = index;
    _selectedCategory = category;
    notifyListeners();
  }

  void setCategory(String? category) {
    if (_selectedCategory != category) {
      _selectedCategory = category;
      notifyListeners();
    }
  }
}
