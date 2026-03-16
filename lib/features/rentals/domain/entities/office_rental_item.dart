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
  });

  final int id;
  final String dateText;
  final String title;
  final String room;
  final int capacity;
  final List<String> availableTimeSlots;
  final int price;
  final String? photoUrl;
}
