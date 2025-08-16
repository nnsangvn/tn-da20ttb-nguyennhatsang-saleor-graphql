import 'package:flutter/material.dart';
import 'package:get_it/get_it.dart';
import 'package:petshop/common/helper/utils.dart';
import 'package:petshop/components/button_base.dart';
import 'package:petshop/components/input_base.dart';
import 'package:petshop/components/loading.dart';
import 'package:petshop/service/auth_service.dart';
import 'package:petshop/service/loading_service.dart';
import 'package:petshop/core/themes/colors.dart';

class ForgetPasswordScreen extends StatefulWidget {
  const ForgetPasswordScreen({super.key});

  @override
  State<ForgetPasswordScreen> createState() => _ForgetPasswordScreenState();
}

class _ForgetPasswordScreenState extends State<ForgetPasswordScreen> {
  final _authService = AuthService(ignoreToken: true);
  final LoadingService loadingService = GetIt.I<LoadingService>();
  String email = '';
  bool isDoneStepOne = false;

  String link = '';
  String newPassword = '';
  String reNewPassword = '';

  bool isValidEmail(String email) {
    final RegExp regex = RegExp(
      r'^[a-zA-Z0-9._%+-]+@[a-zA-Z0-9.-]+\.[a-zA-Z]{2,}$',
    );
    return regex.hasMatch(email);
  }

  handleSendRequest() async {
    int id = loadingService.showLoading();
    final response = await _authService.requestPasswordReset(email, 'https://example.com');
    loadingService.hideLoading(id);
    if (!response) {
      return;
    }
    setState(() {
      isDoneStepOne = true;
    });
  }

  handleChangePassword() async {
    if (newPassword != reNewPassword) {
      Utils().showToast('Mật khẩu và nhập lại mật khẩu không trùng khớp', ToastType.failed);
      return;
    }
    Uri? uri = Uri.tryParse(link);
    if (uri?.queryParameters['email'] == null || uri?.queryParameters['token'] == null) {
      Utils().showToast('Url không hợp lệ', ToastType.failed);
      return;
    }
    final response = await _authService.setPassword(
      email: uri!.queryParameters['email']!,
      token: uri.queryParameters['token']!,
      password: newPassword,
    );
    if (response == null) {
      return;
    }
    Utils().showToast('Đổi mật khẩu thành công', ToastType.success);
    Navigator.of(context).pop();
  }

  @override
  Widget build(BuildContext context) {
    return LoadingOverlay(
      child: Scaffold(
        appBar: AppBar(
          title: const Text(
            'Quên mật khẩu',
            style: TextStyle(
              color: Colors.white,
            ),
          ),
          iconTheme: const IconThemeData(
            color: Colors.white,
          ),
          backgroundColor: AppColors.primary_700,
        ),
        body: Container(
          padding: const EdgeInsets.all(16),
          child: Column(
            children: [
              Image.asset('assets/pet_shop_logo.jpg'),
              const SizedBox(height: 25),
              // view nhập email
              if (!isDoneStepOne) ...[
                InputBase(
                  key: const ValueKey('1'),
                  hintText: "Nhập email",
                  obscureText: false,
                  onChanged: (text) {
                    setState(() {
                      setState(() {
                        email = text.trim();
                      });
                    });
                  },
                ),
                const SizedBox(
                  height: 16,
                ),
                ButtonBase(
                  onTap: email.isNotEmpty
                      ? () {
                          if (!isValidEmail(email)) {
                            Utils().showToast('Email không hợp lệ', ToastType.failed);
                            return;
                          }
                          handleSendRequest();
                        }
                      : null,
                  text: 'Gửi yêu cầu',
                )
              ],

              // view nhập mã
              if (isDoneStepOne) ...[
                Text(
                  'Url chứa token đổi mật khẩu đã được gửi về $email, vui lòng copy url vào ô dưới đây:',
                  style: const TextStyle(color: Colors.grey),
                ),
                const SizedBox(
                  height: 12,
                ),
                InputBase(
                  key: const ValueKey('2'),
                  hintText: "Nhập url",
                  obscureText: false,
                  onChanged: (text) {
                    setState(() {
                      setState(() {
                        link = text.trim();
                      });
                    });
                  },
                ),
                const SizedBox(
                  height: 16,
                ),
                InputBase(
                  key: const ValueKey('3'),
                  hintText: "Nhập mật khẩu mới",
                  obscureText: false,
                  onChanged: (text) {
                    setState(() {
                      setState(() {
                        newPassword = text.trim();
                      });
                    });
                  },
                ),
                const SizedBox(
                  height: 16,
                ),
                InputBase(
                  key: const ValueKey('4'),
                  hintText: "Nhập lại mật khẩu mới",
                  obscureText: false,
                  onChanged: (text) {
                    setState(() {
                      setState(() {
                        reNewPassword = text.trim();
                      });
                    });
                  },
                ),
                const SizedBox(
                  height: 16,
                ),
                ButtonBase(
                  onTap: (link.isNotEmpty && newPassword.isNotEmpty && reNewPassword.isNotEmpty)
                      ? () {
                          handleChangePassword();
                        }
                      : null,
                  text: 'Đổi mật khẩu',
                )
              ]
            ],
          ),
        ),
      ),
    );
  }
}
