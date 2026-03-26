import 'package:flutter/material.dart';
import 'package:flutter_svg/flutter_svg.dart';
import 'package:wordpice/core/theme/app_colors.dart';

class ProfileIdentityAvatar extends StatelessWidget {
  const ProfileIdentityAvatar({
    super.key,
    this.onEditTap,
    this.photoUrl,
    this.isUploading = false,
    this.size = 60,
    this.avatarSize = 60,
    this.iconSize = 26,
    this.editIconAsset = 'assets/icons/edit-2.svg',
    this.editIconSize = 24,
    this.editButtonSize = 24,
  });

  final VoidCallback? onEditTap;
  final String? photoUrl;
  final bool isUploading;
  final double size;
  final double avatarSize;
  final double iconSize;
  final String editIconAsset;
  final double editIconSize;
  final double editButtonSize;

  bool get _isInteractive => onEditTap != null;

  @override
  Widget build(BuildContext context) {
    return SizedBox(
      width: size,
      height: size,
      child: Stack(
        children: [
          Positioned(
            left: 0,
            bottom: 0,
            child: _AvatarBody(
              size: avatarSize,
              iconSize: iconSize,
              photoUrl: photoUrl,
            ),
          ),
          Positioned(
            top: -2,
            right: -4,
            child: isUploading
                ? SizedBox(
                    width: editButtonSize,
                    height: editButtonSize,
                    child: const CircularProgressIndicator(strokeWidth: 2),
                  )
                : _isInteractive
                ? _EditIconButton(
                    size: editButtonSize,
                    onPressed: onEditTap!,
                    child: _EditIcon(asset: editIconAsset, size: editIconSize),
                  )
                : _EditIcon(asset: editIconAsset, size: editIconSize),
          ),
        ],
      ),
    );
  }
}

class _AvatarBody extends StatelessWidget {
  const _AvatarBody({
    required this.size,
    required this.iconSize,
    required this.photoUrl,
  });

  final double size;
  final double iconSize;
  final String? photoUrl;

  @override
  Widget build(BuildContext context) {
    final hasPhoto = photoUrl != null && photoUrl!.trim().isNotEmpty;

    return Container(
      width: size,
      height: size,
      decoration: BoxDecoration(
        color: AppColors.background,
        borderRadius: BorderRadius.circular(size / 2),
      ),
      clipBehavior: Clip.antiAlias,
      child: hasPhoto
          ? Image.network(
              photoUrl!,
              fit: BoxFit.cover,
              errorBuilder: (_, _, _) => Icon(Icons.person_outline, size: iconSize),
            )
          : Icon(Icons.person_outline, size: iconSize),
    );
  }
}

class _EditIconButton extends StatelessWidget {
  const _EditIconButton({
    required this.size,
    required this.onPressed,
    required this.child,
  });

  final double size;
  final VoidCallback onPressed;
  final Widget child;

  @override
  Widget build(BuildContext context) {
    return SizedBox(
      width: size,
      height: size,
      child: IconButton(
        onPressed: onPressed,
        padding: EdgeInsets.zero,
        icon: child,
      ),
    );
  }
}

class _EditIcon extends StatelessWidget {
  const _EditIcon({required this.asset, required this.size});

  final String asset;
  final double size;

  @override
  Widget build(BuildContext context) {
    return SvgPicture.asset(
      asset,
      width: size,
      height: size,
      colorFilter: const ColorFilter.mode(
        AppColors.textPrimary,
        BlendMode.srcIn,
      ),
    );
  }
}
