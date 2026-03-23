import 'package:flutter/material.dart';
import 'package:wordpice/app/app_scope.dart';
import 'package:wordpice/app/navigation/app_tab_navigator.dart';
import 'package:wordpice/core/network/api_client.dart';
import 'package:wordpice/core/theme/app_colors.dart';
import 'package:wordpice/core/widgets/buttons/app_outlined_icon_button.dart';
import 'package:wordpice/core/widgets/navigation/app_bottom_nav_bar.dart';
import 'package:wordpice/core/widgets/navigation/app_header.dart';
import 'package:wordpice/core/widgets/states/app_empty_state_text.dart';
import 'package:wordpice/features/auth/data/datasources/auth_data_source.dart';
import 'package:wordpice/features/auth/presentation/screens/auth_screen.dart';
import 'package:wordpice/features/notifications/domain/entities/notifications_overview.dart';
import 'package:wordpice/features/notifications/presentation/models/notification_item.dart';
import 'package:wordpice/features/notifications/presentation/widgets/buttons/notification_read_action.dart';
import 'package:wordpice/features/notifications/presentation/widgets/cards/notification_card.dart';
import 'package:wordpice/features/notifications/presentation/widgets/styles/notification_styles.dart';

class NotificationsScreen extends StatefulWidget {
  const NotificationsScreen({super.key, required this.selectedBottomIndex});

  final int selectedBottomIndex;

  @override
  State<NotificationsScreen> createState() => _NotificationsScreenState();
}

class _NotificationsScreenState extends State<NotificationsScreen> {
  List<NotificationItem> _items = const <NotificationItem>[];
  List<bool> _readStates = const <bool>[];
  bool _isLoading = true;
  String? _errorMessage;
  bool _hasLoadedInitially = false;
  bool _isMarkingAllRead = false;
  final Set<int> _markingReadIds = <int>{};
  final Set<int> _deletingIds = <int>{};
  int _unreadCount = 0;

  @override
  void didChangeDependencies() {
    super.didChangeDependencies();
    if (_hasLoadedInitially) {
      return;
    }
    _hasLoadedInitially = true;
    _loadNotifications();
  }

  void _logout() {
    Navigator.pushAndRemoveUntil(
      context,
      MaterialPageRoute(builder: (_) => const AuthScreen()),
      (_) => false,
    );
  }

  void _onBottomChanged(int index) {
    AppTabNavigator.goToTab(context, index);
  }

  bool get _areAllRead =>
      _readStates.isNotEmpty && _readStates.every((value) => value);

  Future<void> _loadNotifications() async {
    setState(() {
      _isLoading = true;
      _errorMessage = null;
    });

    try {
      final NotificationsOverview overview = await AppScope.of(
        context,
      ).notificationsRepository.getNotifications();

      if (!mounted) {
        return;
      }

      final items = overview.items
          .map(
            (entry) => NotificationItem(
              id: entry.id,
              title: entry.title,
              message: entry.message,
              dateTimeText: entry.dateTimeText,
              isRead: entry.isRead,
            ),
          )
          .toList(growable: false);

      setState(() {
        _items = items;
        _readStates = items.map((item) => item.isRead).toList(growable: false);
        _unreadCount = items.where((item) => !item.isRead).length;
        _markingReadIds.clear();
        _deletingIds.clear();
        _isMarkingAllRead = false;
        _isLoading = false;
      });
    } on AuthRequestException catch (error) {
      if (!mounted) {
        return;
      }
      setState(() {
        _errorMessage = error.message;
        _isLoading = false;
      });
    } on ApiConnectionException catch (error) {
      if (!mounted) {
        return;
      }
      setState(() {
        _errorMessage = error.message;
        _isLoading = false;
      });
    }
  }

  Future<void> _markAsRead(int index) async {
    if (_readStates[index]) {
      return;
    }

    final notificationId = _items[index].id;
    setState(() {
      _markingReadIds.add(notificationId);
    });

    try {
      await AppScope.of(context).notificationsRepository.markAsRead(
        notificationId,
      );

      if (!mounted) {
        return;
      }

      setState(() {
        _readStates[index] = true;
        if (_unreadCount > 0) {
          _unreadCount -= 1;
        }
        _markingReadIds.remove(notificationId);
      });
    } on AuthRequestException catch (error) {
      _handleActionError(error.message, notificationId);
    } on ApiConnectionException catch (error) {
      _handleActionError(error.message, notificationId);
    }
  }

  Future<void> _markAllAsRead() async {
    if (_areAllRead || _isMarkingAllRead) {
      return;
    }

    setState(() {
      _isMarkingAllRead = true;
    });

    try {
      await AppScope.of(context).notificationsRepository.markAllAsRead();

      if (!mounted) {
        return;
      }

      setState(() {
        _readStates = List<bool>.filled(_readStates.length, true);
        _unreadCount = 0;
        _markingReadIds.clear();
        _isMarkingAllRead = false;
      });
    } on AuthRequestException catch (error) {
      _handleMarkAllError(error.message);
    } on ApiConnectionException catch (error) {
      _handleMarkAllError(error.message);
    }
  }

  Future<void> _deleteNotification(int index) async {
    final notificationId = _items[index].id;
    if (_deletingIds.contains(notificationId)) {
      return;
    }

    setState(() {
      _deletingIds.add(notificationId);
    });

    try {
      await AppScope.of(context).notificationsRepository.deleteNotification(
        notificationId,
      );

      if (!mounted) {
        return;
      }

      final wasUnread = !_readStates[index];
      setState(() {
        _items = List<NotificationItem>.from(_items)..removeAt(index);
        _readStates = List<bool>.from(_readStates)..removeAt(index);
        _markingReadIds.remove(notificationId);
        _deletingIds.remove(notificationId);
        if (wasUnread && _unreadCount > 0) {
          _unreadCount -= 1;
        }
      });
    } on AuthRequestException catch (error) {
      _handleDeleteError(error.message, notificationId);
    } on ApiConnectionException catch (error) {
      _handleDeleteError(error.message, notificationId);
    }
  }

  void _handleActionError(String message, int notificationId) {
    if (!mounted) {
      return;
    }

    setState(() {
      _markingReadIds.remove(notificationId);
    });

    ScaffoldMessenger.of(context)
      ..hideCurrentSnackBar()
      ..showSnackBar(SnackBar(content: Text(message)));
  }

  void _handleMarkAllError(String message) {
    if (!mounted) {
      return;
    }

    setState(() {
      _isMarkingAllRead = false;
    });

    ScaffoldMessenger.of(context)
      ..hideCurrentSnackBar()
      ..showSnackBar(SnackBar(content: Text(message)));
  }

  void _handleDeleteError(String message, int notificationId) {
    if (!mounted) {
      return;
    }

    setState(() {
      _deletingIds.remove(notificationId);
    });

    ScaffoldMessenger.of(context)
      ..hideCurrentSnackBar()
      ..showSnackBar(SnackBar(content: Text(message)));
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
              onLogout: _logout,
              onNotifications: () {},
              notificationCount: _unreadCount,
              showActions: false,
            ),
          ),
          Expanded(
            child: Padding(
              padding: const EdgeInsets.fromLTRB(16, 22, 16, 24),
              child: _NotificationsBody(
                items: _items,
                isLoading: _isLoading,
                errorMessage: _errorMessage,
                areAllRead: _areAllRead,
                isMarkingAllRead: _isMarkingAllRead,
                readStates: _readStates,
                markingReadIds: _markingReadIds,
                deletingIds: _deletingIds,
                onAllReadChanged: _markAllAsRead,
                onReadChanged: _markAsRead,
                onDeletePressed: _deleteNotification,
                onRetry: _loadNotifications,
              ),
            ),
          ),
        ],
      ),
      bottomNavigationBar: SafeArea(
        top: false,
        child: AppBottomNavBar(
          selectedIndex: widget.selectedBottomIndex,
          onChanged: _onBottomChanged,
          showArchive:
              AppScope.of(context).appSession.currentUser?.isAdmin ?? false,
        ),
      ),
    );
  }
}

class _NotificationsBody extends StatelessWidget {
  const _NotificationsBody({
    required this.items,
    required this.isLoading,
    required this.errorMessage,
    required this.areAllRead,
    required this.isMarkingAllRead,
    required this.readStates,
    required this.markingReadIds,
    required this.deletingIds,
    required this.onAllReadChanged,
    required this.onReadChanged,
    required this.onDeletePressed,
    required this.onRetry,
  });

  final List<NotificationItem> items;
  final bool isLoading;
  final String? errorMessage;
  final bool areAllRead;
  final bool isMarkingAllRead;
  final List<bool> readStates;
  final Set<int> markingReadIds;
  final Set<int> deletingIds;
  final Future<void> Function() onAllReadChanged;
  final Future<void> Function(int index) onReadChanged;
  final Future<void> Function(int index) onDeletePressed;
  final VoidCallback onRetry;

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.stretch,
      children: [
        const _NotificationsTitleBar(),
        const SizedBox(height: 22),
        Center(
          child: NotificationReadAction(
            label: 'Прочитать все уведомления',
            value: areAllRead,
            isEnabled: !areAllRead,
            isLoading: isMarkingAllRead,
            onChanged: (_) => onAllReadChanged(),
          ),
        ),
        const SizedBox(height: 30),
        Expanded(
          child: _NotificationsList(
            items: items,
            isLoading: isLoading,
            errorMessage: errorMessage,
            readStates: readStates,
            markingReadIds: markingReadIds,
            deletingIds: deletingIds,
            onReadChanged: onReadChanged,
            onDeletePressed: onDeletePressed,
            onRetry: onRetry,
          ),
        ),
      ],
    );
  }
}

class _NotificationsTitleBar extends StatelessWidget {
  const _NotificationsTitleBar();

  @override
  Widget build(BuildContext context) {
    return Stack(
      alignment: Alignment.center,
      children: [
        Align(
          alignment: Alignment.centerLeft,
          child: AppOutlinedIconButton(
            icon: Icons.arrow_back_ios_new,
            iconSize: 14,
            size: 30,
            radius: 10,
            onPressed: () => Navigator.of(context).pop(),
          ),
        ),
        const Text('Уведомления', style: NotificationStyles.titleText),
      ],
    );
  }
}

class _NotificationsList extends StatelessWidget {
  const _NotificationsList({
    required this.items,
    required this.isLoading,
    required this.errorMessage,
    required this.readStates,
    required this.markingReadIds,
    required this.deletingIds,
    required this.onReadChanged,
    required this.onDeletePressed,
    required this.onRetry,
  });

  final List<NotificationItem> items;
  final bool isLoading;
  final String? errorMessage;
  final List<bool> readStates;
  final Set<int> markingReadIds;
  final Set<int> deletingIds;
  final Future<void> Function(int index) onReadChanged;
  final Future<void> Function(int index) onDeletePressed;
  final VoidCallback onRetry;

  @override
  Widget build(BuildContext context) {
    if (isLoading) {
      return const Center(child: CircularProgressIndicator());
    }

    if (errorMessage != null) {
      return Center(
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Text(
              errorMessage!,
              textAlign: TextAlign.center,
              style: NotificationStyles.emptyStateText.copyWith(fontSize: 22),
            ),
            const SizedBox(height: 16),
            SizedBox(
              height: 40,
              child: OutlinedButton(
                onPressed: onRetry,
                child: const Text('Повторить'),
              ),
            ),
          ],
        ),
      );
    }

    if (items.isEmpty) {
      return const AppEmptyStateText(
        text: 'Уведомлений нет',
        style: NotificationStyles.emptyStateText,
      );
    }

    return ListView.separated(
      padding: EdgeInsets.zero,
      itemCount: items.length,
      separatorBuilder: (_, _) => const SizedBox(height: 46),
      itemBuilder: (_, i) => NotificationCard(
        item: items[i],
        isRead: readStates[i],
        isReadLoading: markingReadIds.contains(items[i].id),
        isDeleteLoading: deletingIds.contains(items[i].id),
        onReadChanged: (_) => onReadChanged(i),
        onDeletePressed: () => onDeletePressed(i),
      ),
    );
  }
}
