import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:go_router/go_router.dart';
import 'package:petshop/common/helper/utils.dart';
import 'package:petshop/components/button_base.dart';
import 'package:petshop/components/button_custom_content.dart';
import 'package:petshop/components/loading.dart';
import 'package:petshop/core/routes/app_router.dart';
import 'package:petshop/screen/auth/register.dart';
import 'package:petshop/screen/login/bloc/login_bloc.dart';
import 'package:petshop/screen/login/bloc/login_event.dart';
import 'package:petshop/screen/login/bloc/login_state.dart';
import 'package:petshop/core/themes/colors.dart';
import '../../components/input_base.dart';

class LoginScreen extends StatefulWidget {
  final void Function()? onTap;

  const LoginScreen({super.key, this.onTap});

  @override
  State<LoginScreen> createState() => _LoginScreenState();
}

class _LoginScreenState extends State<LoginScreen> {
  final TextEditingController _emailController = TextEditingController();
  final TextEditingController _passwordController = TextEditingController();

  @override
  void initState() {
    super.initState();
  }

  @override
  Widget build(BuildContext context) {
    return LoadingOverlay(
      child: BlocProvider(
        create: (context) => LoginBloc(),
        child: BlocListener<LoginBloc, LoginState>(
          listener: (context, state) {
            if (state is LoginSuccess) {
              Utils().showToast('Đăng nhập thành công', ToastType.success);
              context.go(AppRouter.home);
            } else if (state is LoginFailure) {
              Utils().showToast('Tài khoản hoặc mật khẩu không chính xác', ToastType.failed);
            }
          },
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
                        controller: _emailController,
                        hintText: "Nhập email",
                        obscureText: false,
                      ),
                      const SizedBox(height: 10),
                      InputBase(
                        controller: _passwordController,
                        hintText: "Nhập mật khẩu",
                        obscureText: true,
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
                      const SizedBox(height: 50),
                      BlocBuilder<LoginBloc, LoginState>(
                        builder: (context, state) {
                          bool isLoading = state is LoginLoading;
                          return ButtonBase(
                            text: isLoading ? "Đang đăng nhập..." : "Đăng nhập",
                            onTap: isLoading
                                ? null
                                : () {
                                    context.read<LoginBloc>().add(
                                          LoginSubmit(
                                            email: _emailController.text.trim(),
                                            password: _passwordController.text.trim(),
                                          ),
                                        );
                                  },
                          );
                        },
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
        ),
      ),
    );
  }
}
