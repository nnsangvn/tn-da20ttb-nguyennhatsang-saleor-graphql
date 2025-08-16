import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:graphql_flutter/graphql_flutter.dart';
import 'package:petshop/core/routes/app_router.dart';
import 'package:petshop/screen/login/bloc/login_bloc.dart';
import 'package:petshop/service/graphql_config.dart';
import 'package:petshop/service_locator.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();

  // GraphQL Client to connect GraphQL Server
  await initHiveForFlutter();
  final ValueNotifier<GraphQLClient> client = GraphqlConfig.initializeClient();

  // Kiểm tra token khi khởi động
  // final authService = AuthService();
  // final token = await authService.getToken();
  // Initialize service locator
  initServiceLocator();

  runApp(MyApp(client: client));
}

// Class Main App
class MyApp extends StatelessWidget {
  final ValueNotifier<GraphQLClient> client;
  final String? token;

  const MyApp({super.key, required this.client, this.token});

  // This widget is the root of your application.
  @override
  Widget build(BuildContext context) {
    return GraphQLProvider(
      client: client,
      child: CacheProvider(
        child: MultiBlocProvider(
          providers: [
            BlocProvider(create: (_) => LoginBloc()),
          ],
          child: Builder(
            builder: (context) {
              return MaterialApp.router(
                title: 'PetShop',
                debugShowCheckedModeBanner: false,
                routerConfig: AppRouter.router,
              );
            },
          ),
        ),
      ),
    );
  }
}
