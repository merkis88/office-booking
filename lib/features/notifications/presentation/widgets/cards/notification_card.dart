import 'package:flutter/material.dart';
import 'package:flutter_svg/flutter_svg.dart';
import 'package:wordpice/features/notifications/presentation/models/notification_item.dart';
import 'package:wordpice/features/notifications/presentation/widgets/buttons/notification_read_action.dart';
import 'package:wordpice/features/notifications/presentation/widgets/styles/notification_styles.dart';

class NotificationCard extends StatelessWidget {
  const NotificationCard({
    super.key,
    required this.item,
    required this.isRead,
    required this.onReadChanged,
    required this.onDeletePressed,
    this.isReadLoading = false,
    this.isDeleteLoading = false,
  });

  static const double _cardWidth = 300;
  static const double _blockWidth = 352;

  final NotificationItem item;
  final bool isRead;
  final ValueChanged<bool> onReadChanged;
  final VoidCallback onDeletePressed;
  final bool isReadLoading;
  final bool isDeleteLoading;

  @override
  Widget build(BuildContext context) {
    return Center(
      child: ConstrainedBox(
        constraints: const BoxConstraints(maxWidth: _blockWidth),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              mainAxisSize: MainAxisSize.min,
              crossAxisAlignment: CrossAxisAlignment.center,
              children: [
                SizedBox(
                  width: _cardWidth,
                  child: Container(
                    width: double.infinity,
                    padding: const EdgeInsets.all(12),
                    decoration: NotificationStyles.cardDecoration(),
                    child: Stack(
                      children: [
                        Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Padding(
                              padding: const EdgeInsets.only(right: 18),
                              child: Text(
                                item.title,
                                style: NotificationStyles.cardTopicText,
                              ),
                            ),
                            const SizedBox(height: 4),
                            Text(
                              item.message,
                              style: NotificationStyles.messageText,
                            ),
                            Align(
                              alignment: Alignment.centerRight,
                              child: Text(
                                item.dateTimeText,
                                style: NotificationStyles.dateText,
                              ),
                            ),
                          ],
                        ),
                        Positioned(
                          top: 2,
                          right: 2,
                          child: AnimatedOpacity(
                            duration: const Duration(milliseconds: 180),
                            opacity: isRead ? 0 : 1,
                            child: Container(
                              width: 10,
                              height: 10,
                              decoration: const BoxDecoration(
                                color: Color(0xFFFF5A67),
                                shape: BoxShape.circle,
                              ),
                            ),
                          ),
                        ),
                      ],
                    ),
                  ),
                ),
                const SizedBox(width: 8),
                InkWell(
                  onTap: isDeleteLoading ? null : onDeletePressed,
                  borderRadius: BorderRadius.circular(8),
                  child: Padding(
                    padding: const EdgeInsets.all(2),
                    child: isDeleteLoading
                        ? const SizedBox(
                            width: 40,
                            height: 40,
                            child: Center(
                              child: SizedBox(
                                width: 18,
                                height: 18,
                                child: CircularProgressIndicator(
                                  strokeWidth: 2,
                                ),
                              ),
                            ),
                          )
                        : SvgPicture.asset(
                            'assets/icons/delete.svg',
                            width: 40,
                            height: 40,
                            colorFilter: const ColorFilter.mode(
                              Colors.black54,
                              BlendMode.srcIn,
                            ),
                          ),
                  ),
                ),
              ],
            ),
            const SizedBox(height: 12),
            SizedBox(
              width: _cardWidth,
              child: NotificationReadAction(
                label: 'Прочитать уведомление',
                value: isRead,
                isEnabled: !isRead,
                isLoading: isReadLoading,
                onChanged: onReadChanged,
              ),
            ),
          ],
        ),
      ),
    );
  }
}
