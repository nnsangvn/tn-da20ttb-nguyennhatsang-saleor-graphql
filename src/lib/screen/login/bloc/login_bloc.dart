import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:petshop/data/model/login_req_params.dart';
import 'package:petshop/domain/usecase/login_usecase.dart';
import 'package:petshop/screen/login/bloc/login_event.dart';
import 'package:petshop/screen/login/bloc/login_state.dart';
import 'package:petshop/service_locator.dart';

class LoginBloc extends Bloc<LoginEvent, LoginState> {
  final LoginUsecase _loginUsecase;
  LoginBloc()
      : _loginUsecase = sl<LoginUsecase>(),
        super(LoginInitial()) {
    on<LoginSubmit>(_onLoginSubmit);
  }

  Future<void> _onLoginSubmit(
    LoginSubmit event,
    Emitter<LoginState> emit,
  ) async {
    emit(LoginLoading());
    try {
      final result =
          await _loginUsecase(param: LoginReqParams(email: event.email, password: event.password));
      result.fold((error) {
        emit(LoginFailure(message: error.toString()));
      }, (data) {
        emit(LoginSuccess(data: data));
      });
    } catch (e) {
      emit(LoginFailure(message: e.toString()));
    }
  }
}
