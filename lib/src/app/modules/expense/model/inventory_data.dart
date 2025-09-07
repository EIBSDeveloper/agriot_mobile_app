import 'package:argiot/src/app/modules/expense/model/consumption_record.dart';
import 'package:argiot/src/app/modules/expense/model/purchase_record.dart';


class InventoryData {
  final List<ConsumptionRecord> consumptionRecords;
  final List<PurchaseRecord> purchaseRecords;

  InventoryData({
    required this.consumptionRecords,
    required this.purchaseRecords,
  });
}
