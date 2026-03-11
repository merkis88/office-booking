import 'package:flutter/material.dart';
import 'package:wordpice/app/navigation/app_tab_navigator.dart';
import 'package:wordpice/core/widgets/layout/app_constrained_scroll_view.dart';
import 'package:wordpice/core/widgets/layout/app_shell.dart';
import 'package:wordpice/features/auth/domain/entities/registered_user.dart';
import 'package:wordpice/features/profile/presentation/screens/change_password_screen.dart';
import 'package:wordpice/features/profile/presentation/widgets/cards/edit_profile_cards.dart';
import 'package:wordpice/features/profile/presentation/widgets/delete_account_modal.dart';
import 'package:wordpice/features/profile/presentation/widgets/sections/edit_profile_actions_section.dart';
import 'package:wordpice/features/profile/presentation/widgets/styles/edit_profile_styles.dart';

class EditProfileScreen extends StatefulWidget {
  const EditProfileScreen({super.key, required this.user});

  final RegisteredUser user;

  @override
  State<EditProfileScreen> createState() => _EditProfileScreenState();
}

class _EditProfileScreenState extends State<EditProfileScreen> {
  static const int _tabIndex = 3;

  final TextEditingController _nameController = TextEditingController();
  final TextEditingController _middleNameController = TextEditingController();
  final TextEditingController _lastNameController = TextEditingController();
  final TextEditingController _emailController = TextEditingController();
  final TextEditingController _positionController = TextEditingController();
  final TextEditingController _companyController = TextEditingController();

  late final List<TextEditingController> _controllers = <TextEditingController>[
    _nameController,
    _middleNameController,
    _lastNameController,
    _emailController,
    _positionController,
    _companyController,
  ];

  late final List<EditProfileField> _editorFields = <EditProfileField>[
    EditProfileField(label: 'Имя', controller: _nameController),
    EditProfileField(label: 'Отчество', controller: _middleNameController),
    EditProfileField(label: 'Фамилия', controller: _lastNameController),
    EditProfileField(label: 'Эл.почта', controller: _emailController),
    EditProfileField(label: 'Должность', controller: _positionController),
    EditProfileField(label: 'Компания', controller: _companyController),
  ];

  @override
  void initState() {
    super.initState();
    _nameController.text = widget.user.firstName;
    _middleNameController.text = widget.user.patronymic ?? '';
    _lastNameController.text = widget.user.lastName;
    _emailController.text = widget.user.email;
    _positionController.text = widget.user.post ?? '';
    _companyController.text = widget.user.company ?? '';
  }

  void _onBottomChanged(int index) {
    if (index == _tabIndex) {
      Navigator.of(context).pop();
      return;
    }
    AppTabNavigator.goToTab(context, index);
  }

  void _closeScreen() {
    Navigator.of(context).pop();
  }

  void _changePassword() {
    Navigator.of(
      context,
    ).push(MaterialPageRoute(builder: (_) => const ChangePasswordScreen()));
  }

  Future<void> _showDeleteAccountDialog() => DeleteAccountModal.show(context);

  @override
  void dispose() {
    for (final controller in _controllers) {
      controller.dispose();
    }
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return AppShell(
      selectedBottomIndex: _tabIndex,
      onBottomChanged: _onBottomChanged,
      body: AppConstrainedScrollView(
        maxWidth: EditProfileStyles.maxContentWidth,
        padding: EditProfileStyles.screenPadding,
        child: Column(
          children: [
            EditProfilePreviewCard(user: widget.user),
            const SizedBox(height: 30),
            SizedBox(
              width: EditProfileStyles.editorWidth,
              child: EditProfileEditorCard(
                fields: _editorFields,
                onChangePasswordTap: _changePassword,
                onDeleteTap: _showDeleteAccountDialog,
              ),
            ),
            const SizedBox(height: 14),
            EditProfileActionsSection(
              onSaveTap: _closeScreen,
              onExitTap: _closeScreen,
            ),
          ],
        ),
      ),
    );
  }
}
