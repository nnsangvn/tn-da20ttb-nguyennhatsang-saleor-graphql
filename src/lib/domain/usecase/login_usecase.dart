import 'package:dartz/dartz.dart';
import 'package:petshop/core/usecase/usecase.dart';
import 'package:petshop/data/model/login_req_params.dart';
import 'package:petshop/domain/repository/auth_repository.dart';
import 'package:petshop/service_locator.dart';

class LoginUsecase implements UseCase<Either, LoginReqParams> {
  @override
  Future<Either> call({LoginReqParams? param}) async {
    return sl<AuthRepository>().login(param!);
  }
}
