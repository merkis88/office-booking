import 'package:wordpice/features/rentals/domain/entities/create_booking_result.dart';

class CreateBookingResponseModel {
  const CreateBookingResponseModel({
    required this.id,
    required this.placeId,
    required this.startTime,
    required this.endTime,
    required this.status,
    required this.passType,
  });

  factory CreateBookingResponseModel.fromJson(Map<String, dynamic> json) {
    final data = json['data'] as Map<String, dynamic>? ?? <String, dynamic>{};

    return CreateBookingResponseModel(
      id: _toInt(data['id']),
      placeId: _toInt(data['place_id']),
      startTime: _parseDateTime(data['start_time']),
      endTime: _parseDateTime(data['end_time']),
      status: (data['status'] as String? ?? '').trim(),
      passType: (data['pass_type'] as String? ?? '').trim(),
    );
  }

  final int id;
  final int placeId;
  final DateTime startTime;
  final DateTime endTime;
  final String status;
  final String passType;

  CreateBookingResult toEntity() {
    return CreateBookingResult(
      id: id,
      placeId: placeId,
      startTime: startTime,
      endTime: endTime,
      status: status,
      passType: passType,
    );
  }

  static int _toInt(Object? value) {
    if (value is int) return value;
    return int.tryParse(value?.toString() ?? '') ?? 0;
  }

  static DateTime _parseDateTime(Object? value) {
    final text = value?.toString() ?? '';
    return DateTime.tryParse(text) ?? DateTime.now();
  }
}
