import 'package:flutter/material.dart';
import 'package:flutter_svg/flutter_svg.dart';
import 'package:wordpice/core/theme/app_colors.dart';
import 'package:wordpice/core/widgets/buttons/favorite_heart_toggle.dart';
import 'package:wordpice/core/widgets/dialogs/app_confirmation_dialog.dart';
import 'package:wordpice/features/rentals/presentation/models/office_rental_item.dart';
import 'package:wordpice/features/rentals/presentation/utils/rental_time_slots_helper.dart';
import 'package:wordpice/features/rentals/presentation/widgets/modals/office_booking_confirmation_modal.dart';
import 'package:wordpice/features/rentals/presentation/widgets/modals/office_time_picker_modal.dart';
import 'package:wordpice/features/rentals/presentation/widgets/rental_time_slot_chip.dart';
import 'package:wordpice/features/rentals/presentation/widgets/styles/rental_widget_styles.dart';

class RentalCardLayout {
  static const double previewImageSize = 88;
  static const double previewContentHeight = 134;
  static const double previewPaddingTop = 18;
  static const double previewPaddingBottom = 18;
  static const EdgeInsets previewPadding = EdgeInsets.fromLTRB(15, 18, 13, 18);
  static const double previewCardHeight =
      previewContentHeight + previewPaddingTop + previewPaddingBottom;
}

class OfficeRentalCard extends StatefulWidget {
  const OfficeRentalCard({
    super.key,
    required this.item,
    required this.bookingDate,
    required this.dateText,
    required this.availableTimeSlots,
    required this.onBook,
    required this.onBooked,
    required this.onFavoriteToggle,
    required this.onDetailsTap,
    required this.showArchiveIcon,
    this.onArchiveTap,
  });

  final OfficeRentalItem item;
  final DateTime bookingDate;
  final String dateText;
  final List<String> availableTimeSlots;
  final Future<String?> Function(String timeRange) onBook;
  final void Function(String sourceRange, String bookedRange) onBooked;
  final Future<String?> Function(bool nextValue) onFavoriteToggle;
  final Future<void> Function() onDetailsTap;
  final bool showArchiveIcon;
  final Future<String?> Function({bool force})? onArchiveTap;

  @override
  State<OfficeRentalCard> createState() => _OfficeRentalCardState();
}

class _OfficeRentalCardState extends State<OfficeRentalCard> {
  bool _isBooking = false;
  bool _isFavorite = false;
  bool _isFavoriteLoading = false;
  bool _isArchiveLoading = false;

  @override
  void initState() {
    super.initState();
    _isFavorite = widget.item.isFavorite;
  }

  @override
  void didUpdateWidget(covariant OfficeRentalCard oldWidget) {
    super.didUpdateWidget(oldWidget);
    if (oldWidget.item.isFavorite != widget.item.isFavorite) {
      _isFavorite = widget.item.isFavorite;
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

  Future<void> _pickTimeRangeForSlot(String sourceRange) async {
    if (_isBooking) return;

    final picked = await OfficeTimePickerModal.show(
      context,
      availableTime: sourceRange,
      bookingDate: widget.bookingDate,
    );
    if (picked == null || !mounted) return;

    final confirmed = await OfficeBookingConfirmationModal.show(
      context,
      date: widget.dateText,
      timeRange: picked,
      title: widget.item.title,
      room: widget.item.room,
      price: _calculateBookingPrice(picked),
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

  int _calculateBookingPrice(String timeRange) {
    final parsedRange = RentalTimeSlotsHelper.parseRange(timeRange);
    if (parsedRange == null) {
      return widget.item.price;
    }

    final hours = parsedRange.$2 - parsedRange.$1;
    if (hours <= 0) {
      return widget.item.price;
    }

    return (widget.item.price * hours).toInt();
  }

  Future<void> _archivePlace() async {
    final onArchiveTap = widget.onArchiveTap;
    if (onArchiveTap == null || _isArchiveLoading) {
      return;
    }

    setState(() => _isArchiveLoading = true);
    final errorMessage = await onArchiveTap();
    if (!mounted) {
      return;
    }

    setState(() => _isArchiveLoading = false);

    if (errorMessage == null) {
      return;
    }

    if (_needsArchiveConfirmation(errorMessage)) {
      final confirmed = await AppConfirmationDialog.show<bool>(
        context,
        title:
            '\u0410\u0440\u0445\u0438\u0432\u0430\u0446\u0438\u044f \u043f\u043e\u043c\u0435\u0449\u0435\u043d\u0438\u044f',
        message:
            '\u0423 \u044d\u0442\u043e\u0433\u043e \u043f\u043e\u043c\u0435\u0449\u0435\u043d\u0438\u044f '
            '\u0435\u0441\u0442\u044c \u0430\u043a\u0442\u0438\u0432\u043d\u044b\u0435 '
            '\u0431\u0440\u043e\u043d\u0438\u0440\u043e\u0432\u0430\u043d\u0438\u044f. '
            '\u0427\u0442\u043e\u0431\u044b \u0430\u0440\u0445\u0438\u0432\u0438\u0440\u043e\u0432\u0430\u0442\u044c '
            '\u043f\u043e\u043c\u0435\u0449\u0435\u043d\u0438\u0435, \u043f\u043e\u0434\u0442\u0432\u0435\u0440\u0434\u0438\u0442\u0435 '
            '\u0434\u0435\u0439\u0441\u0442\u0432\u0438\u0435. \u0412\u0441\u0435 '
            '\u0431\u0440\u043e\u043d\u0438\u0440\u043e\u0432\u0430\u043d\u0438\u044f \u044d\u0442\u043e\u0433\u043e '
            '\u043f\u043e\u043c\u0435\u0449\u0435\u043d\u0438\u044f \u0431\u0443\u0434\u0443\u0442 '
            '\u043e\u0442\u043c\u0435\u043d\u0435\u043d\u044b.',
        confirmLabel:
            '\u041f\u043e\u0434\u0442\u0432\u0435\u0440\u0434\u0438\u0442\u044c',
        cancelLabel: '\u041e\u0442\u043c\u0435\u043d\u0438\u0442\u044c',
        confirmResult: true,
        cancelResult: false,
      );
      if (confirmed != true || !mounted) {
        return;
      }

      setState(() => _isArchiveLoading = true);
      final forcedErrorMessage = await onArchiveTap(force: true);
      if (!mounted) {
        return;
      }

      setState(() => _isArchiveLoading = false);
      if (forcedErrorMessage == null) {
        return;
      }

      ScaffoldMessenger.of(context)
        ..hideCurrentSnackBar()
        ..showSnackBar(SnackBar(content: Text(forcedErrorMessage)));
      return;
    }

    ScaffoldMessenger.of(context)
      ..hideCurrentSnackBar()
      ..showSnackBar(SnackBar(content: Text(errorMessage)));
  }

  bool _needsArchiveConfirmation(String errorMessage) {
    final normalized = errorMessage.toLowerCase();
    return normalized.contains(
          '\u0430\u043a\u0442\u0438\u0432\u043d\u044b\u0445 \u0431\u0440\u043e\u043d\u0438\u0440',
        ) ||
        normalized.contains(
          '\u0438\u0441\u043f\u043e\u043b\u044c\u0437\u0443\u0439\u0442\u0435 force',
        ) ||
        normalized.contains('force = 1');
  }

  @override
  Widget build(BuildContext context) {
    final item = widget.item;
    final hasPhoto = item.photoUrl != null && item.photoUrl!.trim().isNotEmpty;

    return Column(
      crossAxisAlignment: CrossAxisAlignment.end,
      children: [
        Center(
          child: SizedBox(
            height: RentalCardLayout.previewCardHeight,
            child: Container(
              constraints: const BoxConstraints(maxWidth: 370),
              width: double.infinity,
              padding: RentalCardLayout.previewPadding,
              decoration: RentalWidgetStyles.outlinedBox(
                12,
                color: AppColors.formSurface,
              ),
              child: Row(
                crossAxisAlignment: CrossAxisAlignment.center,
                children: [
                  Container(
                    width: RentalCardLayout.previewImageSize,
                    height: RentalCardLayout.previewImageSize,
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
                    child: Stack(
                      children: [
                        Positioned(
                          top: 0,
                          right: 0,
                          child: FavoriteHeartToggle(
                            filled: _isFavorite,
                            isBusy: _isFavoriteLoading,
                            onTap: _toggleFavorite,
                          ),
                        ),
                        if (widget.showArchiveIcon)
                          Positioned(
                            right: 0,
                            bottom: 0,
                            child: GestureDetector(
                              onTap: _archivePlace,
                              behavior: HitTestBehavior.opaque,
                              child: SizedBox(
                                width: 28,
                                height: 28,
                                child: _isArchiveLoading
                                    ? const Padding(
                                        padding: EdgeInsets.all(2),
                                        child: CircularProgressIndicator(
                                          strokeWidth: 2,
                                        ),
                                      )
                                    : SvgPicture.asset(
                                        'assets/icons/nav_archive.svg',
                                        width: 25,
                                        height: 25,
                                        colorFilter: const ColorFilter.mode(
                                          AppColors.bottomNavBackground,
                                          BlendMode.srcIn,
                                        ),
                                      ),
                              ),
                            ),
                          ),
                        Padding(
                          padding: const EdgeInsets.only(right: 36),
                          child: Column(
                            mainAxisSize: MainAxisSize.min,
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              _OneLineRentalText(
                                item.title,
                                style: RentalWidgetStyles.cardText,
                              ),
                              const SizedBox(height: 3),
                              _OneLineRentalText(
                                item.room,
                                style: RentalWidgetStyles.cardText,
                              ),
                              const SizedBox(height: 3),
                              _OneLineRentalText(
                                '\u0421\u0442\u043e\u0438\u043c\u043e\u0441\u0442\u044c: ${item.price}\u0440/\u0447\u0430\u0441',
                                style: RentalWidgetStyles.cardText,
                              ),
                              const SizedBox(height: 3),
                              _OneLineRentalText(
                                '\u0412\u043c\u0435\u0441\u0442\u0438\u043c\u043e\u0441\u0442\u044c: ${item.capacity} \u0447\u0435\u043b\u043e\u0432\u0435\u043a',
                                style: RentalWidgetStyles.cardText,
                              ),
                              const SizedBox(height: 6),
                              InkWell(
                                onTap: widget.onDetailsTap,
                                child: Text(
                                  '\u041f\u043e\u0434\u0440\u043e\u0431\u043d\u0435\u0435',
                                  style: RentalWidgetStyles.cardText.copyWith(
                                    decoration: TextDecoration.underline,
                                  ),
                                ),
                              ),
                            ],
                          ),
                        ),
                      ],
                    ),
                  ),
                ],
              ),
            ),
          ),
        ),
        const SizedBox(height: 10),
        RentalAvailabilitySection(
          availableTimeSlots: widget.availableTimeSlots,
          isBusy: _isBooking,
          onPickTimeRange: _pickTimeRangeForSlot,
        ),
        if (_isBooking)
          const Padding(
            padding: EdgeInsets.only(top: 10, bottom: 8),
            child: SizedBox(
              width: 20,
              height: 20,
              child: CircularProgressIndicator(strokeWidth: 2),
            ),
          ),
      ],
    );
  }
}

class RentalAvailabilitySection extends StatefulWidget {
  const RentalAvailabilitySection({
    super.key,
    required this.availableTimeSlots,
    required this.isBusy,
    required this.onPickTimeRange,
  });

  final List<String> availableTimeSlots;
  final bool isBusy;
  final Future<void> Function(String sourceRange) onPickTimeRange;

  @override
  State<RentalAvailabilitySection> createState() =>
      _RentalAvailabilitySectionState();
}

class _RentalAvailabilitySectionState extends State<RentalAvailabilitySection> {
  int _slotWindowStart = 0;

  int get _maxWindowStart => (widget.availableTimeSlots.length - 2).clamp(
    0,
    widget.availableTimeSlots.length,
  );

  @override
  void didUpdateWidget(covariant RentalAvailabilitySection oldWidget) {
    super.didUpdateWidget(oldWidget);
    if (oldWidget.availableTimeSlots != widget.availableTimeSlots &&
        _slotWindowStart > _maxWindowStart) {
      _slotWindowStart = _maxWindowStart;
    }
  }

  Future<void> _pickTimeRange(String sourceRange) async {
    if (widget.isBusy) return;
    await widget.onPickTimeRange(sourceRange);
  }

  void _showPreviousSlots() {
    if (widget.isBusy) return;
    setState(() {
      _slotWindowStart = (_slotWindowStart - 1).clamp(0, _maxWindowStart);
    });
  }

  void _showNextSlots() {
    if (widget.isBusy) return;
    setState(() {
      _slotWindowStart = (_slotWindowStart + 1).clamp(0, _maxWindowStart);
    });
  }

  @override
  Widget build(BuildContext context) {
    final freeTimeSlots = widget.availableTimeSlots;
    final hasFreeTime = freeTimeSlots.isNotEmpty;
    final hasSingleSlot = freeTimeSlots.length == 1;

    if (!hasFreeTime) {
      return Center(
        child: Container(
          width: 286,
          height: 36,
          alignment: Alignment.center,
          decoration: RentalWidgetStyles.outlinedBox(
            8,
            color: AppColors.formSurface,
          ),
          child: const Text(
            '\u0421\u0432\u043e\u0431\u043e\u0434\u043d\u043e\u0433\u043e '
            '\u0432\u0440\u0435\u043c\u0435\u043d\u0438 \u043d\u0435\u0442',
            textAlign: TextAlign.center,
            style: RentalWidgetStyles.slotInfoText,
          ),
        ),
      );
    }

    if (hasSingleSlot) {
      return Center(
        child: Material(
          color: Colors.transparent,
          child: InkWell(
            onTap: () => _pickTimeRange(freeTimeSlots.first),
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
                '\u0414\u043e\u0441\u0442\u0443\u043f\u043d\u043e\u0435 '
                '\u0432\u0440\u0435\u043c\u044f: ${freeTimeSlots.first}',
                textAlign: TextAlign.center,
                style: RentalWidgetStyles.slotInfoText,
              ),
            ),
          ),
        ),
      );
    }

    if (freeTimeSlots.length <= 2) {
      return Padding(
        padding: const EdgeInsets.symmetric(horizontal: 40),
        child: Row(
          children: [
            for (var i = 0; i < freeTimeSlots.length; i++) ...[
              Expanded(
                child: RentalTimeSlotChip(
                  text: freeTimeSlots[i],
                  onTap: () => _pickTimeRange(freeTimeSlots[i]),
                ),
              ),
              if (i != freeTimeSlots.length - 1) const SizedBox(width: 10),
            ],
          ],
        ),
      );
    }

    return Padding(
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
              text: freeTimeSlots[_slotWindowStart],
              onTap: () => _pickTimeRange(freeTimeSlots[_slotWindowStart]),
            ),
          ),
          const SizedBox(width: 10),
          Expanded(
            child: RentalTimeSlotChip(
              text: freeTimeSlots[_slotWindowStart + 1],
              onTap: () => _pickTimeRange(freeTimeSlots[_slotWindowStart + 1]),
            ),
          ),
          const SizedBox(width: 10),
          _SlotArrowButton(
            icon: Icons.chevron_right,
            onTap: _slotWindowStart < freeTimeSlots.length - 2
                ? _showNextSlots
                : null,
          ),
        ],
      ),
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

class _OneLineRentalText extends StatelessWidget {
  const _OneLineRentalText(this.text, {required this.style});

  final String text;
  final TextStyle style;

  @override
  Widget build(BuildContext context) {
    return Text(
      text,
      maxLines: 1,
      overflow: TextOverflow.ellipsis,
      style: style,
    );
  }
}
