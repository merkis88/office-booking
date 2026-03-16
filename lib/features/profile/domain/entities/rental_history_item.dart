
class RentalHistoryItem {
  final int? bookingId;
  final String dateLabel; 
  final String title; 
  final String room; 
  final String capacity; 
  final String priceLabel; 
  final List<String> timeSlots;

  const RentalHistoryItem({
    this.bookingId,
    required this.dateLabel,
    required this.title,
    required this.room,
    required this.capacity,
    required this.priceLabel,
    required this.timeSlots,
  });
}
