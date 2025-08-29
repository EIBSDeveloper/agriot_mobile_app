// lib/app/modules/guidelines/models/inventory_model.dart

class InventoryModel {
  final InventoryFuel fuel;
  final InventoryVehicle vehicle;
  final InventoryMachinery machinery;
  final InventoryTools tools;
  final InventoryPesticides pesticides;
  final InventoryFertilizers fertilizers;
  final InventorySeeds seeds;

  InventoryModel({
    required this.fuel,
    required this.vehicle,
    required this.machinery,
    required this.tools,
    required this.pesticides,
    required this.fertilizers,
    required this.seeds,
  });

  factory InventoryModel.fromJson(Map<String, dynamic> json) {
    return InventoryModel(
      fuel: InventoryFuel.fromJson(json['fuel']),
      vehicle: InventoryVehicle.fromJson(json['vehicle']),
      machinery: InventoryMachinery.fromJson(json['machinery']),
      tools: InventoryTools.fromJson(json['tools']),
      pesticides: InventoryPesticides.fromJson(json['pesticides']),
      fertilizers: InventoryFertilizers.fromJson(json['fertilizers']),
      seeds: InventorySeeds.fromJson(json['seeds']),
    );
  }
}

class InventoryFuel {
  final double totalQuantity;

  InventoryFuel({required this.totalQuantity});

  factory InventoryFuel.fromJson(Map<String, dynamic> json) {
    return InventoryFuel(
      totalQuantity: double.tryParse(json['total_quantity'].toString()) ?? 0.0,
    );
  }
}

class InventoryVehicle {
  final double totalFuelCapacity;

  InventoryVehicle({required this.totalFuelCapacity});

  factory InventoryVehicle.fromJson(Map<String, dynamic> json) {
    return InventoryVehicle(
      totalFuelCapacity: double.tryParse(json['total_fuel_capacity'].toString()) ?? 0.0,
    );
  }
}

class InventoryMachinery {
  final double totalFuelCapacity;

  InventoryMachinery({required this.totalFuelCapacity});

  factory InventoryMachinery.fromJson(Map<String, dynamic> json) {
    return InventoryMachinery(
      totalFuelCapacity: double.tryParse(json['total_fuel_capacity'].toString()) ?? 0.0,
    );
  }
}

class InventoryTools {
  final double totalQuantity;

  InventoryTools({required this.totalQuantity});

  factory InventoryTools.fromJson(Map<String, dynamic> json) {
    return InventoryTools(
      totalQuantity: double.tryParse(json['total_quantity'].toString()) ?? 0.0,
    );
  }
}

class InventoryPesticides {
  final double totalQuantity;

  InventoryPesticides({required this.totalQuantity});

  factory InventoryPesticides.fromJson(Map<String, dynamic> json) {
    return InventoryPesticides(
      totalQuantity: double.tryParse(json['total_quantity'].toString()) ?? 0.0,
    );
  }
}

class InventoryFertilizers {
  final double totalQuantity;

  InventoryFertilizers({required this.totalQuantity});

  factory InventoryFertilizers.fromJson(Map<String, dynamic> json) {
    return InventoryFertilizers(
      totalQuantity: double.tryParse(json['total_quantity'].toString()) ?? 0.0,
    );
  }
}

class InventorySeeds {
  final double totalQuantity;

  InventorySeeds({required this.totalQuantity});

  factory InventorySeeds.fromJson(Map<String, dynamic> json) {
    return InventorySeeds(
      totalQuantity: double.tryParse(json['total_quantity'].toString()) ?? 0.0,
    );
  }
}
