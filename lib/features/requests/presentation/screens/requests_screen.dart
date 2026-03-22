import 'package:flutter/material.dart';
import 'package:flutter_svg/flutter_svg.dart';
import 'package:wordpice/app/app_scope.dart';
import 'package:wordpice/app/navigation/app_tab_navigator.dart';
import 'package:wordpice/core/theme/app_colors.dart';
import 'package:wordpice/core/widgets/layout/app_constrained_scroll_view.dart';
import 'package:wordpice/core/widgets/layout/app_shell.dart';
import 'package:wordpice/features/auth/data/datasources/auth_data_source.dart';
import 'package:wordpice/features/requests/domain/entities/create_request_params.dart';
import 'package:wordpice/features/requests/domain/entities/request_booking_option.dart';
import 'package:wordpice/features/requests/presentation/widgets/forms/request_form_comment_field.dart';
import 'package:wordpice/features/requests/presentation/widgets/forms/request_form_dropdown_menu.dart';
import 'package:wordpice/features/requests/presentation/widgets/forms/request_form_field_label.dart';
import 'package:wordpice/features/requests/presentation/widgets/forms/request_form_input_field.dart';
import 'package:wordpice/features/requests/presentation/widgets/forms/request_form_submit_button.dart';
import 'package:wordpice/features/requests/presentation/widgets/modals/request_confirmation_modal.dart';
import 'package:wordpice/features/requests/presentation/widgets/styles/request_form_styles.dart';

const _kScreenPadding = EdgeInsets.fromLTRB(24, 16, 24, 24);
const _kSectionGap = SizedBox(height: 18);
const _kLabelGap = SizedBox(height: 8);
const _kFieldsBlockPadding = EdgeInsets.fromLTRB(14, 12, 14, 24);

enum _RequestMenu { booking, time, requestType }

class RequestsScreen extends StatefulWidget {
  const RequestsScreen({super.key});

  @override
  State<RequestsScreen> createState() => _RequestsScreenState();
}

class _RequestsScreenState extends State<RequestsScreen> {
  static const int _tabIndex = 1;
  static const double _contentWidth = double.infinity;
  static const List<String> _requestTypes = ['Клининг', 'ТО'];

  int _selectedBottomIndex = _tabIndex;
  DateTime? _selectedDate;
  RequestBookingOption? _selectedBooking;
  String? _selectedRequestType;
  String? _selectedTime;
  _RequestMenu? _openMenu;
  bool _isLoadingBookings = true;
  bool _isSubmitting = false;
  bool _hasLoadedBookings = false;
  String? _bookingsError;
  String? _submitError;
  List<RequestBookingOption> _bookingOptions = const <RequestBookingOption>[];
  final TextEditingController _commentController = TextEditingController();

  @override
  void didChangeDependencies() {
    super.didChangeDependencies();
    if (_hasLoadedBookings) return;
    _hasLoadedBookings = true;
    _loadBookings();
  }

  @override
  void dispose() {
    _commentController.dispose();
    super.dispose();
  }

  void _onBottomChanged(int index) {
    if (index == _tabIndex) return;
    setState(() => _selectedBottomIndex = index);
    AppTabNavigator.goToTab(context, index);
  }

  Future<void> _loadBookings() async {
    setState(() {
      _isLoadingBookings = true;
      _bookingsError = null;
    });

    try {
      final bookings = await AppScope.of(context).requestsRepository.getMyBookings();
      if (!mounted) return;

      setState(() {
        _bookingOptions = bookings;
        _isLoadingBookings = false;

        if (_selectedBooking != null) {
          final selectedId = _selectedBooking!.id;
          _selectedBooking = bookings.cast<RequestBookingOption?>().firstWhere(
                (item) => item?.id == selectedId,
                orElse: () => null,
              );

          if (_selectedBooking != null) {
            _selectedDate = _parseServiceDate(_selectedBooking!.serviceDate);
            if (!_timeSlots.contains(_selectedTime)) {
              _selectedTime = null;
            }
          }
        }
      });
    } on AuthRequestException catch (error) {
      if (!mounted) return;
      setState(() {
        _isLoadingBookings = false;
        _bookingsError = error.message;
      });
    } catch (_) {
      if (!mounted) return;
      setState(() {
        _isLoadingBookings = false;
        _bookingsError = 'Не удалось загрузить бронирования.';
      });
    }
  }

  List<String> get _timeSlots => _selectedBooking?.timeSlots ?? const <String>[];

  String get _dateText {
    if (_selectedBooking != null) {
      return _selectedBooking!.dateLabel;
    }
    return 'Выберите бронирование';
  }

  String get _bookingText {
    if (_selectedBooking != null) return _selectedBooking!.displayText;
    if (_isLoadingBookings) return 'Загрузка бронирований...';
    if (_bookingsError != null) return 'Не удалось загрузить бронирования';
    if (_bookingOptions.isEmpty) return 'Нет активных бронирований';
    return 'Выберите бронирование';
  }

  String get _timeText {
    if (_selectedTime != null) return _selectedTime!;
    if (_selectedBooking == null) return 'Сначала выберите бронирование';
    if (_timeSlots.isEmpty) return 'Нет доступного времени';
    return 'Выберите время из бронирования';
  }

  String get _requestTypeText =>
      _selectedRequestType ?? 'Выберите тип заявки';

  bool get _isBookingMenuOpen => _openMenu == _RequestMenu.booking;
  bool get _isTimeMenuOpen => _openMenu == _RequestMenu.time;
  bool get _isRequestTypeMenuOpen => _openMenu == _RequestMenu.requestType;

  void _toggleMenu(_RequestMenu menu) {
    if (menu == _RequestMenu.booking &&
        (_isLoadingBookings || _bookingOptions.isEmpty)) {
      if (_bookingsError != null) {
        _loadBookings();
      }
      return;
    }

    if (menu == _RequestMenu.time &&
        (_selectedBooking == null || _timeSlots.isEmpty)) {
      return;
    }

    setState(() {
      _openMenu = _openMenu == menu ? null : menu;
    });
  }

  void _selectBooking(RequestBookingOption booking) {
    setState(() {
      _selectedBooking = booking;
      _selectedDate = _parseServiceDate(booking.serviceDate);
      if (!_timeSlots.contains(_selectedTime)) {
        _selectedTime = null;
      }
      _openMenu = null;
    });
  }

  void _selectRequestType(String type) {
    setState(() {
      _selectedRequestType = type;
      _openMenu = null;
    });
  }

  void _selectTime(String slot) {
    setState(() {
      _selectedTime = slot;
      _openMenu = null;
    });
  }

  int get _serviceTypeId {
    switch (_selectedRequestType) {
      case 'Клининг':
        return 1;
      case 'ТО':
        return 2;
      default:
        return 0;
    }
  }

  bool get _canCreateRequest =>
      !_isSubmitting &&
      _selectedDate != null &&
      _selectedBooking != null &&
      _selectedRequestType != null &&
      _selectedTime != null;

  String _extractServiceTime(String slot) {
    final parts = slot.split('-');
    if (parts.isEmpty) return slot.trim();
    return parts.first.trim();
  }

  DateTime? _parseServiceDate(String rawValue) {
    final parts = rawValue.split('-');
    if (parts.length != 3) {
      return null;
    }

    final year = int.tryParse(parts[0]);
    final month = int.tryParse(parts[1]);
    final day = int.tryParse(parts[2]);
    if (year == null || month == null || day == null) {
      return null;
    }

    return DateTime(year, month, day);
  }

  Future<void> _createRequest() async {
    final selectedDate = _selectedDate;
    final selectedBooking = _selectedBooking;
    final selectedRequestType = _selectedRequestType;
    final selectedTime = _selectedTime;

    if (selectedDate == null ||
        selectedBooking == null ||
        selectedRequestType == null ||
        selectedTime == null) {
      return;
    }

    final confirmed = await RequestConfirmationModal.show(
      context,
      date: _dateText,
      time: selectedTime,
      requestType: selectedRequestType,
      booking: selectedBooking.displayText,
    );

    if (!confirmed || !mounted) return;

    setState(() {
      _isSubmitting = true;
      _submitError = null;
    });

    try {
      await AppScope.of(context).requestsRepository.createRequest(
        CreateRequestParams(
          bookingId: selectedBooking.id,
          serviceTypeId: _serviceTypeId,
          serviceDate: selectedBooking.serviceDate,
          serviceTime: _extractServiceTime(selectedTime),
          comment: _commentController.text.trim(),
        ),
      );

      if (!mounted) return;
      AppTabNavigator.goToTab(context, 3);
    } on AuthRequestException catch (error) {
      if (!mounted) return;
      setState(() {
        _isSubmitting = false;
        _submitError = error.message;
      });
    } catch (_) {
      if (!mounted) return;
      setState(() {
        _isSubmitting = false;
        _submitError = 'Не удалось создать заявку.';
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    return AppShell(
      selectedBottomIndex: _selectedBottomIndex,
      onBottomChanged: _onBottomChanged,
      body: AppConstrainedScrollView(
        maxWidth: _contentWidth,
        padding: _kScreenPadding,
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const Text('Заявки', style: RequestFormStyles.title),
            const SizedBox(height: 14),
            Container(
              width: double.infinity,
              padding: _kFieldsBlockPadding,
              decoration: BoxDecoration(
                color: AppColors.formBlockBackground,
                borderRadius: BorderRadius.circular(16),
              ),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  _RequestBookingSection(
                    value: _bookingText,
                    isOpen: _isBookingMenuOpen,
                    onTap: () => _toggleMenu(_RequestMenu.booking),
                    items: _bookingOptions,
                    onSelect: _selectBooking,
                    errorText: _bookingsError,
                    onRetry: _loadBookings,
                  ),
                  _RequestDateSection(dateText: _dateText),
                  _RequestDropdownSection(
                    label: 'Время*',
                    value: _timeText,
                    isOpen: _isTimeMenuOpen,
                    onTap: () => _toggleMenu(_RequestMenu.time),
                    items: _timeSlots,
                    onSelect: _selectTime,
                    menuHeight: 86,
                  ),
                  _RequestDropdownSection(
                    label: 'Тип заявки*',
                    value: _requestTypeText,
                    isOpen: _isRequestTypeMenuOpen,
                    onTap: () => _toggleMenu(_RequestMenu.requestType),
                    items: _requestTypes,
                    onSelect: _selectRequestType,
                    menuHeight: 74,
                  ),
                  _RequestCommentSection(controller: _commentController),
                ],
              ),
            ),
            if (_submitError != null) ...[
              const SizedBox(height: 12),
              Center(
                child: Text(
                  _submitError!,
                  textAlign: TextAlign.center,
                  style: const TextStyle(color: Colors.redAccent),
                ),
              ),
            ],
            const SizedBox(height: 20),
            Center(
              child: RequestFormSubmitButton(
                text: _isSubmitting ? 'Создание...' : 'Создать заявку',
                onPressed: _canCreateRequest ? _createRequest : null,
              ),
            ),
          ],
        ),
      ),
    );
  }
}

class _RequestBookingSection extends StatelessWidget {
  const _RequestBookingSection({
    required this.value,
    required this.isOpen,
    required this.onTap,
    required this.items,
    required this.onSelect,
    required this.errorText,
    required this.onRetry,
  });

  final String value;
  final bool isOpen;
  final VoidCallback onTap;
  final List<RequestBookingOption> items;
  final ValueChanged<RequestBookingOption> onSelect;
  final String? errorText;
  final VoidCallback onRetry;

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        _kSectionGap,
        const RequestFormFieldLabel('Список бронирований*'),
        _kLabelGap,
        RequestFormInputField(
          hint: value,
          trailing: Icon(
            isOpen
                ? Icons.keyboard_arrow_up_rounded
                : Icons.keyboard_arrow_down_rounded,
            size: 26,
          ),
          onTap: onTap,
          borderRadius: isOpen
              ? RequestFormStyles.dropdownOpenRadius
              : RequestFormStyles.fieldBorderRadius,
        ),
        if (errorText != null && !isOpen) ...[
          const SizedBox(height: 8),
          TextButton(
            onPressed: onRetry,
            child: const Text('Повторить загрузку бронирований'),
          ),
        ],
        if (isOpen)
          RequestBookingDropdownMenu(
            items: items,
            onSelect: onSelect,
            height: 132,
          ),
      ],
    );
  }
}

class _RequestDateSection extends StatelessWidget {
  const _RequestDateSection({required this.dateText});

  final String dateText;

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        _kSectionGap,
        const RequestFormFieldLabel('Дата*'),
        _kLabelGap,
        RequestFormInputField(
          hint: dateText,
          trailing: SvgPicture.asset(
            'assets/icons/calendar.svg',
            width: 24,
            height: 24,
            colorFilter: const ColorFilter.mode(
              Colors.black87,
              BlendMode.srcIn,
            ),
          ),
          showTrailingFrame: false,
        ),
      ],
    );
  }
}

class _RequestDropdownSection extends StatelessWidget {
  const _RequestDropdownSection({
    required this.label,
    required this.value,
    required this.isOpen,
    required this.onTap,
    required this.items,
    required this.onSelect,
    required this.menuHeight,
  });

  final String label;
  final String value;
  final bool isOpen;
  final VoidCallback onTap;
  final List<String> items;
  final ValueChanged<String> onSelect;
  final double menuHeight;

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        _kSectionGap,
        RequestFormFieldLabel(label),
        _kLabelGap,
        RequestFormInputField(
          hint: value,
          trailing: Icon(
            isOpen
                ? Icons.keyboard_arrow_up_rounded
                : Icons.keyboard_arrow_down_rounded,
            size: 26,
          ),
          onTap: onTap,
          borderRadius: isOpen
              ? RequestFormStyles.dropdownOpenRadius
              : RequestFormStyles.fieldBorderRadius,
        ),
        if (isOpen)
          RequestFormDropdownMenu(
            items: items,
            onSelect: onSelect,
            height: menuHeight,
          ),
      ],
    );
  }
}

class _RequestCommentSection extends StatelessWidget {
  const _RequestCommentSection({required this.controller});

  final TextEditingController controller;

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        _kSectionGap,
        const RequestFormFieldLabel('Комментарий (необязательно)'),
        _kLabelGap,
        RequestFormCommentField(controller: controller),
      ],
    );
  }
}
