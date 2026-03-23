import 'package:flutter/material.dart';
import 'package:wordpice/core/widgets/states/app_empty_state_text.dart';
import 'package:wordpice/features/archive/presentation/widgets/styles/archive_styles.dart';

class ArchiveEmptyState extends StatelessWidget {
  const ArchiveEmptyState({super.key});

  @override
  Widget build(BuildContext context) {
    return const AppEmptyStateText(
      text: 'Архивных помещений нет',
      style: ArchiveStyles.emptyStateText,
      height: 420,
    );
  }
}
