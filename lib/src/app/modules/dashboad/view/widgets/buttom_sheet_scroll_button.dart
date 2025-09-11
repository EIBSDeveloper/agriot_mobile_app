import 'package:flutter/material.dart';

class ButtomSheetScrollButton extends StatelessWidget {
  const ButtomSheetScrollButton({
    super.key,
  });

  @override
  Widget build(BuildContext context) => Column(
      children: [
        Center(
          child: Container(
            width: 40,
            height: 4,
            decoration: BoxDecoration(
              color: Colors.grey[300],
              borderRadius: BorderRadius.circular(2),
            ),
          ),
        ),
        const SizedBox(height: 16),
      ],
    );
}
