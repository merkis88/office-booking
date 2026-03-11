import 'package:flutter/material.dart';
import 'package:flutter_svg/flutter_svg.dart';
import 'package:wordpice/core/theme/app_colors.dart';
import 'package:wordpice/features/profile/presentation/widgets/cards/profile_surface_card.dart';

class ProfileInfoCard extends StatelessWidget {
  const ProfileInfoCard({
    super.key,
    required this.onEditTap,
    required this.email,
    required this.company,
  });

  final VoidCallback onEditTap;
  final String email;
  final String company;

  @override
  Widget build(BuildContext context) {
    return ProfileSurfaceCard(
      child: Padding(
        padding: const EdgeInsets.fromLTRB(16, 14, 14, 14),
        child: Row(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  _ProfileInfoField(label: 'Почта', value: email),
                  const SizedBox(height: 10),
                  _ProfileInfoField(label: 'Компания', value: company),
                ],
              ),
            ),
            _ProfileEditButton(onTap: onEditTap),
          ],
        ),
      ),
    );
  }
}

class _ProfileInfoField extends StatelessWidget {
  const _ProfileInfoField({required this.label, required this.value});

  static const TextStyle _labelStyle = TextStyle(
    fontSize: 12,
    fontWeight: FontWeight.w400,
    color: AppColors.textPrimary,
  );
  static const TextStyle _valueStyle = TextStyle(
    fontSize: 12,
    fontWeight: FontWeight.w400,
    color: AppColors.textSecondary,
  );

  final String label;
  final String value;

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(label, style: _labelStyle),
        const SizedBox(height: 2),
        Text(value, style: _valueStyle),
      ],
    );
  }
}

class _ProfileEditButton extends StatelessWidget {
  const _ProfileEditButton({required this.onTap});

  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    return SizedBox(
      width: 40,
      height: 40,
      child: IconButton(
        onPressed: onTap,
        padding: EdgeInsets.zero,
        icon: SvgPicture.asset(
          'assets/icons/edit.svg',
          width: 28,
          height: 28,
          colorFilter: const ColorFilter.mode(
            AppColors.textPrimary,
            BlendMode.srcIn,
          ),
        ),
      ),
    );
  }
}
