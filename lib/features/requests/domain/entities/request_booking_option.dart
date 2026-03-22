class RequestBookingOption {
  const RequestBookingOption({
    required this.id,
    required this.placeName,
    required this.dateLabel,
    required this.timeLabel,
    required this.serviceDate,
    required this.timeSlots,
  });

  final int id;
  final String placeName;
  final String dateLabel;
  final String timeLabel;
  final String serviceDate;
  final List<String> timeSlots;

  String get displayText => '$placeName $dateLabel $timeLabel';
}
