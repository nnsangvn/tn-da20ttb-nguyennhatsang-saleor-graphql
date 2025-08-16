import 'package:flutter/material.dart';
import 'package:graphql_flutter/graphql_flutter.dart';
import 'package:petshop/data/model/login_req_params.dart';
import 'package:dartz/dartz.dart';
import 'package:petshop/service/graphql_config.dart';

abstract class AuthApi {
  Future<Either<String, dynamic>> login(LoginReqParams loginReqParams);
}

class AuthApiImpl extends AuthApi {
  late ValueNotifier<GraphQLClient> client = GraphqlConfig.initializeClient();

  @override
  Future<Either<String, dynamic>> login(LoginReqParams loginReqParams) async {
    const String loginMutation = '''
    mutation TokenCreate(\$email: String!, \$password: String!) {
      tokenCreate(email: \$email, password: \$password) {
        token
        refreshToken
        csrfToken
        errors {
          message
          field
          code
          addressType
        }
      }
    }
    ''';

    try {
      final options = MutationOptions(
        document: gql(loginMutation),
        variables: {
          'email': loginReqParams.email,
          'password': loginReqParams.password,
        },
      );

      final result = await client.value.mutate(options);

      if (result.hasException) {
        return Left(result.exception.toString());
      }

      final data = result.data?['tokenCreate'];
      if (data != null && data['token'] != null) {
        return Right(data);
      } else {
        return Left(data?['errors']?[0]?['message'] ?? 'Đăng nhập thất bại');
      }
    } catch (e) {
      return Left(e.toString());
    }
  }
}
