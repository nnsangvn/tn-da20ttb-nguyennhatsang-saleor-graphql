import 'package:flutter/material.dart';
import 'package:petshop/screen/login/login.dart';
import 'package:petshop/screen/auth/register.dart';

/*
  LOGIN OR REGISTER PAGE

  This determines whether to show login page or register page
*/

class LoginOrRegister extends StatefulWidget {
  const LoginOrRegister({super.key});

  @override
  State<LoginOrRegister> createState() => _LoginOrRegisterState();
}

class _LoginOrRegisterState extends State<LoginOrRegister> {
  // initially, show login page
  bool showLoginPage = true;

  //toggle between login $ register
  void togglePages() {
    setState(() {
      showLoginPage = !showLoginPage;
    });
  }

  @override
  Widget build(BuildContext context) {
    if (showLoginPage) {
      return LoginScreen(
        onTap: togglePages,
      );
    } else {
      return RegisterScreen();
    }
  }
}
