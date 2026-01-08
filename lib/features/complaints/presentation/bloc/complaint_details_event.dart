abstract class ComplaintDetailsEvent {}

class FetchComplaintDetails extends ComplaintDetailsEvent {
  final int complaintId;

  FetchComplaintDetails(this.complaintId);
}