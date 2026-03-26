import 'package:flutter/material.dart';
import 'package:image_picker/image_picker.dart';
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
  bool _isUploadingAvatar = false;
  String? _profileLoadErrorMessage;
  RegisteredUser? _user;
  ProfileRentalsOverview _rentalsOverview = _emptyOverview;
  List<RentalHistoryItem> _favoriteRentals = const <RentalHistoryItem>[];
  List<ProfileRequestItem> _requests = const <ProfileRequestItem>[];
  final Set<int> _cancelingBookingIds = <int>{};
  final Set<int> _togglingFavoritePlaceIds = <int>{};
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
    List<RentalHistoryItem>? favoriteRentals;
    List<ProfileRequestItem>? requests;

    try {
      freshUser = await dependencies.profileRepository.getCurrentProfile();
      dependencies.appSession.updateUser(freshUser);
      _profileLoadErrorMessage = null;
    } catch (error) {
      _profileLoadErrorMessage = error.toString();
      // Keep the cached session user if profile refresh fails.
    }

    try {
      rentalsOverview = await dependencies.profileRepository.getRentalsOverview();
    } catch (_) {
      // Keep the last loaded rentals if this request fails.
    }

    try {
      favoriteRentals = await dependencies.profileRepository.getFavoritePlaces();
    } catch (_) {
      // Favorites should not block the rest of the profile.
    }

    try {
      requests = await dependencies.profileRepository.getRequests();
    } catch (_) {
      // Requests should not block rendering profile or rentals.
    }

    if (!mounted) {
      return;
    }

    final profileLoadErrorMessage = _profileLoadErrorMessage;
    if (profileLoadErrorMessage != null && profileLoadErrorMessage.isNotEmpty) {
      WidgetsBinding.instance.addPostFrameCallback((_) {
        if (!mounted) {
          return;
        }
        ScaffoldMessenger.of(context)
          ..hideCurrentSnackBar()
          ..showSnackBar(
            SnackBar(
              content: Text('Не удалось обновить профиль: $profileLoadErrorMessage'),
            ),
          );
      });
    }

    final nextFavoriteRentals = favoriteRentals ?? _favoriteRentals;
    final favoritePlaceIds = nextFavoriteRentals
        .map((item) => item.placeId)
        .whereType<int>()
        .toSet();

    setState(() {
      _user = freshUser ?? _user;
      _rentalsOverview = _applyFavoriteFlags(
        rentalsOverview ?? _rentalsOverview,
        favoritePlaceIds,
      );
      _favoriteRentals = nextFavoriteRentals;
      _requests = requests ?? _requests;
      _isLoading = false;
    });
  }

  Future<void> _pickAndUploadAvatar() async {
    if (_isUploadingAvatar) {
      return;
    }

    final dependencies = AppScope.of(context);
    final picker = ImagePicker();
    final pickedFile = await picker.pickImage(
      source: ImageSource.gallery,
      imageQuality: 90,
    );
    if (pickedFile == null) {
      return;
    }

    setState(() {
      _isUploadingAvatar = true;
    });

    try {
      final updatedUser = await dependencies.profileRepository.uploadProfilePhoto(
        pickedFile.path,
      );
      if (!mounted) {
        return;
      }
      setState(() {
        _user = updatedUser;
      });
    } catch (error) {
      if (!mounted) {
        return;
      }
      final message = error is ApiConnectionException
          ? error.message
          : 'Не удалось обновить аватарку.';
      ScaffoldMessenger.of(context)
        ..hideCurrentSnackBar()
        ..showSnackBar(SnackBar(content: Text(message)));
    } finally {
      if (mounted) {
        setState(() {
          _isUploadingAvatar = false;
        });
      }
    }
  }

  ProfileRentalsOverview _applyFavoriteFlags(
    ProfileRentalsOverview overview,
    Set<int> favoritePlaceIds,
  ) {
    RentalHistoryItem applyFlag(RentalHistoryItem item) {
      final placeId = item.placeId;
      return item.copyWith(
        isFavorite: placeId != null && favoritePlaceIds.contains(placeId),
      );
    }

    return ProfileRentalsOverview(
      activeRentals: overview.activeRentals.map(applyFlag).toList(),
      rentalHistory: overview.rentalHistory.map(applyFlag).toList(),
    );
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
      final refreshedUser = await repository.getCurrentProfile();

      if (!mounted) {
        return;
      }

      setState(() {
        _user = refreshedUser;
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

  Future<void> _toggleFavoriteRental(RentalHistoryItem item) async {
    final placeId = item.placeId;
    if (placeId == null || _togglingFavoritePlaceIds.contains(placeId)) {
      return;
    }

    final nextValue = !item.isFavorite;

    setState(() {
      _togglingFavoritePlaceIds.add(placeId);
    });

    try {
      final rentalsRepository = AppScope.of(context).rentalsRepository;
      if (nextValue) {
        await rentalsRepository.addFavorite(placeId: placeId);
      } else {
        await rentalsRepository.removeFavorite(placeId: placeId);
      }

      if (!mounted) {
        return;
      }

      setState(() {
        _rentalsOverview = ProfileRentalsOverview(
          activeRentals: _rentalsOverview.activeRentals
              .map(
                (current) => current.placeId == placeId
                    ? current.copyWith(isFavorite: nextValue)
                    : current,
              )
              .toList(),
          rentalHistory: _rentalsOverview.rentalHistory
              .map(
                (current) => current.placeId == placeId
                    ? current.copyWith(isFavorite: nextValue)
                    : current,
              )
              .toList(),
        );

        if (nextValue) {
          final alreadyExists = _favoriteRentals.any(
            (favorite) => favorite.placeId == placeId,
          );
          if (!alreadyExists) {
            _favoriteRentals = <RentalHistoryItem>[
              item.copyWith(isFavorite: true),
              ..._favoriteRentals,
            ];
          }
        } else {
          _favoriteRentals = _favoriteRentals
              .where((favorite) => favorite.placeId != placeId)
              .toList();
        }
      });
    } catch (error) {
      if (!mounted) {
        return;
      }

      final message = error is ApiConnectionException
          ? error.message
          : nextValue
              ? 'Не удалось добавить помещение в избранное.'
              : 'Не удалось удалить помещение из избранного.';
      ScaffoldMessenger.of(
        context,
      ).showSnackBar(SnackBar(content: Text(message)));
    } finally {
      if (mounted) {
        setState(() {
          _togglingFavoritePlaceIds.remove(placeId);
        });
      }
    }
  }

  bool _isFavoriteBusy(RentalHistoryItem item) {
    final placeId = item.placeId;
    return placeId != null && _togglingFavoritePlaceIds.contains(placeId);
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

    final qrHash = user.qrHash?.trim();
    final validUntilText = _buildQrValidUntilText(user);
    if (validUntilText == null || qrHash == null || qrHash.isEmpty) {
      QrModal.showNoActiveRentals(context);
      return;
    }
    QrModal.showQr(
      context,
      qrData: qrHash,
      validUntilText: validUntilText,
    );
  }

  String? _buildQrValidUntilText(RegisteredUser user) {
    final availableUntil = user.qrAvailableUntil?.trim();
    if (availableUntil != null && availableUntil.isNotEmpty) {
      return _formatQrDateTime(availableUntil);
    }

    return null;
  }

  String _formatQrDateTime(String value) {
    final isoMatch = RegExp(
      r'^(\d{4})-(\d{2})-(\d{2})T(\d{2}):(\d{2})',
    ).firstMatch(value.trim());
    if (isoMatch != null) {
      final year = isoMatch.group(1)!;
      final month = isoMatch.group(2)!;
      final day = isoMatch.group(3)!;
      final hour = isoMatch.group(4)!;
      final minute = isoMatch.group(5)!;
      return '$day.$month.$year $hour:$minute';
    }

    final dateTime = DateTime.tryParse(value);
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

  ProfilePassItem _buildProfilePass(RegisteredUser user) {
    final validUntilText = _buildQrValidUntilText(user);
    final hasQrHash = user.qrHash?.trim().isNotEmpty == true;
    final emptyStateText = user.qrMessage?.trim();
    return ProfilePassItem(
      title: 'Qr-код пропуск',
      showButtonLabel: 'Показать',
      hasActivePass: hasQrHash && validUntilText != null,
      validUntilText: validUntilText,
      emptyStateText: emptyStateText != null && emptyStateText.isNotEmpty
          ? emptyStateText
          : null,
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
      onAvatarEditTap: _pickAndUploadAvatar,
      isAvatarUploading: _isUploadingAvatar,
      carouselItems: _carouselItems,
      carouselIndex: _carouselIndex,
      onCarouselChanged: (index) => setState(() => _carouselIndex = index),
      selectedActivityFilter: _selectedActivityFilter,
      rentalsOverview: _rentalsOverview,
      favoriteRentals: _favoriteRentals,
      requests: _requests,
      onShowPassQr: _showPassQr,
      onCancelRental: _cancelRental,
      onFavoriteRental: _toggleFavoriteRental,
      isBookingCancelling: _isBookingCancelling,
      isFavoriteBusy: _isFavoriteBusy,
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
    required this.onAvatarEditTap,
    required this.isAvatarUploading,
    required this.carouselItems,
    required this.carouselIndex,
    required this.onCarouselChanged,
    required this.selectedActivityFilter,
    required this.rentalsOverview,
    required this.favoriteRentals,
    required this.requests,
    required this.onShowPassQr,
    required this.onCancelRental,
    required this.onFavoriteRental,
    required this.isBookingCancelling,
    required this.isFavoriteBusy,
    required this.onDownloadRequest,
    required this.isRequestDownloading,
  });

  final RegisteredUser user;
  final ProfilePassItem profilePass;
  final VoidCallback onEditTap;
  final VoidCallback onAvatarEditTap;
  final bool isAvatarUploading;
  final List<String> carouselItems;
  final int carouselIndex;
  final ValueChanged<int> onCarouselChanged;
  final ProfileActivityFilter selectedActivityFilter;
  final ProfileRentalsOverview rentalsOverview;
  final List<RentalHistoryItem> favoriteRentals;
  final List<ProfileRequestItem> requests;
  final VoidCallback onShowPassQr;
  final Future<void> Function(RentalHistoryItem item) onCancelRental;
  final Future<void> Function(RentalHistoryItem item) onFavoriteRental;
  final bool Function(RentalHistoryItem item) isBookingCancelling;
  final bool Function(RentalHistoryItem item) isFavoriteBusy;
  final Future<void> Function(ProfileRequestItem item) onDownloadRequest;
  final bool Function(ProfileRequestItem item) isRequestDownloading;

  @override
  Widget build(BuildContext context) {
    return Column(
      children: [
        ProfileUserCard(
          onAvatarEditTap: onAvatarEditTap,
          fullName: user.fullName,
          photoUrl: user.photo,
          isAvatarUploading: isAvatarUploading,
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
            favoriteRentals: favoriteRentals,
            rentalHistory: rentalsOverview.rentalHistory,
            requests: requests,
            onCancelRental: onCancelRental,
            onFavoriteRental: onFavoriteRental,
            isBookingCancelling: isBookingCancelling,
            isFavoriteBusy: isFavoriteBusy,
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
