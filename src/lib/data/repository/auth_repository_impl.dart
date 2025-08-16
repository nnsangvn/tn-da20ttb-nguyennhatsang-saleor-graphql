import 'package:dartz/dartz.dart';
import 'package:petshop/data/model/login_req_params.dart';
import 'package:petshop/data/source/auth_api.dart';
import 'package:petshop/domain/repository/auth_repository.dart';
import 'package:petshop/service_locator.dart';

class AuthRepositoryImpl extends AuthRepository {
  @override
  Future<Either> login(LoginReqParams loginReqParams) async {
    Either result = await sl<AuthApi>().login(loginReqParams);
    return result.fold((error) {
      return Left(error);
    }, (data) {
      return Right(data);
    });
  }
}
