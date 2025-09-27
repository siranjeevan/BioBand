import 'package:flutter/material.dart';

import 'screens/splash_screen.dart';
import 'screens/onboarding_screen.dart';
import 'screens/login_screen.dart';
import 'screens/device_connect_screen.dart';
import 'screens/dashboard_screen.dart' as dashboard;
import 'screens/main_screen.dart';
import 'screens/health_overview_screen.dart';
import 'screens/reports_screen.dart';
import 'screens/alerts_screen.dart';
import 'screens/doctor_access_screen.dart';
import 'screens/profile_screen.dart';

import 'screens/settings_screen.dart';

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
      theme: ThemeData(
        useMaterial3: true,
        colorScheme: const ColorScheme.dark(
          primary: Color(0xFF4E2A4F),
          secondary: Color(0xFF2D1E2F),
          surface: Color(0xFF4E2A4F),
          onPrimary: Color(0xFFFFFFFF),
          onSecondary: Color(0xFFB0A8B9),
          onSurface: Color(0xFFFFFFFF),
          tertiary: Color(0xFF6B4C6D),
          outline: Color(0xFFB0A8B9),
        ),
        scaffoldBackgroundColor: const Color(0xFF2D1E2F),
        
        // AppBar Theme
        appBarTheme: const AppBarTheme(
          backgroundColor: Colors.transparent,
          foregroundColor: Color(0xFFFFFFFF),
          elevation: 0,
          centerTitle: true,
          titleTextStyle: TextStyle(
            color: Color(0xFFFFFFFF),
            fontSize: 20,
            fontWeight: FontWeight.w600,
          ),
        ),
        
        // Bottom Navigation Theme
        bottomNavigationBarTheme: BottomNavigationBarThemeData(
          backgroundColor: Colors.transparent,
          selectedItemColor: const Color(0xFF4E2A4F),
          unselectedItemColor: const Color(0xFFB0A8B9),
          type: BottomNavigationBarType.fixed,
          elevation: 0,
          selectedLabelStyle: const TextStyle(
            fontWeight: FontWeight.w600,
            fontSize: 12,
          ),
          unselectedLabelStyle: const TextStyle(
            fontWeight: FontWeight.w500,
            fontSize: 11,
          ),
        ),
        
        // Button Themes
        elevatedButtonTheme: ElevatedButtonThemeData(
          style: ElevatedButton.styleFrom(
            backgroundColor: const Color(0xFF4E2A4F),
            foregroundColor: const Color(0xFFFFFFFF),
            elevation: 8,
            shadowColor: const Color(0xFF4E2A4F).withValues(alpha: 0.3),
            shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(16),
            ),
            padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 16),
          ),
        ),
        
        filledButtonTheme: FilledButtonThemeData(
          style: FilledButton.styleFrom(
            backgroundColor: const Color(0xFF4E2A4F),
            foregroundColor: const Color(0xFFFFFFFF),
            shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(16),
            ),
          ),
        ),
        
        // Card Theme
        cardTheme: CardThemeData(
          color: const Color(0xFF4E2A4F).withValues(alpha: 0.2),
          elevation: 0,
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(20),
            side: BorderSide(
              color: const Color(0xFF4E2A4F).withValues(alpha: 0.3),
              width: 1,
            ),
          ),
          shadowColor: const Color(0xFF4E2A4F).withValues(alpha: 0.2),
        ),
        
        // Input Decoration Theme
        inputDecorationTheme: InputDecorationTheme(
          filled: true,
          fillColor: const Color(0xFF4E2A4F).withValues(alpha: 0.1),
          border: OutlineInputBorder(
            borderRadius: BorderRadius.circular(16),
            borderSide: BorderSide(
              color: const Color(0xFF4E2A4F).withValues(alpha: 0.3),
            ),
          ),
          enabledBorder: OutlineInputBorder(
            borderRadius: BorderRadius.circular(16),
            borderSide: BorderSide(
              color: const Color(0xFF4E2A4F).withValues(alpha: 0.3),
            ),
          ),
          focusedBorder: OutlineInputBorder(
            borderRadius: BorderRadius.circular(16),
            borderSide: const BorderSide(
              color: Color(0xFF4E2A4F),
              width: 2,
            ),
          ),
          labelStyle: const TextStyle(
            color: Color(0xFFB0A8B9),
          ),
          hintStyle: const TextStyle(
            color: Color(0xFFB0A8B9),
          ),
        ),
        
        // Text Theme
        textTheme: const TextTheme(
          displayLarge: TextStyle(
            color: Color(0xFFFFFFFF),
            fontWeight: FontWeight.bold,
          ),
          displayMedium: TextStyle(
            color: Color(0xFFFFFFFF),
            fontWeight: FontWeight.w600,
          ),
          headlineLarge: TextStyle(
            color: Color(0xFFFFFFFF),
            fontWeight: FontWeight.bold,
          ),
          headlineMedium: TextStyle(
            color: Color(0xFFFFFFFF),
            fontWeight: FontWeight.w600,
          ),
          titleLarge: TextStyle(
            color: Color(0xFFFFFFFF),
            fontWeight: FontWeight.w600,
          ),
          titleMedium: TextStyle(
            color: Color(0xFFFFFFFF),
            fontWeight: FontWeight.w500,
          ),
          bodyLarge: TextStyle(
            color: Color(0xFFFFFFFF),
          ),
          bodyMedium: TextStyle(
            color: Color(0xFFB0A8B9),
          ),
          bodySmall: TextStyle(
            color: Color(0xFFB0A8B9),
          ),
        ),
        
        // Divider Theme
        dividerTheme: DividerThemeData(
          color: const Color(0xFF4E2A4F).withValues(alpha: 0.3),
          thickness: 1,
        ),
        
        // Icon Theme
        iconTheme: const IconThemeData(
          color: Color(0xFFFFFFFF),
        ),
        
        // List Tile Theme
        listTileTheme: const ListTileThemeData(
          textColor: Color(0xFFFFFFFF),
          iconColor: Color(0xFF4E2A4F),
        ),
      ),
      home: const SplashScreen(),
      routes: {
        '/onboarding': (context) => const OnboardingScreen(),
        '/login': (context) => const LoginScreen(),
        '/device-connect': (context) => const DeviceConnectScreen(),
        '/dashboard': (context) => const dashboard.DashboardScreen(),
        '/main': (context) => const MainScreen(),
        '/health': (context) => const HealthOverviewScreen(),
        '/reports': (context) => const ReportsScreen(),
        '/alerts': (context) => const AlertsScreen(),
        '/doctor-access': (context) => const DoctorAccessScreen(),
        '/profile': (context) => const ProfileScreen(),

        '/settings': (context) => const SettingsScreen(),
      },
    );
  }
}