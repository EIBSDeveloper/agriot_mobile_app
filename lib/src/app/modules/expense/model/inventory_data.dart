import 'package:argiot/src/app/modules/expense/model/consumption_record.dart';
import 'package:argiot/src/app/modules/expense/model/purchase_record.dart';


class InventoryData {
  final List<ConsumptionItem> consumptionRecords;
  final List<PurchaseItem> purchaseRecords;

  InventoryData({
    required this.consumptionRecords,
    required this.purchaseRecords,
  });
}
