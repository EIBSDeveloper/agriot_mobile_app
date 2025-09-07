import 'package:argiot/src/core/app_images.dart';
import 'package:flutter/widgets.dart';

class BackgroundImage extends StatelessWidget {
  final Widget? child;
  const BackgroundImage({super.key, this.child});

  @override
  Widget build(BuildContext context) => Container(
      decoration: const BoxDecoration(
        image: DecorationImage(image: AssetImage(AppImages.bg),fit: BoxFit.fill),
      ),
      width: double.infinity,
      child: child,
    );
}
