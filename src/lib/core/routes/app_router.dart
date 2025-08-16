import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:go_router/go_router.dart';
import 'package:petshop/core/navigation/navigation_cubit.dart';
import 'package:petshop/main_navigation.dart';
import 'package:petshop/screen/auth/forget_password_screen.dart';
import 'package:petshop/screen/auth/register.dart';
import 'package:petshop/screen/cart/cart_screen.dart';
import 'package:petshop/screen/order/order_screen.dart';
import 'package:petshop/screen/personal/personal_screen.dart';
import 'package:petshop/screen/product/product_overview_screen.dart';
import 'package:petshop/service/login_or_register.dart';

abstract final class AppRouter {
  static final _rootNavigatorKey = GlobalKey<NavigatorState>();
  static final _shellNavigatorKey = GlobalKey<NavigatorState>();

  static const String login = '/login';
  static const String register = '/register';
  static const String forgetPassword = '/forget-password';
  static const String home = '/home';
  static const String cart = '/cart';
  static const String order = '/order';
  static const String profile = '/profile';

  static final GoRouter _router = GoRouter(
    initialLocation: '/login',
    debugLogDiagnostics: true,
    navigatorKey: _rootNavigatorKey,
    routes: [
      ShellRoute(
        navigatorKey: _shellNavigatorKey,
        builder: (context, state, child) {
          return BlocProvider<NavigationCubit>(
            create: (context) => NavigationCubit(),
            child: MainNavigation(screen: child),
          );
        },
        pageBuilder: (context, state, child) {
          return NoTransitionPage(
              child: BlocProvider<NavigationCubit>(
            create: (context) => NavigationCubit(),
            child: MainNavigation(screen: child),
          ));
        },
        routes: [
          GoRoute(
            path: home,
            name: home,
            builder: (context, state) => const ProductOverviewScreen(),
          ),
          GoRoute(
            path: cart,
            name: cart,
            builder: (context, state) => const CartScreen(),
          ),
          GoRoute(
            path: order,
            name: order,
            builder: (context, state) => const OrdersScreen(),
          ),
          GoRoute(
            path: profile,
            name: profile,
            builder: (context, state) => const ProfileEdit(),
          ),
        ],
      ),
      GoRoute(
        path: login,
        name: login,
        builder: (context, state) => const LoginOrRegister(),
      ),
      GoRoute(
        path: register,
        name: register,
        builder: (context, state) => const RegisterScreen(),
      ),
      GoRoute(
        path: forgetPassword,
        name: forgetPassword,
        builder: (context, state) => const ForgetPasswordScreen(),
      ),
    ],
  );
  static GoRouter get router => _router;
}
