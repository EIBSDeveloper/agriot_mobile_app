import 'package:argiot/src/app/modules/payouts/model/payoutmodel.dart';
import 'package:argiot/src/app/modules/payouts/repository/payout_repository.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';

import '../../../service/utils/pop_messages.dart';

class PayoutAddController extends GetxController {
  final PayoutRepository repository = Get.find();
  TextEditingController searchController = TextEditingController();
  RxString searchQuery = ''.obs;
  var page = 1.obs;
  var hasMore = true.obs;

  var advancelist = <PayoutModel>[].obs;
  var isLoading = false.obs;

  // Deduction controllers mapped by index
  final Map<int, TextEditingController> deductionControllers = {};
  final Map<int, TextEditingController> payoutControllers = {};
  // Map of deduction colors per index
  var deductionColors = <int, Rx<Color>>{}.obs;

  @override
  void onInit() {
    super.onInit();
    loadadvancelist();
  }

  Future<void> loadadvancelist({bool reset = false}) async {
    if (reset) {
      page.value = 1;
      hasMore.value = true;
      advancelist.clear(); // clear old list
      deductionControllers.clear(); // clear old controllers
      payoutControllers.clear(); // clear old controllers
      deductionColors.clear();
    }

    if (!hasMore.value) return;

    isLoading.value = true;
    try {
      final fetched = await repository.fetchAdvanceList(
        page: page.value,
        search: searchQuery.value, // pass search query
      );

      if (fetched.isNotEmpty) {
        // Add only unique employees to avoid duplicates
        for (var emp in fetched) {
          if (!advancelist.any((e) => e.id == emp.id)) {
            advancelist.add(emp);
          }
        }

        // Initialize controllers for new items
        for (int idx = 0; idx < advancelist.length; idx++) {
          if (!deductionControllers.containsKey(idx)) {
            deductionControllers[idx] = TextEditingController(
              text: (advancelist[idx].deductionAdvance ?? '').toString(),
            );
            deductionColors[idx] = Colors.black54.obs;
          }
          if (!payoutControllers.containsKey(idx)) {
            payoutControllers[idx] = TextEditingController(
              text: (advancelist[idx].payoutAmount ?? '').toString(),
            );
          }
        }
      }

      if (fetched.length < 20) hasMore.value = false;
      page.value += 1;
    } catch (e) {
      debugPrint("⚠️ Error loading payouts: $e");
    } finally {
      isLoading.value = false;
    }
  }

  void onSearchChanged(String query) {
    searchQuery.value = query.toLowerCase();
    loadadvancelist(reset: true);
  }

  Future<void> addPayouts() async {
    final employeeList = advancelist
        .where((e) => e.isEdited == true)
        .map((e) => e.toJson())
        .toList(); // call toJson()

    bool success = await repository.addPayouts(employees: employeeList);

    if (success) {
      Get.back();
      showSuccess('Attendence Added successfully');
      await loadadvancelist(); // refresh list
    } else {
      showError('Failed to submit');
    }
  }
}
