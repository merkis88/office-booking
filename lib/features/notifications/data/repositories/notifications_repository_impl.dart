import 'package:wordpice/features/notifications/data/datasources/notifications_data_source.dart';
import 'package:wordpice/features/notifications/domain/entities/notifications_overview.dart';
import 'package:wordpice/features/notifications/domain/repositories/notifications_repository.dart';

class NotificationsRepositoryImpl implements NotificationsRepository {
  NotificationsRepositoryImpl(this._dataSource);

  final NotificationsDataSource _dataSource;

  @override
  Future<NotificationsOverview> getNotifications({
    int? perPage,
    int? page,
  }) async {
    final response = await _dataSource.getNotifications(
      perPage: perPage,
      page: page,
    );
    return response.toEntity();
  }

  @override
  Future<void> markAsRead(int notificationId) {
    return _dataSource.markAsRead(notificationId);
  }

  @override
  Future<void> markAllAsRead() {
    return _dataSource.markAllAsRead();
  }

  @override
  Future<void> deleteNotification(int notificationId) {
    return _dataSource.deleteNotification(notificationId);
  }
}
