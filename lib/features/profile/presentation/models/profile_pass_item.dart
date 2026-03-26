class ProfilePassItem {
  const ProfilePassItem({
    required this.title,
    required this.showButtonLabel,
    required this.hasActivePass,
    this.validUntilText,
    this.emptyStateText,
  });

  final String title;
  final String showButtonLabel;
  final bool hasActivePass;
  final String? validUntilText;
  final String? emptyStateText;
}
