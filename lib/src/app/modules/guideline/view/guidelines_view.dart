import 'package:argiot/src/app/modules/guideline/model/guideline.dart';
import 'package:argiot/src/app/modules/guideline/controller/guideline_controller.dart';
import 'package:argiot/src/app/controller/app_controller.dart';
import 'package:argiot/src/app/modules/guideline/model/guideline_category.dart';
import 'package:argiot/src/app/modules/near_me/views/widget/widgets.dart';
import 'package:argiot/src/app/widgets/input_card_style.dart';
import 'package:argiot/src/utils.dart';
import 'package:dropdown_button2/dropdown_button2.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';

class GuidelinesView extends GetView<GuidelineController> {
  GuidelinesView({super.key});
  final AppDataController appData = Get.find();
  @override
  Widget build(BuildContext context) => Scaffold(
    appBar: CustomAppBar(title: 'guidelines_title'.tr),
    body: Padding(
      padding: const EdgeInsets.all(10),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          _buildSearchField(),
          const SizedBox(height: 16),
          _buildFilterRow(),
          const SizedBox(height: 16),
          Expanded(
            child: Obx(() {
              if (controller.isLoading.value) {
                return const Center(child: CircularProgressIndicator());
              }

              if (controller.filteredGuidelines.isEmpty) {
                return Center(child: Text('no_guidelines_found'.tr));
              }

              return ListView.builder(
                itemCount: controller.filteredGuidelines.length,
                itemBuilder: (context, index) {
                  final guideline = controller.filteredGuidelines[index];
                  return _buildGuidelineCard(guideline);
                },
              );
            }),
          ),
        ],
      ),
    ),
  );

  Widget _buildSearchField() => InputCardStyle(
    child: TextField(
      decoration: InputDecoration(
        hintText: 'search_placeholder'.tr,
        prefixIcon: const Icon(Icons.search),
        border: InputBorder.none,
        contentPadding: const EdgeInsets.symmetric(vertical: 12),
      ),
      onChanged: (value) => controller.searchGuidelines(value),
    ),
  );

  Widget _buildFilterRow() => Row(
    children: [
      // Expanded(child: Obx(() => _buildCropDropdown())),
      Expanded(
        child: Obx(
          () => InputCardStyle(
            child: DropdownButtonFormField2<GuidelineCategory>(
              isExpanded: true,
              decoration: const InputDecoration(
                border: InputBorder.none, // Removes underline
                enabledBorder:
                    InputBorder.none, // Removes underline when enabled
                focusedBorder:
                    InputBorder.none, // Removes underline when focused
                contentPadding:
                    EdgeInsets.zero, // Optional: adjust vertical space
              ),
              hint: Text('select_category'.tr),

              value: controller.selectedCategory.value,
              items: controller.categories
                  .map(
                    (category) => DropdownMenuItem<GuidelineCategory>(
                      value: category,
                      child: Text(
                        category.name,
                        style: Get.textTheme.bodyMedium,
                      ),
                    ),
                  )
                  .toList(),
              onChanged: (value) => controller.filterByCategory(value),
              buttonStyleData: const ButtonStyleData(
                padding: EdgeInsets.only(right: 8),
              ),
              iconStyleData: const IconStyleData(
                icon: Icon(Icons.keyboard_arrow_down),
              ),
              dropdownStyleData: const DropdownStyleData(
                decoration: BoxDecoration(
                  border: Border.fromBorderSide(BorderSide.none),
                ),
              ),
            ),
          ),
        ),
      ),
    ],
  );

  // Widget _buildCategoryDropdown() =>;

  Widget _buildGuidelineCard(Guideline guideline) => Card(
    elevation: 1,
    margin: const EdgeInsets.only(bottom: 8),
    child: InkWell(
      onTap: () => _handleGuidelineTap(guideline),
      child: Padding(
        padding: const EdgeInsets.all(8),
        child: Row(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            _buildThumbnail(guideline),
            const SizedBox(width: 12),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    guideline.name,
                    style: Get.textTheme.titleMedium?.copyWith(
                      color: Colors.green,
                      fontWeight: FontWeight.bold,
                    ),
                    maxLines: 2,
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

  Widget _buildThumbnail(Guideline guideline) {
    final String? youtubeThumbnailUrl = getYoutubeThumbnailUrl(
      getYoutubeVideoId(guideline.videoUrl),
    );
    return Stack(
      alignment: Alignment.center,
      children: [
        Container(
          width: 80,
          height: 80,
          decoration: BoxDecoration(
            color: Colors.grey[200],
            borderRadius: BorderRadius.circular(8),
          ),
          child: guideline.mediaType == 'video'
              ? const Icon(Icons.videocam, size: 40, color: Colors.grey)
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
                  errorBuilder: (context, error, stackTrace) => const Icon(
                    Icons.insert_drive_file,
                    size: 40,
                    color: Colors.grey,
                  ),
                ),
        ),
        if (guideline.mediaType == 'video' && youtubeThumbnailUrl == null)
          const Icon(Icons.play_circle_fill, size: 40, color: Colors.white),
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

  String? getYoutubeVideoId(String? url) {
    if (url == null) {
      return null;
    }
    final RegExp regExp = RegExp(r"(?:v=|\/)([0-9A-Za-z_-]{11})(?:\?|\&|$)");
    final match = regExp.firstMatch(url);
    return match?.group(1);
  }

  String? getYoutubeThumbnailUrl(
    String? videoId, {
    String quality = 'hqdefault',
  }) {
    if (videoId == null) {
      return null;
    }
    return 'https://img.youtube.com/vi/$videoId/$quality.jpg';
  }

  void _handleGuidelineTap(Guideline guideline) {
    if (guideline.mediaType == 'video' && guideline.videoUrl != null) {
      // Open video player
      // Get.toNamed('/video-player', arguments: guideline.videoUrl);
      openUrl(Uri.parse(guideline.videoUrl!));
    } else if (guideline.mediaType == 'document' &&
        guideline.document != null) {
      // Open document viewer
      Get.toNamed('/document-viewer', arguments: guideline.document);
    } else {
      showError('Unable to open guideline content');
    }
  }
}
