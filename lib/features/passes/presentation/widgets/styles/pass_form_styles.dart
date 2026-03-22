import 'package:flutter/material.dart';
import 'package:wordpice/core/theme/app_colors.dart';
import 'package:wordpice/core/theme/app_text_styles.dart';

class PassFormStyles {
  PassFormStyles._();

  static const double fieldHeight = 48;
  static const double buttonWidth = 200;
  static const double buttonHeight = 44;
  static const double qrPreviewSize = 170;

  static const borderSide = BorderSide(color: Colors.black87, width: 1);
  static const fieldRadius = BorderRadius.all(Radius.circular(12));
  static const trailingRadius = BorderRadius.all(Radius.circular(8));
  static const dropdownOpenRadius = BorderRadius.only(
    topLeft: Radius.circular(12),
    topRight: Radius.circular(12),
  );
  static const dropdownBottomRadius = BorderRadius.only(
    bottomLeft: Radius.circular(12),
    bottomRight: Radius.circular(12),
  );

  static const fieldPadding = EdgeInsets.only(left: 14, right: 10);
  static const editableFieldPadding = EdgeInsets.symmetric(
    horizontal: 14,
    vertical: 12,
  );

  static const title = AppTextStyles.unboundedRegular22;
  static const actionText = TextStyle(
    fontSize: 18,
    fontWeight: FontWeight.w400,
  );
  static const fieldText = TextStyle(fontSize: 16, fontWeight: FontWeight.w400);
  static const buttonText = TextStyle(
    fontSize: 16,
    fontWeight: FontWeight.w400,
  );
  static const fieldLabel = TextStyle(
    fontSize: 16,
    fontWeight: FontWeight.w400,
  );
  static const helperText = TextStyle(
    fontSize: 14,
    fontWeight: FontWeight.w400,
  );

  static const editableFieldDecoration = InputDecoration(
    filled: true,
    fillColor: AppColors.formSurface,
    contentPadding: editableFieldPadding,
    border: OutlineInputBorder(
      borderRadius: fieldRadius,
      borderSide: borderSide,
    ),
    enabledBorder: OutlineInputBorder(
      borderRadius: fieldRadius,
      borderSide: borderSide,
    ),
  );

  static BoxDecoration outlinedBox(BorderRadius radius, {Color? color}) {
    return BoxDecoration(
      color: color ?? AppColors.formSurface,
      border: Border.fromBorderSide(borderSide),
      borderRadius: radius,
    );
  }
}
