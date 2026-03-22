import 'package:flutter/material.dart';
import 'package:wordpice/app/app_scope.dart';
import 'package:wordpice/app/navigation/app_tab_navigator.dart';
import 'package:wordpice/core/network/api_client.dart';
import 'package:wordpice/core/widgets/layout/app_shell.dart';
import 'package:wordpice/features/rentals/domain/entities/create_booking_params.dart';
import 'package:wordpice/features/rentals/presentation/models/office_rental_item.dart';
import 'package:wordpice/features/rentals/presentation/utils/rental_date_text_helper.dart';
import 'package:wordpice/features/rentals/presentation/utils/rental_time_slots_helper.dart';
import 'package:wordpice/features/rentals/presentation/widgets/cards/office_rental_card.dart';
import 'package:wordpice/features/rentals/presentation/widgets/modals/place_details_modal.dart';
import 'package:wordpice/features/rentals/presentation/widgets/sections/rental_filter_controls_section.dart';
import 'package:wordpice/features/rentals/presentation/widgets/states/rental_empty_rooms_state.dart';

class PlaceRentalScreen extends StatefulWidget {
  const PlaceRentalScreen({
    super.key,
    required this.placeType,
  });

  final String placeType;

  @override
  State<PlaceRentalScreen> createState() => _PlaceRentalScreenState();
}

class _PlaceRentalScreenState extends State<PlaceRentalScreen> {
  static const int _tabIndex = 0;
  static const int _defaultMinPrice = 0;
  static const int _defaultMaxPrice = 1000000000;

  final int _selectedBottomIndex = _tabIndex;

  DateTime? _selectedDate;
  RangeValues _priceRange = const RangeValues(0, 0);
  List<OfficeRentalItem> _items = const <OfficeRentalItem>[];
  bool _isLoading = true;
  bool _hasLoadedOnce = false;
  String? _errorMessage;
  double _minPrice = 0;
  double _maxPrice = 0;

  void _onBottomChanged(int index) {
    AppTabNavigator.goToTab(context, index);
  }

  Future<void> _pickDate() async {
    final now = DateTime.now();
    final today = DateTime(now.year, now.month, now.day);
    final picked = await showDatePicker(
      context: context,
      initialDate: _selectedDate ?? today,
      firstDate: today,
      lastDate: DateTime(today.year + 5),
      locale: const Locale('ru', 'RU'),
    );
    if (picked == null) return;

    setState(() => _selectedDate = picked);
    await _loadPlaces();
  }

  String get _dateText => RentalDateTextHelper.formatDayMonth(_selectedDate);

  String get _cardDateText {
    final now = DateTime.now();
    final selectedDate =
        _selectedDate ?? DateTime(now.year, now.month, now.day);
    return RentalDateTextHelper.formatFullDate(selectedDate);
  }

  DateTime get _bookingDate {
    final now = DateTime.now();
    return _selectedDate ?? DateTime(now.year, now.month, now.day);
  }

  String get _selectedDateKey {
    final date = _bookingDate;
    final year = date.year.toString().padLeft(4, '0');
    final month = date.month.toString().padLeft(2, '0');
    final day = date.day.toString().padLeft(2, '0');
    return '$year-$month-$day';
  }

  @override
  void didChangeDependencies() {
    super.didChangeDependencies();
    if (_hasLoadedOnce) return;
    _hasLoadedOnce = true;
    _loadPlaces();
  }

  Future<void> _loadPlaces() async {
    setState(() {
      _isLoading = true;
      _errorMessage = null;
    });

    try {
      final requestMinPrice = _minPrice > 0
          ? _priceRange.start.round()
          : _defaultMinPrice;
      final requestMaxPrice = _maxPrice > 0
          ? _priceRange.end.round()
          : _defaultMaxPrice;

      final result = await AppScope.of(context).rentalsRepository.getPlaces(
        type: widget.placeType,
        date: _selectedDateKey,
        minPrice: requestMinPrice,
        maxPrice: requestMaxPrice,
      );
      if (!mounted) return;

      final minPrice = result.minPrice.toDouble();
      final maxPrice = result.maxPrice.toDouble();
      final normalizedMax = maxPrice < minPrice ? minPrice : maxPrice;
      final shouldResetRange = _priceRange.start == 0 && _priceRange.end == 0;
      final nextStart = shouldResetRange
          ? minPrice
          : _priceRange.start.clamp(minPrice, normalizedMax);
      final nextEnd = shouldResetRange
          ? normalizedMax
          : _priceRange.end.clamp(minPrice, normalizedMax);

      setState(() {
        _items = result.items;
        _minPrice = minPrice;
        _maxPrice = normalizedMax;
        _priceRange = RangeValues(
          nextStart <= nextEnd ? nextStart : nextEnd,
          nextEnd >= nextStart ? nextEnd : nextStart,
        );
      });
    } on ApiConnectionException catch (error) {
      if (!mounted) return;
      setState(() {
        _items = const <OfficeRentalItem>[];
        _errorMessage = error.message;
      });
    } catch (_) {
      if (!mounted) return;
      setState(() {
        _items = const <OfficeRentalItem>[];
        _errorMessage = 'Не удалось загрузить помещения.';
      });
    } finally {
      if (mounted) {
        setState(() => _isLoading = false);
      }
    }
  }

  Future<String?> _createBooking(
    OfficeRentalItem item,
    String timeRange,
  ) async {
    final currentUser = AppScope.of(context).appSession.currentUser;
    if (currentUser == null) {
      return 'Не удалось определить пользователя для бронирования.';
    }

    final parsedRange = RentalTimeSlotsHelper.parseRange(timeRange);
    if (parsedRange == null) {
      return 'Не удалось определить выбранное время.';
    }

    final bookingDate = _bookingDate;
    final startTime = DateTime(
      bookingDate.year,
      bookingDate.month,
      bookingDate.day,
      parsedRange.$1,
    );
    final endTime = DateTime(
      bookingDate.year,
      bookingDate.month,
      bookingDate.day,
      parsedRange.$2,
    );

    try {
      await AppScope.of(context).rentalsRepository.createBooking(
        CreateBookingParams(
          placeId: item.id,
          userId: currentUser.id,
          startTime: startTime,
          endTime: endTime,
          passType: 'qr',
        ),
      );
    } on ApiConnectionException catch (error) {
      return error.message;
    } catch (_) {
      return 'Не удалось создать бронирование.';
    }

    if (!mounted) return null;
    AppTabNavigator.goToTab(context, 3);
    return null;
  }

  Future<String?> _toggleFavorite({
    required OfficeRentalItem item,
    required bool nextValue,
  }) async {
    try {
      if (nextValue) {
        await AppScope.of(context).rentalsRepository.addFavorite(
          placeId: item.id,
        );
      } else {
        await AppScope.of(context).rentalsRepository.removeFavorite(
          placeId: item.id,
        );
      }
      return null;
    } on ApiConnectionException catch (error) {
      return error.message;
    } catch (_) {
      return nextValue
          ? 'Не удалось добавить помещение в избранное.'
          : 'Не удалось удалить помещение из избранного.';
    }
  }

  Future<void> _applyPriceFilter(RangeValues values) async {
    setState(() => _priceRange = values);
    await _loadPlaces();
  }

  Future<void> _showPlaceDetails(OfficeRentalItem item) async {
    try {
      final details = await AppScope.of(context).rentalsRepository.getPlaceDetails(
        placeId: item.id,
        date: _selectedDateKey,
      );
      if (!mounted) return;
      await PlaceDetailsModal.show(context, details: details);
    } on ApiConnectionException catch (error) {
      if (!mounted) return;
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text(error.message)),
      );
    } catch (_) {
      if (!mounted) return;
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('Не удалось загрузить информацию о помещении.'),
        ),
      );
    }
  }

  String _formatPrice(double price) {
    final text = price.round().toString();
    if (text.length <= 3) return text;
    return '${text.substring(0, text.length - 3)} '
        '${text.substring(text.length - 3)}';
  }

  @override
  Widget build(BuildContext context) {
    return AppShell(
      selectedBottomIndex: _selectedBottomIndex,
      onBottomChanged: _onBottomChanged,
      body: SingleChildScrollView(
        padding: const EdgeInsets.fromLTRB(16, 20, 16, 28),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            RentalFilterControlsSection(
              dateText: _dateText,
              onPickDate: _pickDate,
              priceRange: _priceRange,
              minPrice: _minPrice,
              maxPrice: _maxPrice,
              onPriceChanged: (values) => setState(() => _priceRange = values),
              onPriceChangeEnd: _applyPriceFilter,
              formatPrice: _formatPrice,
              dateLeftPadding: 10,
            ),
            const SizedBox(height: 20),
            if (_errorMessage != null)
              Padding(
                padding: const EdgeInsets.only(left: 10, bottom: 12),
                child: Text(
                  _errorMessage!,
                  style: const TextStyle(color: Colors.redAccent),
                ),
              ),
            if (_isLoading)
              const Center(
                child: Padding(
                  padding: EdgeInsets.only(top: 120),
                  child: CircularProgressIndicator(),
                ),
              )
            else if (_items.isEmpty) ...[
              const SizedBox(height: 220),
              const Padding(
                padding: EdgeInsets.only(left: 10),
                child: RentalEmptyRoomsState(),
              ),
            ] else ...[
              for (final item in _items) ...[
                Center(
                  child: ConstrainedBox(
                    constraints: const BoxConstraints(maxWidth: 332),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Padding(
                          padding: const EdgeInsets.only(left: 4, bottom: 6),
                          child: Text(
                            _cardDateText,
                            style: const TextStyle(
                              fontSize: 16,
                              fontWeight: FontWeight.w400,
                            ),
                          ),
                        ),
                        OfficeRentalCard(
                          key: ValueKey('${item.id}_$_selectedDateKey'),
                          item: item,
                          dateText: _cardDateText,
                          availableTimeSlots: item.availableTimeSlots,
                          onBook: (timeRange) => _createBooking(item, timeRange),
                          onBooked: (_, _) {},
                          onFavoriteToggle: (nextValue) => _toggleFavorite(
                            item: item,
                            nextValue: nextValue,
                          ),
                          onDetailsTap: () => _showPlaceDetails(item),
                        ),
                      ],
                    ),
                  ),
                ),
                const SizedBox(height: 12),
              ],
            ],
          ],
        ),
      ),
    );
  }
}
