import 'package:wordpice/features/notifications/domain/entities/notification_entry.dart';
import 'package:wordpice/features/notifications/domain/entities/notifications_overview.dart';

class NotificationsResponseModel {
  const NotificationsResponseModel({
    required this.items,
    required this.currentPage,
    required this.perPage,
    required this.total,
  });

  final List<NotificationEntry> items;
  final int currentPage;
  final int perPage;
  final int total;

  factory NotificationsResponseModel.fromJson(Map<String, dynamic> json) {
    final data = json['data'];
    final items = data is List
        ? data
              .whereType<Map<String, dynamic>>()
              .map(NotificationItemModel.fromJson)
              .map((item) => item.toEntity())
              .toList(growable: false)
        : const <NotificationEntry>[];

    return NotificationsResponseModel(
      items: items,
      currentPage: (json['current_page'] as num?)?.toInt() ?? 1,
      perPage: (json['per_page'] as num?)?.toInt() ?? items.length,
      total: (json['total'] as num?)?.toInt() ?? items.length,
    );
  }

  NotificationsOverview toEntity() {
    return NotificationsOverview(items: items);
  }
}

class NotificationItemModel {
  const NotificationItemModel({
    required this.id,
    required this.title,
    required this.message,
    required this.isRead,
    required this.createdAt,
  });

  final int id;
  final String title;
  final String message;
  final bool isRead;
  final String createdAt;

  factory NotificationItemModel.fromJson(Map<String, dynamic> json) {
    return NotificationItemModel(
      id: (json['id'] as num?)?.toInt() ?? 0,
      title: (json['title'] as String?)?.trim() ?? '',
      message: (json['message'] as String?)?.trim() ?? '',
      isRead: _resolveIsRead(json),
      createdAt: (json['created_at'] as String?)?.trim() ?? '',
    );
  }

  NotificationEntry toEntity() {
    return NotificationEntry(
      id: id,
      title: title,
      message: message,
      isRead: isRead,
      dateTimeText: _formatDateTime(createdAt),
    );
  }

  static String _formatDateTime(String raw) {
    if (raw.isEmpty) {
      return '';
    }

    final parsed = DateTime.tryParse(raw);
    if (parsed == null) {
      return raw;
    }

    final local = parsed.toLocal();
    final day = local.day.toString().padLeft(2, '0');
    final month = local.month.toString().padLeft(2, '0');
    final year = local.year.toString();
    final hour = local.hour.toString().padLeft(2, '0');
    final minute = local.minute.toString().padLeft(2, '0');
    return '$day.$month.$year, $hour:$minute';
  }

  static bool _resolveIsRead(Map<String, dynamic> json) {
    final readAt = (json['read_at'] as String?)?.trim();
    if (readAt != null && readAt.isNotEmpty) {
      return true;
    }

    return json['is_read'] == true;
  }
}
