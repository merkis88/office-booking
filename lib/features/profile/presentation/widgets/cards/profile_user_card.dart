import 'package:flutter/material.dart';
import 'package:wordpice/core/theme/app_colors.dart';
import 'package:wordpice/features/profile/presentation/widgets/cards/profile_surface_card.dart';
import 'package:wordpice/features/profile/presentation/widgets/profile_identity_avatar.dart';

class ProfileUserCard extends StatelessWidget {
  const ProfileUserCard({
    super.key,
    required this.onAvatarEditTap,
    required this.fullName,
    required this.photoUrl,
    this.isAvatarUploading = false,
  });

  static const TextStyle _nameStyle = TextStyle(
    fontSize: 14,
    fontWeight: FontWeight.w500,
    color: AppColors.textPrimary,
  );

  final VoidCallback onAvatarEditTap;
  final String fullName;
  final String? photoUrl;
  final bool isAvatarUploading;

  @override
  Widget build(BuildContext context) {
    return ProfileSurfaceCard(
      child: Padding(
        padding: const EdgeInsets.all(14),
        child: Row(
          children: [
            ProfileIdentityAvatar(
              onEditTap: onAvatarEditTap,
              photoUrl: photoUrl,
              isUploading: isAvatarUploading,
            ),
            const SizedBox(width: 12),
            Expanded(child: Text(fullName, style: _nameStyle)),
          ],
        ),
      ),
    );
  }
}
