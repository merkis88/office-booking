class NotificationEntry {
  const NotificationEntry({
    required this.id,
    required this.title,
    required this.message,
    required this.dateTimeText,
    required this.isRead,
  });

  final int id;
  final String title;
  final String message;
  final String dateTimeText;
  final bool isRead;
}
