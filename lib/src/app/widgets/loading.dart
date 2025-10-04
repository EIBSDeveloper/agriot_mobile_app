import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:loading_animation_widget/loading_animation_widget.dart';

class Loading extends StatelessWidget {
  final double? size;
  const Loading({super.key, this.size});

  @override
  Widget build(BuildContext context) => Center(
    child: Padding(
      padding: const EdgeInsets.all(10.0),
      child: LoadingAnimationWidget.waveDots(
        color: Get.theme.primaryColor,
        size: size ?? 80,
      ),
    ),
  );
}
