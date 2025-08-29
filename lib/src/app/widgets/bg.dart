import 'package:argiot/src/core/app_images.dart';
import 'package:flutter/widgets.dart';

class BackgroudImage extends StatelessWidget {
  final Widget? child;
  const BackgroudImage({super.key, this.child});

  @override
  Widget build(BuildContext context) {
    return Container(
      decoration: BoxDecoration(
        image: DecorationImage(image: AssetImage(AppImages.bg),fit: BoxFit.fill),
      ),
      width: double.infinity,
      child: child,
    );
  }
}
