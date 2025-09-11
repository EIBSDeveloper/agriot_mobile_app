import 'package:flutter/material.dart';

class AppStyle {
  static const double iconsize = 32;
  static const double iconsize2 = 25;
  static const double iconsize3 = 15;
  static const double borderRadiusbox = 10;
  static const double borderRadiusClip = 5;
  static const double borderRadiusbottom = 50;

  static const List<BoxShadow> boxShadow = [
    BoxShadow(
      color: Color.fromRGBO(0, 0, 0, 0.1),
      blurRadius: 3,
      spreadRadius: 0,
      offset: Offset(0, 1),
    ),
    BoxShadow(
      color: Color.fromRGBO(0, 0, 0, 0.06),
      blurRadius: 2,
      spreadRadius: 0,
      offset: Offset(0, 1),
    ),
  ];

  static const BoxDecoration decoration = BoxDecoration(
    color: Colors.white,
    borderRadius: BorderRadius.all(Radius.circular(borderRadiusbox)),
    boxShadow: AppStyle.boxShadow,
  );
  static BoxDecoration inputDecoration = const BoxDecoration(
    borderRadius: BorderRadius.all(Radius.circular(borderRadiusbox)),
  );
}
