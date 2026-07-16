import 'package:flutter/material.dart';
import 'design_tokens.dart';

class ThemeProvider extends ChangeNotifier {
  ThemeMode _themeMode = ThemeMode.light;
  
  ThemeMode get themeMode => _themeMode;
  
  ThemeData get themeData => _buildTheme();
  
  void toggleTheme() {
    _themeMode = _themeMode == ThemeMode.light ? ThemeMode.dark : ThemeMode.light;
    notifyListeners();
  }
  
  ThemeData _buildTheme() {
    final baseTheme = _themeMode == ThemeMode.light
        ? ThemeData.light()
        : ThemeData.dark();
    
    return baseTheme.applyTokens();
  }
}