import '../../domain/entities/user.dart';
import '../sources/user_remote_data_source.dart';

class UserRepository {
  final UserRemoteDataSource _remoteDataSource = UserRemoteDataSource();

  Future<List<User>> getUsers() async {
    return await _remoteDataSource.getAllUsers();
  }
}
