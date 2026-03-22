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
    String? lastName,
    String? firstName,
    String? middleName,
  }) async {
    final lines = <String>[
      if (email != null && email.trim().isNotEmpty) email.trim(),
      if (lastName != null && lastName.trim().isNotEmpty) lastName.trim(),
      if (firstName != null && firstName.trim().isNotEmpty) firstName.trim(),
      if (middleName != null && middleName.trim().isNotEmpty)
        middleName.trim(),
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
