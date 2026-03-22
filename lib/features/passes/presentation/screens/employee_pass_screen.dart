import 'package:flutter/material.dart';
import 'package:wordpice/app/navigation/app_tab_navigator.dart';
import 'package:wordpice/core/theme/app_colors.dart';
import 'package:wordpice/core/widgets/layout/app_constrained_scroll_view.dart';
import 'package:wordpice/core/widgets/layout/app_shell.dart';
import 'package:wordpice/features/passes/presentation/widgets/forms/pass_form_widgets.dart';
import 'package:wordpice/features/passes/presentation/widgets/modals/pass_confirmation_modal.dart';
import 'package:wordpice/features/passes/presentation/widgets/styles/pass_form_styles.dart';

class EmployeePassScreen extends StatefulWidget {
  const EmployeePassScreen({super.key});

  @override
  State<EmployeePassScreen> createState() => _EmployeePassScreenState();
}

class _EmployeePassScreenState extends State<EmployeePassScreen> {
  static const int _tabIndex = 2;
  static const double _contentWidth = double.infinity;

  final int _selectedBottomIndex = _tabIndex;
  final TextEditingController _emailController = TextEditingController();
  final TextEditingController _lastNameController = TextEditingController();
  final TextEditingController _firstNameController = TextEditingController();
  final TextEditingController _middleNameController = TextEditingController();

  void _onAnyFieldChanged() => setState(() {});

  @override
  void initState() {
    super.initState();
    _emailController.addListener(_onAnyFieldChanged);
    _lastNameController.addListener(_onAnyFieldChanged);
    _firstNameController.addListener(_onAnyFieldChanged);
    _middleNameController.addListener(_onAnyFieldChanged);
  }

  void _onBottomChanged(int index) {
    AppTabNavigator.goToTab(context, index);
  }

  Future<void> _showPurchaseModal() {
    return PassConfirmationModal.show(
      context,
      email: _emailController.text.trim(),
      lastName: _lastNameController.text.trim(),
      firstName: _firstNameController.text.trim(),
      middleName: _middleNameController.text.trim(),
    );
  }

  bool get _canBuyPass =>
      _emailController.text.trim().isNotEmpty &&
      _lastNameController.text.trim().isNotEmpty &&
      _firstNameController.text.trim().isNotEmpty;

  @override
  void dispose() {
    _emailController.removeListener(_onAnyFieldChanged);
    _lastNameController.removeListener(_onAnyFieldChanged);
    _firstNameController.removeListener(_onAnyFieldChanged);
    _middleNameController.removeListener(_onAnyFieldChanged);
    _emailController.dispose();
    _lastNameController.dispose();
    _firstNameController.dispose();
    _middleNameController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return AppShell(
      selectedBottomIndex: _selectedBottomIndex,
      onBottomChanged: _onBottomChanged,
      body: AppConstrainedScrollView(
        maxWidth: _contentWidth,
        padding: const EdgeInsets.fromLTRB(24, 20, 24, 24),
        centerVertically: true,
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.center,
          children: [
            const _EmployeePassHeader(),
            Container(
              width: double.infinity,
              padding: const EdgeInsets.fromLTRB(14, 20, 14, 20),
              decoration: BoxDecoration(
                color: AppColors.formBlockBackground,
                borderRadius: BorderRadius.circular(16),
              ),
              child: _EmployeePassFieldsSection(
                emailController: _emailController,
                lastNameController: _lastNameController,
                firstNameController: _firstNameController,
                middleNameController: _middleNameController,
              ),
            ),
            const SizedBox(height: 26),
            PassSubmitButton(
              text: 'Купить пропуск',
              onPressed: _canBuyPass ? _showPurchaseModal : null,
            ),
          ],
        ),
      ),
    );
  }
}

class _EmployeePassHeader extends StatelessWidget {
  const _EmployeePassHeader();

  @override
  Widget build(BuildContext context) {
    return const Column(
      children: [
        SizedBox(
          width: double.infinity,
          child: Text(
            'Пропуск сотрудника',
            style: PassFormStyles.title,
            textAlign: TextAlign.left,
          ),
        ),
        SizedBox(height: 18),
      ],
    );
  }
}

class _EmployeePassFieldsSection extends StatelessWidget {
  const _EmployeePassFieldsSection({
    required this.emailController,
    required this.lastNameController,
    required this.firstNameController,
    required this.middleNameController,
  });

  final TextEditingController emailController;
  final TextEditingController lastNameController;
  final TextEditingController firstNameController;
  final TextEditingController middleNameController;

  @override
  Widget build(BuildContext context) {
    return Column(
      children: [
        _EmployeePassField(
          label: 'Эл.почта*',
          hint: 'Введите электронную почту',
          controller: emailController,
          keyboardType: TextInputType.emailAddress,
        ),
        const SizedBox(height: 18),
        _EmployeePassField(
          label: 'Фамилия*',
          hint: 'Введите фамилию',
          controller: lastNameController,
        ),
        const SizedBox(height: 18),
        _EmployeePassField(
          label: 'Имя*',
          hint: 'Введите имя',
          controller: firstNameController,
        ),
        const SizedBox(height: 18),
        _EmployeePassField(
          label: 'Отчество (необязательно)',
          hint: 'Введите отчество',
          controller: middleNameController,
        ),
      ],
    );
  }
}

class _EmployeePassField extends StatelessWidget {
  const _EmployeePassField({
    required this.label,
    required this.hint,
    required this.controller,
    this.keyboardType,
  });

  final String label;
  final String hint;
  final TextEditingController controller;
  final TextInputType? keyboardType;

  @override
  Widget build(BuildContext context) {
    return Column(
      children: [
        SizedBox(width: double.infinity, child: PassFieldLabel(label)),
        const SizedBox(height: 8),
        PassEditableInputField(
          controller: controller,
          hint: hint,
          keyboardType: keyboardType,
        ),
      ],
    );
  }
}
