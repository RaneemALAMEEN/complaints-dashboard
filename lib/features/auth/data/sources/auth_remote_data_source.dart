import 'package:dio/dio.dart';
import '../../../../core/network/dio_client.dart';
import '../../../../core/network/api_constants.dart';

class AuthRemoteDataSource {
  final Dio dio = DioClient().dio;

  Future<Map<String, dynamic>> login({
    required String email,
    required String password,
  }) async {
    final response = await dio.post(
      ApiConstants.login,
      data: {
        "email": email,
        "password": password,
      },
    );
    return response.data; // نرجع Map مباشرة
  }

  Future<Map<String, dynamic>> registerEmployee({
    required String firstName,
    required String lastName,
    required String email,
    required String password,
    required String governmentEntity,
    required String phone,
    required List<int> permissionId,
    required String token,
  }) async {
    final response = await dio.post(
      '/api/auth/registerAdmin',
      data: {
        "first_name": firstName,
        "last_name": lastName,
        "email": email,
        "password": password,
        "government_entity": governmentEntity,
        "phone": phone,
        "permission_id": permissionId,
      },
      options: Options(
        headers: {
          'Authorization': 'Bearer $token',
          'Content-Type': 'application/json',
        },
      ),
    );
    return response.data;
  }
}
