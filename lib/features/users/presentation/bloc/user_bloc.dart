import 'package:flutter_bloc/flutter_bloc.dart';
import '../../domain/entities/user.dart';
import '../../data/repositories/user_repository.dart';

part 'user_event.dart';
part 'user_state.dart';

// BLoC
class UserBloc extends Bloc<UserEvent, UserState> {
  final UserRepository _repository;

  UserBloc(this._repository) : super(UserInitial()) {
    on<FetchUsers>(_onFetchUsers);
  }

  Future<void> _onFetchUsers(
    FetchUsers event,
    Emitter<UserState> emit,
  ) async {
    emit(UserLoading());
    try {
      final users = await _repository.getUsers();
      emit(UserLoaded(users));
    } catch (e) {
      emit(UserError(e.toString()));
    }
  }
}
