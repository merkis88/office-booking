import 'package:flutter/material.dart';
import 'package:wordpice/app/app_scope.dart';
import 'package:wordpice/app/navigation/app_tab_navigator.dart';
import 'package:wordpice/core/theme/app_colors.dart';
import 'package:wordpice/core/widgets/buttons/app_action_menu_button.dart';
import 'package:wordpice/core/widgets/layout/app_constrained_scroll_view.dart';
import 'package:wordpice/core/widgets/layout/app_shell.dart';
import 'package:wordpice/features/passes/presentation/screens/employee_pass_screen.dart';
import 'package:wordpice/features/passes/presentation/screens/guest_pass_screen.dart';
import 'package:wordpice/features/passes/presentation/widgets/styles/pass_form_styles.dart';

class PassesScreen extends StatefulWidget {
  const PassesScreen({super.key});

  @override
  State<PassesScreen> createState() => _PassesScreenState();
}

class _PassesScreenState extends State<PassesScreen> {
  static const int _tabIndex = 2;
  static const double _contentWidth = double.infinity;

  int _selectedBottomIndex = _tabIndex;
  bool _isLoadingAvailability = true;
  bool _hasActiveBookings = false;
  bool _hasLoadedAvailability = false;

  @override
  void didChangeDependencies() {
    super.didChangeDependencies();
    if (_hasLoadedAvailability) {
      return;
    }
    _hasLoadedAvailability = true;
    _loadBookingAvailability();
  }

  void _onBottomChanged(int index) {
    if (index == _tabIndex) {
      return;
    }
    setState(() => _selectedBottomIndex = index);
    AppTabNavigator.goToTab(context, index);
  }

  Future<void> _loadBookingAvailability() async {
    try {
      final overview = await AppScope.of(context).profileRepository
          .getRentalsOverview();
      if (!mounted) {
        return;
      }
      setState(() {
        _hasActiveBookings = overview.activeRentals.isNotEmpty;
        _isLoadingAvailability = false;
      });
    } catch (_) {
      if (!mounted) {
        return;
      }
      setState(() {
        _hasActiveBookings = false;
        _isLoadingAvailability = false;
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    final canOpenPassScreens = !_isLoadingAvailability && _hasActiveBookings;

    return AppShell(
      selectedBottomIndex: _selectedBottomIndex,
      onBottomChanged: _onBottomChanged,
      body: AppConstrainedScrollView(
        maxWidth: _contentWidth,
        padding: const EdgeInsets.fromLTRB(24, 16, 24, 24),
        centerVertically: true,
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.center,
          children: [
            const SizedBox(
              width: double.infinity,
              child: Text(
                'Пропуск',
                style: PassFormStyles.title,
                textAlign: TextAlign.left,
              ),
            ),
            const SizedBox(height: 10),
            SizedBox(
              width: double.infinity,
              height: 42,
              child: !_isLoadingAvailability && !_hasActiveBookings
                  ? const Center(
                      child: Text(
                        'Пропуски доступны только при наличии активной аренды',
                        textAlign: TextAlign.center,
                        maxLines: 2,
                        style: TextStyle(
                          fontSize: 14,
                          color: Colors.black54,
                        ),
                      ),
                    )
                  : null,
            ),
            const SizedBox(height: 22),
            AppActionMenuButton(
              text: 'Пропуск сотрудника',
              textStyle: PassFormStyles.actionText,
              backgroundColor: AppColors.formSurface,
              onPressed: canOpenPassScreens
                  ? () => Navigator.push(
                      context,
                      MaterialPageRoute(
                        builder: (_) => const EmployeePassScreen(),
                      ),
                    )
                  : null,
            ),
            const SizedBox(height: 30),
            AppActionMenuButton(
              text: 'Пропуск для гостя',
              textStyle: PassFormStyles.actionText,
              backgroundColor: AppColors.formSurface,
              onPressed: canOpenPassScreens
                  ? () => Navigator.push(
                      context,
                      MaterialPageRoute(
                        builder: (_) => const GuestPassScreen(),
                      ),
                    )
                  : null,
            ),
            Transform.translate(
              offset: const Offset(0, 70),
              child: Image.asset(
                'assets/images/passes/employer.png',
                width: 330,
              ),
            ),
          ],
        ),
      ),
    );
  }
}
