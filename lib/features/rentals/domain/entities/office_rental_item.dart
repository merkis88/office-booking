class OfficeRentalItem {
  const OfficeRentalItem({
    required this.id,
    required this.dateText,
    required this.title,
    required this.room,
    required this.capacity,
    required this.availableTimeSlots,
    required this.price,
    required this.photoUrl,
    this.isFavorite = false,
  });

  final int id;
  final String dateText;
  final String title;
  final String room;
  final int capacity;
  final List<String> availableTimeSlots;
  final int price;
  final String? photoUrl;
  final bool isFavorite;

  OfficeRentalItem copyWith({
    int? id,
    String? dateText,
    String? title,
    String? room,
    int? capacity,
    List<String>? availableTimeSlots,
    int? price,
    String? photoUrl,
    bool? isFavorite,
  }) {
    return OfficeRentalItem(
      id: id ?? this.id,
      dateText: dateText ?? this.dateText,
      title: title ?? this.title,
      room: room ?? this.room,
      capacity: capacity ?? this.capacity,
      availableTimeSlots: availableTimeSlots ?? this.availableTimeSlots,
      price: price ?? this.price,
      photoUrl: photoUrl ?? this.photoUrl,
      isFavorite: isFavorite ?? this.isFavorite,
    );
  }
}
