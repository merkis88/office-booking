import 'package:flutter/material.dart';
import 'package:wordpice/features/rentals/presentation/screens/place_rental_screen.dart';

class CoworkingRentalScreen extends StatelessWidget {
  const CoworkingRentalScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return const PlaceRentalScreen(placeType: 'coworking');
  }
}
