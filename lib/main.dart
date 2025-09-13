import 'package:flutter/material.dart';
import 'design_system/app_theme.dart';
import 'screens/login_screen.dart';

void main() {
  runApp(const NadiParikshaApp());
}

class NadiParikshaApp extends StatelessWidget {
  const NadiParikshaApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'Nadi Pariksh',
      debugShowCheckedModeBanner: false,
      theme: AppTheme.darkTheme,
      home: const LoginScreen(),
    );
  }
}