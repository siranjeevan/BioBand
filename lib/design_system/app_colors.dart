import 'package:flutter/material.dart';

class AppColors {
  // Primary Colors - Obsidian Plum Palette
  static const primary = Color(0xFF4E2A4F);
  static const primaryLight = Color(0xFF6B4C6D);
  static const primaryDark = Color(0xFF3A1F3B);
  
  // Secondary colors
  static const secondary = Color(0xFF2D1E2F);
  static const secondaryLight = Color(0xFF4A3A4B);
  
  // Status colors
  static const success = Color(0xFF4CAF50);
  static const warning = Color(0xFFFF9800);
  static const error = Color(0xFFF44336);
  
  // Dark theme colors
  static const surface = Color(0xFF4E2A4F);
  static const surfaceLight = Color(0xFF6B4C6D);
  static const surfaceCard = Color(0xFF3A2A3B);
  static const textPrimary = Color(0xFFFFFFFF);
  static const textSecondary = Color(0xFFB0A8B9);
  static const textMuted = Color(0xFF8A7A8B);
  static const border = Color(0xFF4E2A4F);
  static const borderLight = Color(0xFF6B4C6D);
  
  // Gradients
  static const gradient1 = LinearGradient(
    begin: Alignment.topLeft,
    end: Alignment.bottomRight,
    colors: [primary, primaryLight],
  );
  
  static const backgroundGradient = LinearGradient(
    begin: Alignment.topCenter,
    end: Alignment.bottomCenter,
    colors: [Color(0xFF2D1E2F), Color(0xFF4E2A4F)],
  );
}