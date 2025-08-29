import 'package:flutter/material.dart';

class MinimalHorizontalStepper extends StatelessWidget {
  final List<String> steps;
  final int currentStep;
  final Color activeColor;
  final Color inactiveColor;
  final Color backgroundColor;
  final double circleSize;
  final double lineHeight;

  const MinimalHorizontalStepper({
    super.key,
    required this.steps,
    required this.currentStep,
    this.activeColor = const Color.fromARGB(255, 100, 120, 31),
    this.inactiveColor = Colors.grey,
    this.backgroundColor = const Color(0xFFF6F9F0), // pale green-ish bg
    this.circleSize = 20,
    this.lineHeight = 4,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.symmetric(vertical: 16, horizontal: 10),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          Container(
            padding: const EdgeInsets.symmetric(vertical: 16, horizontal: 16),
            decoration: BoxDecoration(
              color: backgroundColor,
              borderRadius: BorderRadius.circular(10),
            ),
            child: Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: List.generate(steps.length, (index) {
                return Expanded(
                  child: Text(
                    steps[index],
                    textAlign: (index == 0)
                        ? TextAlign.start
                        : ((index == steps.length - 1)
                              ? TextAlign.end
                              : TextAlign.center),
                    style: const TextStyle(
                      fontWeight: FontWeight.w600,
                      color: Colors.black87,
                    ),
                  ),
                );
              }),
            ),
          ),

          const SizedBox(height: 12),

          // Circles and line stack
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: 15, vertical: 6),
            child: SizedBox(
              height: circleSize,
              child: Stack(
                alignment: Alignment.centerLeft,
                children: [
                  // The grey connecting line in the background
                  Positioned(
                    left: circleSize / 2,
                    right: circleSize / 2,
                    top: (circleSize - lineHeight) / 2,
                    child: Container(
                      height: lineHeight,
                      color: inactiveColor.withOpacity(0.3),
                    ),
                  ),

                  // The active part of the line
                  Positioned(
                    left: circleSize / 2,
                    top: (circleSize - lineHeight) / 2,
                    width:
                        (currentStep / (steps.length - 1)) *
                        (MediaQuery.of(context).size.width - 48 - circleSize),
                    child: Container(height: lineHeight, color: activeColor),
                  ),

                  // The circles
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: List.generate(steps.length, (index) {
                      final isActive = index == currentStep;
                      final isCompleted = index < currentStep;

                      return Container(
                        width: circleSize,
                        height: circleSize,
                        decoration: BoxDecoration(
                          color: isActive || isCompleted
                              ? activeColor
                              : Colors.white,
                          border: Border.all(
                            color: isActive || isCompleted
                                ? activeColor
                                : inactiveColor.withOpacity(0.5),
                            width: 2,
                          ),
                          shape: BoxShape.circle,
                        ),
                        child: isCompleted
                            ? Icon(Icons.done, color: Colors.white,size: 15,)
                            : (isActive
                                  ? Icon(Icons.circle, color: Colors.white,size: 7,)
                                  : SizedBox()),
                      );
                    }),
                  ),
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }
}
