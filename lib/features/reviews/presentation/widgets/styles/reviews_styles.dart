import 'package:flutter/material.dart';
import 'package:wordpice/core/theme/app_colors.dart';

class ReviewsStyles {
  ReviewsStyles._();

  static const cardTitle = TextStyle(
    fontSize: 20,
    fontWeight: FontWeight.w400,
    fontFamily: 'MontserratAlternates',
  );
  static const cardDate = TextStyle(fontSize: 14, color: Colors.black87);
  static const cardText = TextStyle(
    fontSize: 16,
    height: 1.5,
    fontFamily: 'Inter',
  );
  static const readMore = TextStyle(
    fontSize: 13,
    color: Colors.black87,
    decoration: TextDecoration.underline,
  );
  static const emptyState = TextStyle(
    fontSize: 24,
    fontWeight: FontWeight.w400,
  );
  static const sectionTitle = TextStyle(
    fontSize: 18,
    fontWeight: FontWeight.w400,
  );
  static const fieldLabel = TextStyle(
    fontSize: 16,
    fontWeight: FontWeight.w400,
  );
  static const buttonText = TextStyle(
    fontSize: 16,
    fontWeight: FontWeight.w400,
  );
  static const filterAll = TextStyle(fontSize: 20, fontWeight: FontWeight.w400);
  static const inputHint = TextStyle(color: Colors.black54);

  static const starActive = Color(0xFFFFFFAA);
  static const starInactive = AppColors.profileSurface;
}
