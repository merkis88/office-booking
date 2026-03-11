import 'package:flutter/material.dart';
import 'package:wordpice/app/app_scope.dart';
import 'package:wordpice/core/theme/app_colors.dart';
import 'package:wordpice/core/widgets/navigation/app_bottom_nav_bar.dart';
import 'package:wordpice/core/widgets/navigation/app_header.dart';
import 'package:wordpice/features/auth/presentation/screens/auth_screen.dart';
import 'package:wordpice/features/notifications/data/mock/notifications_mock_data.dart';
import 'package:wordpice/features/notifications/presentation/screens/notifications_screen.dart';

class AppShell extends StatelessWidget {
  const AppShell({
    super.key,
    required this.body,
    required this.selectedBottomIndex,
    required this.onBottomChanged,
    this.onLogout,
    this.onNotifications,
    this.notificationCount,
  });

  final Widget body;
  final int selectedBottomIndex;
  final ValueChanged<int> onBottomChanged;
  final VoidCallback? onLogout;
  final VoidCallback? onNotifications;
  final int? notificationCount;

  Future<void> _defaultLogout(BuildContext context) async {
    final dependencies = AppScope.of(context);

    try {
      await dependencies.authRepository.logout();
    } catch (_) {
      dependencies.appSession.clear();
    }

    if (!context.mounted) return;
    Navigator.pushAndRemoveUntil(
      context,
      MaterialPageRoute(builder: (_) => const AuthScreen()),
      (_) => false,
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.screenBackground,
      body: Column(
        children: [
          SafeArea(
            bottom: false,
            child: AppHeader(
              onLogout:
                  onLogout ??
                  () {
                    _defaultLogout(context);
                  },
              onNotifications:
                  onNotifications ??
                  () {
                    Navigator.of(context).push(
                      MaterialPageRoute(
                        builder: (_) => NotificationsScreen(
                          selectedBottomIndex: selectedBottomIndex,
                        ),
                      ),
                    );
                  },
              notificationCount:
                  notificationCount ?? notificationsMockData.length,
            ),
          ),
          Expanded(child: body),
        ],
      ),
      bottomNavigationBar: SafeArea(
        top: false,
        child: AppBottomNavBar(
          selectedIndex: selectedBottomIndex,
          onChanged: onBottomChanged,
        ),
      ),
    );
  }
}
