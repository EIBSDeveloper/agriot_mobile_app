import 'package:flutter/material.dart';

class ErrorText extends StatelessWidget {
  const ErrorText({super.key, this.error});

  final String? error;

  @override
  Widget build(BuildContext context) {
    return error == null
        ? SizedBox()
        : Row(
            mainAxisAlignment: MainAxisAlignment.start,
            children: [Text(error!, style: const TextStyle(color: Colors.red))],
          );
  }
}
