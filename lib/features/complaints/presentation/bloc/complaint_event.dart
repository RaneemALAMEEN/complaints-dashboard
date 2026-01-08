import 'package:equatable/equatable.dart';

abstract class ComplaintEvent extends Equatable {
  const ComplaintEvent();

  @override
  List<Object> get props => [];
}

class FetchAllComplaints extends ComplaintEvent {
  final int page;

  const FetchAllComplaints(this.page);

  @override
  List<Object> get props => [page];
}

class FetchComplaintStats extends ComplaintEvent {
  const FetchComplaintStats();
}

class FetchDashboardData extends ComplaintEvent {
  const FetchDashboardData();
}

class UpdateComplaintStatus extends ComplaintEvent {
  final int complaintId;
  final String status;
  final String? notes;

  const UpdateComplaintStatus(this.complaintId, this.status, {this.notes});

  @override
  List<Object> get props => [complaintId, status, notes ?? ''];
}