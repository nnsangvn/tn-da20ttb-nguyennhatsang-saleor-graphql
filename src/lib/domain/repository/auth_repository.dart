import 'package:dartz/dartz.dart';
import 'package:petshop/data/model/login_req_params.dart';

abstract class AuthRepository {
  Future<Either> login(LoginReqParams loginReqParams);
}
