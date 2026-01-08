import 'package:complaints/features/complaints/domain/entities/complaint.dart';

abstract class ComplaintDetailsState {}

class ComplaintDetailsInitial extends ComplaintDetailsState {}

class ComplaintDetailsLoading extends ComplaintDetailsState {}

class ComplaintDetailsLoaded extends ComplaintDetailsState {
  final Complaint complaint;

  ComplaintDetailsLoaded(this.complaint);
}

class ComplaintDetailsFailure extends ComplaintDetailsState {
  final String message;
  final int complaintId;

  ComplaintDetailsFailure(this.message, this.complaintId);
}