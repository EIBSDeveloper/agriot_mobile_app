import 'package:argiot/src/app/controller/app_controller.dart';
import 'package:argiot/src/app/modules/guideline/model/guideline.dart';
import 'package:argiot/src/app/service/utils/utils.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';

import '../../../../service/utils/input_validation.dart';

class GuidelineThunbnail extends StatelessWidget {
  GuidelineThunbnail({super.key, required this.guideline});
  final Guideline guideline;

  final AppDataController appData = Get.find();

  @override
  Widget build(BuildContext context) {
    String? youtubeThumbnailUrl = getYoutubeThumbnailUrl(
      getYoutubeVideoId(guideline.videoUrl),
    );

    return Stack(
      alignment: Alignment.center,
      children: [
        Container(
          width: 80,
          height: 80,
          decoration: BoxDecoration(
            color:Colors.grey.withAlpha(30),
            borderRadius: BorderRadius.circular(8),
          ),
          child: (guideline.mediaType == 'video' && youtubeThumbnailUrl == null)
              ?   Icon(Icons.play_circle_fill, size: 40, color: Get.theme.colorScheme.primary,)
              : Image.network(
                  "${appData.baseUrlWithoutAPi.value}${guideline.document}",
                  fit: BoxFit.cover,
                  height: 60,
                  width: 60,
                  loadingBuilder: (context, child, loadingProgress) {
                    if (loadingProgress == null) {
                      return child;
                    }
                    return const Center(child: CircularProgressIndicator());
                  },
                  errorBuilder: (context, error, stackTrace) =>  Icon(
                    Icons.insert_drive_file,
                    size: 40,
                  color: Get.theme.colorScheme.primary,
                  ),
                ),
        ),
       
         
        if (youtubeThumbnailUrl != null && guideline.mediaType == 'video')
          Image.network(
            youtubeThumbnailUrl,
            fit: BoxFit.cover,
            height: 60,
            width: 60,
            loadingBuilder: (context, child, loadingProgress) {
              if (loadingProgress == null) {
                return child;
              }
              return const Center(child: CircularProgressIndicator());
            },
            errorBuilder: (context, error, stackTrace) =>
                const Text("Thumbnail not found"),
          ),
      ],
    );
  }
}
