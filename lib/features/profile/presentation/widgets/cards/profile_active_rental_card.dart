import 'package:flutter/material.dart';
import 'package:wordpice/core/theme/app_colors.dart';
import 'package:wordpice/core/widgets/buttons/app_outlined_icon_button.dart';
import 'package:wordpice/core/widgets/dialogs/app_confirmation_dialog.dart';
import 'package:wordpice/features/passes/presentation/screens/employee_pass_screen.dart';
import 'package:wordpice/features/profile/domain/entities/rental_history_item.dart';
import 'package:wordpice/features/profile/presentation/widgets/cards/profile_rental_card_layout.dart';
import 'package:wordpice/features/profile/presentation/widgets/styles/profile_card_styles.dart';

class ProfileActiveRentalCard extends StatefulWidget {
  const ProfileActiveRentalCard({
    super.key,
    required this.item,
    required this.onCancelPressed,
    this.isCancelling = false,
  });

  final RentalHistoryItem item;
  final Future<void> Function(RentalHistoryItem item) onCancelPressed;
  final bool isCancelling;

  @override
  State<ProfileActiveRentalCard> createState() =>
      _ProfileActiveRentalCardState();
}

class _ProfileActiveRentalCardState extends State<ProfileActiveRentalCard> {
  static const int _loopMultiplier = 1000;
  static const List<String> _actions = [
    'Пригласить сотрудника',
    'Перенести бронь',
    'Отменить бронь',
  ];

  late final PageController _actionController;

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
      if (!mounted) return;
      await Navigator.of(
        context,
      ).push(MaterialPageRoute(builder: (_) => const EmployeePassScreen()));
      return;
    }

    if (actionIndex != 2 || widget.isCancelling) return;

    final shouldCancel = await AppConfirmationDialog.show<bool>(
      context,
      title: 'Отмена брони',
      message: 'Вы действительно хотите отменить бронь?',
      confirmLabel: 'Подтвердить',
      cancelLabel: 'Отмена',
      confirmResult: true,
      cancelResult: false,
    );

    if (shouldCancel != true || !mounted) return;
    await widget.onCancelPressed(widget.item);
  }

  @override
  Widget build(BuildContext context) {
    final item = widget.item;

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        ProfileRentalCardDateLabel(item.dateLabel),
        ProfileRentalCardFrame(
          child: ProfileRentalCardContent(
            title: item.title,
            room: item.room,
            capacity: item.capacity,
            timeText: item.timeSlots.isEmpty ? null : item.timeSlots.first,
          ),
        ),
        const SizedBox(height: 10),
        _ActiveRentalActions(
          controller: _actionController,
          onPrevious: _showPrevAction,
          onNext: _showNextAction,
          onActionPressed: _onActionPressed,
          isCancelling: widget.isCancelling,
        ),
      ],
    );
  }
}

class _ActiveRentalActions extends StatelessWidget {
  const _ActiveRentalActions({
    required this.controller,
    required this.onPrevious,
    required this.onNext,
    required this.onActionPressed,
    required this.isCancelling,
  });

  final PageController controller;
  final VoidCallback onPrevious;
  final VoidCallback onNext;
  final Future<void> Function(int actionIndex) onActionPressed;
  final bool isCancelling;

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
                onTap: () {
                  onActionPressed(actionIndex);
                },
                isBusy: isCancelling && actionIndex == 2,
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
