import 'package:flutter/material.dart';
import 'package:wordpice/app/navigation/app_tab_navigator.dart';
import 'package:wordpice/core/theme/app_text_styles.dart';
import 'package:wordpice/core/widgets/layout/app_shell.dart';
import 'package:wordpice/features/archive/data/mock/archive_mock_data.dart';
import 'package:wordpice/features/archive/presentation/widgets/cards/archive_card.dart';
import 'package:wordpice/features/archive/presentation/widgets/states/archive_empty_state.dart';

class ArchiveScreen extends StatefulWidget {
  const ArchiveScreen({super.key});

  @override
  State<ArchiveScreen> createState() => _ArchiveScreenState();
}

class _ArchiveScreenState extends State<ArchiveScreen> {
  static const int _tabIndex = 5;
  int _selectedBottomIndex = _tabIndex;

  void _onBottomChanged(int index) {
    if (index == _tabIndex) return;
    setState(() => _selectedBottomIndex = index);
    AppTabNavigator.goToTab(context, index);
  }

  @override
  Widget build(BuildContext context) {
    final items = archiveMockData;

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
            if (items.isEmpty)
              const ArchiveEmptyState()
            else
              Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  for (final item in items) ...[
                    ArchiveCard(item: item),
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
