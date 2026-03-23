import 'package:flutter/material.dart';
import 'package:flutter_svg/flutter_svg.dart';
import 'package:wordpice/core/theme/app_colors.dart';

class AppBottomNavBar extends StatefulWidget {
  const AppBottomNavBar({
    super.key,
    required this.selectedIndex,
    required this.onChanged,
    required this.showArchive,
  });

  final int selectedIndex;
  final ValueChanged<int> onChanged;
  final bool showArchive;

  @override
  State<AppBottomNavBar> createState() => _AppBottomNavBarState();
}

class _AppBottomNavBarState extends State<AppBottomNavBar> {
  static const int _visibleCount = 4;
  static const int _loopMultiplier = 1000;
  static int _persistedStartIndex = 0;

  final List<_NavItemData> _items = const <_NavItemData>[
    _NavItemData(
      label: 'Аренды',
      iconAsset: 'assets/icons/nav_rentals.svg',
      routeIndex: 0,
    ),
    _NavItemData(
      label: 'Заявки',
      iconAsset: 'assets/icons/nav_requests.svg',
      routeIndex: 1,
    ),
    _NavItemData(
      label: 'Пропуск',
      iconAsset: 'assets/icons/nav_pass.svg',
      routeIndex: 2,
    ),
    _NavItemData(
      label: 'Профиль',
      iconAsset: 'assets/icons/nav_profile.svg',
      routeIndex: 3,
    ),
    _NavItemData(
      label: 'Отзывы',
      iconAsset: 'assets/icons/nav_reviews.svg',
      routeIndex: 4,
    ),
    _NavItemData(
      label: 'Архив',
      iconAsset: 'assets/icons/nav_archive.svg',
      routeIndex: 5,
    ),
  ];

  late final PageController _controller;
  late int _page;

  List<_NavItemData> get _visibleItems => widget.showArchive
      ? _items
      : _items.where((item) => item.routeIndex != 5).toList();

  int get _itemsCount => _visibleItems.length;

  @override
  void initState() {
    super.initState();
    final startIndex = _persistedStartIndex.clamp(0, _itemsCount - 1);
    final basePage = _itemsCount * _loopMultiplier;
    _page = basePage + startIndex;
    _controller = PageController(
      initialPage: _page,
      viewportFraction: 1 / _visibleCount,
    );
  }

  @override
  void didUpdateWidget(covariant AppBottomNavBar oldWidget) {
    super.didUpdateWidget(oldWidget);
    if (oldWidget.showArchive != widget.showArchive) {
      final nextStartIndex = _persistedStartIndex.clamp(0, _itemsCount - 1);
      final nextPage = _itemsCount * _loopMultiplier + nextStartIndex;
      _page = nextPage;
      _persistedStartIndex = nextStartIndex;
      _controller.jumpToPage(nextPage);
    }
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  void _prev() {
    _controller.previousPage(
      duration: const Duration(milliseconds: 250),
      curve: Curves.easeOut,
    );
  }

  void _next() {
    _controller.nextPage(
      duration: const Duration(milliseconds: 250),
      curve: Curves.easeOut,
    );
  }

  @override
  Widget build(BuildContext context) {
    return Container(
      height: 116,
      padding: const EdgeInsets.fromLTRB(12, 12, 12, 16),
      decoration: BoxDecoration(
        color: AppColors.bottomNavBackground,
        borderRadius: const BorderRadius.only(
          topLeft: Radius.circular(18),
          topRight: Radius.circular(18),
        ),
      ),
      child: Row(
        children: [
          _ArrowButton(icon: Icons.chevron_left, onTap: _prev),
          const SizedBox(width: 10),
          Expanded(
            child: SizedBox(
              height: 80,
              child: PageView.builder(
                controller: _controller,
                padEnds: false,
                onPageChanged: (page) {
                  _page = page;
                  _persistedStartIndex = page % _itemsCount;
                },
                itemCount: _itemsCount * _loopMultiplier * 2,
                itemBuilder: (_, page) {
                  final itemIndex = page % _itemsCount;
                  final item = _visibleItems[itemIndex];
                  final isSelected = item.routeIndex == widget.selectedIndex;

                  return SizedBox.expand(
                    child: _NavItem(
                      label: item.label,
                      iconAsset: item.iconAsset,
                      isSelected: isSelected,
                      onTap: () => widget.onChanged(item.routeIndex),
                    ),
                  );
                },
              ),
            ),
          ),
          const SizedBox(width: 10),
          _ArrowButton(icon: Icons.chevron_right, onTap: _next),
        ],
      ),
    );
  }
}

class _ArrowButton extends StatelessWidget {
  const _ArrowButton({
    required this.icon,
    required this.onTap,
  });

  final IconData icon;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    return SizedBox(
      width: 34,
      height: 34,
      child: OutlinedButton(
        onPressed: onTap,
        style: OutlinedButton.styleFrom(
          padding: EdgeInsets.zero,
          side: BorderSide(color: AppColors.border, width: 1),
          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(14)),
        ),
        child: Icon(icon, color: Colors.black87, size: 20),
      ),
    );
  }
}

class _NavItem extends StatelessWidget {
  const _NavItem({
    required this.label,
    required this.iconAsset,
    required this.isSelected,
    required this.onTap,
  });

  final String label;
  final String iconAsset;
  final bool isSelected;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    return InkWell(
      borderRadius: BorderRadius.circular(12),
      onTap: onTap,
      child: Padding(
        padding: const EdgeInsets.symmetric(horizontal: 4),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            AnimatedContainer(
              duration: const Duration(milliseconds: 180),
              curve: Curves.easeOut,
              width: 48,
              height: 48,
              decoration: BoxDecoration(
                shape: BoxShape.circle,
                color: isSelected ? const Color(0x40FFFFFF) : Colors.transparent,
              ),
              alignment: Alignment.center,
              child: SvgPicture.asset(
                iconAsset,
                width: 33,
                height: 33,
                colorFilter: const ColorFilter.mode(
                  Colors.black87,
                  BlendMode.srcIn,
                ),
              ),
            ),
            Text(
              label,
              maxLines: 1,
              overflow: TextOverflow.ellipsis,
              style: TextStyle(
                fontSize: 13,
                fontWeight: isSelected ? FontWeight.w600 : FontWeight.w400,
                color: AppColors.textPrimary,
              ),
            ),
          ],
        ),
      ),
    );
  }
}

class _NavItemData {
  const _NavItemData({
    required this.label,
    required this.iconAsset,
    required this.routeIndex,
  });

  final String label;
  final String iconAsset;
  final int routeIndex;
}
