class RentalHistoryItem {
  const RentalHistoryItem({
    this.bookingId,
    this.placeId,
    this.placeType,
    this.dateIso,
    this.photoUrl,
    this.isFavorite = false,
    this.statusLabel,
    required this.dateLabel,
    required this.title,
    required this.room,
    required this.capacity,
    required this.priceLabel,
    required this.timeSlots,
  });

  final int? bookingId;
  final int? placeId;
  final String? placeType;
  final String? dateIso;
  final String? photoUrl;
  final bool isFavorite;
  final String? statusLabel;
  final String dateLabel;
  final String title;
  final String room;
  final String capacity;
  final String priceLabel;
  final List<String> timeSlots;

  RentalHistoryItem copyWith({
    int? bookingId,
    int? placeId,
    String? placeType,
    String? dateIso,
    String? photoUrl,
    bool? isFavorite,
    String? statusLabel,
    String? dateLabel,
    String? title,
    String? room,
    String? capacity,
    String? priceLabel,
    List<String>? timeSlots,
  }) {
    return RentalHistoryItem(
      bookingId: bookingId ?? this.bookingId,
      placeId: placeId ?? this.placeId,
      placeType: placeType ?? this.placeType,
      dateIso: dateIso ?? this.dateIso,
      photoUrl: photoUrl ?? this.photoUrl,
      isFavorite: isFavorite ?? this.isFavorite,
      statusLabel: statusLabel ?? this.statusLabel,
      dateLabel: dateLabel ?? this.dateLabel,
      title: title ?? this.title,
      room: room ?? this.room,
      capacity: capacity ?? this.capacity,
      priceLabel: priceLabel ?? this.priceLabel,
      timeSlots: timeSlots ?? this.timeSlots,
    );
  }
}
