import 'package:cached_network_image/cached_network_image.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:loading_animation_widget/loading_animation_widget.dart';

class MyNetworkImage extends StatelessWidget {
  const MyNetworkImage(
    this.imageUrl, {
    super.key,
    this.fit,
    this.height,
    this.width,
  });

  final String imageUrl;
  final BoxFit? fit;
  final double? width;
  final double? height;

  @override
  Widget build(BuildContext context) => CachedNetworkImage(
      imageUrl: imageUrl,
      width: width,
      height: height,
      fit: fit,
      progressIndicatorBuilder:
          (context, url, downloadProgress) => Center(
            child: Padding(
              padding: const EdgeInsets.all(10.0),
              child: LoadingAnimationWidget.hexagonDots(
                color: Get.theme.primaryColor,
                size: 40,
              ),
            ),
          ),
      errorWidget:
          (context, url, error) => const Icon(Icons.now_wallpaper_outlined),
    );
}
class MyNetworkImageProvider extends StatelessWidget {
  const MyNetworkImageProvider(
    this.imageUrl, {
    super.key,
    this.fit,
    this.height,
    this.width,
  });

  final String imageUrl;
  final BoxFit? fit;
  final double? width;
  final double? height;

  @override
  Widget build(BuildContext context) => CachedNetworkImage(
      imageUrl: imageUrl,
      fit: fit,
      width: width,
      height: height,
      placeholder: (context, url) => Center(
        child: Padding(
          padding: const EdgeInsets.all(10.0),
          child: LoadingAnimationWidget.hexagonDots(
            color: Get.theme.primaryColor,
            size: 40,
          ),
        ),
      ),
      errorWidget: (context, url, error) =>
          const Icon(Icons.wallpaper_outlined),
    );
}