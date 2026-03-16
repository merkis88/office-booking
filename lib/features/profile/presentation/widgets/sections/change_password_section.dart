import 'package:flutter/material.dart';
import 'package:wordpice/core/theme/app_colors.dart';
import 'package:wordpice/core/theme/app_input_decorations.dart';
import 'package:wordpice/features/auth/presentation/widgets/buttons/auth_action_button.dart';
import 'package:wordpice/features/auth/presentation/widgets/sections/auth_text.dart';
import 'package:wordpice/features/profile/presentation/widgets/styles/change_password_styles.dart';

class ChangePasswordSection extends StatelessWidget {
  const ChangePasswordSection({
    super.key,
    required this.currentPasswordController,
    required this.passwordController,
    required this.confirmPasswordController,
    required this.obscureCurrentPassword,
    required this.obscurePassword,
    required this.obscureConfirmPassword,
    required this.onToggleCurrentPasswordVisibility,
    required this.onTogglePasswordVisibility,
    required this.onToggleConfirmPasswordVisibility,
    required this.onSubmit,
    this.currentPasswordError,
    this.passwordError,
    this.confirmPasswordError,
    this.successMessage,
    this.isSubmitting = false,
  });

  final TextEditingController currentPasswordController;
  final TextEditingController passwordController;
  final TextEditingController confirmPasswordController;
  final bool obscureCurrentPassword;
  final bool obscurePassword;
  final bool obscureConfirmPassword;
  final VoidCallback onToggleCurrentPasswordVisibility;
  final VoidCallback onTogglePasswordVisibility;
  final VoidCallback onToggleConfirmPasswordVisibility;
  final VoidCallback onSubmit;
  final String? currentPasswordError;
  final String? passwordError;
  final String? confirmPasswordError;
  final String? successMessage;
  final bool isSubmitting;

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: ChangePasswordStyles.cardPadding,
      decoration: const BoxDecoration(
        color: AppColors.controlGrey,
        borderRadius: ChangePasswordStyles.cardRadius,
      ),
      child: Column(
        children: [
          const AuthTitleText('Смена пароля'),
          const SizedBox(height: 30),
          _ChangePasswordField(
            label: 'Текущий пароль*',
            hint: 'Введите текущий пароль',
            controller: currentPasswordController,
            obscureText: obscureCurrentPassword,
            onToggleVisibility: onToggleCurrentPasswordVisibility,
            errorText: currentPasswordError,
          ),
          const SizedBox(height: 24),
          _ChangePasswordField(
            label: 'Новый пароль*',
            hint: 'Введите новый пароль',
            controller: passwordController,
            obscureText: obscurePassword,
            onToggleVisibility: onTogglePasswordVisibility,
            errorText: passwordError,
          ),
          const SizedBox(height: 24),
          _ChangePasswordField(
            label: 'Подтверждение пароля*',
            hint: 'Введите пароль',
            controller: confirmPasswordController,
            obscureText: obscureConfirmPassword,
            onToggleVisibility: onToggleConfirmPasswordVisibility,
            errorText: confirmPasswordError,
          ),
          if (successMessage != null) ...[
            const SizedBox(height: 18),
            Text(
              successMessage!,
              textAlign: TextAlign.center,
              style: const TextStyle(
                fontSize: 14,
                fontWeight: FontWeight.w400,
                color: Colors.green,
              ),
            ),
          ],
          const SizedBox(height: 30),
          Center(
            child: AuthActionButton(
              label: isSubmitting ? 'Сохранение...' : 'Подтвердить',
              onPressed: isSubmitting ? null : onSubmit,
            ),
          ),
        ],
      ),
    );
  }
}

class _ChangePasswordField extends StatelessWidget {
  const _ChangePasswordField({
    required this.label,
    required this.hint,
    required this.controller,
    required this.obscureText,
    required this.onToggleVisibility,
    this.errorText,
  });

  final String label;
  final String hint;
  final TextEditingController controller;
  final bool obscureText;
  final VoidCallback onToggleVisibility;
  final String? errorText;

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(label, style: ChangePasswordStyles.inputLabelStyle),
        const SizedBox(height: 8),
        TextField(
          controller: controller,
          obscureText: obscureText,
          scrollPadding: const EdgeInsets.all(20),
          decoration: AppInputDecorations.authField(
            hintText: hint,
            errorText: errorText,
            suffixIcon: IconButton(
              onPressed: onToggleVisibility,
              icon: Icon(
                obscureText ? Icons.visibility_off_outlined : Icons.visibility,
                color: AppColors.textSecondary,
                size: 20,
              ),
            ),
          ),
        ),
      ],
    );
  }
}
