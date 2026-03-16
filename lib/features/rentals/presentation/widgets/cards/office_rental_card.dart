import 'package:flutter/material.dart';
import 'package:flutter_svg/flutter_svg.dart';
import 'package:wordpice/core/theme/app_colors.dart';
import 'package:wordpice/core/widgets/buttons/favorite_heart_toggle.dart';
import 'package:wordpice/features/rentals/presentation/models/office_rental_item.dart';
import 'package:wordpice/features/rentals/presentation/widgets/modals/office_booking_confirmation_modal.dart';
import 'package:wordpice/features/rentals/presentation/widgets/modals/office_time_picker_modal.dart';
import 'package:wordpice/features/rentals/presentation/widgets/rental_time_slot_chip.dart';
import 'package:wordpice/features/rentals/presentation/widgets/styles/rental_widget_styles.dart';

class OfficeRentalCard extends StatefulWidget {
  const OfficeRentalCard({
    super.key,
    required this.item,
    required this.dateText,
    required this.availableTimeSlots,
    required this.onBook,
    required this.onBooked,
    required this.onFavoriteToggle,
  });

  final OfficeRentalItem item;
  final String dateText;
  final List<String> availableTimeSlots;
  final Future<String?> Function(String timeRange) onBook;
  final void Function(String sourceRange, String bookedRange) onBooked;
  final Future<String?> Function(bool nextValue) onFavoriteToggle;

  @override
  State<OfficeRentalCard> createState() => _OfficeRentalCardState();
}

class _OfficeRentalCardState extends State<OfficeRentalCard> {
  late final List<String> _freeTimeSlots;
  int _slotWindowStart = 0;
  bool _isBooking = false;
  bool _isFavorite = false;
  bool _isFavoriteLoading = false;

  int get _maxWindowStart =>
      (_freeTimeSlots.length - 2).clamp(0, _freeTimeSlots.length);

  @override
  void initState() {
    super.initState();
    _freeTimeSlots = List<String>.from(widget.availableTimeSlots);
  }

  @override
  void didUpdateWidget(covariant OfficeRentalCard oldWidget) {
    super.didUpdateWidget(oldWidget);
    if (oldWidget.availableTimeSlots != widget.availableTimeSlots) {
      _freeTimeSlots
        ..clear()
        ..addAll(widget.availableTimeSlots);
      if (_slotWindowStart > _maxWindowStart) {
        _slotWindowStart = _maxWindowStart;
      }
    }
  }

  Future<void> _toggleFavorite() async {
    if (_isFavoriteLoading) return;

    final nextValue = !_isFavorite;
    setState(() => _isFavoriteLoading = true);
    final errorMessage = await widget.onFavoriteToggle(nextValue);
    if (!mounted) return;

    setState(() {
      _isFavoriteLoading = false;
      if (errorMessage == null) {
        _isFavorite = nextValue;
      }
    });

    if (errorMessage != null) {
      ScaffoldMessenger.of(context)
        ..hideCurrentSnackBar()
        ..showSnackBar(SnackBar(content: Text(errorMessage)));
    }
  }

  Future<void> _pickTimeRange() async {
    if (_freeTimeSlots.isEmpty || _isBooking) return;
    await _pickTimeRangeForSlot(_freeTimeSlots.first);
  }

  Future<void> _pickTimeRangeForSlot(String sourceRange) async {
    if (_isBooking) return;

    final picked = await OfficeTimePickerModal.show(
      context,
      availableTime: sourceRange,
    );
    if (picked == null || !mounted) return;

    final confirmed = await OfficeBookingConfirmationModal.show(
      context,
      date: widget.dateText,
      timeRange: picked,
      title: widget.item.title,
      room: widget.item.room,
      price: widget.item.price,
    );
    if (!confirmed || !mounted) return;

    setState(() => _isBooking = true);
    final errorMessage = await widget.onBook(picked);
    if (!mounted) return;
    setState(() => _isBooking = false);

    if (errorMessage != null) {
      ScaffoldMessenger.of(context)
        ..hideCurrentSnackBar()
        ..showSnackBar(SnackBar(content: Text(errorMessage)));
      return;
    }

    widget.onBooked(sourceRange, picked);
  }

  void _showPreviousSlots() {
    if (_isBooking) return;
    setState(() {
      _slotWindowStart = (_slotWindowStart - 1).clamp(0, _maxWindowStart);
    });
  }

  void _showNextSlots() {
    if (_isBooking) return;
    setState(() {
      _slotWindowStart = (_slotWindowStart + 1).clamp(0, _maxWindowStart);
    });
  }

  @override
  Widget build(BuildContext context) {
    final item = widget.item;
    final hasFreeTime = _freeTimeSlots.isNotEmpty;
    final hasSingleSlot = _freeTimeSlots.length == 1;
    final hasPhoto = item.photoUrl != null && item.photoUrl!.trim().isNotEmpty;

    return Column(
      crossAxisAlignment: CrossAxisAlignment.end,
      children: [
        Center(
          child: Container(
            constraints: const BoxConstraints(maxWidth: 332),
            width: double.infinity,
            padding: const EdgeInsets.fromLTRB(14, 10, 12, 10),
            decoration: RentalWidgetStyles.outlinedBox(
              12,
              color: AppColors.formSurface,
            ),
            child: Row(
              crossAxisAlignment: CrossAxisAlignment.center,
              children: [
                Container(
                  width: 80,
                  height: 80,
                  decoration: BoxDecoration(
                    color: const Color(0xFFBDBDBD),
                    borderRadius: BorderRadius.circular(8),
                    border: Border.all(
                      color: AppColors.bottomNavBackground,
                      width: 1.5,
                    ),
                  ),
                  child: ClipRRect(
                    borderRadius: BorderRadius.circular(6),
                    child: hasPhoto
                        ? Image.network(
                            item.photoUrl!,
                            fit: BoxFit.cover,
                            errorBuilder: (_, _, _) => const _PhotoPlaceholder(),
                          )
                        : const _PhotoPlaceholder(),
                  ),
                ),
                const SizedBox(width: 12),
                Expanded(
                  child: SizedBox(
                    height: 90,
                    child: Stack(
                      children: [
                        Align(
                          alignment: Alignment.topRight,
                          child: Column(
                            mainAxisSize: MainAxisSize.min,
                            crossAxisAlignment: CrossAxisAlignment.end,
                            children: [
                              FavoriteHeartToggle(
                                filled: _isFavorite,
                                isBusy: _isFavoriteLoading,
                                onTap: _toggleFavorite,
                              ),
                              const SizedBox(height: 6),
                              SvgPicture.asset(
                                'assets/icons/nav_archive.svg',
                                width: 22,
                                height: 22,
                                colorFilter: const ColorFilter.mode(
                                  Colors.black87,
                                  BlendMode.srcIn,
                                ),
                              ),
                            ],
                          ),
                        ),
                        Center(
                          child: Column(
                            mainAxisSize: MainAxisSize.min,
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Text(
                                item.title,
                                style: RentalWidgetStyles.cardText,
                              ),
                              const SizedBox(height: 3),
                              Text(
                                item.room,
                                style: RentalWidgetStyles.cardText,
                              ),
                              const SizedBox(height: 3),
                              Text(
                                'Вместимость: ${item.capacity} человек',
                                style: RentalWidgetStyles.cardText,
                              ),
                            ],
                          ),
                        ),
                      ],
                    ),
                  ),
                ),
              ],
            ),
          ),
        ),
        const SizedBox(height: 10),
        if (!hasFreeTime)
          Center(
            child: Container(
              width: 286,
              height: 36,
              alignment: Alignment.center,
              decoration: RentalWidgetStyles.outlinedBox(
                8,
                color: AppColors.formSurface,
              ),
              child: const Text(
                'Свободного времени нет',
                textAlign: TextAlign.center,
                style: RentalWidgetStyles.slotInfoText,
              ),
            ),
          ),
        if (hasSingleSlot) ...[
          Center(
            child: Material(
              color: Colors.transparent,
              child: InkWell(
                onTap: _pickTimeRange,
                borderRadius: BorderRadius.circular(8),
                child: Container(
                  width: 286,
                  height: 36,
                  padding: const EdgeInsets.symmetric(horizontal: 12),
                  decoration: RentalWidgetStyles.outlinedBox(
                    8,
                    color: AppColors.formSurface,
                  ),
                  alignment: Alignment.center,
                  child: Text(
                    'Доступное время: ${_freeTimeSlots.first}',
                    textAlign: TextAlign.center,
                    style: RentalWidgetStyles.slotInfoText,
                  ),
                ),
              ),
            ),
          ),
        ],
        if (hasFreeTime && !hasSingleSlot) ...[
          if (_freeTimeSlots.length <= 2)
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 40),
              child: Row(
                children: [
                  for (var i = 0; i < _freeTimeSlots.length; i++) ...[
                    Expanded(
                      child: RentalTimeSlotChip(
                        text: _freeTimeSlots[i],
                        onTap: () => _pickTimeRangeForSlot(_freeTimeSlots[i]),
                      ),
                    ),
                    if (i != _freeTimeSlots.length - 1)
                      const SizedBox(width: 10),
                  ],
                ],
              ),
            )
          else
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 24),
              child: Row(
                children: [
                  _SlotArrowButton(
                    icon: Icons.chevron_left,
                    onTap: _slotWindowStart > 0 ? _showPreviousSlots : null,
                  ),
                  const SizedBox(width: 10),
                  Expanded(
                    child: RentalTimeSlotChip(
                      text: _freeTimeSlots[_slotWindowStart],
                      onTap: () => _pickTimeRangeForSlot(
                        _freeTimeSlots[_slotWindowStart],
                      ),
                    ),
                  ),
                  const SizedBox(width: 10),
                  Expanded(
                    child: RentalTimeSlotChip(
                      text: _freeTimeSlots[_slotWindowStart + 1],
                      onTap: () => _pickTimeRangeForSlot(
                        _freeTimeSlots[_slotWindowStart + 1],
                      ),
                    ),
                  ),
                  const SizedBox(width: 10),
                  _SlotArrowButton(
                    icon: Icons.chevron_right,
                    onTap: _slotWindowStart < _freeTimeSlots.length - 2
                        ? _showNextSlots
                        : null,
                  ),
                ],
              ),
            ),
        ],
        const SizedBox(height: 10),
        if (_isBooking)
          const Padding(
            padding: EdgeInsets.only(bottom: 8),
            child: SizedBox(
              width: 20,
              height: 20,
              child: CircularProgressIndicator(strokeWidth: 2),
            ),
          ),
        Text('${item.price}р', style: RentalWidgetStyles.priceText),
      ],
    );
  }
}

class _SlotArrowButton extends StatelessWidget {
  const _SlotArrowButton({required this.icon, required this.onTap});

  final IconData icon;
  final VoidCallback? onTap;

  @override
  Widget build(BuildContext context) {
    return InkWell(
      onTap: onTap,
      borderRadius: BorderRadius.circular(10),
      child: Container(
        width: 30,
        height: 30,
        decoration: RentalWidgetStyles.outlinedBox(10),
        child: Icon(
          icon,
          size: 20,
          color: onTap == null ? Colors.black38 : Colors.black87,
        ),
      ),
    );
  }
}

class _PhotoPlaceholder extends StatelessWidget {
  const _PhotoPlaceholder();

  @override
  Widget build(BuildContext context) {
    return const Icon(
      Icons.image_outlined,
      size: 28,
      color: Colors.white,
    );
  }
}
