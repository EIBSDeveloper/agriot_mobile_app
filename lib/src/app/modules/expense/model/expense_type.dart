class ExpenseType {
  final int id;
  final String name;

  ExpenseType({required this.id, required this.name});

  factory ExpenseType.fromJson(Map<String, dynamic> json) => ExpenseType(id: json['id'], name: json['name']);
}
