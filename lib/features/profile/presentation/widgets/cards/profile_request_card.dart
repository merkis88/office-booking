import 'package:flutter/material.dart';
import 'package:flutter_svg/flutter_svg.dart';
import 'package:wordpice/core/theme/app_colors.dart';
import 'package:wordpice/features/profile/presentation/models/profile_request_item.dart';
import 'package:wordpice/features/profile/presentation/widgets/styles/profile_card_decorations.dart';
import 'package:wordpice/features/profile/presentation/widgets/styles/profile_card_styles.dart';

class ProfileRequestCard extends StatelessWidget {
  const ProfileRequestCard({
    super.key,
    required this.item,
    required this.onDownloadPressed,
    required this.isDownloading,
  });

  final ProfileRequestItem item;
  final Future<void> Function(ProfileRequestItem item) onDownloadPressed;
  final bool isDownloading;

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Padding(
          padding: const EdgeInsets.only(left: 4, bottom: 8),
          child: Text(
            'Заявка №${item.number}:',
            style: ProfileCardStyles.title,
          ),
        ),
        Container(
          width: double.infinity,
          padding: const EdgeInsets.all(13),
          decoration: ProfileCardDecorations.outlinedCard(
            color: AppColors.formSurface,
          ),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              _RequestDetailRow(text: 'Тип заявки: ${item.requestType}'),
              _RequestDetailRow(text: 'Тип помещения: ${item.roomType}'),
              _RequestDetailRow(text: 'Кабинет №: ${item.roomNumber}'),
              _RequestDetailRow(text: 'Время работы: ${item.workTime}'),
              Row(
                crossAxisAlignment: CrossAxisAlignment.end,
                children: [
                  Expanded(
                    child: _RequestDetailRow(
                      text: 'Комментарий: ${item.comment}',
                    ),
                  ),
                  if (item.hasAttachment) ...[
                    const SizedBox(width: 10),
                    Padding(
                      padding: const EdgeInsets.only(bottom: 2),
                      child: _RequestAttachmentIcon(
                        isLoading: isDownloading,
                        onTap: () => onDownloadPressed(item),
                      ),
                    ),
                  ],
                ],
              ),
            ],
          ),
        ),
      ],
    );
  }
}

class _RequestDetailRow extends StatelessWidget {
  const _RequestDetailRow({required this.text});

  final String text;

  @override
  Widget build(BuildContext context) {
    return Text(text, style: ProfileCardStyles.body);
  }
}

class _RequestAttachmentIcon extends StatelessWidget {
  const _RequestAttachmentIcon({
    required this.onTap,
    required this.isLoading,
  });

  final VoidCallback onTap;
  final bool isLoading;

  @override
  Widget build(BuildContext context) {
    if (isLoading) {
      return const SizedBox(
        width: 28,
        height: 28,
        child: Padding(
          padding: EdgeInsets.all(4),
          child: CircularProgressIndicator(strokeWidth: 2),
        ),
      );
    }

    return InkWell(
      onTap: onTap,
      borderRadius: BorderRadius.circular(6),
      child: SvgPicture.asset(
        'assets/icons/document_download.svg',
        width: 28,
        height: 28,
        colorFilter: const ColorFilter.mode(
          AppColors.textPrimary,
          BlendMode.srcIn,
        ),
      ),
    );
  }
}
