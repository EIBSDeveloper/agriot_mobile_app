import 'package:argiot/src/app/modules/near_me/views/widget/count_card.dart';
import 'package:argiot/src/app/modules/near_me/views/widget/custom_app_bar.dart';
import 'package:argiot/src/app/modules/near_me/views/widget/custom_search_bar.dart';
import 'package:argiot/src/app/modules/near_me/views/widget/land_dropdown.dart';
import 'package:argiot/src/app/modules/near_me/views/widget/man_power_agent_card.dart';
import 'package:argiot/src/app/modules/near_me/views/widget/market_card.dart';
import 'package:argiot/src/app/modules/near_me/views/widget/place_detail_card.dart';
import 'package:argiot/src/app/modules/near_me/views/widget/rental_detail_card.dart';
import 'package:argiot/src/app/modules/near_me/views/widget/worker_card.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart' hide Worker;

import '../../../../routes/app_routes.dart';
import '../../../../widgets/loading.dart';
import '../../controller/controllers.dart';
import '../../model/models.dart';

class NearMeScreen extends StatelessWidget {
  final NearMeController controller = Get.find();

  NearMeScreen({super.key});

  @override
  Widget build(BuildContext context) => Scaffold(
    appBar: CustomAppBar(title: 'near_me_places'.tr, showBackButton: true),
    body: Column(
      children: [
        Padding(
          padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
          child: Row(
            children: [
              // Expanded(child: Text("Near me")),
              Expanded(
                child: Obx(
                  () => LandDropdown(
                    lands: controller.lands,
                    selectedLand: controller.selectedLand.value,
                    onChanged: (land) => controller.changeLand(land!),
                  ),
                ),
              ),
            ],
          ),
        ),
        // SizedBox(height: 8),
        _buildTabBar(),
        Expanded(child: _buildTabView()),
      ],
    ),
  );

  Widget _buildTabBar() => TabBar(
    controller: controller.tabController,
    onTap: controller.changeTabIndex,
    tabs: [
      Tab(text: 'place'.tr),
      Tab(text: 'man_power'.tr),
      Tab(text: 'rental'.tr),
    ],
    labelColor: Get.theme.primaryColor,
    unselectedLabelColor: Colors.grey,
    indicatorColor: Get.theme.primaryColor,
  );

  Widget _buildTabView() => Obx(() {
    switch (controller.currentTabIndex.value) {
      case 0:
        return PlaceTab();
      case 1:
        return ManPowerTab();
      case 2:
        return RentalTab();
      default:
        return PlaceTab();
    }
  });
}
//
// screens/market_list_screen.dart

class MarketListScreen extends StatelessWidget {
  final NearMeController controller = Get.find();
  final List<Market> markets = Get.arguments['markets'];

  MarketListScreen({super.key});

  @override
  Widget build(BuildContext context) => Scaffold(
    appBar: CustomAppBar(title: 'markets'.tr, showBackButton: true),
    body: Column(
      children: [
        Padding(
          padding: const EdgeInsets.all(16),
          child: CustomSearchBar(
            labelText: 'search_market_name_or_place'.tr,
            onChanged: (query) => controller.filterMarkets(query),
          ),
        ),
        Expanded(
          child: Obx(
            () => ListView.builder(
              // padding: EdgeInsets.symmetric(horizontal: 16),
              itemCount: controller.filteredMarkets.length,
              itemBuilder: (context, index) {
                final market = controller.filteredMarkets[index];
                return MarketCard(market: market);
              },
            ),
          ),
        ),
      ],
    ),
  );
}
// screens/near_me/widgets/place_tab.dart

class PlaceTab extends StatelessWidget {
  final NearMeController controller = Get.find();

  PlaceTab({super.key});

  @override
  Widget build(BuildContext context) => Obx(() {
    if (controller.isLoading.value) {
      return const Loading();
    }

    if (controller.placeCategories.isEmpty) {
      return Center(child: Text('no_places_available'.tr));
    }

    return Column(
      children: [
        CountCard(
          title: "market".tr,
          count: controller.marketCount.value,
          onTap: () => Get.toNamed(
            Routes.marketList,
            arguments: {'markets': controller.markets},
          ),
        ),
        Expanded(
          child: ListView.builder(
            itemCount: controller.placeCategories.length,
            itemBuilder: (context, index) {
              final category = controller.placeCategories[index];
              return CountCard(
                title: category.categoryName,
                count: category.count,
                onTap: () => Get.toNamed(
                  Routes.placeDetailsList,
                  arguments: {'category': category},
                ),
              );
            },
          ),
        ),
      ],
    );
  });
}

// screens/place_details_list_screen.dart

class PlaceDetailsListScreen extends StatelessWidget {
  final NearMeController controller = Get.find();
  final PlaceCategory category = Get.arguments['category'];

  PlaceDetailsListScreen({super.key});

  @override
  Widget build(BuildContext context) => Scaffold(
    appBar: CustomAppBar(title: category.categoryName, showBackButton: true),
    body: Column(
      children: [
        Padding(
          padding: const EdgeInsets.all(16),
          child: CustomSearchBar(
            labelText: 'search_name_or_address'.tr,
            onChanged: (query) => controller.filterPlaceDetails(query),
          ),
        ),
        Expanded(
          child: Obx(() {
            // Find the category in filtered list
            final filteredCategory = controller.filteredPlaceCategories
                .firstWhere(
                  (cat) => cat.categoryName == category.categoryName,
                  orElse: () => PlaceCategory(
                    categoryName: category.categoryName,
                    count: 0,
                    details: [],
                  ),
                );

            return ListView.builder(
              padding: const EdgeInsets.symmetric(horizontal: 16),
              itemCount: filteredCategory.details.length,
              itemBuilder: (context, index) {
                final detail = filteredCategory.details[index];
                return PlaceDetailCard(detail: detail);
              },
            );
          }),
        ),
      ],
    ),
  );
}

// screens/near_me/widgets/man_power_tab.dart

class ManPowerTab extends StatelessWidget {
  final NearMeController controller = Get.find();

  ManPowerTab({super.key});

  @override
  Widget build(BuildContext context) => Obx(() {
    if (controller.isLoading.value) {
      return const Loading();
    }

    if (controller.manPowerAgents.isEmpty) {
      return Center(child: Text('no_man_power_agents_available'.tr));
    }

    return ListView.builder(
      padding: const EdgeInsets.all(16),
      itemCount: controller.manPowerAgents.length,
      itemBuilder: (context, index) {
        final agent = controller.manPowerAgents[index];
        return ManPowerAgentCard(
          agent: agent,
          onTap: () =>
              Get.toNamed(Routes.workersList, arguments: {'agent': agent}),
        );
      },
    );
  });
}

// screens/workers_list_screen.dart
class WorkersListScreen extends StatelessWidget {
  final NearMeController controller = Get.find();
  final ManPowerAgent agent = Get.arguments['agent'];

  WorkersListScreen({super.key});

  @override
  Widget build(BuildContext context) => Scaffold(
    backgroundColor: Colors.grey[100],
    appBar: CustomAppBar(
      title: "${'workers_agent'.tr} ${agent.name}",
      showBackButton: true,
    ),
    body: Column(
      children: [
        /// Top header section (optional)
        Container(
          width: double.infinity,
          padding: const EdgeInsets.all(16),
          decoration: const BoxDecoration(
            color: Colors.white,
            boxShadow: [
              BoxShadow(
                color: Colors.black12,
                blurRadius: 6,
                offset: Offset(0, 3),
              ),
            ],
            borderRadius: BorderRadius.only(
              bottomLeft: Radius.circular(16),
              bottomRight: Radius.circular(16),
            ),
          ),
          child: Row(
            children: [
              Icon(Icons.groups, color: Theme.of(context).primaryColor),
              const SizedBox(width: 10),
              Text(
                "available_workers".tr,
                style: Theme.of(
                  context,
                ).textTheme.titleMedium!.copyWith(fontWeight: FontWeight.bold),
              ),
            ],
          ),
        ),

        const SizedBox(height: 8),

        /// Workers list
        Expanded(
          child: Obx(() {
            if (controller.filteredWorkers.isEmpty) {
              return Center(
                child: Column(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    Icon(Icons.work_off, size: 80, color: Colors.grey.shade400),
                    const SizedBox(height: 10),
                    Text(
                      "no_workers_found".tr,
                      style: TextStyle(
                        color: Colors.grey.shade600,
                        fontSize: 16,
                      ),
                    ),
                  ],
                ),
              );
            }

            return ListView.separated(
              padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
              itemCount: controller.filteredWorkers.length,
              separatorBuilder: (_, __) => const SizedBox(height: 12),
              itemBuilder: (context, index) {
                final worker = controller.filteredWorkers[index];
                return WorkerCard(worker: worker);
              },
            );
          }),
        ),
      ],
    ),
  );
}

// screens/near_me/widgets/rental_tab.dart
class RentalTab extends StatelessWidget {
  final NearMeController controller = Get.find();

  RentalTab({super.key});

  @override
  Widget build(BuildContext context) => Obx(() {
    if (controller.isLoading.value) {
      return const Loading();
    }

    if (controller.rentalItems.isEmpty) {
      return Center(child: Text('no_rental_items_available'.tr));
    }

    return ListView.builder(
      itemCount: controller.rentalItems.length,
      itemBuilder: (context, index) {
        final item = controller.rentalItems[index];
        return CountCard(
          title: item.inventoryItemName,
          count: item.count,
          onTap: () =>
              Get.toNamed(Routes.rentalDetailsList, arguments: {'item': item}),
        );
      },
    );
  });
}

// screens/rental_details_list_screen.dart

class RentalDetailsListScreen extends StatelessWidget {
  final NearMeController controller = Get.find();
  final RentalItem item = Get.arguments['item'];

  RentalDetailsListScreen({super.key});

  @override
  Widget build(BuildContext context) => Scaffold(
    appBar: CustomAppBar(title: item.inventoryItemName, showBackButton: true),
    body: Column(
      children: [
        Padding(
          padding: const EdgeInsets.all(16),
          child: CustomSearchBar(
            labelText: 'search_item_name'.tr,
            onChanged: (query) => controller.filterRentalDetails(query),
          ),
        ),
        Expanded(
          child: Obx(
            () => ListView.builder(
              padding: const EdgeInsets.symmetric(horizontal: 16),
              itemCount: controller.filteredRentalDetails.length,
              itemBuilder: (context, index) {
                final detail = controller.filteredRentalDetails[index];
                return RentalDetailCard(detail: detail);
              },
            ),
          ),
        ),
      ],
    ),
  );
}
