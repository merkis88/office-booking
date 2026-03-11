import 'package:flutter/material.dart';
import 'package:wordpice/core/theme/app_colors.dart';
import 'package:wordpice/features/profile/presentation/widgets/cards/profile_surface_card.dart';
import 'package:wordpice/features/profile/presentation/widgets/profile_identity_avatar.dart';

class ProfileUserCard extends StatelessWidget {
  const ProfileUserCard({
    super.key,
    required this.onEditTap,
    required this.fullName,
  });

  static const String _role = 'Должность';
  static const TextStyle _nameStyle = TextStyle(
    fontSize: 14,
    fontWeight: FontWeight.w500,
    color: AppColors.textPrimary,
  );
  static const TextStyle _roleStyle = TextStyle(
    fontSize: 12,
    fontWeight: FontWeight.w400,
    color: AppColors.textSecondary,
  );

  final VoidCallback onEditTap;
  final String fullName;

  @override
  Widget build(BuildContext context) {
    return ProfileSurfaceCard(
      child: Padding(
        padding: const EdgeInsets.all(14),
        child: Row(
          children: [
            ProfileIdentityAvatar(onEditTap: onEditTap),
            const SizedBox(width: 12),
            Expanded(
              child: _ProfileIdentityText(
                title: fullName,
                subtitle: _role,
                titleStyle: _nameStyle,
                subtitleStyle: _roleStyle,
              ),
            ),
          ],
        ),
      ),
    );
  }
}

class _ProfileIdentityText extends StatelessWidget {
  const _ProfileIdentityText({
    required this.title,
    required this.subtitle,
    required this.titleStyle,
    required this.subtitleStyle,
  });

  final String title;
  final String subtitle;
  final TextStyle titleStyle;
  final TextStyle subtitleStyle;

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(title, style: titleStyle),
        const SizedBox(height: 4),
        Text(subtitle, style: subtitleStyle),
      ],
    );
  }
}
