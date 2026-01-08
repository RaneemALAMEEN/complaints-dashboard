import 'package:complaints/core/network/dio_client.dart';
import 'package:complaints/core/network/api_constants.dart';

class ComplaintRemoteDataSource {
  final DioClient dioClient;

  ComplaintRemoteDataSource(this.dioClient);

  Future<Map<String, dynamic>> getAllComplaints({int page = 1}) async {
    try {
      final response = await dioClient.get(ApiConstants.getAllComplaints, queryParameters: {'page': page});
      return response.data;
    } catch (e) {
      throw Exception('Failed to fetch complaints: $e');
    }
  }

  Future<Map<String, dynamic>> getEmployeeComplaints({int page = 1}) async {
    try {
      final response = await dioClient.get('/api/complaint/employee-complaints', queryParameters: {'page': page});
      return response.data;
    } catch (e) {
      throw Exception('Failed to fetch employee complaints: $e');
    }
  }

  Future<Map<String, dynamic>> getComplaintDetails(int id) async {
    try {
      final response = await dioClient.get('/api/complaint/$id');
      return response.data;
    } catch (e) {
      throw Exception('Failed to fetch complaint details: $e');
    }
  }

  Future<Map<String, dynamic>> updateComplaintStatus(int id, String status) async {
    try {
      final response = await dioClient.put(
        '/api/complaint/$id/status',
        data: {'status': status},
      );
      return response.data;
    } catch (e) {
      throw Exception('Failed to update complaint status: $e');
    }
  }
}
