class ProfilePassItem {
  const ProfilePassItem({
    required this.title,
    required this.showButtonLabel,
    this.validUntilText,
  });

  final String title;
  final String showButtonLabel;
  final String? validUntilText;

  bool get hasActivePass => (validUntilText?.trim().isNotEmpty ?? false);
}
