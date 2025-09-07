import 'package:flutter/material.dart';
import 'package:get/get.dart';

class TitleText extends StatelessWidget {
  final String title;
  final Color? color;
  final BoxFit? fit;
  const TitleText(this.title, {super.key, this.color, this.fit});

  @override
  Widget build(BuildContext context) => fit != BoxFit.none
      ? FittedBox(
          alignment: Alignment.centerLeft,
          fit: fit ?? BoxFit.scaleDown,
          child: Text(
            title,
            textAlign: TextAlign.start,
            style: Get.textTheme.titleLarge?.copyWith(
              fontWeight: FontWeight.bold,
              color: color ?? Get.theme.primaryColor,
            ),
          ),
        )
      : Text(
          title,
          textAlign: TextAlign.start,
          style: Get.textTheme.titleLarge?.copyWith(
            fontWeight: FontWeight.bold,
            color: color ?? Get.theme.primaryColor,
          ),
        );
}
