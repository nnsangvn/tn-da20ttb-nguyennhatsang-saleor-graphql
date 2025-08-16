import 'package:flutter/material.dart';
import 'package:petshop/core/themes/colors.dart';

class InputBase extends StatelessWidget {
  final TextEditingController? controller;
  final String hintText;
  final bool obscureText;
  final Function(String text)? onChanged;
  const InputBase({
    super.key,
    this.controller,
    required this.hintText,
    required this.obscureText,
    this.onChanged,
  });

  @override
  Widget build(BuildContext context) {
    return TextField(
      controller: controller,
      obscureText: obscureText,
      onChanged: onChanged,
      decoration: InputDecoration(
        // Border when unselected
        enabledBorder: OutlineInputBorder(
          borderSide: BorderSide(color: AppColors.primary_50),
          borderRadius: BorderRadius.circular(12),
        ),
        // Border when selected
        focusedBorder: OutlineInputBorder(
          borderSide: BorderSide(color: AppColors.primary_700),
          borderRadius: BorderRadius.circular(12),
        ),

        fillColor: Colors.white,
        filled: true,
        hintText: hintText,
      ),
      style: const TextStyle(color: Colors.black),
    );
  }
}
