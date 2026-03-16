import 'package:wordpice/features/notifications/domain/entities/notification_entry.dart';

class NotificationsOverview {
  const NotificationsOverview({required this.items});

  final List<NotificationEntry> items;
}
