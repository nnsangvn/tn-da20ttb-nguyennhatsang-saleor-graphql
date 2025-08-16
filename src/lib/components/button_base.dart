import 'package:flutter/material.dart';
import 'package:petshop/core/themes/colors.dart';

class ButtonBase extends StatefulWidget {
  const ButtonBase({super.key, required this.text, this.onTap, this.customBackgroundColor});
  final String text;
  final Color? customBackgroundColor;
  final void Function()? onTap;
  @override
  State<ButtonBase> createState() => _ButtonBaseState();
}

class _ButtonBaseState extends State<ButtonBase> {
  @override
  void didUpdateWidget(covariant ButtonBase oldWidget) {
    super.didUpdateWidget(oldWidget);
  }

  @override
  Widget build(BuildContext context) {
    return Material(
      borderRadius: BorderRadius.circular(12),
      color: widget.customBackgroundColor ??
          (widget.onTap != null ? AppColors.primary_700 : AppColors.primary_100),
      child: InkWell(
        borderRadius: BorderRadius.circular(12),
        onTap: widget.onTap,
        child: Container(
          padding: const EdgeInsets.all(16),
          decoration: BoxDecoration(
            // Curved corners
            borderRadius: BorderRadius.circular(12),
          ),
          // Text
          child: Center(
            child: Text(
              widget.text,
              style: TextStyle(
                fontWeight: FontWeight.bold,
                color: widget.onTap != null ? Colors.white : AppColors.primary_300,
              ),
            ),
          ),
        ),
      ),
    );
  }
}
