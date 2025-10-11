import 'package:flutter/material.dart';
import 'package:flutter_svg/flutter_svg.dart';
import 'package:get/get.dart';

class SvgIcons extends StatelessWidget {
  const SvgIcons(
    this.assetName,{
    super.key,
   
     this.height,
     this.width,
     this.color,
  });

  final String assetName;
  final double? height;
  final double? width;
  final Color? color;

  @override
  Widget build(BuildContext context) => SvgPicture.asset(
    assetName,
    height: height??24,
    width: width??24,
    
    colorFilter: ColorFilter.mode(color??Get.theme.primaryColor, BlendMode.srcIn),
  );
}
