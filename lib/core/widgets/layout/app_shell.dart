import 'package:flutter/material.dart';
import 'package:wordpice/app/app_scope.dart';
import 'package:wordpice/core/network/api_client.dart';
import 'package:wordpice/core/theme/app_colors.dart';
import 'package:wordpice/core/widgets/navigation/app_bottom_nav_bar.dart';
import 'package:wordpice/core/widgets/navigation/app_header.dart';
import 'package:wordpice/features/auth/data/datasources/auth_data_source.dart';
import 'package:wordpice/features/auth/presentation/screens/auth_screen.dart';
import 'package:wordpice/features/notifications/presentation/screens/notifications_screen.dart';

class AppShell extends StatefulWidget {
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

  @override
  State<AppShell> createState() => _AppShellState();
}

class _AppShellState extends State<AppShell> {
  int _notificationCount = 0;
  bool _hasLoadedCount = false;

  @override
  void didChangeDependencies() {
    super.didChangeDependencies();
    if (widget.notificationCount != null || _hasLoadedCount) {
      return;
    }
    _hasLoadedCount = true;
    _loadNotificationCount();
  }

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

  Future<void> _loadNotificationCount() async {
    try {
      final overview = await AppScope.of(context).notificationsRepository
          .getNotifications();
      final unreadCount = overview.items.where((item) => !item.isRead).length;

      if (!mounted) {
        return;
      }

      setState(() {
        _notificationCount = unreadCount;
      });
    } on AuthRequestException {
      if (!mounted) {
        return;
      }
      setState(() {
        _notificationCount = 0;
      });
    } on ApiConnectionException {
      if (!mounted) {
        return;
      }
      setState(() {
        _notificationCount = 0;
      });
    }
  }

  Future<void> _openNotifications() async {
    if (widget.onNotifications != null) {
      widget.onNotifications!.call();
      return;
    }

    await Navigator.of(context).push(
      MaterialPageRoute(
        builder: (_) => NotificationsScreen(
          selectedBottomIndex: widget.selectedBottomIndex,
        ),
      ),
    );

    if (widget.notificationCount == null) {
      _loadNotificationCount();
    }
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
                  widget.onLogout ??
                  () {
                    _defaultLogout(context);
                  },
              onNotifications: _openNotifications,
              notificationCount: widget.notificationCount ?? _notificationCount,
            ),
          ),
          Expanded(child: widget.body),
        ],
      ),
      bottomNavigationBar: SafeArea(
        top: false,
        child: AppBottomNavBar(
          selectedIndex: widget.selectedBottomIndex,
          onChanged: widget.onBottomChanged,
        ),
      ),
    );
  }
}
