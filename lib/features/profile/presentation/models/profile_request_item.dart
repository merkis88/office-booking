class ProfileRequestItem {
  const ProfileRequestItem({
    required this.id,
    required this.number,
    required this.requestType,
    required this.roomType,
    required this.roomNumber,
    required this.workTime,
    required this.comment,
    this.hasAttachment = true,
    this.attachmentLabel = 'pdf',
  });

  final int id;
  final int number;
  final String requestType;
  final String roomType;
  final String roomNumber;
  final String workTime;
  final String comment;
  final bool hasAttachment;
  final String attachmentLabel;
}
