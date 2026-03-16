import 'package:flutter/material.dart';
import 'package:wordpice/features/rentals/presentation/screens/place_rental_screen.dart';

class OfficeRentalScreen extends StatelessWidget {
  const OfficeRentalScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return const PlaceRentalScreen(placeType: 'office');
  }
}
