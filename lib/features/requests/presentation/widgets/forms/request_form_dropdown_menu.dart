import 'package:flutter/material.dart';
import 'package:wordpice/features/requests/domain/entities/request_booking_option.dart';
import 'package:wordpice/features/requests/presentation/widgets/styles/request_form_styles.dart';

const _kDropdownSurfaceColor = Color(0xFFE6F2FA);
const _kDropdownMaxHeight = 116.0;

Future<String?> showRequestFormDropdownMenu({
  required BuildContext context,
  required GlobalKey anchorKey,
  required List<String> items,
}) {
  return _showOverlayDropdown<String>(
    context: context,
    anchorKey: anchorKey,
    items: items,
    labelBuilder: (value) => value,
  );
}

Future<RequestBookingOption?> showRequestBookingDropdownMenu({
  required BuildContext context,
  required GlobalKey anchorKey,
  required List<RequestBookingOption> items,
}) {
  return _showOverlayDropdown<RequestBookingOption>(
    context: context,
    anchorKey: anchorKey,
    items: items,
    labelBuilder: (value) => value.displayText,
  );
}

Future<T?> _showOverlayDropdown<T>({
  required BuildContext context,
  required GlobalKey anchorKey,
  required List<T> items,
  required String Function(T value) labelBuilder,
}) async {
  final anchorContext = anchorKey.currentContext;
  if (anchorContext == null || items.isEmpty) {
    return null;
  }

  final buttonBox = anchorContext.findRenderObject() as RenderBox;
  final overlayBox =
      Overlay.of(context).context.findRenderObject() as RenderBox;
  final topLeft = buttonBox.localToGlobal(Offset.zero, ancestor: overlayBox);
  final buttonRect = Rect.fromLTWH(
    topLeft.dx,
    topLeft.dy,
    buttonBox.size.width,
    buttonBox.size.height,
  );

  return showMenu<T>(
    context: context,
    color: _kDropdownSurfaceColor,
    surfaceTintColor: _kDropdownSurfaceColor,
    shadowColor: Colors.black12,
    elevation: 4,
    clipBehavior: Clip.antiAlias,
    menuPadding: EdgeInsets.zero,
    constraints: BoxConstraints(
      minWidth: buttonBox.size.width,
      maxWidth: buttonBox.size.width,
      maxHeight: _kDropdownMaxHeight,
    ),
    shape: const RoundedRectangleBorder(
      side: BorderSide(color: Colors.black87, width: 1),
      borderRadius: BorderRadius.vertical(
        top: Radius.zero,
        bottom: Radius.circular(12),
      ),
    ),
    position: RelativeRect.fromRect(
      Rect.fromLTWH(
        buttonRect.left,
        buttonRect.bottom,
        buttonRect.width,
        0,
      ),
      Offset.zero & overlayBox.size,
    ),
    items: [
      for (final item in items)
        PopupMenuItem<T>(
          value: item,
          padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 10),
          child: Text(
            labelBuilder(item),
            style: RequestFormStyles.fieldText,
            maxLines: 2,
            overflow: TextOverflow.ellipsis,
          ),
        ),
    ],
  );
}

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
        color: _kDropdownSurfaceColor,
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
        color: _kDropdownSurfaceColor,
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
