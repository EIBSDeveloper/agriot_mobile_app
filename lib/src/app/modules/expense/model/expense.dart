
class GroupedExpenseRecord {
  final String date;
  final List<ExpenseRecord> records;

  GroupedExpenseRecord({
    required this.date,
    required this.records,
  });

  factory GroupedExpenseRecord.fromJson(Map<String, dynamic> json) => GroupedExpenseRecord(
      date: json['date'],
      records: List<ExpenseRecord>.from(
          json['records'].map((x) => ExpenseRecord.fromJson(x))),
    );
}

class ExpenseRecord {
  final int id;
  final String date;
  final Vendor? vendor;
  final Item item;
  final double amount;
  final String? quantity;
  final String description;

  ExpenseRecord({
    required this.id,
    required this.date,
    required this.vendor,
    required this.item,
    required this.amount,
    this.quantity,
    required this.description,
  });

  factory ExpenseRecord.fromJson(Map<String, dynamic> json) => ExpenseRecord(
      id: json['id'],
      date: json['date'],
      vendor: Vendor.fromJson(json['vendor']),
      item: Item.fromJson(json['item']),
      amount: double.parse(json['amount'].toString()),
      quantity: json['quantity']?.toString(),
      description: json['description'] ?? '',
    );
}

class Vendor {
  final String? id;
  final String? name;

  Vendor({
    required this.id,
    required this.name,
  });

  factory Vendor.fromJson(Map<String, dynamic> json) => Vendor(
      id: json['id'].toString(),
      name: json['name'],
    );
}

class Item {
  final int id;
  final String name;

  Item({
    required this.id,
    required this.name,
  });

  factory Item.fromJson(Map<String, dynamic> json) => Item(
      id: json['id'],
      name: json['name'],
    );
}