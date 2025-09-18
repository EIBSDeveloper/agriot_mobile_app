// import 'package:flutter/material.dart';
// import 'package:get/get.dart';

// class ConsumptionPurchaseController extends GetxController {
//   // Existing variables
//   RxInt purchasePage = 1.obs;
//   RxInt consumptionPage = 1.obs;
//   RxBool isLoadingMorePurchase = false.obs;
//   RxBool isLoadingMoreConsumption = false.obs;
//   RxBool hasMorePurchase = true.obs;
//   RxBool hasMoreConsumption = true.obs;
  
//   // Scroll controllers for detecting page end
//   ScrollController purchaseScrollController = ScrollController();
//   ScrollController consumptionScrollController = ScrollController();

//   @override
//   void onInit() {
//     super.onInit();
//     // Add scroll listeners
//     purchaseScrollController.addListener(_onPurchaseScroll);
//     consumptionScrollController.addListener(_onConsumptionScroll);
//   }

//   @override
//   void onClose() {
//     purchaseScrollController.dispose();
//     consumptionScrollController.dispose();
//     super.onClose();
//   }

//   void _onPurchaseScroll() {
//     if (purchaseScrollController.position.pixels == 
//         purchaseScrollController.position.maxScrollExtent) {
//       if (hasMorePurchase.value && !isLoadingMorePurchase.value) {
//         loadMorePurchaseData();
//       }
//     }
//   }

//   void _onConsumptionScroll() {
//     if (consumptionScrollController.position.pixels == 
//         consumptionScrollController.position.maxScrollExtent) {
//       if (hasMoreConsumption.value && !isLoadingMoreConsumption.value) {
//         loadMoreConsumptionData();
//       }
//     }
//   }

//   Future<void> loadMorePurchaseData() async {
//     if (isLoadingMorePurchase.value || !hasMorePurchase.value) return;
    
//     isLoadingMorePurchase.value = true;
//     purchasePage.value++;
    
//     try {
//       // Call your API with pagination parameters
//       final newData = await YourApiService.getPurchaseData(
//         page: purchasePage.value,
//         pageSize: 20, // Adjust as needed
//       );
      
//       if (newData.isEmpty) {
//         hasMorePurchase.value = false;
//       } else {
//         purchaseData.addAll(newData);
//       }
//     } catch (e) {
//       purchasePage.value--; // Revert page on error
//       Get.snackbar('Error', 'Failed to load more data');
//     } finally {
//       isLoadingMorePurchase.value = false;
//     }
//   }

//   Future<void> loadMoreConsumptionData() async {
//     if (isLoadingMoreConsumption.value || !hasMoreConsumption.value) return;
    
//     isLoadingMoreConsumption.value = true;
//     consumptionPage.value++;
    
//     try {
//       // Call your API with pagination parameters
//       final newData = await YourApiService.getConsumptionData(
//         page: consumptionPage.value,
//         pageSize: 20, // Adjust as needed
//       );
      
//       if (newData.isEmpty) {
//         hasMoreConsumption.value = false;
//       } else {
//         consumptionData.addAll(newData);
//       }
//     } catch (e) {
//       consumptionPage.value--; // Revert page on error
//       Get.snackbar('Error', 'Failed to load more data');
//     } finally {
//       isLoadingMoreConsumption.value = false;
//     }
//   }

//   Future<void> refreshData() async {
//     // Reset pagination on refresh
//     purchasePage.value = 1;
//     consumptionPage.value = 1;
//     hasMorePurchase.value = true;
//     hasMoreConsumption.value = true;
    
//     // Clear existing data
//     purchaseData.clear();
//     consumptionData.clear();
    
//     // Load fresh data
//     await loadData();
//   }
// }