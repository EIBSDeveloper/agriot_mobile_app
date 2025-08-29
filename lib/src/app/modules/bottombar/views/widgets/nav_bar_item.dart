import 'package:flutter/material.dart';

import '../../../../../core/app_style.dart';
import '../../model/bottom_nav_bar_item.dart';

class NavBarItem extends StatefulWidget {
  final BottomNavBarItem item;
  final int index;
  final bool selected;
  final Function onTap;
  final Color? backgroundColor;
  const NavBarItem({
    super.key,
    required this.item,
    this.selected = false,
    required this.onTap,
    this.backgroundColor,
    required this.index,
  });

  @override
  State<NavBarItem> createState() => _NavBarItemState();
}

class _NavBarItemState extends State<NavBarItem> {
  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: () {
        widget.onTap();
      },
      child: AnimatedContainer(
        margin: const EdgeInsets.all(8),
        padding: const EdgeInsets.all(8),
        duration: const Duration(milliseconds: 300),
        constraints: BoxConstraints(minWidth: widget.selected ? 70 : 56),
        height: 56,
        decoration: BoxDecoration(
          color:
              widget.selected
                  ? widget.backgroundColor!.withAlpha(70) // 0.2 * 255 = 51
                  : Colors.transparent,
          borderRadius: BorderRadius.circular(10),
        ),
        child: Row(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
              //  Icon(Icons.av_timer_outlined,color:  Get.theme.primaryColor),
            Image.asset(widget.item.icon,width: AppStyle.iconsize,height: AppStyle.iconsize,),
            const SizedBox(width: 4),
            Offstage(
              offstage: !widget.selected,
              child: Text(
                widget.item.title,
                style: TextStyle(color: widget.backgroundColor),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
