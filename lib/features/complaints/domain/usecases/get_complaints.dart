import '../entities/complaint.dart';
import '../../data/repositories/complaint_repository.dart';

class GetComplaints {
  final ComplaintRepository repository;

  GetComplaints(this.repository);

  Future<List<Complaint>> call() async {
    return await repository.getAllComplaints();
  }
}
