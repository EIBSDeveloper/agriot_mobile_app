import 'package:flutter/material.dart';
import 'package:get/get.dart';

class WalkthroughPage extends StatelessWidget {
  final String imagePath;
  final String title;
  final String description;

  const WalkthroughPage({
    super.key,
    required this.imagePath,
    required this.title,
    required this.description,
  });

  @override
  Widget build(BuildContext context) => Padding(
    padding: const EdgeInsets.symmetric(horizontal: 24.0),
    child: Column(
      mainAxisAlignment: MainAxisAlignment.center,
      children: [
        Container(
          width: 300,
          height: 300,
          decoration: BoxDecoration(
            shape: BoxShape.circle,
            color: Get.theme.colorScheme.primary.withOpacity(0.1),
            image: DecorationImage(
              image: AssetImage(imagePath),
              fit: BoxFit.fill,
            ),
          ),
        ),
        const SizedBox(height: 40),
        Text(
          title,
          style: Get.textTheme.headlineSmall?.copyWith(
            fontWeight: FontWeight.bold,
          ),
          textAlign: TextAlign.center,
        ),
        const SizedBox(height: 16),
        Padding(
          padding: const EdgeInsets.symmetric(horizontal: 20.0),
          child: Text(
            description,
            style: Get.textTheme.bodyMedium,
            textAlign: TextAlign.center,
          ),
        ),
      ],
    ),
  );
}
