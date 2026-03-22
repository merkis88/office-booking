import 'package:flutter/material.dart';
import 'package:wordpice/features/archive/presentation/screens/archive_screen.dart';
import 'package:wordpice/features/passes/presentation/screens/passes_screen.dart';
import 'package:wordpice/features/profile/presentation/screens/profile_screen.dart';
import 'package:wordpice/features/requests/presentation/screens/requests_screen.dart';
import 'package:wordpice/features/rentals/presentation/screens/rentals_screen.dart';
import 'package:wordpice/features/reviews/presentation/screens/reviews_screen.dart';

class AppTabNavigator {
  AppTabNavigator._();

  static Widget screenForIndex(int index) {
    switch (index) {
      case 0:
        return const RentalsScreen();
      case 1:
        return const RequestsScreen();
      case 2:
        return const PassesScreen();
      case 3:
        return const ProfileScreen();
      case 4:
        return const ReviewsScreen();
      case 5:
        return const ArchiveScreen();
      default:
        return const _PlaceholderScreen(title: 'Раздел');
    }
  }

  static void goToTab(BuildContext context, int index) {
    Navigator.pushReplacement(
      context,
      MaterialPageRoute(builder: (_) => screenForIndex(index)),
    );
  }
}

class _PlaceholderScreen extends StatelessWidget {
  const _PlaceholderScreen({required this.title});

  final String title;

  @override
  Widget build(BuildContext context) {
    return Scaffold(body: Center(child: Text(title)));
  }
}
