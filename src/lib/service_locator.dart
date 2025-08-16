import 'package:get_it/get_it.dart';
import 'package:petshop/data/repository/auth_repository_impl.dart';
import 'package:petshop/data/source/auth_api.dart';
import 'package:petshop/domain/repository/auth_repository.dart';
import 'package:petshop/domain/usecase/login_usecase.dart';
import 'package:petshop/service/loading_service.dart';

final sl = GetIt.instance;

void initServiceLocator() {
  sl.registerLazySingleton<LoadingService>(() => LoadingService());

  // Services
  sl.registerSingleton<AuthApi>(AuthApiImpl());

  // Repository
  sl.registerSingleton<AuthRepository>(
    AuthRepositoryImpl(),
  );

  // Usecase
  sl.registerSingleton<LoginUsecase>(LoginUsecase());
}
