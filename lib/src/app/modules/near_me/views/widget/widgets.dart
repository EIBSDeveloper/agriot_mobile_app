// widgets/search_bar.dart
import 'package:argiot/src/app/widgets/my_network_image.dart';
import 'package:argiot/src/core/app_style.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart' hide Worker;
// widgets/land_dropdown.dart
import '../../../../widgets/input_card_style.dart';
import '../../model/models.dart';

class LandDropdown extends StatelessWidget {
  final List<Land> lands;
  final Land selectedLand;
  final Color? color;
  final Function(Land?) onChanged;

  const LandDropdown({
    super.key,
    required this.lands,
    this.color,
    required this.selectedLand,
    required this.onChanged,
  });

  @override
  Widget build(BuildContext context) {
    return InputCardStyle(
     
      child: DropdownButtonFormField<Land>(
        value: selectedLand,
        items: lands.map((Land land) {
          return DropdownMenuItem<Land>(value: land, child: Text(land.name));
        }).toList(),
        icon: Icon(Icons.keyboard_arrow_down_rounded),
        onChanged: onChanged,
        decoration: InputDecoration(
          // labelText: 'Land',
          border: InputBorder.none,

          contentPadding: EdgeInsets.symmetric(horizontal: 16),
        ),
      ),
    );
  }
}

class CountCard extends StatelessWidget {
  final String title;
  final int count;
  final String? imageUrl;
  final VoidCallback onTap;

  const CountCard({
    super.key,
    required this.title,
    required this.count,
    this.imageUrl,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    return InkWell(
      onTap: onTap,
      child: Container(
        decoration: AppStyle.decoration,
        margin: EdgeInsets.symmetric(horizontal: 16, vertical: 4),
        padding: EdgeInsets.symmetric(horizontal: 10, vertical: 10),
        child: Row(
          mainAxisAlignment: MainAxisAlignment.start,
          children: [
            Text(
              title,
              style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold),
              textAlign: TextAlign.center,
              maxLines: 2,
              overflow: TextOverflow.ellipsis,
            ),
            SizedBox(width: 8),
            if (count > 0) Text('($count) '),
          ],
        ),
      ),
    );
  }
}

class MarketCard extends StatelessWidget {
  final Market market;

  const MarketCard({super.key, required this.market});

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: EdgeInsets.symmetric(horizontal: 8, vertical: 10),
      margin: EdgeInsets.symmetric(horizontal: 10, vertical: 4),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              if (market.marketImg.isNotEmpty)
                ClipRRect(
                  borderRadius: BorderRadius.circular(8),
                  child: MyNetworkImage(
                    market.marketImg,
                    height: 100,
                    width: 100,
                    fit: BoxFit.fill,
                  ),
                ),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      market.name,
                      style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
                    ),
                    SizedBox(height: 8),
                    Row(
                      children: [
                        Icon(Icons.location_on, size: 16, color: Colors.grey),
                        SizedBox(width: 4),
                        Expanded(
                          child: Text(
                            market.address,
                            style: TextStyle(color: Colors.grey),
                            maxLines: 1,
                            overflow: TextOverflow.ellipsis,
                          ),
                        ),
                      ],
                    ),
                
                    SizedBox(height: 8),
                    Row(
                      children: [
                        Icon(Icons.access_time, size: 16, color: Colors.grey),
                        SizedBox(width: 4),
                        Text(
                          '${market.openingTime} - ${market.closingTime}',
                          style: TextStyle(color: Colors.grey),
                        ),
                      ],
                    ),
                  ],
                ),
              ),
            ],
          ),
          SizedBox(height: 8),
          Wrap(
            spacing: 4,
            children: market.products.take(3).map((product) {
              return Chip(
                label: Text(product),
                materialTapTargetSize: MaterialTapTargetSize.shrinkWrap,
              );
            }).toList(),
          ),
          // if (market.products.length > 3)
          //   Align(
          //     alignment: Alignment.centerRight,
          //     child: Text(
          //       '+${market.products.length - 3} more',
          //       style: TextStyle(color: Colors.grey),
          //     ),
          //   ),
        ],
      ),
    );
  }
}

class PlaceDetailCard extends StatelessWidget {
  final PlaceDetail detail;

  const PlaceDetailCard({super.key, required this.detail});

  @override
  Widget build(BuildContext context) {
    return Card(
      margin: EdgeInsets.only(bottom: 16),
      elevation: 4,
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
      child: Padding(
        padding: EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              detail.name,
              style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
            ),
            SizedBox(height: 8),
            Row(
              children: [
                Icon(Icons.phone, size: 16, color: Colors.grey),
                SizedBox(width: 4),
                Text(detail.contact, style: TextStyle(color: Colors.grey)),
              ],
            ),
            SizedBox(height: 8),
            Row(
              children: [
                Icon(Icons.location_on, size: 16, color: Colors.grey),
                SizedBox(width: 4),
                Expanded(
                  child: Text(
                    detail.address,
                    style: TextStyle(color: Colors.grey),
                    maxLines: 2,
                    overflow: TextOverflow.ellipsis,
                  ),
                ),
              ],
            ),
            // SizedBox(height: 8),
            // if (detail.days.isNotEmpty)
            //   Wrap(
            //     spacing: 4,
            //     children: detail.days.map((day) {
            //       return Chip(
            //         label: Text(day),
            //         materialTapTargetSize: MaterialTapTargetSize.shrinkWrap,
            //       );
            //     }).toList(),
            //   ),
          ],
        ),
      ),
    );
  }
}

class ManPowerAgentCard extends StatelessWidget {
  final ManPowerAgent agent;
  final VoidCallback onTap;

  const ManPowerAgentCard({
    super.key,
    required this.agent,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    return InkWell(
      borderRadius: BorderRadius.circular(12),
      onTap: onTap,
      child: Container(
        padding: EdgeInsets.symmetric(horizontal: 10, vertical: 10),
        decoration: AppStyle.decoration,
        margin: EdgeInsets.symmetric(horizontal: 0, vertical: 6),
        child: Row(
          crossAxisAlignment: CrossAxisAlignment.center,
          children: [
            Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  agent.name,
                  style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
                ),
                SizedBox(height: 8),
                Row(
                  children: [
                    Icon(Icons.phone, size: 16, color: Colors.grey),
                    SizedBox(width: 4),
                    Text(
                      agent.mobileNo.toString(),
                      style: TextStyle(color: Colors.grey),
                    ),
                  ],
                ),
                SizedBox(height: 8),
                Row(
                  children: [
                    Icon(Icons.location_on, size: 16, color: Colors.grey),
                    SizedBox(width: 4),
                    Text(agent.taluk, style: TextStyle(color: Colors.grey)),
                  ],
                ),
              ],
            ),
            if (agent.workersCount > 0)
              Padding(
                padding: const EdgeInsets.all(8.0),
                child: Text('(${agent.workersCount} Workers )'),
              ),
          ],
        ),
      ),
    );
  }
}

class WorkerCard extends StatelessWidget {
  final Worker worker;

  const WorkerCard({super.key, required this.worker});

  @override
  Widget build(BuildContext context) {
    return Card(
      elevation: 4,
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            /// Worker Header Row (Avatar + Name + Phone)
            Row(
              crossAxisAlignment: CrossAxisAlignment.center,
              children: [
                CircleAvatar(
                  radius: 28,
                  backgroundColor: Get.theme.primaryColor.withAlpha(100),
                  child: Icon(
                    Icons.person,
                    size: 30,
                    color: Get.theme.primaryColor,
                  ),
                ),
                const SizedBox(width: 12),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        worker.workerName,
                        style: const TextStyle(
                          fontSize: 18,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                      const SizedBox(height: 4),
                      Row(
                        children: [
                          const Icon(Icons.phone, size: 16, color: Colors.grey),
                          const SizedBox(width: 4),
                          Text(
                            worker.workerMobile.toString(),
                            style: TextStyle(color: Colors.grey[700]),
                          ),
                        ],
                      ),
                    ],
                  ),
                ),
              ],
            ),

            const SizedBox(height: 16),

            /// Work types section
            Text(
              "Work Types",
              style: TextStyle(
                fontSize: 20,
                fontWeight: FontWeight.bold,
                color: Colors.grey[800],
              ),
            ),
            const SizedBox(height: 8),

            Wrap(
              spacing: 8,
              runSpacing: 8,
              children: worker.workTypes.map((workType) {
                return Chip(
                  label: Text(
                    '${workType.workType} (${workType.personCount})',
                    style: const TextStyle(fontSize: 13),
                  ),
                  // backgroundColor: Colors.blue.shade50,
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(10),
                  ),
                );
              }).toList(),
            ),
          ],
        ),
      ),
    );
  }
}

class RentalDetailCard extends StatelessWidget {
  final RentalDetail detail;

  const RentalDetailCard({super.key, required this.detail});

  @override
  Widget build(BuildContext context) {
    return Card(
      margin: EdgeInsets.only(bottom: 16),
      elevation: 4,
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
      child: Padding(
        padding: EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              detail.inventoryItemName,
              style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
            ),
            SizedBox(height: 8),
            Text(
              'Vendor: ${detail.vendorName}',
              style: TextStyle(fontSize: 16),
            ),
            SizedBox(height: 8),
            Row(
              children: [
                Icon(Icons.phone, size: 16, color: Colors.grey),
                SizedBox(width: 4),
                Text(
                  detail.vendorPhone.toString(),
                  style: TextStyle(color: Colors.grey),
                ),
              ],
            ),
            SizedBox(height: 8),
            Row(
              children: [
                Icon(Icons.location_on, size: 16, color: Colors.grey),
                SizedBox(width: 4),
                Expanded(
                  child: Text(
                    detail.vendorAddress,
                    style: TextStyle(color: Colors.grey),
                    maxLines: 2,
                    overflow: TextOverflow.ellipsis,
                  ),
                ),
              ],
            ),
            SizedBox(height: 8),
            Text(
              'Reg No: ${detail.registerNumber}',
              style: TextStyle(color: Colors.grey),
            ),
          ],
        ),
      ),
    );
  }
}

class CustomSearchBar extends StatelessWidget {
  final String hintText;
  final Function(String) onChanged;

  const CustomSearchBar({
    super.key,
    required this.hintText,
    required this.onChanged,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      decoration: AppStyle.decoration.copyWith(
        color: const Color.fromARGB(137, 221, 234, 234),
        boxShadow: const [],
      ),
      padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 5),
      height: 55,
      child: TextField(
        decoration: InputDecoration(
          hintText: hintText,
          prefixIcon: Icon(Icons.search),
          border: InputBorder.none,
        ),
        onChanged: onChanged,
      ),
    );
  }
}

class CustomAppBar extends StatelessWidget implements PreferredSizeWidget {
  final String title;
  final List<Widget>? actions;
  final bool showBackButton;

  const CustomAppBar({
    super.key,
    required this.title,
    this.actions,
    this.showBackButton = false,
  });

  @override
  Widget build(BuildContext context) {
    return AppBar(
      title: Text(title),
      // centerTitle: true,
      actions: actions,
      leading: showBackButton
          ? IconButton(
              icon: Icon(Icons.arrow_back_ios_new),
              onPressed: () => Navigator.of(context).pop(),
            )
          : null,
    );
  }

  @override
  Size get preferredSize => Size.fromHeight(kToolbarHeight);
}
