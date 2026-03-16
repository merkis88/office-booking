class CreateBookingParams {
  const CreateBookingParams({
    required this.placeId,
    required this.userId,
    required this.startTime,
    required this.endTime,
    required this.passType,
  });

  final int placeId;
  final int userId;
  final DateTime startTime;
  final DateTime endTime;
  final String passType;
}
