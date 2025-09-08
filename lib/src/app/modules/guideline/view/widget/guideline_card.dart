import 'package:argiot/src/app/modules/guideline/model/guideline.dart';
import 'package:argiot/src/app/modules/guideline/view/widget/guideline_thunbnail.dart';
import 'package:argiot/src/app/service/utils/utils.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';

class GuidelineCard extends StatelessWidget {
final  Guideline guideline;
  const GuidelineCard({
    super.key , required this.guideline
  });

  @override
  Widget build(BuildContext context) => Card(
      elevation: 1,
      margin: const EdgeInsets.only(bottom: 8),
      child: InkWell(
        onTap: () => handleGuidelineTap(guideline),
        child: Padding(
          padding: const EdgeInsets.all(8),
          child: Row(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              GuidelineThunbnail(guideline: guideline),
              const SizedBox(width: 12),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      guideline.name,
                      style: Get.textTheme.titleMedium?.copyWith(
                        color: Get.theme.primaryColor,
                        fontWeight: FontWeight.bold,
                      ),
                      maxLines: 1,
                      overflow: TextOverflow.ellipsis,
                    ),
                    const SizedBox(height: 4),
                    Text(
                      guideline.description,
                      style: Get.textTheme.bodySmall?.copyWith(),
                      maxLines: 2,
                      overflow: TextOverflow.ellipsis,
                    ),
                  ],
                ),
              ),
            ],
          ),
        ),
      ),
    );
}
