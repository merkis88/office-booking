import 'package:flutter/material.dart';
import 'package:wordpice/app/app_scope.dart';
import 'package:wordpice/core/network/api_client.dart';
import 'package:wordpice/core/theme/app_colors.dart';
import 'package:wordpice/core/widgets/buttons/app_outlined_icon_button.dart';
import 'package:wordpice/core/widgets/dialogs/app_confirmation_dialog.dart';
import 'package:wordpice/features/passes/presentation/screens/employee_pass_screen.dart';
import 'package:wordpice/features/profile/domain/entities/rental_history_item.dart';
import 'package:wordpice/features/profile/presentation/widgets/cards/profile_rental_card_layout.dart';
import 'package:wordpice/features/profile/presentation/widgets/modals/profile_booking_reschedule_modal.dart';
import 'package:wordpice/features/profile/presentation/widgets/styles/profile_card_styles.dart';
import 'package:wordpice/features/rentals/presentation/utils/tomsk_time_helper.dart';
import 'package:wordpice/features/rentals/presentation/widgets/modals/office_time_picker_modal.dart';

class ProfileActiveRentalCard extends StatefulWidget {
  const ProfileActiveRentalCard({
    super.key,
    required this.item,
    required this.onCancelPressed,
    required this.onFavoritePressed,
    this.isCancelling = false,
    this.isFavoriteBusy = false,
  });

  final RentalHistoryItem item;
  final Future<void> Function(RentalHistoryItem item) onCancelPressed;
  final Future<void> Function(RentalHistoryItem item) onFavoritePressed;
  final bool isCancelling;
  final bool isFavoriteBusy;

  @override
  State<ProfileActiveRentalCard> createState() =>
      _ProfileActiveRentalCardState();
}

class _ProfileActiveRentalCardState extends State<ProfileActiveRentalCard> {
  static const int _loopMultiplier = 1000;
  static const List<String> _actions = [
    'Пригласить сотрудника',
    'Перенести бронирование',
    'Отменить бронь',
  ];

  late final PageController _actionController;
  bool _isRescheduleLoading = false;
  String? _rescheduledTime;

  @override
  void initState() {
    super.initState();
    _actionController = PageController(
      initialPage: _actions.length * _loopMultiplier,
      viewportFraction: 1,
    );
  }

  @override
  void dispose() {
    _actionController.dispose();
    super.dispose();
  }

  void _showPrevAction() {
    _actionController.previousPage(
      duration: const Duration(milliseconds: 250),
      curve: Curves.easeOut,
    );
  }

  void _showNextAction() {
    _actionController.nextPage(
      duration: const Duration(milliseconds: 250),
      curve: Curves.easeOut,
    );
  }

  Future<void> _onActionPressed(int actionIndex) async {
    if (actionIndex == 0) {
      if (!mounted) {
        return;
      }
      await Navigator.of(
        context,
      ).push(MaterialPageRoute(builder: (_) => const EmployeePassScreen()));
      return;
    }

    if (actionIndex == 1) {
      await _openRescheduleFlow();
      return;
    }

    if (actionIndex != 2 || widget.isCancelling) {
      return;
    }

    final shouldCancel = await AppConfirmationDialog.show<bool>(
      context,
      title: 'Отмена брони',
      message: 'Вы действительно хотите отменить бронь?',
      confirmLabel: 'Подтвердить',
      cancelLabel: 'Отмена',
      confirmResult: true,
      cancelResult: false,
    );

    if (shouldCancel != true || !mounted) {
      return;
    }
    await widget.onCancelPressed(widget.item);
  }

  Future<void> _openRescheduleFlow() async {
    final placeId = widget.item.placeId;
    final placeType = widget.item.placeType;
    final dateIso = widget.item.dateIso;

    if (placeId == null || placeType == null || dateIso == null) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('Не удалось загрузить доступное время для переноса.'),
        ),
      );
      return;
    }

    setState(() {
      _isRescheduleLoading = true;
    });

    List<String> availableSlots;
    final currentBookingTime = widget.item.timeSlots.isEmpty
        ? null
        : widget.item.timeSlots.first;

    try {
      final type = _mapPlaceTypeToQuery(placeType);
      if (type == null) {
        throw const ApiConnectionException(
          'Не удалось определить тип помещения.',
        );
      }

      final places = await AppScope.of(context).rentalsRepository.getPlaces(
        type: type,
        date: dateIso,
        minPrice: 0,
        maxPrice: 1000000000,
      );

      if (!mounted) {
        return;
      }

      final currentPlace = places.items.where((item) => item.id == placeId);
      if (currentPlace.isEmpty) {
        throw const ApiConnectionException(
          'Не удалось найти доступное время этого помещения.',
        );
      }

      final filteredAvailableSlots = _filterPastTimeSlots(
        currentPlace.first.availableTimeSlots,
        dateIso: dateIso,
      );
      availableSlots = _mergeCurrentBookingWithAvailableSlots(
        availableSlots: filteredAvailableSlots,
        currentBookingTime: currentBookingTime,
      );
    } catch (error) {
      if (!mounted) {
        return;
      }
      final message = error is ApiConnectionException
          ? error.message
          : 'Не удалось загрузить доступное время для переноса.';
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text(message)),
      );
      return;
    } finally {
      if (mounted) {
        setState(() {
          _isRescheduleLoading = false;
        });
      }
    }

    if (availableSlots.isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('Нет доступных слотов для переноса.'),
        ),
      );
      return;
    }

    final selectedSlot = await ProfileBookingRescheduleModal.show(
      context,
      title: widget.item.title,
      dateLabel: widget.item.dateLabel,
      availableSlots: availableSlots,
    );

    if (selectedSlot == null || !mounted) {
      return;
    }

    final selectedTime = await OfficeTimePickerModal.show(
      context,
      availableTime: selectedSlot,
      bookingDate: DateTime.tryParse(dateIso) ?? DateTime.now(),
      submitLabel: 'Перенести бронирование',
    );

    if (selectedTime == null || !mounted) {
      return;
    }

    final bookingId = widget.item.bookingId;
    final startTime = _buildRequestDateTime(
      dateIso: dateIso,
      timeRange: selectedTime,
      takeEnd: false,
    );
    final endTime = _buildRequestDateTime(
      dateIso: dateIso,
      timeRange: selectedTime,
      takeEnd: true,
    );

    if (bookingId == null || startTime == null || endTime == null) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('Не удалось подготовить данные для переноса.'),
        ),
      );
      return;
    }

    setState(() {
      _isRescheduleLoading = true;
    });

    try {
      await AppScope.of(context).profileRepository.rescheduleBooking(
        bookingId: bookingId,
        startTime: startTime,
        endTime: endTime,
      );

      if (!mounted) {
        return;
      }

      setState(() {
        _rescheduledTime = selectedTime;
      });
    } catch (error) {
      if (!mounted) {
        return;
      }

      final message = error is ApiConnectionException
          ? error.message
          : 'Не удалось перенести бронирование.';
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text(message)),
      );
    } finally {
      if (mounted) {
        setState(() {
          _isRescheduleLoading = false;
        });
      }
    }
  }

  String? _mapPlaceTypeToQuery(String value) {
    switch (value) {
      case 'meeting_room':
      case 'meeting':
        return 'meeting';
      case 'office':
        return 'office';
      case 'coworking':
        return 'coworking';
      default:
        return null;
    }
  }

  List<String> _mergeCurrentBookingWithAvailableSlots({
    required List<String> availableSlots,
    required String? currentBookingTime,
  }) {
    final ranges = <_TimeRange>[
      for (final slot in availableSlots)
        if (_parseRange(slot) != null) _parseRange(slot)!,
    ];

    final currentRange = _parseRange(currentBookingTime);
    if (currentRange != null) {
      ranges.add(currentRange);
    }

    if (ranges.isEmpty) {
      return const <String>[];
    }

    ranges.sort((a, b) => a.startMinutes.compareTo(b.startMinutes));

    final merged = <_TimeRange>[ranges.first];
    for (var i = 1; i < ranges.length; i++) {
      final last = merged.last;
      final next = ranges[i];

      if (next.startMinutes <= last.endMinutes) {
        merged[merged.length - 1] = _TimeRange(
          startMinutes: last.startMinutes,
          endMinutes: next.endMinutes > last.endMinutes
              ? next.endMinutes
              : last.endMinutes,
        );
        continue;
      }

      if (next.startMinutes == last.endMinutes) {
        merged[merged.length - 1] = _TimeRange(
          startMinutes: last.startMinutes,
          endMinutes: next.endMinutes,
        );
        continue;
      }

      merged.add(next);
    }

    return merged.map(_formatRange).toList();
  }

  List<String> _filterPastTimeSlots(
    List<String> slots, {
    required String dateIso,
  }) {
    final bookingDate = DateTime.tryParse(dateIso);
    if (bookingDate == null) {
      return slots;
    }

    final now = TomskTimeHelper.now();
    final isToday =
        bookingDate.year == now.year &&
        bookingDate.month == now.month &&
        bookingDate.day == now.day;

    if (!isToday) {
      return slots;
    }

    final nextAvailableHour =
        now.minute > 0 || now.second > 0 || now.millisecond > 0
        ? now.hour + 1
        : now.hour;

    final filtered = <String>[];
    for (final slot in slots) {
      final parsedRange = _parseRange(slot);
      if (parsedRange == null) {
        filtered.add(slot);
        continue;
      }

      final effectiveStart = nextAvailableHour > parsedRange.startMinutes ~/ 60
          ? nextAvailableHour
          : parsedRange.startMinutes ~/ 60;
      final endHour = parsedRange.endMinutes ~/ 60;

      if (effectiveStart >= endHour) {
        continue;
      }

      filtered.add(_formatRange(_TimeRange(
        startMinutes: effectiveStart * 60,
        endMinutes: parsedRange.endMinutes,
      )));
    }

    return filtered;
  }

  _TimeRange? _parseRange(String? value) {
    if (value == null || value.isEmpty) {
      return null;
    }

    final match = RegExp(
      r'(\d{2}):(\d{2})\s*-\s*(\d{2}):(\d{2})',
    ).firstMatch(value);
    if (match == null) {
      return null;
    }

    int? parsePart(int index) => int.tryParse(match.group(index) ?? '');
    final startHour = parsePart(1);
    final startMinute = parsePart(2);
    final endHour = parsePart(3);
    final endMinute = parsePart(4);
    if (startHour == null ||
        startMinute == null ||
        endHour == null ||
        endMinute == null) {
      return null;
    }

    return _TimeRange(
      startMinutes: startHour * 60 + startMinute,
      endMinutes: endHour * 60 + endMinute,
    );
  }

  String _formatRange(_TimeRange range) {
    String formatMinutes(int totalMinutes) {
      final hours = (totalMinutes ~/ 60).toString().padLeft(2, '0');
      final minutes = (totalMinutes % 60).toString().padLeft(2, '0');
      return '$hours:$minutes';
    }

    return '${formatMinutes(range.startMinutes)} - ${formatMinutes(range.endMinutes)}';
  }

  String? _buildRequestDateTime({
    required String dateIso,
    required String timeRange,
    required bool takeEnd,
  }) {
    final match = RegExp(
      r'(\d{2}:\d{2})\s*-\s*(\d{2}:\d{2})',
    ).firstMatch(timeRange);
    if (match == null) {
      return null;
    }

    final time = takeEnd ? match.group(2) : match.group(1);
    if (time == null) {
      return null;
    }

    return '${dateIso}T$time:00Z';
  }

  @override
  Widget build(BuildContext context) {
    final item = widget.item;
    final displayedTime =
        _rescheduledTime ?? (item.timeSlots.isEmpty ? null : item.timeSlots.first);

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        ProfileRentalCardDateLabel(item.dateLabel),
        ProfileRentalCardFrame(
          child: ProfileRentalCardContent(
            title: item.title,
            room: item.room,
            priceLabel: item.priceLabel,
            capacity: item.capacity,
            photoUrl: item.photoUrl,
            timeText: displayedTime,
            favoriteInitiallyFilled: item.isFavorite,
            onFavoriteTap: () => widget.onFavoritePressed(item),
            isFavoriteBusy: widget.isFavoriteBusy,
          ),
        ),
        const SizedBox(height: 10),
        _ActiveRentalActions(
          controller: _actionController,
          onPrevious: _showPrevAction,
          onNext: _showNextAction,
          onActionPressed: _onActionPressed,
          isCancelling: widget.isCancelling,
          isRescheduleLoading: _isRescheduleLoading,
        ),
      ],
    );
  }
}

class _TimeRange {
  const _TimeRange({
    required this.startMinutes,
    required this.endMinutes,
  });

  final int startMinutes;
  final int endMinutes;
}

class _ActiveRentalActions extends StatelessWidget {
  const _ActiveRentalActions({
    required this.controller,
    required this.onPrevious,
    required this.onNext,
    required this.onActionPressed,
    required this.isCancelling,
    required this.isRescheduleLoading,
  });

  final PageController controller;
  final VoidCallback onPrevious;
  final VoidCallback onNext;
  final Future<void> Function(int actionIndex) onActionPressed;
  final bool isCancelling;
  final bool isRescheduleLoading;

  @override
  Widget build(BuildContext context) {
    return Row(
      mainAxisAlignment: MainAxisAlignment.center,
      children: [
        _ActionArrowButton(
          icon: Icons.chevron_left_rounded,
          onPressed: onPrevious,
        ),
        const SizedBox(width: 12),
        SizedBox(
          width: 190,
          height: 30,
          child: PageView.builder(
            controller: controller,
            itemCount:
                _ProfileActiveRentalCardState._actions.length *
                _ProfileActiveRentalCardState._loopMultiplier *
                2,
            itemBuilder: (_, index) {
              final actionIndex =
                  index % _ProfileActiveRentalCardState._actions.length;
              return _ActionChip(
                label: _ProfileActiveRentalCardState._actions[actionIndex],
                onTap: () => onActionPressed(actionIndex),
                isBusy: (isCancelling && actionIndex == 2) ||
                    (isRescheduleLoading && actionIndex == 1),
              );
            },
          ),
        ),
        const SizedBox(width: 12),
        _ActionArrowButton(
          icon: Icons.chevron_right_rounded,
          onPressed: onNext,
        ),
      ],
    );
  }
}

class _ActionArrowButton extends StatelessWidget {
  const _ActionArrowButton({required this.icon, required this.onPressed});

  final IconData icon;
  final VoidCallback onPressed;

  @override
  Widget build(BuildContext context) {
    return AppOutlinedIconButton(
      icon: icon,
      size: 30,
      iconSize: 18,
      radius: 10,
      borderColor: AppColors.border,
      iconColor: AppColors.textPrimary,
      onPressed: onPressed,
    );
  }
}

class _ActionChip extends StatelessWidget {
  const _ActionChip({
    required this.label,
    required this.onTap,
    this.isBusy = false,
  });

  final String label;
  final VoidCallback onTap;
  final bool isBusy;

  @override
  Widget build(BuildContext context) {
    return Material(
      color: Colors.transparent,
      child: InkWell(
        onTap: isBusy ? null : onTap,
        borderRadius: BorderRadius.circular(5),
        child: Container(
          alignment: Alignment.center,
          decoration: BoxDecoration(
            color: AppColors.formSurface,
            border: Border.all(color: AppColors.border, width: 1),
            borderRadius: BorderRadius.circular(5),
          ),
          child: isBusy
              ? const SizedBox(
                  width: 16,
                  height: 16,
                  child: CircularProgressIndicator(strokeWidth: 2),
                )
              : Text(label, style: ProfileCardStyles.body),
        ),
      ),
    );
  }
}
