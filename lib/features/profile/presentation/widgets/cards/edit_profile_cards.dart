import 'package:flutter/material.dart';
import 'package:wordpice/core/theme/app_colors.dart';
import 'package:wordpice/features/auth/domain/entities/registered_user.dart';
import 'package:wordpice/features/profile/presentation/widgets/profile_identity_avatar.dart';
import 'package:wordpice/features/profile/presentation/widgets/styles/edit_profile_styles.dart';

class EditProfileField {
  const EditProfileField({required this.label, required this.controller});

  final String label;
  final TextEditingController controller;
}

class EditProfilePreviewCard extends StatelessWidget {
  const EditProfilePreviewCard({super.key, required this.user});

  static const String _role = 'Должность';

  final RegisteredUser user;

  @override
  Widget build(BuildContext context) {
    return Container(
      width: double.infinity,
      padding: EditProfileStyles.previewCardPadding,
      decoration: const BoxDecoration(
        color: AppColors.profileSurface,
        border: Border.fromBorderSide(
          BorderSide(color: AppColors.bottomNavBackground, width: 1),
        ),
        borderRadius: EditProfileStyles.cardRadius,
      ),
      child: Row(
        children: [
          const ProfileIdentityAvatar(size: 58),
          const SizedBox(width: 12),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(user.fullName, style: EditProfileStyles.previewNameStyle),
                const SizedBox(height: 4),
                const Text(_role, style: EditProfileStyles.previewRoleStyle),
              ],
            ),
          ),
        ],
      ),
    );
  }
}

class EditProfileEditorCard extends StatelessWidget {
  const EditProfileEditorCard({
    super.key,
    required this.fields,
    required this.onChangePasswordTap,
    required this.onDeleteTap,
  });

  static const String _sectionTitle = 'ОСНОВНОЕ';
  static const String _changePasswordLabel = 'Сменить пароль';
  static const String _deleteLabel = 'Удалить аккаунт';

  final List<EditProfileField> fields;
  final VoidCallback onChangePasswordTap;
  final VoidCallback onDeleteTap;

  @override
  Widget build(BuildContext context) {
    return Container(
      width: double.infinity,
      height: 458,
      padding: EditProfileStyles.editorCardPadding,
      decoration: const BoxDecoration(
        color: AppColors.profileSurface,
        border: Border.fromBorderSide(
          BorderSide(color: AppColors.bottomNavBackground, width: 1),
        ),
        borderRadius: EditProfileStyles.cardRadius,
      ),
      child: SingleChildScrollView(
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const SizedBox(height: 16),
            const Text(
              _sectionTitle,
              style: EditProfileStyles.sectionTitleStyle,
            ),
            for (final field in fields) ...[
              const SizedBox(height: 8),
              _LabeledInput(label: field.label, controller: field.controller),
            ],
            const SizedBox(height: 24),
            Center(
              child: _ActionButton(
                label: _changePasswordLabel,
                onPressed: onChangePasswordTap,
              ),
            ),
            const SizedBox(height: 8),
            Center(
              child: _ActionButton(label: _deleteLabel, onPressed: onDeleteTap),
            ),
          ],
        ),
      ),
    );
  }
}

class _ActionButton extends StatelessWidget {
  const _ActionButton({required this.label, required this.onPressed});

  final String label;
  final VoidCallback onPressed;

  @override
  Widget build(BuildContext context) {
    return SizedBox(
      width: EditProfileStyles.deleteButtonWidth,
      height: EditProfileStyles.deleteButtonHeight,
      child: OutlinedButton(
        onPressed: onPressed,
        style: OutlinedButton.styleFrom(
          backgroundColor: AppColors.formSurface,
          side: const BorderSide(color: Colors.black87, width: 1),
          padding: EdgeInsets.zero,
          alignment: Alignment.center,
          shape: const RoundedRectangleBorder(
            borderRadius: EditProfileStyles.deleteButtonRadius,
          ),
        ),
        child: Text(label, style: EditProfileStyles.deleteButtonTextStyle),
      ),
    );
  }
}

class _LabeledInput extends StatelessWidget {
  const _LabeledInput({required this.label, required this.controller});

  static const Border _inputBorder = Border(
    bottom: BorderSide(color: Colors.black26, width: 1),
  );

  final String label;
  final TextEditingController controller;

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(label, style: EditProfileStyles.inputLabelStyle),
        const SizedBox(height: 3),
        Container(
          height: 28,
          alignment: Alignment.centerLeft,
          decoration: const BoxDecoration(border: _inputBorder),
          child: TextField(
            controller: controller,
            style: EditProfileStyles.inputTextStyle,
            decoration: EditProfileStyles.inputDecoration,
          ),
        ),
      ],
    );
  }
}
