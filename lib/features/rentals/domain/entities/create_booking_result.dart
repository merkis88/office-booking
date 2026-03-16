class CreateBookingResult {
  const CreateBookingResult({
    required this.id,
    required this.placeId,
    required this.startTime,
    required this.endTime,
    required this.status,
    required this.passType,
  });

  final int id;
  final int placeId;
  final DateTime startTime;
  final DateTime endTime;
  final String status;
  final String passType;
}
