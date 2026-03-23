import 'package:wordpice/features/rentals/domain/entities/create_booking_params.dart';

class CreateBookingRequestModel {
  static const Duration _businessCenterOffset = Duration(hours: 7);

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
      'start_time': _formatBusinessCenterDateTime(startTime),
      'end_time': _formatBusinessCenterDateTime(endTime),
      'pass_type': passType,
    };
  }

  String _formatBusinessCenterDateTime(DateTime value) {
    final year = value.year.toString().padLeft(4, '0');
    final month = value.month.toString().padLeft(2, '0');
    final day = value.day.toString().padLeft(2, '0');
    final hour = value.hour.toString().padLeft(2, '0');
    final minute = value.minute.toString().padLeft(2, '0');
    final offset = _businessCenterOffset;
    final sign = offset.isNegative ? '-' : '+';
    final totalMinutes = offset.inMinutes.abs();
    final offsetHours = (totalMinutes ~/ 60).toString().padLeft(2, '0');
    final offsetMinutes = (totalMinutes % 60).toString().padLeft(2, '0');
    return '$year-$month-$day'
        'T$hour:$minute:00$sign$offsetHours:$offsetMinutes';
  }
}
