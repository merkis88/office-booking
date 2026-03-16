import 'package:flutter/material.dart';
import 'package:wordpice/features/notifications/presentation/widgets/styles/notification_styles.dart';

class NotificationReadAction extends StatelessWidget {
  const NotificationReadAction({
    super.key,
    required this.label,
    required this.value,
    this.onChanged,
    this.isEnabled = true,
    this.isLoading = false,
  });

  final String label;
  final bool value;
  final ValueChanged<bool>? onChanged;
  final bool isEnabled;
  final bool isLoading;

  @override
  Widget build(BuildContext context) {
    final canTap = isEnabled && !isLoading;

    return InkWell(
      onTap: canTap ? () => onChanged?.call(true) : null,
      borderRadius: BorderRadius.circular(999),
      child: Opacity(
        opacity: canTap || value ? 1 : 0.55,
        child: Row(
          mainAxisSize: MainAxisSize.min,
          children: [
            _NotificationReadToggle(isActive: value, isLoading: isLoading),
            const SizedBox(width: 8),
            Text(label, style: NotificationStyles.actionText),
          ],
        ),
      ),
    );
  }
}

class _NotificationReadToggle extends StatelessWidget {
  const _NotificationReadToggle({
    required this.isActive,
    required this.isLoading,
  });

  final bool isActive;
  final bool isLoading;

  @override
  Widget build(BuildContext context) {
    return Container(
      width: 38,
      height: 22,
      padding: const EdgeInsets.all(2),
      decoration: BoxDecoration(
        color: const Color(0xFFE9EEF2),
        borderRadius: BorderRadius.circular(99),
        border: Border.all(color: Colors.black54, width: 1),
      ),
      child: isLoading
          ? const Center(
              child: SizedBox(
                width: 10,
                height: 10,
                child: CircularProgressIndicator(strokeWidth: 1.5),
              ),
            )
          : AnimatedAlign(
              duration: const Duration(milliseconds: 180),
              curve: Curves.easeOut,
              alignment: isActive
                  ? Alignment.centerRight
                  : Alignment.centerLeft,
              child: Container(
                width: 10,
                height: 10,
                decoration: BoxDecoration(
                  color: isActive
                      ? const Color(0xFF5EBD7E)
                      : const Color(0xFFFF7C8F),
                  shape: BoxShape.circle,
                ),
              ),
            ),
    );
  }
}
