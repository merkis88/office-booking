import 'package:flutter/material.dart';
import 'package:wordpice/core/theme/app_colors.dart';

class ProfileRentalTypeFilters extends StatelessWidget {
  const ProfileRentalTypeFilters({
    super.key,
    required this.selectedIndex,
    required this.onChanged,
  });

  final int selectedIndex;
  final ValueChanged<int> onChanged;

  @override
  Widget build(BuildContext context) {
    Widget button(String text, int index) {
      final isSelected = selectedIndex == index;

      return SizedBox(
        width: 130,
        height: 40,
        child: Stack(
          children: [
            if (isSelected)
              Positioned(
                left: 5,
                right: 5,
                top: 34,
                child: Container(
                  height: 2,
                  decoration: BoxDecoration(
                    borderRadius: BorderRadius.circular(6),
                    color: const Color(0x01000000),
                    boxShadow: const [
                      BoxShadow(
                        color: Color(0x66000000),
                        offset: Offset(1, 2),
                        blurRadius: 4,
                        spreadRadius: 1,
                      ),
                    ],
                  ),
                ),
              ),
            Align(
              alignment: Alignment.topCenter,
              child: SizedBox(
                width: 130,
                height: 34,
                child: OutlinedButton(
                  onPressed: () => onChanged(index),
                  style: OutlinedButton.styleFrom(
                    backgroundColor: AppColors.formSurface,
                    side: const BorderSide(color: AppColors.border, width: 1),
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(6),
                    ),
                    padding: EdgeInsets.zero,
                  ),
                  child: Text(
                    text,
                    style: TextStyle(
                      fontSize: 14,
                      fontWeight:
                          isSelected ? FontWeight.w600 : FontWeight.w400,
                      color: AppColors.textPrimary,
                    ),
                  ),
                ),
              ),
            ),
          ],
        ),
      );
    }

    return Column(
      children: [
        Row(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            button('Все аренды', 0),
            const SizedBox(width: 10),
            button('Переговорные', 1),
          ],
        ),
        const SizedBox(height: 10),
        Row(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            button('Коворкинг', 2),
            const SizedBox(width: 10),
            button('Офис', 3),
          ],
        ),
      ],
    );
  }
}
