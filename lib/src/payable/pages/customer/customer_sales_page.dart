
import 'package:argiot/src/payable/pages/customer/customer_historydetails.dart';
import 'package:flutter/material.dart';
import 'package:fluttertoast/fluttertoast.dart';
import 'package:get/get.dart';

import '../../controller/customer_add_controller/customer_add_controller.dart';
import '../../controller/customercontroller/customer_salaes_controller.dart';
import '../../repository/customer_add_repository/customer_add_repository.dart';
import '../../repository/customer_repository/customer_sales_repository.dart';
import '../../widgets/dialogwidget/customer_dialog_widget.dart';

class CustomerSalesPage extends StatelessWidget {
  final int customerId;
  final String customerName;
  final double amount;
  final bool isPayable;

  const CustomerSalesPage({
    super.key,
    required this.customerId,
    required this.customerName,
    required this.amount,
    required this.isPayable,
  });

  @override
  Widget build(BuildContext context) {
    final controller = Get.put(
      CustomerSalesController(repository: CustomerSalesRepository()),
    );
    final addController = Get.put(
      CustomerAddController(repository: CustomerAddRepository()),
    );

    // 🔥 Schedule API call after first frame
    WidgetsBinding.instance.addPostFrameCallback((_) {
      if (isPayable) {
        controller.loadPayables(customerId);
      } else {
        controller.loadReceivables(customerId);
      }
    });

    return Scaffold(
      appBar: AppBar(title: Text(isPayable ? 'payables'.tr : 'receivables'.tr)),
      body: Obx(() {
        if (controller.isLoading.value) {
          return const Center(child: CircularProgressIndicator());
        }
        if (controller.errorMessage.isNotEmpty) {
          return Center(child: Text('error'.tr));
        }

        final data = isPayable ? controller.payables : controller.receivables;

        if (data.isEmpty) {
          return Center(child: Text('no_data'.tr));
        }

        return Column(
          children: [
            _buildCustomerCard(context, addController, data[0], isPayable),
          ],
        );
      }),
    );
  }

  Widget _buildCustomerCard(
    BuildContext context,
    CustomerAddController addController,
    dynamic customer,
    bool isPayable,
  ) => Card(
      elevation: 4,
      margin: const EdgeInsets.symmetric(vertical: 10),
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(15)),
      child: Padding(
        padding: const EdgeInsets.all(12),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // Customer Info
            Row(
              children: [
                CircleAvatar(
                  radius: 30,
                  backgroundImage: customer.customerImage.isNotEmpty
                      ? NetworkImage(customer.customerImage)
                      : const AssetImage('assets/images/user_placeholder.png')
                            as ImageProvider,
                ),
                const SizedBox(width: 12),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        customer.customerName,
                        style: const TextStyle(
                          fontSize: 18,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                      const SizedBox(height: 4),
                      Text(
                        customer.shopName,
                        style: TextStyle(fontSize: 14, color: Colors.grey[700]),
                      ),
                    ],
                  ),
                ),
              ],
            ),
            const Divider(height: 20, thickness: 1.2),

            // Sales Info
            Column(
              children: customer.sales.map<Widget>((sale) => Container(
                  margin: const EdgeInsets.symmetric(vertical: 6),
                  padding: const EdgeInsets.all(10),
                  decoration: BoxDecoration(
                    color: Colors.blueGrey.shade50,
                    borderRadius: BorderRadius.circular(10),
                  ),
                  child: Row(
                    children: [
                      Expanded(
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Text(
                              "${sale.cropName} (${sale.salesDate})",
                              style: const TextStyle(
                                fontWeight: FontWeight.bold,
                                fontSize: 16,
                              ),
                            ),
                            const SizedBox(height: 4),
                            Text(
                              "${'total'.tr}: ₹${sale.totalSalesAmount} | ${'paid'.tr}: ₹${sale.amountPaid}",
                              style: const TextStyle(fontSize: 14),
                            ),
                          ],
                        ),
                      ),
                      /*IconButton(
                        icon: const Icon(
                          Icons.add_circle,
                          color: Colors.green,
                          size: 28,
                        ),
                        onPressed: () {
                          showPaymentBottomSheet(
                            context: context,
                            isPayable: isPayable,
                            controller: addController,
                            customerId: customer.customerId,
                            customerName: customer.customerName,
                            currentAmount: isPayable
                                ? sale.topayAmount
                                : sale.receivedAmount,
                            salesId: sale.salesId,
                          );
                        },
                      ),*/
                      IconButton(
                        icon: const Icon(
                          Icons.add_circle,
                          color: Colors.green,
                          size: 28,
                        ),
                        onPressed: () {
                          print(
                            "🔎 Opening balance for ${customer.customerName}: $amount",
                          );

                          if (amount <= 0) {
                            print(
                              "❌ No outstanding left → cannot open bottom sheet",
                            );
                            Fluttertoast.showToast(
                              msg: "No outstanding left",
                              toastLength: Toast.LENGTH_SHORT,
                              gravity: ToastGravity.BOTTOM,
                              backgroundColor: Colors.red,
                              textColor: Colors.white,
                              fontSize: 16.0,
                            );
                            return;
                          }

                          print(
                            "✅ Opening balance available → opening payment bottom sheet",
                          );

                          showPaymentBottomSheet(
                            context: context,
                            isPayable: isPayable,
                            controller: addController,
                            customerId: customer.customerId,
                            customerName: customer.customerName,
                            currentAmount:
                                amount, // 🔥 always use amount from page
                            salesId: sale.salesId,
                          );
                        },
                      ),

                      IconButton(
                        icon: const Icon(
                          Icons.history,
                          color: Colors.blue,
                          size: 26,
                        ),
                        onPressed: () {
                          Get.to(
                            () => HistoryPage(
                              customerId: customer.customerId,
                              saleId: sale.salesId,
                              isPayable: isPayable,
                            ),
                          );
                        },
                      ),
                    ],
                  ),
                )).toList(),
            ),
          ],
        ),
      ),
    );
}
