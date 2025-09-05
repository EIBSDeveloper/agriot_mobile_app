// lib/modules/expenses/models/expense_model.dart

class Expense {
  final int id;
  final Farmer farmer;
  final Crop myCrop;
  final ExpenseType typeExpenses;
  final double amount;
  final String description;
  final String createdDay;

  Expense({
    required this.id,
    required this.farmer,
    required this.myCrop,
    required this.typeExpenses,
    required this.amount,
    required this.description,
    required this.createdDay,
  });

  factory Expense.fromJson(Map<String, dynamic> json) {
    return Expense(
      id: json['id'],
      farmer: Farmer.fromJson(json['farmer']),
      myCrop: Crop.fromJson(json['my_crop']),
      typeExpenses: ExpenseType.fromJson(json['type_expenses']),
      amount: json['amount'].toDouble(),
      description: json['description'],
      createdDay: json['created_day'],
    );
  }
}

class Farmer {
  final int id;
  final String name;

  Farmer({required this.id, required this.name});

  factory Farmer.fromJson(Map<String, dynamic> json) {
    return Farmer(id: json['id'], name: json['name']);
  }
}

class Crop {
  final int id;
  final String name;

  Crop({required this.id, required this.name});

  factory Crop.fromJson(Map<String, dynamic> json) {
    return Crop(id: json['id'], name: json['name']);
  }
}

class ExpenseType {
  final int id;
  final String name;

  ExpenseType({required this.id, required this.name});

  factory ExpenseType.fromJson(Map<String, dynamic> json) {
    return ExpenseType(id: json['id'], name: json['name']);
  }
}

class Purchase {
  final int id;
  final Farmer farmer;
  final String dateOfConsumption;
  final Vendor vendor;
  final InventoryItem inventorytype;
  final InventoryItem inventoryItems;
  final String quantity;
  final String purchaseAmount;
  final String? availableQuans;
  final String type;

  Purchase({
    required this.id,
    required this.farmer,
    required this.dateOfConsumption,
    required this.vendor,
    required this.inventorytype,
    required this.inventoryItems,
    required this.quantity,
    required this.purchaseAmount,
    this.availableQuans,
    required this.type,
  });

  factory Purchase.fromJson(Map<String, dynamic> json) {
    return Purchase(
      id: json['id'],
      farmer: Farmer.fromJson(json['farmer']),
      dateOfConsumption: json['date_of_consumption'],
      vendor: Vendor.fromJson(json['vendor']),
      inventorytype: InventoryItem.fromJson(json['inventory_type']),
      inventoryItems: InventoryItem.fromJson(json['inventory_items']),
      quantity: json['quantity']??"0",
      purchaseAmount: json['purchase_amount'],
      availableQuans: json['available_quans']?.toString(),
      type: json['type'],
    );
  }
}

class Vendor {
  final int id;
  final String name;

  Vendor({required this.id, required this.name});

  factory Vendor.fromJson(Map<String, dynamic> json) {
    return Vendor(id: json['id'], name: json['name']);
  }
}

class InventoryItem {
  final int id;
  final String name;

  InventoryItem({required this.id, required this.name});

  factory InventoryItem.fromJson(Map<String, dynamic> json) {
    return InventoryItem(id: json['id'], name: json['name']);
  }
}

class ExpenseSummary {
  final String category;
  final double totalAmount;
  final double percentage;

  ExpenseSummary({
    required this.category,
    required this.totalAmount,
    required this.percentage,
  });

  factory ExpenseSummary.fromJson(Map<String, dynamic> json) {
    return ExpenseSummary(
      category: json['type_expenses__name'],
      totalAmount: json['total_amount'].toDouble(),
      percentage: json['percentage'].toDouble(),
    );
  }
}

class TotalExpense {
  final bool success;
  final double expenseAmount;

  TotalExpense({required this.success, required this.expenseAmount});

  factory TotalExpense.fromJson(Map<String, dynamic> json) {
    return TotalExpense(
      success: json['success'],
      expenseAmount: json['expenseamount'].toDouble(),
    );
  }
}

class ExpenseResponse {
  final bool success;
  final List<Expense> expenses;
  final List<Purchase> purchases;

  ExpenseResponse({
    required this.success,
    required this.expenses,
    required this.purchases,
  });

  factory ExpenseResponse.fromJson(Map<String, dynamic> json) {
    return ExpenseResponse(
      success: json['success'],
      expenses: List<Expense>.from(
        json['expenses'].map((x) => Expense.fromJson(x)),
      ),
      purchases: List<Purchase>.from(
        json['purchases'].map((x) => Purchase.fromJson(x)),
      ),
    );
  }
}

class FileType {
  final int id;
  final int docType;
  final String name;
  final String description;

  FileType({
    required this.id,
    required this.docType,
    required this.name,
    required this.description,
  });

  factory FileType.fromJson(Map<String, dynamic> json) {
    return FileType(
      id: json['id'],
      docType: json['doctype'],
      name: json['name'],
      description: json['description']??"",
    );
  }
}

class Chart {
  final String type_expenses__name;
  final double total_amount;
  final double percentage;

  Chart({
    required this.type_expenses__name,
    required this.total_amount,
    required this.percentage,
  });

  factory Chart.fromJson(Map<String, dynamic> json) {
    return Chart(
      type_expenses__name: json['type_expenses__name'] ?? '',
      total_amount: (json['total_amount'] ?? 0).toDouble(),
      percentage: (json['percentage'] ?? 0).toDouble(),
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'type_expenses__name': type_expenses__name,
      'total_amount': total_amount,
      'percentage': percentage,
    };
  }
}








