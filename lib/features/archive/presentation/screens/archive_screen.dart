import 'package:flutter/material.dart';
import 'package:wordpice/app/app_scope.dart';
import 'package:wordpice/app/navigation/app_tab_navigator.dart';
import 'package:wordpice/core/network/api_client.dart';
import 'package:wordpice/core/theme/app_colors.dart';
import 'package:wordpice/core/theme/app_text_styles.dart';
import 'package:wordpice/core/widgets/layout/app_shell.dart';
import 'package:wordpice/features/archive/presentation/models/archive_item.dart';
import 'package:wordpice/features/archive/presentation/widgets/cards/archive_card.dart';
import 'package:wordpice/features/archive/presentation/widgets/states/archive_empty_state.dart';
import 'package:wordpice/features/rentals/presentation/widgets/styles/rental_widget_styles.dart';

class ArchiveScreen extends StatefulWidget {
  const ArchiveScreen({super.key});

  @override
  State<ArchiveScreen> createState() => _ArchiveScreenState();
}

class _ArchiveScreenState extends State<ArchiveScreen> {
  static const int _tabIndex = 5;

  int _selectedBottomIndex = _tabIndex;
  bool _isLoading = true;
  bool _hasLoadedOnce = false;
  String? _errorMessage;
  List<ArchiveItem> _items = const <ArchiveItem>[];
  int? _expandedPlaceId;
  final Set<int> _restoringPlaceIds = <int>{};

  @override
  void didChangeDependencies() {
    super.didChangeDependencies();
    if (_hasLoadedOnce) {
      return;
    }
    _hasLoadedOnce = true;
    _loadArchivedPlaces();
  }

  Future<void> _loadArchivedPlaces() async {
    setState(() {
      _isLoading = true;
      _errorMessage = null;
    });

    try {
      final items = await AppScope.of(context).archiveRepository.getArchivedPlaces();
      if (!mounted) {
        return;
      }
      setState(() {
        _items = items;
      });
    } on ApiConnectionException catch (error) {
      if (!mounted) {
        return;
      }
      setState(() {
        _items = const <ArchiveItem>[];
        _errorMessage = error.message;
      });
    } catch (_) {
      if (!mounted) {
        return;
      }
      setState(() {
        _items = const <ArchiveItem>[];
        _errorMessage = 'Не удалось загрузить архив помещений.';
      });
    } finally {
      if (mounted) {
        setState(() {
          _isLoading = false;
        });
      }
    }
  }

  void _onBottomChanged(int index) {
    if (index == _tabIndex) {
      return;
    }
    setState(() => _selectedBottomIndex = index);
    AppTabNavigator.goToTab(context, index);
  }

  void _toggleDetails(ArchiveItem item) {
    setState(() {
      _expandedPlaceId = _expandedPlaceId == item.id ? null : item.id;
    });
  }

  Future<void> _restorePlace(ArchiveItem item) async {
    if (_restoringPlaceIds.contains(item.id)) {
      return;
    }

    setState(() {
      _restoringPlaceIds.add(item.id);
    });

    try {
      await AppScope.of(context).archiveRepository.restorePlace(placeId: item.id);
      if (!mounted) {
        return;
      }

      setState(() {
        _items = _items.where((currentItem) => currentItem.id != item.id).toList();
        _restoringPlaceIds.remove(item.id);
        if (_expandedPlaceId == item.id) {
          _expandedPlaceId = null;
        }
      });

      ScaffoldMessenger.of(context)
        ..hideCurrentSnackBar()
        ..showSnackBar(
          const SnackBar(content: Text('Помещение восстановлено из архива.')),
        );
    } on ApiConnectionException catch (error) {
      if (!mounted) {
        return;
      }
      setState(() {
        _restoringPlaceIds.remove(item.id);
      });
      ScaffoldMessenger.of(context)
        ..hideCurrentSnackBar()
        ..showSnackBar(SnackBar(content: Text(error.message)));
    } catch (_) {
      if (!mounted) {
        return;
      }
      setState(() {
        _restoringPlaceIds.remove(item.id);
      });
      ScaffoldMessenger.of(context)
        ..hideCurrentSnackBar()
        ..showSnackBar(
          const SnackBar(content: Text('Не удалось восстановить помещение.')),
        );
    }
  }

  @override
  Widget build(BuildContext context) {
    return AppShell(
      selectedBottomIndex: _selectedBottomIndex,
      onBottomChanged: _onBottomChanged,
      body: SingleChildScrollView(
        padding: const EdgeInsets.fromLTRB(16, 24, 16, 28),
        child: Column(
          children: [
            const Center(
              child: Text(
                'Архив',
                style: AppTextStyles.unboundedRegular24,
              ),
            ),
            const SizedBox(height: 26),
            if (_errorMessage != null)
              Padding(
                padding: const EdgeInsets.only(bottom: 12),
                child: Text(
                  _errorMessage!,
                  style: const TextStyle(color: Colors.redAccent),
                ),
              ),
            if (_isLoading)
              const Padding(
                padding: EdgeInsets.only(top: 120),
                child: Center(child: CircularProgressIndicator()),
              )
            else if (_items.isEmpty)
              const ArchiveEmptyState()
            else
              Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  for (final item in _items) ...[
                    if (_expandedPlaceId == item.id)
                      _InlineArchiveDetailsCard(
                        title: item.title,
                        description: item.description,
                        onBack: () => _toggleDetails(item),
                      )
                    else
                      ArchiveCard(
                        item: item,
                        onDetailsTap: () => _toggleDetails(item),
                        onRestoreTap: () => _restorePlace(item),
                        isRestoring: _restoringPlaceIds.contains(item.id),
                      ),
                    const SizedBox(height: 30),
                  ],
                ],
              ),
          ],
        ),
      ),
    );
  }
}

class _InlineArchiveDetailsCard extends StatelessWidget {
  const _InlineArchiveDetailsCard({
    required this.title,
    required this.description,
    required this.onBack,
  });

  final String title;
  final String description;
  final VoidCallback onBack;

  @override
  Widget build(BuildContext context) {
    return Center(
      child: ConstrainedBox(
        constraints: const BoxConstraints(maxWidth: 332),
        child: Container(
          width: double.infinity,
          padding: const EdgeInsets.fromLTRB(18, 18, 18, 20),
          decoration: RentalWidgetStyles.outlinedBox(
            18,
            color: AppColors.formSurface,
          ),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Row(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  InkWell(
                    onTap: onBack,
                    borderRadius: BorderRadius.circular(12),
                    child: Container(
                      width: 32,
                      height: 32,
                      decoration: RentalWidgetStyles.outlinedBox(12),
                      child: const Icon(Icons.chevron_left, size: 22),
                    ),
                  ),
                  const SizedBox(width: 18),
                  Expanded(
                    child: Padding(
                      padding: const EdgeInsets.only(top: 2),
                      child: Text(
                        title,
                        style: const TextStyle(
                          fontSize: 22,
                          fontWeight: FontWeight.w500,
                          color: Colors.black87,
                        ),
                      ),
                    ),
                  ),
                ],
              ),
              const SizedBox(height: 22),
              Text(
                description,
                style: const TextStyle(
                  fontSize: 16,
                  height: 1.45,
                  color: Colors.black87,
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
