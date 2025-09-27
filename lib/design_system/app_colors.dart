import 'package:flutter/material.dart';

class AppColors {
  // Primary Colors - Obsidian Plum Palette
  static const primary = Color(0xFF000428);
  static const primaryLight = Color(0xFF1729CB);
  static const primaryDark = Color(0xFF000428);
  
  // Secondary colors
  static const secondary = Color(0xFF000428);
  static const secondaryLight = Color(0xFF0B135E);
  
  // Status colors
  static const success = Color(0xFF4CAF50);
  static const warning = Color(0xFFFF9800);
  static const error = Color(0xFFF44336);
  
  // Dark theme colors
  static const surface = Color(0xFF0B135E);
  static const surfaceLight = Color(0xFF0B135E);
  static const surfaceCard = Color(0xFF000428);
  static const textPrimary = Color(0xFFFFFFFF);
  static const textSecondary = Color(0xFFFFFFFF);
  static const textMuted = Color(0xFFFFFFFF);
  static const border = Color(0xFFFFFFFF);
  static const borderLight = Color(0xFFFFFFFF);
   static const transperant=Colors.transparent;
  // Icon colors
  static const iconPrimary = Color(0xFFFFFFFF);
  static const iconSecondary = Color(0xFFFFFFFF);
  // Gradients
  static const gradient1 = LinearGradient(
    begin: Alignment.topLeft,
    end: Alignment.bottomRight,
    colors: [primary, primaryLight],
  );
  
  static const backgroundGradient = LinearGradient(
    begin: Alignment.topCenter,
    end: Alignment.bottomCenter,
    colors: [Color(0xFF000428),Color(0xFF0B135E)],
  );
}