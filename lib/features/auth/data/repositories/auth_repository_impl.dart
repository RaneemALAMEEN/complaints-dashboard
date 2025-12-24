import '../../domain/entities/login_result.dart';
import '../../domain/entities/user.dart';
import '../../domain/repositories/auth_repository.dart';
import '../sources/auth_remote_data_source.dart';

class AuthRepositoryImpl implements AuthRepository {
  final AuthRemoteDataSource remoteDataSource;

  AuthRepositoryImpl(this.remoteDataSource);

  @override
  Future<LoginResult> login(String email, String password) async {
    final response = await remoteDataSource.login(email: email, password: password);

    final data = response['data'];
    if (data == null) throw Exception('No data in login response');

    final userData = data['user'];
    final token = data['token'] ?? '';
    final user = User(
      id: userData['id'],
      firstName: userData['first_name'],
      lastName: userData['last_name'],
    );

    return LoginResult(user: user, token: token);
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
    final response = await remoteDataSource.registerEmployee(
      firstName: firstName,
      lastName: lastName,
      email: email,
      password: password,
      governmentEntity: governmentEntity,
      phone: phone,
      permissionId: permissionId,
      token: token,
    );

    return {
      "user": response['data']['user'],
      "governmentEntity": response['data']['newEmployee']['government_entity'],
      "message": response['message'],
    };
  }
}
