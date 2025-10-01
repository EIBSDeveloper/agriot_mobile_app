import 'package:argiot/src/app/modules/attendence/controller/attendence_controller.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:intl/intl.dart';

class HorizontalDatePicker extends GetView<AttendenceController> {
  final Function(DateTime) onDateSelected;

  const HorizontalDatePicker({super.key, required this.onDateSelected});

  List<DateTime> generateDates({int monthsAhead = 12}) {
    final now = DateTime.now();
    List<DateTime> allDates = [];
    for (int monthOffset = 0; monthOffset <= monthsAhead; monthOffset++) {
      final year = now.year + ((now.month + monthOffset - 1) ~/ 12);
      final month = (now.month + monthOffset - 1) % 12 + 1;
      final _ = DateTime(year, month, 1);
      final lastDay = DateTime(year, month + 1, 0);
      for (int day = 1; day <= lastDay.day; day++) {
        allDates.add(DateTime(year, month, day));
      }
    }
    return allDates;
  }

  @override
  Widget build(BuildContext context) {
    final today = DateTime.now();
    final allDates = generateDates(monthsAhead: 12);

    ScrollController scrollController = ScrollController();

    // Auto-scroll to today
    WidgetsBinding.instance.addPostFrameCallback((_) {
      final todayIndex = allDates.indexWhere(
        (d) =>
            d.day == today.day &&
            d.month == today.month &&
            d.year == today.year,
      );
      if (todayIndex >= 0) {
        scrollController.jumpTo(todayIndex * 57.0);
      }
    });

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Obx(
          () => Padding(
            padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
            child: Center(
              child: Text(
                controller.currentMonthYear.value,
                style: const TextStyle(
                  fontSize: 16,
                  fontWeight: FontWeight.bold,
                ),
              ),
            ),
          ),
        ),
        SizedBox(
          height: 90,
          child: NotificationListener<ScrollNotification>(
            onNotification: (scrollNotification) {
              if (scrollNotification is ScrollUpdateNotification) {
                // Update current month-year based on first visible date
                final firstVisibleIndex = (scrollController.offset / 57.0)
                    .floor();
                if (firstVisibleIndex >= 0 &&
                    firstVisibleIndex < allDates.length) {
                  controller.updateMonthYear(allDates[firstVisibleIndex]);
                }
              }
              return false;
            },
            child: ListView.builder(
              controller: scrollController,
              scrollDirection: Axis.horizontal,
              itemCount: allDates.length,
              itemBuilder: (context, index) {
                final date = allDates[index];

                return Obx(() {
                  final _ =
                      date.day == controller.selectedDate.value.day &&
                      date.month == controller.selectedDate.value.month &&
                      date.year == controller.selectedDate.value.year;

                  final isToday =
                      date.day == today.day &&
                      date.month == today.month &&
                      date.year == today.year;

                  final isFuture = date.isAfter(today);
                  final isPast = date.isBefore(today);

                  Color bgColor = Colors.transparent;
                  Color textColor = Colors.black87;

                  if (isPast) {
                    bgColor = Colors.grey;
                    textColor = Colors.white;
                  } else if (isFuture) {
                    textColor = Colors.grey.shade400;
                  }

                  if (isToday) {
                    bgColor = Get.theme.colorScheme.primary;
                    textColor = Colors.white;
                  }

                  return GestureDetector(
                    onTap: isFuture
                        ? null
                        : () {
                            controller.setSelectedDate(date);
                            onDateSelected(date);
                          },
                    child: Container(
                      width: 50,
                      margin: const EdgeInsets.symmetric(
                        horizontal: 6,
                        vertical: 10,
                      ),
                      decoration: BoxDecoration(
                        color: bgColor,
                        borderRadius: BorderRadius.circular(8),
                      ),
                      alignment: Alignment.center,
                      child: Column(
                        mainAxisAlignment: MainAxisAlignment.center,
                        children: [
                          Text(
                            DateFormat.E().format(date),
                            style: TextStyle(
                              color: textColor,
                              fontWeight: FontWeight.bold,
                            ),
                          ),
                          const SizedBox(height: 4),
                          Text(
                            date.day.toString(),
                            style: TextStyle(
                              color: textColor,
                              fontWeight: FontWeight.bold,
                            ),
                          ),
                        ],
                      ),
                    ),
                  );
                });
              },
            ),
          ),
        ),
      ],
    );
  }
}

/* return Obx(() {
                  final isSelected =
                      date.day == controller.selectedDate.value.day &&
                      date.month == controller.selectedDate.value.month &&
                      date.year == controller.selectedDate.value.year;

                  final isToday =
                      date.day == today.day &&
                      date.month == today.month &&
                      date.year == today.year;

                  final isFuture = date.isAfter(today);
                  final isPast = date.isBefore(today);

                  Color bgColor = Colors.transparent;
                  Color textColor = Colors.black87;

                  if (isSelected && isPast) {
                    // 🚀 Selected past date: orange
                    bgColor = Colors.orange;
                    textColor = Colors.white;
                  } else if (isToday) {
                    // Today
                    bgColor = Get.theme.colorScheme.primary;
                    textColor = Colors.white;
                  } else if (isPast) {
                    // Other past dates
                    bgColor = Colors.grey;
                    textColor = Colors.white;
                  } else if (isFuture) {
                    // Future dates
                    textColor = Colors.grey.shade400;
                  }

                  return GestureDetector(
                    onTap: isFuture
                        ? null
                        : () {
                            controller.setSelectedDate(date);
                            onDateSelected(date);
                          },
                    child: Container(
                      width: 50,
                      margin: const EdgeInsets.symmetric(
                        horizontal: 6,
                        vertical: 10,
                      ),
                      decoration: BoxDecoration(
                        color: bgColor,
                        borderRadius: BorderRadius.circular(8),
                      ),
                      alignment: Alignment.center,
                      child: Column(
                        mainAxisAlignment: MainAxisAlignment.center,
                        children: [
                          Text(
                            DateFormat.E().format(date),
                            style: TextStyle(
                              color: textColor,
                              fontWeight: FontWeight.bold,
                            ),
                          ),
                          const SizedBox(height: 4),
                          Text(
                            date.day.toString(),
                            style: TextStyle(
                              color: textColor,
                              fontWeight: FontWeight.bold,
                            ),
                          ),
                        ],
                      ),
                    ),
                  );
                });*/
