class CreateRequestParams {
  const CreateRequestParams({
    required this.bookingId,
    required this.serviceTypeId,
    required this.serviceDate,
    required this.serviceTime,
    this.comment,
  });

  final int bookingId;
  final int serviceTypeId;
  final String serviceDate;
  final String serviceTime;
  final String? comment;
}
