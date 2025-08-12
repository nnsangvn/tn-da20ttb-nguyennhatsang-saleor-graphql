import 'dart:convert';

import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:petshop/Utils/utils.dart';
import 'package:petshop/common/app_constants.dart';
import 'package:petshop/components/button_base.dart';
import 'package:petshop/components/button_custom_content.dart';
import 'package:petshop/components/loading.dart';
import 'package:petshop/core/routes/app_router.dart';
import 'package:petshop/screen/auth/forget_password_screen.dart';
import 'package:petshop/screen/auth/register.dart';
import 'package:petshop/screen/product/product_overview_screen.dart';

import 'package:petshop/service/auth_service.dart';
import 'package:petshop/service/graphql_config.dart';
import 'package:petshop/service/loading_service.dart';
import 'package:petshop/themes/colors.dart';
import 'package:shared_preferences/shared_preferences.dart';
import '../../components/input_base.dart';
import 'package:get_it/get_it.dart';

class LoginScreen extends StatefulWidget {
  final void Function()? onTap;

  const LoginScreen({super.key, this.onTap});

  @override
  State<LoginScreen> createState() => _LoginScreenState();
}

class _LoginScreenState extends State<LoginScreen> {
  final AuthService _authService = AuthService(ignoreToken: true);
  String email = '';
  String password = '';
  final LoadingService loadingService = GetIt.I<LoadingService>();

  void _login() async {
    int loadingId = loadingService.showLoading();
    final response = await _authService.loginUser(email, password);
    loadingService.hideLoading(loadingId);
    if (response != null && response['token'] != null) {
      final SharedPreferences sharedPreferences = await SharedPreferences.getInstance();
      await sharedPreferences.setString(AppConstants.keyToken, response['token']);
      await sharedPreferences.setString(AppConstants.keyRefreshToken, response['refreshToken']);
      if (response['user']?['checkoutIds'] != null &&
          response['user']?['checkoutIds'] is List &&
          (response['user']?['checkoutIds'] as List).isNotEmpty) {
        await sharedPreferences.setString(
            AppConstants.keyCheckoutId, (response['user']?['checkoutIds'] as List).first);
      } else {
        await sharedPreferences.setString(AppConstants.keyCheckoutId, '');
      }
      if (response['user']?['defaultBillingAddress'] != null) {
        await sharedPreferences.setString(
          AppConstants.keyAddress,
          jsonEncode(response['user']?['defaultBillingAddress']),
        );
      }
      if (mounted) {
        // Navigate to MyHomePage
        context.go(AppRouter.home);
      }
    } else {
      Utils().showToast('Tài khoản hoặc mật khẩu không chính xác', ToastType.failed);
      if (mounted) {
        // Check if the state is still mounted
        print('Login failed');
      }
    }
  }

  @override
  void initState() {
    super.initState();
  }

  @override
  Widget build(BuildContext context) {
    return LoadingOverlay(
      child: Scaffold(
        backgroundColor: Colors.white,
        body: SafeArea(
          child: Padding(
            padding: const EdgeInsets.only(left: 16, right: 16, top: 70),
            child: Center(
              child: Column(
                children: [
                  Image.asset('assets/pet_shop_logo.jpg'),
                  const SizedBox(height: 25),
                  InputBase(
                    hintText: "Nhập email",
                    obscureText: false,
                    onChanged: (text) {
                      setState(() {
                        email = text;
                      });
                    },
                  ),
                  const SizedBox(height: 10),
                  InputBase(
                    hintText: "Nhập mật khẩu",
                    obscureText: true,
                    onChanged: (text) {
                      setState(() {
                        password = text;
                      });
                    },
                  ),
                  const SizedBox(height: 10),
                  Align(
                    alignment: Alignment.centerRight,
                    child: ButtonCustomContent(
                      radius: BorderRadius.circular(4),
                      onTap: () {
                        context.push(AppRouter.forgetPassword);
                      },
                      child: Text(
                        'Quên mật khẩu?',
                        style: TextStyle(
                          color: AppColors.primary_700,
                          fontWeight: FontWeight.bold,
                          decorationStyle: TextDecorationStyle.solid,
                          decoration: TextDecoration.underline,
                          decorationColor: AppColors.primary_700,
                        ),
                      ),
                    ),
                  ),
                  const SizedBox(height: 25),
                  ButtonBase(
                    text: "Đăng nhập",
                    onTap: email.isNotEmpty && password.isNotEmpty ? _login : null,
                  ),
                  const SizedBox(height: 50),
                  Row(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      const Text(
                        "Chưa có tài khoản?",
                        style: TextStyle(
                          color: Colors.black,
                        ),
                      ),
                      const SizedBox(width: 10),
                      ButtonCustomContent(
                        radius: BorderRadius.circular(4),
                        onTap: () {
                          Navigator.push(
                            context,
                            MaterialPageRoute(
                              builder: (context) => const RegisterScreen(),
                            ),
                          );
                        },
                        child: Text(
                          'Đăng ký',
                          style: TextStyle(
                            color: AppColors.primary_700,
                            fontWeight: FontWeight.bold,
                            decorationStyle: TextDecorationStyle.solid,
                            decoration: TextDecoration.underline,
                            decorationColor: AppColors.primary_700,
                          ),
                        ),
                      ),
                    ],
                  ),
                ],
              ),
            ),
          ),
        ),
      ),
    );
  }
}
