import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'auth_event.dart';
import 'auth_state.dart';
import '../../data/repositories/auth_repository_impl.dart';
import 'package:complaints/core/models/permission.dart';

class AuthBloc extends Bloc<AuthEvent, AuthState> {
  final AuthRepositoryImpl repository;

  AuthBloc(this.repository) : super(AuthInitial()) {
    on<LoginRequested>((event, emit) async {
      emit(AuthLoading());
      try {
        final result = await repository.login(event.email, event.password);

        // حفظ التوكن
        await saveToken(result.token);

        // Parse user data from result
        final user = User.fromJson(result.user);
        
        emit(AuthSuccess(user, result.token));
      } catch (e, stackTrace) {
        print('Login Error: $e');
        print('StackTrace: $stackTrace');
        
        // Extract meaningful error message
        String errorMessage = 'فشل تسجيل الدخول';
        
        if (e.toString().toLowerCase().contains('invalid') || 
            e.toString().toLowerCase().contains('wrong') ||
            e.toString().toLowerCase().contains('incorrect')) {
          errorMessage = 'البريد الإلكتروني أو كلمة المرور غير صحيحة';
        } else if (e.toString().toLowerCase().contains('network') ||
                   e.toString().toLowerCase().contains('connection')) {
          errorMessage = 'مشكلة في الاتصال بالإنترنت';
        } else if (e.toString().toLowerCase().contains('not found') ||
                   e.toString().toLowerCase().contains('user')) {
          errorMessage = 'المستخدم غير موجود';
        } else if (e.toString().toLowerCase().contains('password')) {
          errorMessage = 'كلمة المرور غير صحيحة';
        } else if (e.toString().toLowerCase().contains('email')) {
          errorMessage = 'البريد الإلكتروني غير صحيح';
        }
        
        emit(AuthFailure(errorMessage));
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
