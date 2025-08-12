import 'package:flutter/material.dart';
import 'package:graphql_flutter/graphql_flutter.dart';
import 'package:petshop/core/routes/app_router.dart';
import 'package:petshop/service/auth_service.dart';
import 'package:petshop/service/cart_service.dart';
import 'package:petshop/service/checkout_service.dart';
import 'package:petshop/service/graphql_config.dart';
import 'package:petshop/service/loading_service.dart';
import 'package:petshop/service/order_service.dart';
import 'package:petshop/service/product_service.dart';
import 'package:petshop/themes/theme_provider.dart';
import 'package:provider/provider.dart';
import 'package:get_it/get_it.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();

  // GraphQL Client to connect GraphQL Server
  await initHiveForFlutter();
  final ValueNotifier<GraphQLClient> client = GraphqlConfig.initializeClient();

  // Kiểm tra token khi khởi động
  final authService = AuthService();
  final token = await authService.getToken();
  final GetIt sl = GetIt.instance;

  sl.registerLazySingleton<LoadingService>(() => LoadingService());

  runApp(MyApp(client: client, token: token));
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
        child: MultiProvider(
          providers: [
            ChangeNotifierProvider(create: (_) => ThemeProvider()),
            ChangeNotifierProvider(create: (_) => ProductService()),
            ChangeNotifierProvider(create: (_) => CartService()),
            ChangeNotifierProvider(create: (_) => OrderService()),
            ChangeNotifierProvider(create: (_) => CheckoutService()),
            ChangeNotifierProvider(create: (_) => OrderService()),
            ChangeNotifierProvider(create: (_) => CartService()),
          ],
          child: Builder(
            builder: (context) {
              return MaterialApp.router(
                title: 'PetShop',
                debugShowCheckedModeBanner: false,
                theme: Provider.of<ThemeProvider>(context).themeData,
                routerConfig: AppRouter.router,
              );
            },
          ),
        ),
      ),
    );
  }
}
