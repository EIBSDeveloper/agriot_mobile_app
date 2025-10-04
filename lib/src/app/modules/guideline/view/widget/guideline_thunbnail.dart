import 'package:argiot/src/app/controller/app_controller.dart';
import 'package:argiot/src/app/modules/guideline/model/guideline.dart';
import 'package:argiot/src/app/service/utils/utils.dart';
import 'package:argiot/src/app/widgets/my_network_image.dart';
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
              : MyNetworkImage(
                  "${appData.imageBaseUrl.value}${guideline.document}",
                  fit: BoxFit.cover,
                  height: 60,
                  width: 60,
                
                ),
        ),
       
         
        if (youtubeThumbnailUrl != null && guideline.mediaType == 'video')
         MyNetworkImage(
            youtubeThumbnailUrl,
            fit: BoxFit.cover,
            height: 60,
            width: 60,
          ),
      ],
    );
  }
}
