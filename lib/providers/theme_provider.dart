import 'package:flutter/material.dart';
import '../design_system/app_colors.dart';

class ThemeProvider extends ChangeNotifier {
  bool _isDarkMode = true;
  
  bool get isDarkMode => _isDarkMode;
  
  void toggleTheme() {
    _isDarkMode = !_isDarkMode;
    notifyListeners();
  }
  
  // Dynamic color getters based on theme
  Color get surface => AppColors.surface;
  Color get surfaceLight => AppColors.surfaceLight;
  Color get textPrimary => AppColors.textPrimary;
  Color get textSecondary => AppColors.textSecondary;
  Color get border => AppColors.border;
  
  LinearGradient get backgroundGradient => AppColors.backgroundGradient;
}