import 'package:flutter/material.dart';
import 'package:get/get.dart';

import '../../model/bottom_nav_bar_item.dart';
import 'nav_bar_item.dart';

class BottomNavBar extends StatefulWidget {
  final List<BottomNavBarItem> children;
  final int curentIndex;
  final Color? backgroundColor;
  final Color? selectColor;
  final Function(int)? onTap;

  const BottomNavBar({
    super.key,
    required this.children,
    required this.selectColor,
    required this.curentIndex,
    this.backgroundColor,
    required this.onTap,
  });

  @override
  State<BottomNavBar> createState() => _BottomNavBarState();
}

class _BottomNavBarState extends State<BottomNavBar> {
  late int _currentIndex;

  @override
  void initState() {
    super.initState();
    _currentIndex = widget.curentIndex;
  }

  @override
  Widget build(BuildContext context) {
double screenWidth = Get.width;
    return Container(
      decoration: BoxDecoration(
        borderRadius: BorderRadius.circular(16),
        color: widget.backgroundColor ?? Theme.of(context).colorScheme.primary,
      ),
      width: screenWidth,
      margin: const EdgeInsets.only(bottom: 10, left: 5, right: 5),
      height: 56,
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceEvenly,
        children: List.generate(
          widget.children.length,
          (index) => NavBarItem(
            index: index,
            backgroundColor: widget.children[index].color,
            item: widget.children[index],
            selected: _currentIndex == index,
            onTap: () {
              setState(() {
                _currentIndex = index;
                widget.onTap?.call(index);
              });
            },
          ),
        ),
      ),
    );
  }
}
