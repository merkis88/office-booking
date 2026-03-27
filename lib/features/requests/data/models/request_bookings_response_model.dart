import 'package:wordpice/features/requests/domain/entities/request_booking_option.dart';

class RequestBookingsResponseModel {
  const RequestBookingsResponseModel({required this.items});

  final List<RequestBookingOption> items;

  factory RequestBookingsResponseModel.fromJson(Map<String, dynamic> json) {
    final data = json['data'];
    final items = data is List
        ? data
              .whereType<Map>()
              .map((item) => _mapItem(item.cast<String, dynamic>()))
              .whereType<RequestBookingOption>()
              .toList()
        : const <RequestBookingOption>[];

    return RequestBookingsResponseModel(items: items);
  }

  static RequestBookingOption? _mapItem(Map<String, dynamic> item) {
    final id = _parseInt(item['id']);
    final rawDate = item['date']?.toString().trim();
    final rawTime = item['time']?.toString().trim();

    if (id == null ||
        rawDate == null ||
        rawDate.isEmpty ||
        rawTime == null ||
        rawTime.isEmpty) {
      return null;
    }

    final serviceDate = _formatServiceDate(rawDate);
    if (serviceDate == null) {
      return null;
    }

    return RequestBookingOption(
      id: id,
      placeName: _resolvePlaceName(item),
      dateLabel: _formatDateLabel(rawDate),
      timeLabel: rawTime,
      serviceDate: serviceDate,
      timeSlots: _buildTimeSlots(rawTime),
    );
  }

  static int? _parseInt(Object? value) {
    if (value is int) {
      return value;
    }
    return int.tryParse(value?.toString() ?? '');
  }

  static String _resolvePlaceName(Map<String, dynamic> item) {
    final placeName = item['place_name']?.toString().trim();
    if (placeName != null && placeName.isNotEmpty) {
      return placeName;
    }

    return 'Бронирование';
  }

  static String? _formatServiceDate(String rawDate) {
    final parts = rawDate.split('.');
    if (parts.length != 3) {
      return null;
    }

    final day = int.tryParse(parts[0]);
    final month = int.tryParse(parts[1]);
    final year = int.tryParse(parts[2]);
    if (day == null || month == null || year == null) {
      return null;
    }

    final normalizedDay = day.toString().padLeft(2, '0');
    final normalizedMonth = month.toString().padLeft(2, '0');
    return '$year-$normalizedMonth-$normalizedDay';
  }

  static String _formatDateLabel(String rawDate) {
    final parts = rawDate.split('.');
    if (parts.length != 3) {
      return rawDate.trim();
    }

    final day = int.tryParse(parts[0]);
    final month = int.tryParse(parts[1]);
    if (day == null || month == null || month < 1 || month > 12) {
      return rawDate.trim();
    }

    const months = <String>[
      'января',
      'февраля',
      'марта',
      'апреля',
      'мая',
      'июня',
      'июля',
      'августа',
      'сентября',
      'октября',
      'ноября',
      'декабря',
    ];

    return '$day ${months[month - 1]}';
  }

  static List<String> _buildTimeSlots(String rawTime) {
    final match = RegExp(
      r'(\d{2}):(\d{2})\s*-\s*(\d{2}):(\d{2})',
    ).firstMatch(rawTime);
    if (match == null) {
      return <String>[rawTime];
    }

    final startHour = int.tryParse(match.group(1) ?? '');
    final startMinute = int.tryParse(match.group(2) ?? '');
    final endHour = int.tryParse(match.group(3) ?? '');
    final endMinute = int.tryParse(match.group(4) ?? '');
    if (startHour == null ||
        startMinute == null ||
        endHour == null ||
        endMinute == null) {
      return <String>[rawTime];
    }

    final startTotal = startHour * 60 + startMinute;
    final endTotal = endHour * 60 + endMinute;
    if (endTotal <= startTotal) {
      return <String>[rawTime];
    }

    final slots = <String>[];
    for (var current = startTotal; current < endTotal; current += 60) {
      final next = current + 60;
      if (next > endTotal) {
        break;
      }
      slots.add('${_formatMinutes(current)} - ${_formatMinutes(next)}');
    }

    return slots.isEmpty ? <String>[rawTime] : slots;
  }

  static String _formatMinutes(int totalMinutes) {
    final hours = (totalMinutes ~/ 60).toString().padLeft(2, '0');
    final minutes = (totalMinutes % 60).toString().padLeft(2, '0');
    return '$hours:$minutes';
  }
}
