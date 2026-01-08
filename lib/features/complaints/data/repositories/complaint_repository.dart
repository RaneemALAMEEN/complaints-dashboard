
import 'package:complaints/features/complaints/domain/entities/complaint.dart';
import '../sources/complaint_remote_data_source.dart';
import 'package:complaints/core/services/permissions_service.dart';
import 'package:complaints/core/network/dio_client.dart';

class ComplaintRepository {
  final ComplaintRemoteDataSource _remoteDataSource;

  ComplaintRepository() : _remoteDataSource = ComplaintRemoteDataSource(DioClient());

  Future<List<Complaint>> getAllComplaints({int page = 1}) async {
    try {
      // Get auth token
      final token = await PermissionsService.getToken();
      if (token == null) throw Exception('No authentication token found');

      // Set auth token
      _remoteDataSource.dioClient.setAuthToken(token);

      // Fetch from API
      final response = await _remoteDataSource.getAllComplaints(page: page);
      
      if (!response['success']) {
        throw Exception('Failed to fetch complaints');
      }

      final List<dynamic> complaintsData = response['data'];
      return complaintsData.map((json) => _mapToComplaint(json)).toList();
    } catch (e) {
      throw Exception('Failed to fetch complaints: $e');
    }
  }

  Future<Complaint> getComplaintDetails(int id) async {
    try {
      print('Repository: Getting complaint details for ID: $id');
      
      // Get auth token
      final token = await PermissionsService.getToken();
      if (token == null) {
        print('Repository: No auth token found');
        throw Exception('No authentication token found');
      }
      print('Repository: Auth token found');

      // Set auth token
      _remoteDataSource.dioClient.setAuthToken(token);

      // Get user role to determine endpoint
      final user = await PermissionsService.getCurrentUser();
      final isEmployee = user != null && PermissionsService.isEmployee(user);
      
      if (isEmployee) {
        // For employees, search in their assigned complaints
        print('Repository: User is employee, searching in assigned complaints');
        final response = await _remoteDataSource.getEmployeeComplaints();
        
        if (!response['success']) {
          print('Repository: API response not successful');
          throw Exception('Failed to fetch complaints');
        }

        // Handle different response structure for employee endpoint
        final complaintsResponse = response['complaints'] ?? response;
        final List<dynamic> complaintsData = complaintsResponse['data'];
        print('Repository: Found ${complaintsData.length} complaints');
        
        final complaintData = complaintsData.firstWhere(
          (json) => json['id'] == id,
          orElse: () {
            print('Repository: Complaint with ID $id not found in employee complaints');
            throw Exception('Complaint not found');
          },
        );
        
        print('Repository: Found complaint with ID $id in employee complaints');
        return _mapToComplaint(complaintData);
      } else {
        // For admins, use the existing method
        print('Repository: User is admin, fetching all complaints');
        final response = await _remoteDataSource.getAllComplaints();
        print('Repository: API response received');
        
        if (!response['success']) {
          print('Repository: API response not successful');
          throw Exception('Failed to fetch complaints');
        }

        final List<dynamic> complaintsData = response['data'];
        print('Repository: Found ${complaintsData.length} complaints');
        
        final complaintData = complaintsData.firstWhere(
          (json) => json['id'] == id,
          orElse: () {
            print('Repository: Complaint with ID $id not found');
            throw Exception('Complaint not found');
          },
        );

        print('Repository: Found complaint with ID $id');
        return _mapToComplaint(complaintData);
      }
    } catch (e) {
      print('Repository Error: $e');
      throw Exception('Failed to fetch complaint details: $e');
    }
  }

  Complaint _mapToComplaint(Map<String, dynamic> json) {
    return Complaint(
      id: json['id'],
      referenceNumber: json['reference_number'] ?? '',
      description: json['description'] ?? '',
      governorate: json['governorate'] ?? '',
      location: json['location'] ?? '',
      governmentEntity: json['government_entity'] ?? '',
      citizenId: json['citizen_id'] ?? 0,
      images: List<String>.from(json['images'] ?? []),
      attachments: List<String>.from(json['attachments'] ?? []),
      status: _mapStatus(json['status'] ?? 'جديدة'),
      createdAt: DateTime.parse(json['created_at']),
      updatedAt: DateTime.parse(json['updated_at']),
      notes: json['notes'],
      responsibleId: json['responsible_id'],
    );
  }

  ComplaintStatus _mapStatus(String status) {
    switch (status) {
      case 'جديدة':
        return ComplaintStatus.newOne;
      case 'بانتظار المعلومات':
      case 'بانتظار معلومات اضافية':
        return ComplaintStatus.waitingInfo;
      case 'قيد التنفيذ':
      case 'قيد المعالجة':
        return ComplaintStatus.inProgress;
      case 'تم حلها':
      case 'منجزة':
        return ComplaintStatus.resolved;
      case 'مرفوضة':
        return ComplaintStatus.rejected;
      default:
        return ComplaintStatus.newOne;
    }
  }
}
