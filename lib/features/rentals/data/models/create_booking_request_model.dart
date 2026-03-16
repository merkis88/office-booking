import 'package:wordpice/features/rentals/domain/entities/create_booking_params.dart';

class CreateBookingRequestModel {
  const CreateBookingRequestModel({
    required this.placeId,
    required this.userId,
    required this.startTime,
    required this.endTime,
    required this.passType,
  });

  factory CreateBookingRequestModel.fromParams(CreateBookingParams params) {
    return CreateBookingRequestModel(
      placeId: params.placeId,
      userId: params.userId,
      startTime: params.startTime,
      endTime: params.endTime,
      passType: params.passType,
    );
  }

  final int placeId;
  final int userId;
  final DateTime startTime;
  final DateTime endTime;
  final String passType;

  Map<String, dynamic> toJson() {
    return <String, dynamic>{
      'place_id': placeId,
      'user_id': userId,
      'start_time': _formatUtcDateTime(startTime),
      'end_time': _formatUtcDateTime(endTime),
      'pass_type': passType,
    };
  }

  String _formatUtcDateTime(DateTime value) {
    final year = value.year.toString().padLeft(4, '0');
    final month = value.month.toString().padLeft(2, '0');
    final day = value.day.toString().padLeft(2, '0');
    final hour = value.hour.toString().padLeft(2, '0');
    final minute = value.minute.toString().padLeft(2, '0');
    return '$year-$month-$day'
        'T$hour:$minute:00+00:00';
  }
}
