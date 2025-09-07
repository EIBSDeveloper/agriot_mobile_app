// models/sales_model.dart

import 'package:argiot/src/app/modules/task/view/screens/screen.dart';

class Reason extends NamedItem {
  @override
  final int id;
  @override
  final String name;

  Reason({required this.id, required this.name});

  factory Reason.fromJson(Map<String, dynamic> json) =>
      Reason(id: json['id'] ?? 0, name: json['name'] ?? '');
}
