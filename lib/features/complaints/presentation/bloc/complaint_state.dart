import 'package:equatable/equatable.dart';
import '../../domain/entities/complaint.dart';

class Pagination {
  final int total;
  final int page;
  final int pageSize;
  final int totalPages;

  const Pagination({
    required this.total,
    required this.page,
    required this.pageSize,
    required this.totalPages,
  });

  factory Pagination.fromJson(Map<String, dynamic> json) {
    return Pagination(
      total: json['total'],
      page: json['page'],
      pageSize: json['pageSize'],
      totalPages: json['totalPages'],
    );
  }
}

class ComplaintStats {
  final int newComplaints;
  final int totalComplaints;
  final int inProgressComplaints;
  final int resolvedComplaints;

  const ComplaintStats({
    required this.newComplaints,
    required this.totalComplaints,
    required this.inProgressComplaints,
    required this.resolvedComplaints,
  });
}

abstract class ComplaintState extends Equatable {
  const ComplaintState();

  @override
  List<Object> get props => [];
}

class ComplaintInitial extends ComplaintState {}

class ComplaintLoading extends ComplaintState {}

class ComplaintsLoaded extends ComplaintState {
  final List<Complaint> complaints;
  final Pagination pagination;

  const ComplaintsLoaded(this.complaints, this.pagination);

  @override
  List<Object> get props => [complaints, pagination];
}

class ComplaintStatsLoaded extends ComplaintState {
  final ComplaintStats stats;

  const ComplaintStatsLoaded(this.stats);

  @override
  List<Object> get props => [stats];
}

class DashboardDataLoaded extends ComplaintState {
  final List<Complaint> complaints;
  final Pagination pagination;
  final ComplaintStats stats;

  const DashboardDataLoaded(this.complaints, this.pagination, this.stats);

  @override
  List<Object> get props => [complaints, pagination, stats];
}

class ComplaintFailure extends ComplaintState {
  final String message;

  const ComplaintFailure(this.message);

  @override
  List<Object> get props => [message];
}