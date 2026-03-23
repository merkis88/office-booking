import 'package:flutter/material.dart';
import 'package:wordpice/core/widgets/dialogs/app_confirmation_dialog.dart';

class PassConfirmationModal {
  PassConfirmationModal._();

  static const String _title = 'Подтверждение';
  static const String _message =
      'Пожалуйста, проверьте правильность\nуказанных данных';
  static const String _confirmLabel = 'Подтвердить';
  static const String _cancelLabel = 'Отмена';

  static Future<void> show(
    BuildContext context, {
    String? email,
  }) async {
    final lines = <String>[
      if (email != null && email.trim().isNotEmpty) email.trim(),
    ];

    await AppConfirmationDialog.show<void>(
      context,
      title: _title,
      message: _message,
      details: lines,
      confirmLabel: _confirmLabel,
      cancelLabel: _cancelLabel,
    );
  }
}
