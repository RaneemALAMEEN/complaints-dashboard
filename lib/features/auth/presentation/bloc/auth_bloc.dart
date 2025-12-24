import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'auth_event.dart';
import 'auth_state.dart';
import '../../data/repositories/auth_repository_impl.dart';

class AuthBloc extends Bloc<AuthEvent, AuthState> {
  final AuthRepositoryImpl repository;

  AuthBloc(this.repository) : super(AuthInitial()) {
    on<LoginRequested>((event, emit) async {
      emit(AuthLoading());
      try {
        final result = await repository.login(event.email, event.password);

        // حفظ التوكن
        await saveToken(result.token);

        emit(AuthSuccess(result.token));
      } catch (e, stackTrace) {
        print('Login Error: $e');
        print('StackTrace: $stackTrace');
        emit(AuthFailure('فشل تسجيل الدخول: ${e.toString()}'));
      }
    });
  }
}

Future<void> saveToken(String token) async {
  final prefs = await SharedPreferences.getInstance();
  await prefs.setString('auth_token', token);
}

Future<String?> getToken() async {
  final prefs = await SharedPreferences.getInstance();
  return prefs.getString('auth_token');
}
