// controllers/near_me_controller.dart
import 'package:flutter/material.dart';
import 'package:get/get.dart' hide Worker;

import '../model/models.dart';
import '../repostory/near_me_repository.dart';

// controllers/near_me_controller.dart
// ignore: deprecated_member_use
class NearMeController extends GetxController
    with SingleGetTickerProviderMixin {
  final NearMeRepository _repository = Get.find();
  // Add TabController
  late TabController tabController;
  // Reactive variables
  var isLoading = false.obs;
  var selectedLand = Land(id: 0, name: '').obs;
  var lands = <Land>[].obs;

  // Market
  var markets = <Market>[].obs;
  var marketCount = 0.obs;
  var filteredMarkets = <Market>[].obs;

  // Places
  var placeCategories = <PlaceCategory>[].obs;
  var filteredPlaceCategories = <PlaceCategory>[].obs;

  // Man Power
  var manPowerAgents = <ManPowerAgent>[].obs;
  var filteredManPowerAgents = <ManPowerAgent>[].obs;
  var workers = <Worker>[].obs;
  var filteredWorkers = <Worker>[].obs;

  // Rental
  var rentalItems = <RentalItem>[].obs;
  var filteredRentalItems = <RentalItem>[].obs;
  var rentalDetails = <RentalDetail>[].obs;
  var filteredRentalDetails = <RentalDetail>[].obs;

  // Tab index
  var currentTabIndex = 0.obs;

  @override
  void onInit() {
    super.onInit(); // Initialize TabController with 4 tabs
    tabController = TabController(
      length: 4,
      vsync: this,
      initialIndex: currentTabIndex.value,
    );

    // Sync the Rx value with tab controller
    tabController.addListener(() {
      currentTabIndex.value = tabController.index;
    });

    fetchLands();
  }

  void changeTabIndex(int index) {
    currentTabIndex.value = index;
    tabController.animateTo(index);
  }

  @override
  void onClose() {
    tabController.dispose();
    super.onClose();
  }

  Future<void> fetchLands() async {
    try {
      isLoading(true);
      final landList = await _repository.getLands();
      lands.assignAll(landList.lands);
      if (lands.isNotEmpty) {
        selectedLand.value = lands.first;
        fetchAllData(lands.first.id);
      }
    } finally {
      isLoading(false);
    }
  }

  Future<void> fetchAllData(int landId) async {
    await Future.wait([
      fetchMarkets(landId),
      fetchPlaceDetails(landId),
      fetchManPower(landId),
      fetchRentals(landId),
    ]);
  }

  Future<void> fetchMarkets(int landId) async {
    try {
      isLoading(true);
      final response = await _repository.getNearbyMarkets(landId);
      markets.assignAll(response.markets);
      marketCount.value = response.marketCount;
      filteredMarkets.assignAll(markets);
    } finally {
      isLoading(false);
    }
  }

  Future<void> fetchPlaceDetails(int landId) async {
    try {
      isLoading(true);
      final categories = await _repository.getPlaceDetails(landId);
      placeCategories.assignAll(categories);
      filteredPlaceCategories.assignAll(placeCategories);
    } finally {
      isLoading(false);
    }
  }

  Future<void> fetchManPower(int landId) async {
    try {
      isLoading(true);
      final agents = await _repository.getNearbyManPower(landId);
      manPowerAgents.assignAll(agents);
      filteredManPowerAgents.assignAll(manPowerAgents);
      // Extract all workers
      workers.assignAll(agents.expand((agent) => agent.workers).toList());
      filteredWorkers.assignAll(workers);
    } finally {
      isLoading(false);
    }
  }

  Future<void> fetchRentals(int landId) async {
    try {
      isLoading(true);
      // final rentals = await _repository.getNearbyRentals(landId);
      // rentalItems.assignAll(rentals);
      // filteredRentalItems.assignAll(rentalItems);
      // // Extract all rental details
      // rentalDetails.assignAll(rentals.expand((item) => item.details).toList());
      // filteredRentalDetails.assignAll(rentalDetails);
    } finally {
      isLoading(false);
    }
  }

  void filterMarkets(String query) {
    if (query.isEmpty) {
      filteredMarkets.assignAll(markets);
    } else {
      filteredMarkets.assignAll(
        markets.where(
          (market) =>
              market.name.toLowerCase().contains(query.toLowerCase()) ||
              market.address.toLowerCase().contains(query.toLowerCase()),
        ),
      );
    }
  }

  void filterPlaceCategories(String query) {
    if (query.isEmpty) {
      filteredPlaceCategories.assignAll(placeCategories);
    } else {
      filteredPlaceCategories.assignAll(
        placeCategories.where(
          (category) =>
              category.categoryName.toLowerCase().contains(query.toLowerCase()),
        ),
      );
    }
  }

  void filterPlaceDetails(String query) {
    if (query.isEmpty) {
      filteredPlaceCategories.assignAll(placeCategories);
    } else {
      var filteredCategories = placeCategories.map((category) {
        var filteredDetails = category.details
            .where(
              (detail) =>
                  detail.name.toLowerCase().contains(query.toLowerCase()) ||
                  detail.address.toLowerCase().contains(query.toLowerCase()),
            )
            .toList();
        return PlaceCategory(
          categoryName: category.categoryName,
          count: filteredDetails.length,
          details: filteredDetails,
        );
      }).toList();
      filteredPlaceCategories.assignAll(filteredCategories);
    }
  }

  void filterManPowerAgents(String query) {
    if (query.isEmpty) {
      filteredManPowerAgents.assignAll(manPowerAgents);
    } else {
      filteredManPowerAgents.assignAll(
        manPowerAgents.where(
          (agent) =>
              agent.name.toLowerCase().contains(query.toLowerCase()) ||
              agent.taluk.toLowerCase().contains(query.toLowerCase()) ||
              agent.mobileNo.toString().contains(query),
        ),
      );
    }
  }

  void filterWorkers(String query) {
    if (query.isEmpty) {
      filteredWorkers.assignAll(workers);
    } else {
      filteredWorkers.assignAll(
        workers.where(
          (worker) =>
              worker.workerName.toLowerCase().contains(query.toLowerCase()) ||
              worker.workerMobile.toString().contains(query),
        ),
      );
    }
  }

  void filterRentalItems(String query) {
    if (query.isEmpty) {
      filteredRentalItems.assignAll(rentalItems);
    } else {
      filteredRentalItems.assignAll(
        rentalItems.where(
          (item) => item.inventoryItemName.toLowerCase().contains(
            query.toLowerCase(),
          ),
        ),
      );
    }
  }

  void filterRentalDetails(String query) {
    if (query.isEmpty) {
      filteredRentalDetails.assignAll(rentalDetails);
    } else {
      filteredRentalDetails.assignAll(
        rentalDetails.where(
          (detail) =>
              detail.inventoryItemName.toLowerCase().contains(
                query.toLowerCase(),
              ) ||
              detail.vendorName.toLowerCase().contains(query.toLowerCase()),
        ),
      );
    }
  }

  // void changeTabIndex(int index) {
  //   currentTabIndex.value = index;
  // }

  void changeLand(Land land) {
    selectedLand.value = land;
    fetchAllData(land.id);
  }
}
