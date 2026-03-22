import 'package:flutter/material.dart';
import 'package:wordpice/core/widgets/dialogs/app_confirmation_dialog.dart';

class RequestConfirmationModal {
  RequestConfirmationModal._();

  static Future<bool> show(
    BuildContext context, {
    required String date,
    required String time,
    required String requestType,
    required String booking,
  }) async {
    final result = await AppConfirmationDialog.show<bool>(
      context,
      title: 'Подтверждение',
      message: 'Пожалуйста, проверьте правильность\nуказанных данных',
      details: ['$date, $time', booking, requestType],
      confirmLabel: 'Подтвердить',
      cancelLabel: 'Отмена',
      confirmResult: true,
      cancelResult: false,
    );

    return result ?? false;
  }
}
