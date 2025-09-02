import 'dart:convert';
import 'package:argiot/src/app/utils/http/http_service.dart';
import 'package:dropdown_button2/dropdown_button2.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';

import 'src/app/widgets/input_card_style.dart';
import 'src/utils.dart';

class Guideline {
  final int id;
  final String name;
  final String guidelinestype;
  final GuidelineCategory? guidelinescategory;
  final Crop? crop;
  final String description;
  final int status;
  final String? videoUrl;
  final String? document;
  final String mediaType;
  final DateTime? createdAt;
  final DateTime? updatedAt;

  Guideline({
    required this.id,
    required this.name,
    required this.guidelinestype,
    required this.guidelinescategory,
    this.crop,
    required this.description,
    required this.status,
    this.videoUrl,
    this.document,
    required this.mediaType,
    this.createdAt,
    this.updatedAt,
  });

  factory Guideline.fromJson(Map<String, dynamic> json) {
    return Guideline(
      id: json['id'],
      name: json['name'],
      guidelinestype: json['guidelinestype'],
      guidelinescategory: GuidelineCategory.fromJson(
        json['guidelinescategory'],
      ),
      crop: json['crop'] != null ? Crop.fromJson(json['crop']) : null,
      description: json['description'],
      status: json['status'],
      videoUrl: json['video_url'],
      document: json['document'],
      mediaType: json['media_type'],
      createdAt: json['created_at'] != null
          ? DateTime.parse(json['created_at'])
          : null,
      updatedAt: json['updated_at'] != null
          ? DateTime.parse(json['updated_at'])
          : null,
    );
  }
}

class GuidelineCategory {
  final int id;
  final String name;
  final String? description;

  GuidelineCategory({required this.id, required this.name, this.description});

  factory GuidelineCategory.fromJson(Map<String, dynamic> json) {
    return GuidelineCategory(
      id: json['id'],
      name: json['name'],
      description: json['description'],
    );
  }
}

class Crop {
  final int id;
  final String name;

  Crop({required this.id, required this.name});

  factory Crop.fromJson(Map<String, dynamic> json) {
    return Crop(id: json['id'], name: json['name']);
  }
}

// lib/app/modules/guidelines/repositories/guideline_repository.dart

class GuidelineRepository {
  final HttpService _httpService = Get.put(HttpService());

  Future<List<Guideline>> getGuidelinesList(int guidelinestypeId) async {
    try {
      final response = await _httpService.post('/get_guidelines_list', {
        'guidelinestype_id': guidelinestypeId,
      });

      if (response.statusCode == 200) {
        var body = jsonDecode(response.body);
        return (body as List).map((item) => Guideline.fromJson(item)).toList();
      }
      throw Exception('Failed to load guidelines list');
    } catch (e) {
      throw Exception('Error: $e');
    }
  }

  Future<List<Guideline>> searchGuidelines(String query) async {
    try {
      final response = await _httpService.post('/guidelines_filter', {
        'filter': query,
      });

      // For http package Response
      final responseBody = jsonDecode(response.body);

      if (response.statusCode == 200) {
        return (responseBody as List)
            .map((item) => Guideline.fromJson(item))
            .toList();
      } else {
        throw Exception('Failed to search guidelines: ${response.statusCode}');
      }
    } catch (e) {
      throw Exception('Error searching guidelines: $e');
    }
  }

  Future<List<GuidelineCategory>> getGuidelineCategories() async {
    try {
      final response = await _httpService.get('/guidelines_categories');

      if (response.statusCode == 200) {
        var body = jsonDecode(response.body)['data'];
        return (body as List)
            .map((item) => GuidelineCategory.fromJson(item))
            .toList();
      }
      throw Exception('Failed to load guideline categories');
    } catch (e) {
      throw Exception('Error: $e');
    }
  }
}
// lib/app/modules/guidelines/controllers/guideline_controller.dart

class GuidelineController extends GetxController {
  final GuidelineRepository _repository = GuidelineRepository();

  var isLoading = false.obs;
  var guidelines = <Guideline>[].obs;
  var filteredGuidelines = <Guideline>[].obs;
  var searchQuery = ''.obs;
  var selectedCrop = Rxn<Crop>();
  var selectedCategory = Rxn<GuidelineCategory>();
  var categories = <GuidelineCategory>[].obs;
  var crops = <Crop>[].obs;

  @override
  void onInit() {
    super.onInit();
    loadInitialData();
  }

  Future<void> loadInitialData() async {
    isLoading(true);
    try {
      // Load initial guidelines (type_id 2 as per your API example)
      final guidelinesList = await _repository.getGuidelinesList(2);
      guidelines.assignAll(guidelinesList);
      filteredGuidelines.assignAll(guidelinesList);

      // Extract unique crops from guidelines
      final uniqueCrops = guidelines
          .where((g) => g.crop != null)
          .map((g) => g.crop!)
          .toSet()
          .toList();
      crops.assignAll(uniqueCrops);

      // Load categories
      final categoriesList = await _repository.getGuidelineCategories();
      categories.assignAll(categoriesList);
    } catch (e) {
      showError('Failed to load data');
    } finally {
      isLoading(false);
    }
  }

  void searchGuidelines(String query) async {
    searchQuery.value = query;

    // Clear filters when searching
    selectedCrop.value = null;
    selectedCategory.value = null;

    if (query.isEmpty) {
      filteredGuidelines.assignAll(guidelines);
      return;
    }

    isLoading(true);
    try {
      final results = await _repository.searchGuidelines(query);
      filteredGuidelines.assignAll(results);
    } catch (e) {
      showError('Search failed');
    } finally {
      isLoading(false);
    }
  }

  void filterByCrop(Crop? crop) {
    selectedCrop.value = crop;
    // Clear search when applying filters
    searchQuery.value = '';
    _applyFilters();
  }

  void filterByCategory(GuidelineCategory? category) {
    selectedCategory.value = category;
    // Clear search when applying filters
    searchQuery.value = '';
    _applyFilters();
  }

  void _applyFilters() {
    var results = guidelines.toList();

    if (selectedCrop.value != null) {
      results = results
          .where((g) => g.crop?.id == selectedCrop.value?.id)
          .toList();
    }

    if (selectedCategory.value != null) {
      results = results
          .where((g) => g.guidelinescategory!.id == selectedCategory.value?.id)
          .toList();
    }

    filteredGuidelines.assignAll(results);
  }

  void clearFilters() {
    selectedCrop.value = null;
    selectedCategory.value = null;
    searchQuery.value = '';
    filteredGuidelines.assignAll(guidelines);
  }
}

// lib/app/modules/guidelines/views/guidelines_view.dart

class GuidelinesView extends GetView<GuidelineController> {
  const GuidelinesView({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        leading: IconButton(
          icon: const Icon(Icons.arrow_back),
          onPressed: () => Get.back(),
        ),
        title: Text('guidelines_title'.tr),
        // actions: [
        //   IconButton(icon: const Icon(Icons.notifications), onPressed: () {}),
        // ],
      ),
      body: Padding(
        padding: const EdgeInsets.all(16.0),
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
  }

  Widget _buildSearchField() {
    return   InputCardStyle(
         
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
  }

  Widget _buildFilterRow() {
    return Row(
      children: [
        // Expanded(child: Obx(() => _buildCropDropdown())),
     
        Expanded(child: Obx(() => _buildCategoryDropdown())),
      ],
    );
  }


  Widget _buildCategoryDropdown() {
    return   InputCardStyle(
         
      child: DropdownButtonFormField2<GuidelineCategory>(
        isExpanded: true,
        decoration: const InputDecoration(
          border: InputBorder.none, // Removes underline
          enabledBorder: InputBorder.none, // Removes underline when enabled
          focusedBorder: InputBorder.none, // Removes underline when focused
          contentPadding: EdgeInsets.zero, // Optional: adjust vertical space
        ),
        hint: Text('select_category'.tr),
        value: controller.selectedCategory.value,
        items: controller.categories
            .map(
              (category) => DropdownMenuItem<GuidelineCategory>(
                value: category,
                child: Text(category.name, style: Get.textTheme.bodyMedium),
              ),
            )
            .toList(),
        onChanged: (value) => controller.filterByCategory(value),
        buttonStyleData: const ButtonStyleData(
          padding: EdgeInsets.only(right: 8),
        ),
        iconStyleData: const IconStyleData(
          icon: Icon(Icons.keyboard_arrow_down),
          iconSize: 24,
        ),
        dropdownStyleData: DropdownStyleData(
          decoration: BoxDecoration(
            border: Border.fromBorderSide(BorderSide.none),
          ),
        ),
      ),
    );
  }

  Widget _buildGuidelineCard(Guideline guideline) {
    return Card(
      elevation: 1,
      margin: const EdgeInsets.only(bottom: 16),
      child: InkWell(
        onTap: () => _handleGuidelineTap(guideline),
        child: Padding(
          padding: const EdgeInsets.all(12),
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
                      style: Get.textTheme.bodySmall?.copyWith(
                        color: Colors.grey,
                      ),
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

  Widget _buildThumbnail(Guideline guideline) {
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
              : const Icon(
                  Icons.insert_drive_file,
                  size: 40,
                  color: Colors.grey,
                ),
        ),
        if (guideline.mediaType == 'video')
          const Icon(Icons.play_circle_fill, size: 40, color: Colors.white),
      ],
    );
  }

  void _handleGuidelineTap(Guideline guideline) {
    if (guideline.mediaType == 'video' && guideline.videoUrl != null) {
      // Open video player
      Get.toNamed('/video-player', arguments: guideline.videoUrl);
    } else if (guideline.mediaType == 'document' &&
        guideline.document != null) {
      // Open document viewer
      Get.toNamed('/document-viewer', arguments: guideline.document);
    } else {
      showError('Unable to open guideline content');
    }
  }
}

class GuidelineBinding implements Bindings {
  @override
  void dependencies() {
    Get.lazyPut<GuidelineController>(
      () => GuidelineController(),
      fenix: true, // Allows recreation if needed
    );
  }
}
