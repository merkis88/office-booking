import 'package:flutter/material.dart';
import 'package:wordpice/app/app_scope.dart';
import 'package:wordpice/core/network/api_client.dart';
import 'package:wordpice/core/theme/app_colors.dart';
import 'package:wordpice/core/theme/app_input_decorations.dart';
import 'package:wordpice/core/widgets/dialogs/app_confirmation_dialog.dart';
import 'package:wordpice/features/auth/presentation/screens/auth_screen.dart';

class DeleteAccountModal {
  const DeleteAccountModal._();

  static const TextStyle _messageStyle = TextStyle(
    fontSize: 16,
    fontWeight: FontWeight.w400,
    color: Colors.black87,
  );

  static Future<void> show(BuildContext context) async {
    final confirmed = await AppConfirmationDialog.show<bool>(
      context,
      title: 'Удаление аккаунта',
      message: 'Вы действительно хотите удалить аккаунт?',
      confirmLabel: 'Подтвердить',
      cancelLabel: 'Отмена',
      confirmResult: true,
      cancelResult: false,
      backgroundColor: AppColors.modalBackground,
      messageStyle: _messageStyle,
      contentPadding: const EdgeInsets.fromLTRB(20, 24, 20, 20),
    );

    if (confirmed != true || !context.mounted) {
      return;
    }

    await showDialog<void>(
      context: context,
      barrierDismissible: true,
      builder: (_) => const _DeleteAccountPasswordDialog(),
    );
  }
}

class _DeleteAccountPasswordDialog extends StatefulWidget {
  const _DeleteAccountPasswordDialog();

  @override
  State<_DeleteAccountPasswordDialog> createState() =>
      _DeleteAccountPasswordDialogState();
}

class _DeleteAccountPasswordDialogState
    extends State<_DeleteAccountPasswordDialog> {
  final TextEditingController _passwordController = TextEditingController();
  bool _obscurePassword = true;
  bool _isSubmitting = false;
  String? _errorText;

  @override
  void dispose() {
    _passwordController.dispose();
    super.dispose();
  }

  Future<void> _submit() async {
    final password = _passwordController.text.trim();
    if (password.isEmpty) {
      setState(() {
        _errorText = 'Введите пароль';
      });
      return;
    }

    setState(() {
      _isSubmitting = true;
      _errorText = null;
    });

    try {
      final dependencies = AppScope.of(context);
      await dependencies.profileRepository.deleteAccount(password);
      try {
        await dependencies.authRepository.logout();
      } catch (_) {
        // The session is still cleared inside logout(), even if the API call fails.
      }

      if (!mounted) {
        return;
      }

      Navigator.of(context, rootNavigator: true).pushAndRemoveUntil(
        MaterialPageRoute(builder: (_) => const AuthScreen()),
        (route) => false,
      );
    } catch (error) {
      if (!mounted) {
        return;
      }

      setState(() {
        _errorText = error is ApiConnectionException
            ? error.message
            : 'Не удалось удалить аккаунт.';
        _isSubmitting = false;
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    return Dialog(
      backgroundColor: AppColors.modalBackground,
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(8)),
      child: Padding(
        padding: const EdgeInsets.fromLTRB(20, 24, 20, 20),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            const Text(
              'Введите пароль',
              style: TextStyle(
                fontSize: 18,
                fontWeight: FontWeight.w500,
                color: Colors.black87,
              ),
            ),
            const SizedBox(height: 14),
            const Text(
              'Для удаления аккаунта подтвердите пароль',
              textAlign: TextAlign.center,
              style: TextStyle(
                fontSize: 14,
                fontWeight: FontWeight.w400,
                color: Colors.black54,
              ),
            ),
            const SizedBox(height: 16),
            TextField(
              controller: _passwordController,
              obscureText: _obscurePassword,
              enabled: !_isSubmitting,
              decoration: AppInputDecorations.authField(
                hintText: 'Введите пароль',
                errorText: _errorText,
                suffixIcon: IconButton(
                  onPressed: _isSubmitting
                      ? null
                      : () => setState(() {
                          _obscurePassword = !_obscurePassword;
                        }),
                  icon: Icon(
                    _obscurePassword
                        ? Icons.visibility_off_outlined
                        : Icons.visibility_outlined,
                  ),
                ),
              ),
            ),
            const SizedBox(height: 18),
            _DialogActionButton(
              label: _isSubmitting ? 'Удаление...' : 'Удалить аккаунт',
              onPressed: _isSubmitting ? null : _submit,
            ),
            const SizedBox(height: 12),
            _DialogActionButton(
              label: 'Отмена',
              onPressed: _isSubmitting
                  ? null
                  : () => Navigator.of(context).pop(),
              backgroundColor: const Color(0x807C8FA0),
            ),
          ],
        ),
      ),
    );
  }
}

class _DialogActionButton extends StatelessWidget {
  const _DialogActionButton({
    required this.label,
    required this.onPressed,
    this.backgroundColor = const Color(0x407C8FA0),
  });

  final String label;
  final VoidCallback? onPressed;
  final Color backgroundColor;

  @override
  Widget build(BuildContext context) {
    return SizedBox(
      width: 200,
      height: 44,
      child: Container(
        decoration: BoxDecoration(
          color: backgroundColor,
          borderRadius: BorderRadius.circular(6),
          border: Border.all(color: Colors.black87, width: 1),
        ),
        child: Material(
          color: Colors.transparent,
          child: InkWell(
            borderRadius: BorderRadius.circular(6),
            onTap: onPressed,
            child: Center(
              child: Text(
                label,
                style: const TextStyle(
                  fontSize: 16,
                  fontWeight: FontWeight.w400,
                  color: Colors.black87,
                ),
              ),
            ),
          ),
        ),
      ),
    );
  }
}
