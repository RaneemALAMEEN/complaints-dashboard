abstract class ComplaintDetailsEvent {}

class FetchComplaintDetails extends ComplaintDetailsEvent {
  final int complaintId;

  FetchComplaintDetails(this.complaintId);
}

class UpdateComplaintDetailsStatus extends ComplaintDetailsEvent {
  final int complaintId;
  final String status;
  final String? notes;

  UpdateComplaintDetailsStatus(
    this.complaintId,
    this.status, {
    this.notes,
  });
}