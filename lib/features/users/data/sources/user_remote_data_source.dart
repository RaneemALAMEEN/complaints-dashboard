import 'package:dio/dio.dart';
import '../../../../core/network/dio_client.dart';
import '../../../../core/network/api_constants.dart';
import '../../../../core/services/permissions_service.dart';
import '../../domain/entities/user.dart';

class UserRemoteDataSource {
  final Dio dio = DioClient().dio;

  Future<List<User>> getAllUsers() async {
    try {
      final token = await PermissionsService.getToken();
      if (token == null) {
        print('=== GET ALL USERS ERROR ===');
        print('Token not found');
        print('==========================');
        throw Exception('Token not found');
      }

      final response = await dio.get(
        ApiConstants.getAllUsers,
        options: Options(
          headers: {
            'accept': '*/*',
            'Authorization': 'Bearer $token',
          },
        ),
      );

      print('=== GET ALL USERS RESPONSE ===');
      print('Request: GET ${dio.options.baseUrl}${ApiConstants.getAllUsers}');
      print('Status Code: ${response.statusCode}');
      print('Response Data: ${response.data}');
      print('==============================');

      if (response.statusCode == 200) {
        final data = response.data;
        final List<User> allUsers = [];

        // Process userCitizen array
        if (data['userCitizen'] != null) {
          for (var citizenGroup in data['userCitizen']) {
            if (citizenGroup['users'] != null) {
              for (var user in citizenGroup['users']) {
                final userType = citizenGroup['name'] == 'Employee' 
                    ? UserType.employee 
                    : UserType.citizen;

                allUsers.add(User(
                  id: user['id'],
                  firstName: user['first_name'],
                  lastName: user['last_name'],
                  email: user['email'],
                  phone: user['phone'],
                  type: userType,
                  governmentEntity: user['employee']?['government_entity'],
                ));
              }
            }
          }
        }

        return allUsers;
      } else {
        throw Exception('Failed to load users: ${response.statusCode}');
      }
    } on DioException catch (e) {
      print('=== GET ALL USERS ERROR (DioException) ===');
      print('Request: ${e.requestOptions.method} ${e.requestOptions.baseUrl}${e.requestOptions.path}');
      print('Status Code: ${e.response?.statusCode}');
      print('Response Data: ${e.response?.data}');
      print('Error Type: ${e.type}');
      print('Message: ${e.message}');
      print('=========================================');

      throw Exception('Error fetching users: $e');
    } catch (e) {
      print('=== GET ALL USERS ERROR ===');
      print('Error: $e');
      print('==========================');

      throw Exception('Error fetching users: $e');
    }
  }
}
