class ArchiveItem {
  const ArchiveItem({
    required this.id,
    required this.dateText,
    required this.title,
    required this.room,
    required this.capacity,
    required this.price,
    required this.photoUrl,
    required this.description,
  });

  final int id;
  final String dateText;
  final String title;
  final String room;
  final int capacity;
  final int price;
  final String? photoUrl;
  final String description;
}
