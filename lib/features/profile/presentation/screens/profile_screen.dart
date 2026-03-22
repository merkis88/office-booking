import 'package:flutter/material.dart';
import 'package:wordpice/app/app_scope.dart';
import 'package:wordpice/app/navigation/app_tab_navigator.dart';
import 'package:wordpice/core/network/api_client.dart';
import 'package:wordpice/core/widgets/layout/app_constrained_scroll_view.dart';
import 'package:wordpice/core/widgets/layout/app_shell.dart';
import 'package:wordpice/features/auth/domain/entities/registered_user.dart';
import 'package:wordpice/features/profile/domain/entities/profile_rentals_overview.dart';
import 'package:wordpice/features/profile/domain/entities/rental_history_item.dart';
import 'package:wordpice/features/profile/presentation/models/profile_activity_filter.dart';
import 'package:wordpice/features/profile/presentation/models/profile_pass_item.dart';
import 'package:wordpice/features/profile/presentation/models/profile_request_item.dart';
import 'package:wordpice/features/profile/presentation/screens/edit_profile_screen.dart';
import 'package:wordpice/features/profile/presentation/widgets/cards/profile_info_card.dart';
import 'package:wordpice/features/profile/presentation/widgets/cards/profile_pass_card.dart';
import 'package:wordpice/features/profile/presentation/widgets/cards/profile_user_card.dart';
import 'package:wordpice/features/profile/presentation/widgets/profile_rental_type_filters.dart';
import 'package:wordpice/features/profile/presentation/widgets/qr_modal.dart';
import 'package:wordpice/features/profile/presentation/widgets/sections/profile_activity_section.dart';
import 'package:wordpice/features/profile/presentation/widgets/segment_carousel.dart';

class ProfileScreen extends StatefulWidget {
  const ProfileScreen({super.key});

  @override
  State<ProfileScreen> createState() => _ProfileScreenState();
}

class _ProfileScreenState extends State<ProfileScreen> {
  static const int _tabIndex = 3;
  static const double _contentWidth = 360;
  static const double _narrowCardWidth = 340;
  static const List<ProfileActivityFilter> _activityFilters = [
    ProfileActivityFilter.activeRentals,
    ProfileActivityFilter.favorites,
    ProfileActivityFilter.rentalHistory,
    ProfileActivityFilter.requests,
  ];
  static const List<String> _carouselItems = [
    'Активные аренды',
    'Избранное',
    'История аренды',
    'Заявки',
  ];
  static const ProfileRentalsOverview _emptyOverview = ProfileRentalsOverview(
    activeRentals: <RentalHistoryItem>[],
    rentalHistory: <RentalHistoryItem>[],
  );

  int _selectedBottomIndex = _tabIndex;
  int _carouselIndex = 0;
  bool _isLoading = true;
  bool _hasLoadedOnce = false;
  RegisteredUser? _user;
  ProfileRentalsOverview _rentalsOverview = _emptyOverview;
  List<ProfileRequestItem> _requests = const <ProfileRequestItem>[];
  final Set<int> _cancelingBookingIds = <int>{};
  final Set<int> _downloadingRequestIds = <int>{};

  @override
  void didChangeDependencies() {
    super.didChangeDependencies();
    if (_hasLoadedOnce) {
      return;
    }
    _hasLoadedOnce = true;
    _loadProfile();
  }

  Future<void> _loadProfile() async {
    final dependencies = AppScope.of(context);
    final sessionUser = dependencies.appSession.currentUser;

    if (sessionUser != null) {
      setState(() {
        _user = sessionUser;
        _isLoading = false;
      });
    } else {
      setState(() {
        _isLoading = true;
      });
    }

    RegisteredUser? freshUser;
    ProfileRentalsOverview? rentalsOverview;
    List<ProfileRequestItem>? requests;

    try {
      freshUser = await dependencies.profileRepository.getCurrentProfile();
      dependencies.appSession.updateUser(freshUser);
    } catch (_) {
      // Keep the cached session user if profile refresh fails.
    }

    try {
      rentalsOverview = await dependencies.profileRepository.getRentalsOverview();
    } catch (_) {
      // Keep the last loaded rentals if this request fails.
    }

    try {
      requests = await dependencies.profileRepository.getRequests();
    } catch (_) {
      // Requests should not block rendering profile or rentals.
    }

    if (!mounted) {
      return;
    }

    setState(() {
      _user = freshUser ?? _user;
      _rentalsOverview = rentalsOverview ?? _rentalsOverview;
      _requests = requests ?? _requests;
      _isLoading = false;
    });
  }

  Future<void> _cancelRental(RentalHistoryItem item) async {
    final bookingId = item.bookingId;
    if (bookingId == null) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Не удалось определить бронирование.')),
      );
      return;
    }

    setState(() {
      _cancelingBookingIds.add(bookingId);
    });

    try {
      final repository = AppScope.of(context).profileRepository;
      await repository.cancelBooking(bookingId);

      if (!mounted) {
        return;
      }

      setState(() {
        _rentalsOverview = ProfileRentalsOverview(
          activeRentals: _rentalsOverview.activeRentals
              .where((rental) => rental.bookingId != bookingId)
              .toList(),
          rentalHistory: _rentalsOverview.rentalHistory,
        );
      });
    } catch (error) {
      if (!mounted) {
        return;
      }

      final message = error is ApiConnectionException
          ? error.message
          : 'Не удалось отменить бронь.';
      ScaffoldMessenger.of(
        context,
      ).showSnackBar(SnackBar(content: Text(message)));
    } finally {
      if (mounted) {
        setState(() {
          _cancelingBookingIds.remove(bookingId);
        });
      }
    }
  }

  bool _isBookingCancelling(RentalHistoryItem item) {
    final bookingId = item.bookingId;
    return bookingId != null && _cancelingBookingIds.contains(bookingId);
  }

  Future<void> _downloadRequestPdf(ProfileRequestItem item) async {
    if (_downloadingRequestIds.contains(item.id)) {
      return;
    }

    setState(() {
      _downloadingRequestIds.add(item.id);
    });

    try {
      final filePath = await AppScope.of(context).profileRepository
          .exportRequestPdf(item.id);

      if (!mounted) {
        return;
      }

      ScaffoldMessenger.of(
        context,
      ).showSnackBar(SnackBar(content: Text('PDF сохранен: $filePath')));
    } catch (error) {
      if (!mounted) {
        return;
      }

      final message = error is ApiConnectionException
          ? error.message
          : 'Не удалось скачать PDF.';
      ScaffoldMessenger.of(
        context,
      ).showSnackBar(SnackBar(content: Text(message)));
    } finally {
      if (mounted) {
        setState(() {
          _downloadingRequestIds.remove(item.id);
        });
      }
    }
  }

  bool _isRequestDownloading(ProfileRequestItem item) {
    return _downloadingRequestIds.contains(item.id);
  }

  Future<void> _openEditScreen() async {
    final user = _user;
    if (user == null) {
      return;
    }

    final updatedUser = await Navigator.of(
      context,
    ).push<RegisteredUser>(
      MaterialPageRoute(builder: (_) => EditProfileScreen(user: user)),
    );

    if (!mounted || updatedUser == null) {
      return;
    }

    setState(() {
      _user = updatedUser;
    });
  }

  void _onBottomChanged(int index) {
    if (index == _tabIndex) {
      return;
    }
    setState(() {
      _selectedBottomIndex = index;
    });
    AppTabNavigator.goToTab(context, index);
  }

  ProfileActivityFilter get _selectedActivityFilter {
    if (_carouselIndex < 0 || _carouselIndex >= _activityFilters.length) {
      return ProfileActivityFilter.rentalHistory;
    }
    return _activityFilters[_carouselIndex];
  }

  void _showPassQr() {
    final user = _user;
    if (user == null) {
      return;
    }

    final validUntilText =
        _buildQrValidUntilText(user) ?? _buildFallbackQrValidUntilText();
    if (validUntilText == null) {
      QrModal.showNoActiveRentals(context);
      return;
    }
    QrModal.showQr(context, validUntilText: validUntilText);
  }

  String? _buildQrValidUntilText(RegisteredUser user) {
    final availableUntil = user.qrAvailableUntil?.trim();
    final timeWindow = user.qrTimeWindow?.trim();

    if (availableUntil != null && availableUntil.isNotEmpty) {
      return _formatQrDateTime(availableUntil);
    }

    if (timeWindow != null && timeWindow.isNotEmpty) {
      return timeWindow;
    }

    return null;
  }

  String _formatQrDateTime(String value) {
    final dateTime = DateTime.tryParse(value)?.toLocal();
    if (dateTime == null) {
      return value;
    }

    final day = dateTime.day.toString().padLeft(2, '0');
    final month = dateTime.month.toString().padLeft(2, '0');
    final year = dateTime.year.toString();
    final hour = dateTime.hour.toString().padLeft(2, '0');
    final minute = dateTime.minute.toString().padLeft(2, '0');
    return '$day.$month.$year $hour:$minute';
  }

  String? _buildFallbackQrValidUntilText() {
    if (_rentalsOverview.activeRentals.isEmpty) {
      return null;
    }

    DateTime? latestEnd;
    for (final rental in _rentalsOverview.activeRentals) {
      final candidate = _extractRentalEndDateTime(rental);
      if (candidate == null) {
        continue;
      }
      if (latestEnd == null || candidate.isAfter(latestEnd)) {
        latestEnd = candidate;
      }
    }

    if (latestEnd == null) {
      return null;
    }

    return _formatQrDateTime(latestEnd.toIso8601String());
  }

  DateTime? _extractRentalEndDateTime(RentalHistoryItem rental) {
    final dateIso = rental.dateIso;
    if (dateIso == null || rental.timeSlots.isEmpty) {
      return null;
    }

    final match = RegExp(
      r'(\d{2}:\d{2})\s*-\s*(\d{2}:\d{2})',
    ).firstMatch(rental.timeSlots.first);
    if (match == null) {
      return null;
    }

    final endTime = match.group(2);
    if (endTime == null) {
      return null;
    }

    return DateTime.tryParse('${dateIso}T$endTime:00');
  }

  ProfilePassItem _buildProfilePass(RegisteredUser user) {
    final validUntilText =
        _buildQrValidUntilText(user) ?? _buildFallbackQrValidUntilText();
    return ProfilePassItem(
      title: 'Qr-код пропуск',
      showButtonLabel: 'Показать',
      validUntilText: validUntilText,
    );
  }

  Widget _buildBody() {
    if (_isLoading && _user == null) {
      return const Center(child: CircularProgressIndicator());
    }

    final user = _user;
    if (user == null) {
      return const Center(child: Text('Данные профиля недоступны.'));
    }

    return _ProfileContent(
      user: user,
      profilePass: _buildProfilePass(user),
      onEditTap: () => _openEditScreen(),
      carouselItems: _carouselItems,
      carouselIndex: _carouselIndex,
      onCarouselChanged: (index) => setState(() => _carouselIndex = index),
      selectedActivityFilter: _selectedActivityFilter,
      rentalsOverview: _rentalsOverview,
      requests: _requests,
      onShowPassQr: _showPassQr,
      onCancelRental: _cancelRental,
      isBookingCancelling: _isBookingCancelling,
      onDownloadRequest: _downloadRequestPdf,
      isRequestDownloading: _isRequestDownloading,
    );
  }

  @override
  Widget build(BuildContext context) {
    return AppShell(
      selectedBottomIndex: _selectedBottomIndex,
      onBottomChanged: _onBottomChanged,
      body: AppConstrainedScrollView(
        maxWidth: _contentWidth,
        padding: const EdgeInsets.fromLTRB(16, 40, 16, 28),
        child: _buildBody(),
      ),
    );
  }
}

class _ProfileContent extends StatelessWidget {
  const _ProfileContent({
    required this.user,
    required this.profilePass,
    required this.onEditTap,
    required this.carouselItems,
    required this.carouselIndex,
    required this.onCarouselChanged,
    required this.selectedActivityFilter,
    required this.rentalsOverview,
    required this.requests,
    required this.onShowPassQr,
    required this.onCancelRental,
    required this.isBookingCancelling,
    required this.onDownloadRequest,
    required this.isRequestDownloading,
  });

  final RegisteredUser user;
  final ProfilePassItem profilePass;
  final VoidCallback onEditTap;
  final List<String> carouselItems;
  final int carouselIndex;
  final ValueChanged<int> onCarouselChanged;
  final ProfileActivityFilter selectedActivityFilter;
  final ProfileRentalsOverview rentalsOverview;
  final List<ProfileRequestItem> requests;
  final VoidCallback onShowPassQr;
  final Future<void> Function(RentalHistoryItem item) onCancelRental;
  final bool Function(RentalHistoryItem item) isBookingCancelling;
  final Future<void> Function(ProfileRequestItem item) onDownloadRequest;
  final bool Function(ProfileRequestItem item) isRequestDownloading;

  @override
  Widget build(BuildContext context) {
    return Column(
      children: [
        ProfileUserCard(
          onEditTap: onEditTap,
          fullName: user.fullName,
          photoUrl: user.photo,
        ),
        const SizedBox(height: 30),
        _NarrowCard(
          child: ProfileInfoCard(
            onEditTap: onEditTap,
            email: user.email,
          ),
        ),
        const SizedBox(height: 30),
        _NarrowCard(
          child: ProfilePassCard(
            pass: profilePass,
            onShowPressed: onShowPassQr,
          ),
        ),
        const SizedBox(height: 30),
        _ProfileActivityControls(
          items: carouselItems,
          carouselIndex: carouselIndex,
          onChanged: onCarouselChanged,
        ),
        const SizedBox(height: 30),
        _NarrowCard(
          child: ProfileActivitySection(
            filter: selectedActivityFilter,
            activeRentals: rentalsOverview.activeRentals,
            rentalHistory: rentalsOverview.rentalHistory,
            requests: requests,
            onCancelRental: onCancelRental,
            isBookingCancelling: isBookingCancelling,
            onDownloadRequest: onDownloadRequest,
            isRequestDownloading: isRequestDownloading,
          ),
        ),
      ],
    );
  }
}

class _ProfileActivityControls extends StatelessWidget {
  const _ProfileActivityControls({
    required this.items,
    required this.carouselIndex,
    required this.onChanged,
  });

  final List<String> items;
  final int carouselIndex;
  final ValueChanged<int> onChanged;

  @override
  Widget build(BuildContext context) {
    return Column(
      children: [
        _NarrowCard(
          child: Center(
            child: SegmentCarousel(
              items: items,
              initialIndex: carouselIndex,
              onChanged: onChanged,
            ),
          ),
        ),
        const SizedBox(height: 26),
        const _NarrowCard(child: ProfileRentalTypeFilters()),
      ],
    );
  }
}

class _NarrowCard extends StatelessWidget {
  const _NarrowCard({required this.child});

  final Widget child;

  @override
  Widget build(BuildContext context) {
    return SizedBox(width: _ProfileScreenState._narrowCardWidth, child: child);
  }
}
