import 'package:wordpice/features/profile/domain/entities/profile_rentals_overview.dart';
import 'package:wordpice/features/profile/domain/entities/rental_history_item.dart';
import 'package:wordpice/features/rentals/presentation/utils/rental_date_text_helper.dart';

class ProfileBookingsResponseModel {
  const ProfileBookingsResponseModel({
    required this.items,
  });

  factory ProfileBookingsResponseModel.fromJson(Map<String, dynamic> json) {
    final rawData = json['data'];
    final items = rawData is List
        ? rawData
              .whereType<Map>()
              .map(
                (item) => ProfileBookingItemModel.fromJson(
                  item.cast<String, dynamic>(),
                ),
              )
              .toList()
        : const <ProfileBookingItemModel>[];

    return ProfileBookingsResponseModel(items: items);
  }

  final List<ProfileBookingItemModel> items;

  ProfileRentalsOverview toEntity() {
    final active = <RentalHistoryItem>[];
    final history = <RentalHistoryItem>[];

    for (final item in items) {
      final entity = item.toEntity();
      if (item.isActive) {
        active.add(entity);
      } else {
        history.add(entity);
      }
    }

    return ProfileRentalsOverview(
      activeRentals: active,
      rentalHistory: history,
    );
  }
}

class ProfileBookingItemModel {
  const ProfileBookingItemModel({
    required this.bookingId,
    required this.status,
    required this.startTime,
    required this.endTime,
    required this.placeNumber,
    required this.placeType,
    required this.capacity,
  });

  factory ProfileBookingItemModel.fromJson(Map<String, dynamic> json) {
    final place = (json['place'] as Map?)?.cast<String, dynamic>() ?? const {};

    return ProfileBookingItemModel(
      bookingId: (json['id'] as num?)?.toInt(),
      status: (json['status'] as String? ?? '').trim().toLowerCase(),
      startTime: _parseDateTime(json['start_time']),
      endTime: _parseDateTime(json['end_time']),
      placeNumber: (place['number_place'] as num?)?.toInt() ?? 0,
      placeType: (place['type'] as String? ?? '').trim(),
      capacity: (place['capacity'] as num?)?.toInt() ?? 0,
    );
  }

  final int? bookingId;
  final String status;
  final DateTime startTime;
  final DateTime endTime;
  final int placeNumber;
  final String placeType;
  final int capacity;

  bool get isActive => status == 'active' || status == 'pending';

  RentalHistoryItem toEntity() {
    final date = DateTime(startTime.year, startTime.month, startTime.day);
    final room = placeNumber > 0 ? 'Кабинет №$placeNumber' : 'Помещение';

    return RentalHistoryItem(
      bookingId: bookingId,
      dateLabel: RentalDateTextHelper.formatFullDate(date),
      title: _mapTypeToTitle(placeType),
      room: room,
      capacity: 'Вместимость: $capacity человек',
      priceLabel: '',
      timeSlots: <String>[_formatTimeRange(startTime, endTime)],
    );
  }

  static DateTime _parseDateTime(Object? value) {
    final text = value?.toString() ?? '';
    return DateTime.tryParse(text)?.toLocal() ?? DateTime.now();
  }

  static String _mapTypeToTitle(String type) {
    switch (type) {
      case 'meeting_room':
      case 'meeting':
        return 'Аренда переговорной';
      case 'office':
        return 'Аренда офиса';
      case 'coworking':
        return 'Аренда коворкинга';
      default:
        return 'Аренда помещения';
    }
  }

  static String _formatTimeRange(DateTime startTime, DateTime endTime) {
    String format(DateTime value) {
      final hour = value.hour.toString().padLeft(2, '0');
      final minute = value.minute.toString().padLeft(2, '0');
      return '$hour:$minute';
    }

    return '${format(startTime)} - ${format(endTime)}';
  }
}
