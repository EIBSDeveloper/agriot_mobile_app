// import 'package:flutter/material.dart';
// import 'package:get/get.dart';

// import '../../model/model.dart';
// import '../../repostory/repostory.dart';



// class Marketreport extends StatelessWidget {
//   const Marketreport({super.key});

//   @override
//   Widget build(BuildContext context) {
//     // Initialize controller with repository
//     final DashboardController controller = Get.find();

   

//     return Center(
//       child: Column(
//         mainAxisAlignment: MainAxisAlignment.center,
//         children: [
//           // Your original header row - unchanged
//           Padding(
//             padding: const EdgeInsets.all(8.0),
//             child: Row(
//               mainAxisAlignment: MainAxisAlignment.spaceBetween,
//               children: const [
//                 Text(
//                   'Near-By Market Prices',
//                   style: TextStyle(
//                     fontSize: 18,
//                     fontWeight: FontWeight.bold,
//                     color: Colors.black,
//                   ),
//                 ),
//                 Icon(Icons.arrow_forward, size: 22),
//               ],
//             ),
//           ),

//           const SizedBox(height: 5),

//           // Container holding the Table
//           Container(
//             margin: const EdgeInsets.only(right: 10, left: 10),
//             child: Obx(() {
//               if (controller.marketLoading.value) {
//                 return const Center(child: CircularProgressIndicator());
//               }

//               if (controller.marketError.isNotEmpty) {
//                 return Center(child: Text('Error: ${controller.marketError.value}'));
//               }

//               if (controller.marketPrices.isEmpty) {
//                 return const Center(child: Text('No data available'));
//               }

//               // Prepare list of markets for header (limit 4 markets max to keep your 5 columns)
//               final markets = controller.marketPrices.map((r) => r.marketName).toList();

//               // Extract all unique products across all markets
//               final Set<String> allProducts = {};
//               for (var report in controller.marketPrices) {
//                 for (var price in report.prices) {
//                   allProducts.add(price.product);
//                 }
//               }
//               final productList = allProducts.toList();

//               // Use max 4 markets to fit your columns (you can extend columns but UI changes)
//               final displayMarkets = markets.length > 4
//                   ? markets.sublist(0, 4)
//                   : markets;

//               // Build header row widgets — keep your original style
//               final headerCells = <Widget>[
//                 _buildHeaderCell('Trending Crops'),
//                 for (var market in displayMarkets) _buildHeaderCell(market),
//               ];

//               // Build data rows dynamically for each product
//               final dataRows = productList.map((product) {
//                 final rowCells = <String>[product];

//                 // For each market in displayMarkets, find price or show '-'
//                 for (var marketName in displayMarkets) {
//                   final market = controller.marketPrices.firstWhere(
//                     (m) => m.marketName == marketName,
//                   );
//                   final priceObj = market.prices.firstWhere(
//                     (p) => p.product == product,
//                     orElse: () => ProductPrice(product: product, price: 0),
//                   );

//                   rowCells.add(
//                     priceObj != null ? '₹ ${priceObj.price}' : '-',
//                   );
//                 }

//                 return _buildDataRow(rowCells);
//               }).toList();

//               return Table(
//                 border: TableBorder.all(color: const Color(0xFFD1D1D1)),
//                 columnWidths: const {
//                   0: FlexColumnWidth(1),
//                   1: FlexColumnWidth(1),
//                   2: FlexColumnWidth(1),
//                   3: FlexColumnWidth(1),
//                   4: FlexColumnWidth(1),
//                 },
//                 children: [
//                   TableRow(
//                     decoration: const BoxDecoration(color: Color(0xFFE7F4E4)),
//                     children: headerCells,
//                   ),
//                   ...dataRows,
//                 ],
//               );
//             }),
//           ),
//         ],
//       ),
//     );
//   }

//   // Your existing helpers — unchanged
//   Widget _buildHeaderCell(String text) {
//     return Padding(
//       padding: const EdgeInsets.all(8.0),
//       child: Text(
//         text,
//         textAlign: TextAlign.center,
//         style: const TextStyle(
//           fontWeight: FontWeight.bold,
//           color: Colors.black,
//         ),
//       ),
//     );
//   }

//   TableRow _buildDataRow(List<String> cells) {
//     return TableRow(
//       decoration: const BoxDecoration(color: Colors.white),
//       children: [
//         Padding(
//           padding: const EdgeInsets.all(8.0),
//           child: Text(cells[0], style: const TextStyle(color: Colors.black)),
//         ),
//         ...cells
//             .sublist(1)
//             .map(
//               (text) => Padding(
//                 padding: const EdgeInsets.all(8.0),
//                 child: Text(
//                   // text,
//                   textAlign: TextAlign.center,
//                   style: const TextStyle(color: Colors.black),
//                 ),
//               ),
//             ),
//       ],
//     );
//   }


// }
