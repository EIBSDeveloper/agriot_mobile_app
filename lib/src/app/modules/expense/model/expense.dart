import 'package:argiot/src/app/modules/forming/model/crop.dart';

import 'farmer.dart';

class Expense {
  final int id;
  final Farmer farmer;
  final Crop myCrop;
  final double amount;
  final String description;
  final String createdDay;

  Expense({
    required this.id,
    required this.farmer,
    required this.myCrop,
    required this.amount,
    required this.description,
    required this.createdDay,
  });

  factory Expense.fromJson(Map<String, dynamic> json) => Expense(
      id: json['id'],
      farmer: Farmer.fromJson(json['farmer']),
      myCrop: Crop.fromJson(json['my_crop']),
      amount: json['amount'].toDouble(),
      description: json['description'],
      createdDay: json['created_day'],
    );
}
