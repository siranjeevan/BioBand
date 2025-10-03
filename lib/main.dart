import 'package:flutter/material.dart';
import 'package:firebase_core/firebase_core.dart';
import 'package:flutter_dotenv/flutter_dotenv.dart';
import 'package:nadi_pariksh/design_system/app_colors.dart';
import 'firebase_options.dart';
import 'screens/splash_screen.dart';
import 'screens/onboarding_screen.dart';
import 'screens/login_screen.dart';
import 'screens/device_connect_screen.dart';
import 'screens/device_login_screen.dart';
import 'screens/dashboard_screen.dart' as dashboard;
import 'screens/reports_screen.dart';
import 'screens/health_report_screen.dart';
import 'screens/profile_screen.dart';
import 'screens/ai_analytics_screen.dart';
import 'screens/main_navigation_screen.dart';

final RouteObserver<PageRoute> routeObserver = RouteObserver<PageRoute>();

void main() async {
  WidgetsFlutterBinding.ensureInitialized();
  try {
    await dotenv.load(fileName: ".env");
  } catch (e) {
    print('Error loading .env file: $e');
  }
  await Firebase.initializeApp(
    options: DefaultFirebaseOptions.currentPlatform,
  );
  runApp(const NadiParikshaApp());
}

class NadiParikshaApp extends StatelessWidget {
  const NadiParikshaApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'Bio Band',
      debugShowCheckedModeBanner: false,
      navigatorObservers: [routeObserver],
      theme: ThemeData(
        useMaterial3: true,
        colorScheme: const ColorScheme.dark(
          primary:AppColors.secondaryLight,
          secondary: AppColors.primary,
          surface: AppColors.secondaryLight,
          onPrimary: AppColors.textPrimary,
          onSecondary: AppColors.textPrimary,
          onSurface: AppColors.textPrimary,
          tertiary:AppColors.primaryLight,
          outline: AppColors.textPrimary,
        ),
        scaffoldBackgroundColor: AppColors.primary,
        
        // AppBar Theme
        appBarTheme: const AppBarTheme(
          backgroundColor: AppColors.primary,
          foregroundColor: AppColors.textPrimary,
          elevation: 0,
          centerTitle: true,
          titleTextStyle: TextStyle(
            color:AppColors.textPrimary,
            fontSize: 20,
            fontWeight: FontWeight.w600,
          ),
        ),
        
        // Bottom Navigation Theme
        bottomNavigationBarTheme: BottomNavigationBarThemeData(
          backgroundColor: AppColors.primary,
          selectedItemColor: AppColors.primaryLight,
          unselectedItemColor: AppColors.textPrimary,
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
            backgroundColor: AppColors.primary,
            foregroundColor: AppColors.textPrimary,
            elevation: 8,
            shadowColor: AppColors.primary.withValues(alpha: 0.3),
            shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(16),
            ),
            padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 16),
          ),
        ),
        
        filledButtonTheme: FilledButtonThemeData(
          style: FilledButton.styleFrom(
            backgroundColor: AppColors.primary,
            foregroundColor: AppColors.textPrimary,
            shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(16),
            ),
          ),
        ),
        
        // Card Theme
        cardTheme: CardThemeData(
          color: AppColors.primary.withValues(alpha: 0.2),
          elevation: 0,
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(20),
            side: BorderSide(
              color: AppColors.primary.withValues(alpha: 0.3),
              width: 1,
            ),
          ),
          shadowColor: AppColors.primary.withValues(alpha: 0.2),
        ),
        
        // Input Decoration Theme
        inputDecorationTheme: InputDecorationTheme(
          filled: true,
          fillColor: AppColors.surfaceCard.withValues(alpha: 0.1),
          border: OutlineInputBorder(
            borderRadius: BorderRadius.circular(16),
            borderSide: BorderSide(
              color: AppColors.surfaceCard.withValues(alpha: 0.3),
            ),
          ),
          enabledBorder: OutlineInputBorder(
            borderRadius: BorderRadius.circular(16),
            borderSide: BorderSide(
              color:AppColors.surface.withValues(alpha: 0.3),
            ),
          ),
          focusedBorder: OutlineInputBorder(
            borderRadius: BorderRadius.circular(16),
            borderSide: const BorderSide(
              color:AppColors.surface,
              width: 2,
            ),
          ),
          labelStyle: const TextStyle(
            color: AppColors.textPrimary,
          ),
          hintStyle: const TextStyle(
            color:AppColors.textPrimary,
          ),
        ),
        
        // Text Theme
        textTheme: const TextTheme(
          displayLarge: TextStyle(
            color: AppColors.textPrimary,
            fontWeight: FontWeight.bold,
          ),
          displayMedium: TextStyle(
            color: AppColors.textPrimary,
            fontWeight: FontWeight.w600,
          ),
          headlineLarge: TextStyle(
            color: AppColors.textPrimary,
            fontWeight: FontWeight.bold,
          ),
          headlineMedium: TextStyle(
            color: AppColors.textPrimary,
            fontWeight: FontWeight.w600,
          ),
          titleLarge: TextStyle(
            color: AppColors.textPrimary,
            fontWeight: FontWeight.w600,
          ),
          titleMedium: TextStyle(
            color: AppColors.textPrimary,
            fontWeight: FontWeight.w500,
          ),
          bodyLarge: TextStyle(
            color: AppColors.textPrimary,
          ),
          bodyMedium: TextStyle(
            color:AppColors.textPrimary,
          ),
          bodySmall: TextStyle(
            color: AppColors.textPrimary,
          ),
        ),
        
        // Divider Theme
        dividerTheme: DividerThemeData(
          color: AppColors.surfaceCard.withValues(alpha: 0.3),
          thickness: 1,
        ),
        
        // Icon Theme
        iconTheme: const IconThemeData(
          color: AppColors.textPrimary,
        ),
        
        // List Tile Theme
        listTileTheme: const ListTileThemeData(
          textColor:AppColors.textPrimary,
          iconColor: AppColors.surfaceCard,
        ),
      ),
      home: const SplashScreen(),
      routes: {
        '/onboarding': (context) => const OnboardingScreen(),
        '/login': (context) => const LoginScreen(),
        '/device-connect': (context) => const DeviceConnectScreen(),
        '/device-login': (context) => const DeviceLoginScreen(),
        '/main': (context) => const MainNavigationScreen(initialIndex: 0),
        '/dashboard': (context) => const MainNavigationScreen(initialIndex: 0),
        '/reports': (context) => const MainNavigationScreen(initialIndex: 2),
        '/health-report': (context) => const HealthReportScreen(),
        '/profile': (context) => const MainNavigationScreen(initialIndex: 3),
        '/ai-analytics': (context) => const MainNavigationScreen(initialIndex: 1),
      },
    );
  }
}