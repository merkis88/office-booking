import 'package:wordpice/features/notifications/data/models/notifications_response_model.dart';

abstract class NotificationsDataSource {
  Future<NotificationsResponseModel> getNotifications({
    int? perPage,
    int? page,
  });

  Future<void> markAsRead(int notificationId);

  Future<void> markAllAsRead();

  Future<void> deleteNotification(int notificationId);
}
