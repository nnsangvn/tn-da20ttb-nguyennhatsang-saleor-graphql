import 'package:flutter/material.dart';
import 'package:get_it/get_it.dart';
import 'package:loading_animation_widget/loading_animation_widget.dart';
import 'package:petshop/service/loading_service.dart';
import 'package:petshop/core/themes/colors.dart';

class LoadingOverlay extends StatelessWidget {
  final Widget child;

  const LoadingOverlay({super.key, required this.child});

  @override
  Widget build(BuildContext context) {
    final loadingService = GetIt.instance<LoadingService>();

    return Stack(
      children: [
        child,
        ValueListenableBuilder<bool>(
          valueListenable: loadingService.isLoading,
          builder: (context, isLoading, child) {
            if (!isLoading) return const SizedBox.shrink();
            return Container(
              color: Colors.black.withOpacity(0.4),
              child: Center(
                child: LoadingAnimationWidget.discreteCircle(
                  color: AppColors.primary_300,
                  secondRingColor: AppColors.primary_700,
                  thirdRingColor: AppColors.primary_500,
                  size: 20,
                ),
              ),
            );
          },
        ),
      ],
    );
  }
}
