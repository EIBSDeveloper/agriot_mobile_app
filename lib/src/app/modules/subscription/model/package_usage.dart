class PackageUsage {
  final int id;
  final String name;
  final int mylandCount;
  final int landCountUsed;
  final int mycropsCount;
  final int cropCountUsed;
  final int employeeCount;
  final int employeeCountUsed;
  final bool isWidget;

  PackageUsage({
    required this.id,
    required this.name,
    required this.mylandCount,
    required this.landCountUsed,
    required this.mycropsCount,
    required this.cropCountUsed,
    required this.employeeCount,
    required this.employeeCountUsed,
    required this.isWidget,
  });

  factory PackageUsage.fromJson(Map<String, dynamic> json) => PackageUsage(
      id: json['id'] ?? 0,
      name: json['name'] ?? '',
      mylandCount: json['myland_count'] ?? 0,
      landCountUsed: json['land_count_used'] ?? 0,
      mycropsCount: json['mycrops_count'] ?? 0,
      cropCountUsed: json['crop_count_used'] ?? 0,
      employeeCount: json['employee_count'] ?? 0,
      employeeCountUsed: json['employee_count_used'] ?? 0,
      isWidget: json['is_widget'] ?? false,
    );

  // Balance Getters
  int get landBalance => _safeBalance(mylandCount, landCountUsed);
  int get cropBalance => _safeBalance(mycropsCount, cropCountUsed);
  int get employeeBalance => _safeBalance(employeeCount, employeeCountUsed);

  // Helper method to ensure non-negative balance
  int _safeBalance(int total, int used) => (total - used).clamp(0, total);
}
