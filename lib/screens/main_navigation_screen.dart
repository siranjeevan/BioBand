import 'package:flutter/material.dart';
import '../design_system/app_colors.dart';
import '../models/device_state.dart';
import '../main.dart';
import 'dashboard_screen.dart';
import 'ai_analytics_screen.dart';
import 'reports_screen.dart';
import 'profile_screen.dart';

class MainNavigationScreen extends StatefulWidget {
  final int initialIndex;
  const MainNavigationScreen({super.key, this.initialIndex = 0});

  @override
  State<MainNavigationScreen> createState() => _MainNavigationScreenState();
}

class _MainNavigationScreenState extends State<MainNavigationScreen> with RouteAware {
  late int _currentIndex;
  final GlobalKey<DashboardScreenState> _dashboardKey = GlobalKey<DashboardScreenState>();
  bool _dialogDismissedByUser = false;

  
  late final List<Widget> _screens;

  @override
  void initState() {
    super.initState();
    _currentIndex = widget.initialIndex;
    _screens = [
      DashboardScreen(
        key: _dashboardKey,
        onDialogDismissed: () => _dialogDismissedByUser = true,
      ),
      const AiAnalyticsScreen(),
      const ReportsScreen(),
      const ProfileScreen(),
    ];
    
    WidgetsBinding.instance.addPostFrameCallback((_) {
      // Only show dialog if starting on dashboard tab and device not connected
      if (_currentIndex == 0 && !DeviceState.isConnected) {
        _dashboardKey.currentState?.showNoDeviceDialog();
      }
    });
  }

  @override
  void didChangeDependencies() {
    super.didChangeDependencies();
    final route = ModalRoute.of(context);
    if (route is PageRoute) {
      routeObserver.subscribe(this, route);
    }
  }

  @override
  void dispose() {
    routeObserver.unsubscribe(this);
    super.dispose();
  }



  @override
  void didPopNext() {
    super.didPopNext();
    // Only show dialog if currently on dashboard tab and device not connected
    if (_currentIndex == 0 && !DeviceState.isConnected && mounted && !_dialogDismissedByUser) {
      WidgetsBinding.instance.addPostFrameCallback((_) {
        _dashboardKey.currentState?.showNoDeviceDialog();
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: IndexedStack(
        index: _currentIndex,
        children: _screens,
      ),
      bottomNavigationBar: Container(
        decoration: BoxDecoration(
          color: AppColors.surface.withValues(alpha: 0.9),
          borderRadius: const BorderRadius.vertical(top: Radius.circular(20)),
        ),
        child: BottomNavigationBar(
          backgroundColor: Colors.transparent,
          elevation: 0,
          type: BottomNavigationBarType.fixed,
          selectedItemColor: AppColors.primary,
          unselectedItemColor: AppColors.textSecondary,
          currentIndex: _currentIndex,
          onTap: (index) {
            setState(() {
              _currentIndex = index;
              if (index != 0) _dialogDismissedByUser = false;
            });
            if (index == 0 && !DeviceState.isConnected && !_dialogDismissedByUser) {
              WidgetsBinding.instance.addPostFrameCallback((_) {
                _dashboardKey.currentState?.showNoDeviceDialog();
              });
            }
          },
          items: const [
            BottomNavigationBarItem(
                icon: Icon(Icons.dashboard), label: 'Dashboard'),
            BottomNavigationBarItem(
                icon: Icon(Icons.psychology), label: 'AI Analytics'),
            BottomNavigationBarItem(
                icon: Icon(Icons.assessment), label: 'Reports'),
            BottomNavigationBarItem(
                icon: Icon(Icons.person), label: 'Profile'),
          ],
        ),
      ),
    );
  }
}