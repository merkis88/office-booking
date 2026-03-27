import 'package:flutter/material.dart';
import 'package:wordpice/core/theme/app_colors.dart';
import 'package:wordpice/features/requests/domain/entities/request_booking_option.dart';
import 'package:wordpice/features/requests/presentation/widgets/styles/request_form_styles.dart';

class RequestFormDropdownMenu extends StatelessWidget {
  const RequestFormDropdownMenu({
    super.key,
    required this.items,
    required this.onSelect,
    required this.height,
  });

  final List<String> items;
  final ValueChanged<String> onSelect;
  final double height;

  @override
  Widget build(BuildContext context) {
    return Container(
      height: height,
      decoration: const BoxDecoration(
        color: AppColors.formSurface,
        border: RequestFormStyles.dropdownMenuBorder,
        borderRadius: RequestFormStyles.dropdownMenuRadius,
      ),
      child: ListView.separated(
        padding: const EdgeInsets.all(8),
        itemCount: items.length,
        separatorBuilder: (_, _) => const SizedBox(height: 6),
        itemBuilder: (context, index) {
          final value = items[index];
          return InkWell(
            onTap: () => onSelect(value),
            borderRadius: BorderRadius.circular(6),
            child: Container(
              height: 30,
              alignment: Alignment.centerLeft,
              padding: const EdgeInsets.symmetric(horizontal: 8),
              child: Text(value, style: RequestFormStyles.fieldText),
            ),
          );
        },
      ),
    );
  }
}

class RequestBookingDropdownMenu extends StatelessWidget {
  const RequestBookingDropdownMenu({
    super.key,
    required this.items,
    required this.onSelect,
  });

  final List<RequestBookingOption> items;
  final ValueChanged<RequestBookingOption> onSelect;

  @override
  Widget build(BuildContext context) {
    final height = _menuHeight(items.length);

    return Container(
      height: height,
      decoration: const BoxDecoration(
        color: AppColors.formSurface,
        border: RequestFormStyles.dropdownMenuBorder,
        borderRadius: RequestFormStyles.dropdownMenuRadius,
      ),
      child: ListView.separated(
        padding: const EdgeInsets.all(8),
        itemCount: items.length,
        separatorBuilder: (_, _) => const SizedBox(height: 6),
        itemBuilder: (context, index) {
          final item = items[index];
          return InkWell(
            onTap: () => onSelect(item),
            borderRadius: BorderRadius.circular(6),
            child: Container(
              constraints: const BoxConstraints(minHeight: 36),
              alignment: Alignment.centerLeft,
              padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 6),
              child: Text(
                item.displayText,
                style: RequestFormStyles.fieldText,
              ),
            ),
          );
        },
      ),
    );
  }

  double _menuHeight(int itemCount) {
    if (itemCount <= 0) {
      return 0;
    }
    if (itemCount == 1) {
      return 56;
    }
    if (itemCount == 2) {
      return 98;
    }
    return 132;
  }
}
