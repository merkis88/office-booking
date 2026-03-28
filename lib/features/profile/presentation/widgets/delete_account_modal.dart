import 'package:flutter/material.dart';
import 'package:wordpice/app/app_scope.dart';
import 'package:wordpice/core/network/api_client.dart';
import 'package:wordpice/core/theme/app_colors.dart';
import 'package:wordpice/core/theme/app_input_decorations.dart';
import 'package:wordpice/features/auth/presentation/screens/auth_screen.dart';

class DeleteAccountModal {
  const DeleteAccountModal._();

  static Future<void> show(BuildContext context) async {
    await showDialog<void>(
      context: context,
      barrierDismissible: true,
      builder: (_) => const _DeleteAccountDialog(),
    );
  }
}

enum _DeleteAccountStep {
  password,
  confirmation,
}

class _DeleteAccountDialog extends StatefulWidget {
  const _DeleteAccountDialog();

  @override
  State<_DeleteAccountDialog> createState() => _DeleteAccountDialogState();
}

class _DeleteAccountDialogState extends State<_DeleteAccountDialog> {
  final TextEditingController _passwordController = TextEditingController();

  _DeleteAccountStep _step = _DeleteAccountStep.password;
  bool _obscurePassword = true;
  bool _isSubmitting = false;
  String? _errorText;

  @override
  void dispose() {
    _passwordController.dispose();
    super.dispose();
  }

  void _continueToConfirmation() {
    final password = _passwordController.text.trim();
    if (password.isEmpty) {
      setState(() {
        _errorText = 'Введите пароль';
      });
      return;
    }

    setState(() {
      _errorText = null;
      _step = _DeleteAccountStep.confirmation;
    });
  }

  Future<void> _deleteAccount() async {
    final password = _passwordController.text.trim();
    if (password.isEmpty || _isSubmitting) {
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
        // Session cleanup still happens inside logout().
      }

      if (!mounted) {
        return;
      }

      Navigator.of(context).pop();
      Navigator.of(context, rootNavigator: true).pushAndRemoveUntil(
        MaterialPageRoute(builder: (_) => const AuthScreen()),
        (route) => false,
      );
    } catch (error) {
      if (!mounted) {
        return;
      }

      setState(() {
        _isSubmitting = false;
        _step = _DeleteAccountStep.password;
        _errorText = error is ApiConnectionException
            ? error.message
            : 'Не удалось удалить аккаунт.';
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    return Dialog(
      backgroundColor: AppColors.modalBackground,
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(8)),
      child: AnimatedSwitcher(
        duration: const Duration(milliseconds: 180),
        child: _step == _DeleteAccountStep.password
            ? _PasswordStep(
                key: const ValueKey('password_step'),
                controller: _passwordController,
                errorText: _errorText,
                obscurePassword: _obscurePassword,
                onToggleVisibility: () => setState(() {
                  _obscurePassword = !_obscurePassword;
                }),
                onContinue: _continueToConfirmation,
                onCancel: () => Navigator.of(context).pop(),
              )
            : _ConfirmationStep(
                key: const ValueKey('confirmation_step'),
                isSubmitting: _isSubmitting,
                onConfirm: _deleteAccount,
                onBack: () => setState(() {
                  _step = _DeleteAccountStep.password;
                }),
              ),
      ),
    );
  }
}

class _PasswordStep extends StatelessWidget {
  const _PasswordStep({
    super.key,
    required this.controller,
    required this.errorText,
    required this.obscurePassword,
    required this.onToggleVisibility,
    required this.onContinue,
    required this.onCancel,
  });

  final TextEditingController controller;
  final String? errorText;
  final bool obscurePassword;
  final VoidCallback onToggleVisibility;
  final VoidCallback onContinue;
  final VoidCallback onCancel;

  @override
  Widget build(BuildContext context) {
    return Padding(
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
            controller: controller,
            obscureText: obscurePassword,
            decoration: AppInputDecorations.authField(
              hintText: 'Введите пароль',
              errorText: errorText,
              suffixIcon: IconButton(
                onPressed: onToggleVisibility,
                icon: Icon(
                  obscurePassword
                      ? Icons.visibility_off_outlined
                      : Icons.visibility_outlined,
                ),
              ),
            ),
          ),
          const SizedBox(height: 18),
          _DialogActionButton(
            label: 'Продолжить',
            onPressed: onContinue,
          ),
          const SizedBox(height: 12),
          _DialogActionButton(
            label: 'Отмена',
            onPressed: onCancel,
            backgroundColor: const Color(0x807C8FA0),
          ),
        ],
      ),
    );
  }
}

class _ConfirmationStep extends StatelessWidget {
  const _ConfirmationStep({
    super.key,
    required this.isSubmitting,
    required this.onConfirm,
    required this.onBack,
  });

  final bool isSubmitting;
  final VoidCallback onConfirm;
  final VoidCallback onBack;

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.fromLTRB(20, 24, 20, 20),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          const Text(
            'Удаление аккаунта',
            style: TextStyle(
              fontSize: 18,
              fontWeight: FontWeight.w500,
              color: Colors.black87,
            ),
          ),
          const SizedBox(height: 14),
          const Text(
            'Вы действительно хотите удалить аккаунт?',
            textAlign: TextAlign.center,
            style: TextStyle(
              fontSize: 16,
              fontWeight: FontWeight.w400,
              color: Colors.black87,
            ),
          ),
          const SizedBox(height: 18),
          _DialogActionButton(
            label: isSubmitting ? 'Удаление...' : 'Подтвердить',
            onPressed: isSubmitting ? null : onConfirm,
          ),
          const SizedBox(height: 12),
          _DialogActionButton(
            label: 'Отмена',
            onPressed: isSubmitting ? null : onBack,
            backgroundColor: const Color(0x807C8FA0),
          ),
        ],
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
