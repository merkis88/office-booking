class RentalPlaceDetails {
  const RentalPlaceDetails({
    required this.id,
    required this.name,
    required this.type,
    required this.typeName,
    required this.capacity,
    required this.numberPlace,
    required this.price,
    required this.description,
    required this.availableTimeSlots,
    this.photoUrl,
    this.occupancyRate,
    this.date,
  });

  final int id;
  final String name;
  final String type;
  final String typeName;
  final int capacity;
  final int numberPlace;
  final int price;
  final String description;
  final List<String> availableTimeSlots;
  final String? photoUrl;
  final double? occupancyRate;
  final String? date;
}
