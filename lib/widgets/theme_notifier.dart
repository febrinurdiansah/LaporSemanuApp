import 'package:flutter/material.dart';

class ThemeNotifier extends ChangeNotifier{
  bool _isDarkMode = false;
  bool get isDarkMode => _isDarkMode;
  
  void toggleDarkMode() {
    _isDarkMode =!_isDarkMode;
    notifyListeners();
  }
}