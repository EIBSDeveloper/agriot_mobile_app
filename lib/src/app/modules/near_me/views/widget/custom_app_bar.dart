// widgets/search_bar.dart

import 'package:flutter/material.dart';

import '../../../../service/utils/utils.dart';

class CustomAppBar extends StatelessWidget implements PreferredSizeWidget {
  final String title;
  final List<Widget>? actions;
  final bool showBackButton;

  const CustomAppBar({
    super.key,
    required this.title,
    this.actions,
    this.showBackButton = false,
  });

  @override
  Widget build(BuildContext context) => AppBar(
      title: Text(capitalizeFirstLetter(title)),
      // centerTitle: true,
      actions: actions,
      leading:  IconButton(
              icon: const Icon(Icons.arrow_back_ios_new),
              onPressed: () => Navigator.of(context).pop(),
            )
          ,
    );

  @override
  Size get preferredSize => const Size.fromHeight(kToolbarHeight);
}
