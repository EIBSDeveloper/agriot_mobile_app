import 'package:argiot/src/app/service/utils/utils.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';

class MonthDayFormat extends StatelessWidget {
  final DateTime date;
  const MonthDayFormat({super.key, required this.date});

  @override
  Widget build(BuildContext context) => Column(
    children: [
      Text(
        getMonthName(date.month),
        style: TextStyle(
          color: Get.theme.primaryColor,
          fontWeight: FontWeight.bold,
        ),
      ),
      Text(
        date.day.toString(),
        style: TextStyle(
          color: Get.theme.primaryColor,
          fontWeight: FontWeight.bold,
          fontSize: 18,
        ),
      ),
    ],
  );
}
