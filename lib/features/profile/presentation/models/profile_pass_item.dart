class ProfilePassItem {
  const ProfilePassItem({
    required this.title,
    required this.showButtonLabel,
    required this.hasActivePass,
    this.validUntilText,
  });

  final String title;
  final String showButtonLabel;
  final bool hasActivePass;
  final String? validUntilText;
}
