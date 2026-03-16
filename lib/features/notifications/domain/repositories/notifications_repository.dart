import 'package:wordpice/features/notifications/domain/entities/notifications_overview.dart';

abstract class NotificationsRepository {
  Future<NotificationsOverview> getNotifications({
    int? perPage,
    int? page,
  });

  Future<void> markAsRead(int notificationId);

  Future<void> markAllAsRead();

  Future<void> deleteNotification(int notificationId);
}
