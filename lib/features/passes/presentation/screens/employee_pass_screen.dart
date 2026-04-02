import 'package:flutter/material.dart';
import 'package:wordpice/app/app_scope.dart';
import 'package:wordpice/app/navigation/app_tab_navigator.dart';
import 'package:wordpice/core/theme/app_colors.dart';
import 'package:wordpice/core/widgets/layout/app_shell.dart';
import 'package:wordpice/features/auth/data/datasources/auth_data_source.dart';
import 'package:wordpice/features/passes/presentation/widgets/forms/pass_form_widgets.dart';
import 'package:wordpice/features/passes/presentation/widgets/modals/pass_confirmation_modal.dart';
import 'package:wordpice/features/passes/presentation/widgets/styles/pass_form_styles.dart';
import 'package:wordpice/features/requests/domain/entities/request_booking_option.dart';
import 'package:wordpice/features/requests/presentation/widgets/forms/request_form_dropdown_menu.dart';

class EmployeePassScreen extends StatefulWidget {
  const EmployeePassScreen({super.key});

  @override
  State<EmployeePassScreen> createState() => _EmployeePassScreenState();
}

class _EmployeePassScreenState extends State<EmployeePassScreen> {
  static const int _tabIndex = 2;

  final int _selectedBottomIndex = _tabIndex;
  final TextEditingController _emailController = TextEditingController();

  RequestBookingOption? _selectedBooking;
  List<RequestBookingOption> _bookingOptions = const <RequestBookingOption>[];
  final GlobalKey _bookingFieldKey = GlobalKey();
  bool _isLoadingBookings = true;
  bool _hasLoadedBookings = false;
  bool _isBookingMenuOpen = false;
  bool _isSubmitting = false;
  String? _bookingsError;
  String? _emailError;
  String? _emailSuccess;

  @override
  void initState() {
    super.initState();
    _emailController.addListener(_onAnyFieldChanged);
  }

  @override
  void didChangeDependencies() {
    super.didChangeDependencies();
    if (_hasLoadedBookings) {
      return;
    }
    _hasLoadedBookings = true;
    _loadBookings();
  }

  void _onAnyFieldChanged() {
    setState(() {
      _emailError = null;
      _emailSuccess = null;
    });
  }

  void _onBottomChanged(int index) {
    AppTabNavigator.goToTab(context, index);
  }

  Future<void> _loadBookings() async {
    setState(() {
      _isLoadingBookings = true;
      _bookingsError = null;
    });

    try {
      final bookings = await AppScope.of(context).requestsRepository
          .getMyBookings();
      if (!mounted) {
        return;
      }

      setState(() {
        _bookingOptions = bookings;
        _isLoadingBookings = false;

        if (_selectedBooking != null) {
          final selectedId = _selectedBooking!.id;
          _selectedBooking = bookings.cast<RequestBookingOption?>().firstWhere(
                (item) => item?.id == selectedId,
                orElse: () => null,
              );
        }
      });
    } on AuthRequestException catch (error) {
      if (!mounted) {
        return;
      }
      setState(() {
        _isLoadingBookings = false;
        _bookingsError = error.message;
      });
    } catch (_) {
      if (!mounted) {
        return;
      }
      setState(() {
        _isLoadingBookings = false;
        _bookingsError = 'Не удалось загрузить бронирования.';
      });
    }
  }

  Future<void> _toggleBookingMenu() async {
    if (_isLoadingBookings || _bookingOptions.isEmpty) {
      if (_bookingsError != null) {
        _loadBookings();
      }
      return;
    }

    setState(() {
      _isBookingMenuOpen = !_isBookingMenuOpen;
    });

    if (!_isBookingMenuOpen) {
      return;
    }

    final selected = await showRequestBookingDropdownMenu(
      context: context,
      anchorKey: _bookingFieldKey,
      items: _bookingOptions,
    );
    if (!mounted) {
      return;
    }

    setState(() {
      _isBookingMenuOpen = false;
    });

    if (selected != null) {
      _selectBooking(selected);
    }
  }

  void _selectBooking(RequestBookingOption booking) {
    setState(() {
      _selectedBooking = booking;
      _isBookingMenuOpen = false;
    });
  }

  Future<void> _showPurchaseModal() async {
    final selectedBooking = _selectedBooking;
    final email = _emailController.text.trim();
    if (selectedBooking == null || email.isEmpty) {
      return;
    }

    final confirmed = await PassConfirmationModal.show(
      context,
      booking: selectedBooking.displayText,
      email: email,
    );
    if (!confirmed || !mounted) {
      return;
    }

    setState(() {
      _isSubmitting = true;
      _emailError = null;
      _emailSuccess = null;
    });

    try {
      await AppScope.of(context).rentalsRepository.createUserQr(
        bookingId: selectedBooking.id,
        email: email,
      );

      if (!mounted) {
        return;
      }

      setState(() {
        _isSubmitting = false;
        _selectedBooking = null;
        _isBookingMenuOpen = false;
        _emailError = null;
        _emailSuccess = 'Пропуск успешно выдан';
      });
      _emailController.removeListener(_onAnyFieldChanged);
      _emailController.clear();
      _emailController.addListener(_onAnyFieldChanged);
    } on AuthRequestException catch (error) {
      if (!mounted) {
        return;
      }
      setState(() {
        _isSubmitting = false;
        _emailError = _localizeEmailError(error.message);
        _emailSuccess = null;
      });
    } catch (error) {
      if (!mounted) {
        return;
      }
      setState(() {
        _isSubmitting = false;
        _emailError = error.toString().trim().isNotEmpty
            ? _localizeEmailError(error.toString())
            : 'Не удалось выдать пропуск сотруднику.';
        _emailSuccess = null;
      });
    }
  }

  String _localizeEmailError(String message) {
    final normalized = message.toLowerCase();
    if (normalized.contains('email') &&
        (normalized.contains('valid') ||
            normalized.contains('invalid') ||
            normalized.contains('format'))) {
      return 'Введите корректный адрес электронной почты.';
    }
    return message;
  }

  String get _bookingText {
    if (_selectedBooking != null) {
      return _selectedBooking!.displayText;
    }
    if (_isLoadingBookings) {
      return 'Загрузка бронирований...';
    }
    if (_bookingsError != null) {
      return 'Не удалось загрузить бронирования';
    }
    if (_bookingOptions.isEmpty) {
      return 'Нет активных бронирований';
    }
    return 'Выберите бронирование';
  }

  bool get _canBuyPass =>
      !_isSubmitting &&
      _selectedBooking != null &&
      _emailController.text.trim().isNotEmpty;

  @override
  void dispose() {
    _emailController.removeListener(_onAnyFieldChanged);
    _emailController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return AppShell(
      selectedBottomIndex: _selectedBottomIndex,
      onBottomChanged: _onBottomChanged,
      body: LayoutBuilder(
        builder: (context, constraints) {
          return Padding(
            padding: const EdgeInsets.fromLTRB(20, 46, 20, 0),
            child: SizedBox(
              height: constraints.maxHeight,
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.center,
                children: [
                  const _EmployeePassHeader(),
                  Container(
                    width: double.infinity,
                    padding: const EdgeInsets.fromLTRB(18, 18, 18, 18),
                    decoration: BoxDecoration(
                      color: AppColors.formBlockBackground,
                      borderRadius: BorderRadius.circular(18),
                    ),
                    child: Column(
                      children: [
                        _BookingSelectorSection(
                          fieldKey: _bookingFieldKey,
                          label: 'Список бронирований*',
                          value: _bookingText,
                          isOpen: _isBookingMenuOpen,
                          items: _bookingOptions,
                          onTap: _toggleBookingMenu,
                          onSelect: _selectBooking,
                          errorText: _bookingsError,
                          onRetry: _loadBookings,
                        ),
                        const SizedBox(height: 18),
                        _EmployeePassField(
                          label: 'Эл.почта*',
                          hint: 'Введите электронную почту',
                          controller: _emailController,
                          keyboardType: TextInputType.emailAddress,
                          errorText: _emailError,
                          successText: _emailSuccess,
                        ),
                      ],
                    ),
                  ),
                  const SizedBox(height: 20),
                  PassSubmitButton(
                    text: _isSubmitting ? 'Отправка...' : 'Выдать пропуск',
                    onPressed: _canBuyPass ? _showPurchaseModal : null,
                  ),
                  Expanded(
                    child: Align(
                      alignment: Alignment.bottomCenter,
                      child: Image.asset(
                        'assets/images/passes/employerPasses.png',
                        width: 300,
                        fit: BoxFit.contain,
                      ),
                    ),
                  ),
                ],
              ),
            ),
          );
        },
      ),
    );
  }
}

class _EmployeePassHeader extends StatelessWidget {
  const _EmployeePassHeader();

  @override
  Widget build(BuildContext context) {
    return const Padding(
      padding: EdgeInsets.only(bottom: 14),
      child: SizedBox(
        width: double.infinity,
        child: Text(
          'Пропуск сотрудника',
          style: PassFormStyles.title,
          textAlign: TextAlign.left,
        ),
      ),
    );
  }
}

class _EmployeePassField extends StatelessWidget {
  const _EmployeePassField({
    required this.label,
    required this.hint,
    required this.controller,
    required this.errorText,
    required this.successText,
    this.keyboardType,
  });

  final String label;
  final String hint;
  final TextEditingController controller;
  final String? errorText;
  final String? successText;
  final TextInputType? keyboardType;

  @override
  Widget build(BuildContext context) {
    return Column(
      children: [
        SizedBox(width: double.infinity, child: PassFieldLabel(label)),
        const SizedBox(height: 10),
        PassEditableInputField(
          controller: controller,
          hint: hint,
          keyboardType: keyboardType,
        ),
        if (errorText != null) ...[
          const SizedBox(height: 8),
          PassFieldErrorText(errorText!),
        ] else if (successText != null) ...[
          const SizedBox(height: 8),
          PassFieldSuccessText(successText!),
        ],
      ],
    );
  }
}

class _BookingSelectorSection extends StatelessWidget {
  const _BookingSelectorSection({
    required this.fieldKey,
    required this.label,
    required this.value,
    required this.isOpen,
    required this.items,
    required this.onTap,
    required this.onSelect,
    required this.errorText,
    required this.onRetry,
  });

  final GlobalKey fieldKey;
  final String label;
  final String value;
  final bool isOpen;
  final List<RequestBookingOption> items;
  final VoidCallback onTap;
  final ValueChanged<RequestBookingOption> onSelect;
  final String? errorText;
  final VoidCallback onRetry;

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        SizedBox(width: double.infinity, child: PassFieldLabel(label)),
        const SizedBox(height: 10),
        PassInputField(
          key: fieldKey,
          hint: value,
          hasTrailingBox: true,
          trailing: Icon(
            isOpen
                ? Icons.keyboard_arrow_up_rounded
                : Icons.keyboard_arrow_down_rounded,
            size: 26,
          ),
          onTap: onTap,
          borderRadius: isOpen
              ? const BorderRadius.vertical(
                  top: Radius.circular(12),
                  bottom: Radius.zero,
                )
              : null,
        ),
        if (errorText != null && !isOpen) ...[
          const SizedBox(height: 8),
          TextButton(
            onPressed: onRetry,
            child: const Text('Повторить загрузку бронирований'),
          ),
        ],
      ],
    );
  }
}


