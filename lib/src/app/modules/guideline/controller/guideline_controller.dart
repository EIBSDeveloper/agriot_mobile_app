import 'package:argiot/src/app/modules/forming/model/crop.dart';
import 'package:argiot/src/app/modules/guideline/model/guideline.dart';

import 'package:argiot/src/app/modules/guideline/model/guideline_category.dart';
import 'package:argiot/src/app/service/utils/pop_messages.dart';

import 'package:get/get.dart';

import '../repository/guideline_repository.dart';

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

      categories.assignAll([
        GuidelineCategory(id: 0, name: "All"),
        ...categoriesList,
      ]);
    } catch (e) {
      showError('Failed to load data');
    } finally {
      isLoading(false);
    }
  }

  Future<void> searchGuidelines(String query) async {
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

    if (selectedCategory.value != null && selectedCategory.value!.id != 0) {
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
