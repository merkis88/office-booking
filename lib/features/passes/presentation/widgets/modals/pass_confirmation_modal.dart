import 'package:flutter/material.dart';
import 'package:wordpice/core/widgets/dialogs/app_confirmation_dialog.dart';

class PassConfirmationModal {
  PassConfirmationModal._();

  static const String _title = 'Подтверждение';
  static const String _message =
      'Пожалуйста, проверьте правильность\nуказанных данных';
  static const String _confirmLabel = 'Подтвердить';
  static const String _cancelLabel = 'Отмена';

  static Future<bool> show(
    BuildContext context, {
    String? booking,
    String? email,
  }) async {
    final lines = <String>[
      if (booking != null && booking.trim().isNotEmpty) booking.trim(),
      if (email != null && email.trim().isNotEmpty) email.trim(),
    ];

    final confirmed = await AppConfirmationDialog.show<bool>(
      context,
      title: _title,
      message: _message,
      details: lines,
      confirmLabel: _confirmLabel,
      cancelLabel: _cancelLabel,
      confirmResult: true,
      cancelResult: false,
    );

    return confirmed ?? false;
  }
}
