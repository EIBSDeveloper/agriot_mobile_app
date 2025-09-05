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
  final int id;
  // final String name ;

  InventoryFuel({required this.totalQuantity,required this.id});

  factory InventoryFuel.fromJson(Map<String, dynamic> json) {
    return InventoryFuel(
      totalQuantity: double.tryParse(json['total_quantity'].toString()) ?? 0.0,
      id: json['id'],
    );
  }
}

class InventoryVehicle {
  final double totalFuelCapacity;
 final int id;
  InventoryVehicle({required this.totalFuelCapacity,required this.id});

  factory InventoryVehicle.fromJson(Map<String, dynamic> json) {
    return InventoryVehicle(
       id: json['id'],
      totalFuelCapacity: double.tryParse(json['total_fuel_capacity'].toString()) ?? 0.0,
    );
  }
}

class InventoryMachinery {
  final double totalFuelCapacity;
 final int id;
  InventoryMachinery({required this.totalFuelCapacity,required this.id});

  factory InventoryMachinery.fromJson(Map<String, dynamic> json) {
    return InventoryMachinery(
       id: json['id'],
      totalFuelCapacity: double.tryParse(json['total_fuel_capacity'].toString()) ?? 0.0,
    );
  }
}

class InventoryTools {
  final double totalQuantity;
 final int id;
  InventoryTools({required this.totalQuantity,required this.id});

  factory InventoryTools.fromJson(Map<String, dynamic> json) {
    return InventoryTools(
       id: json['id'],
      totalQuantity: double.tryParse(json['total_quantity'].toString()) ?? 0.0,
    );
  }
}

class InventoryPesticides {
  final double totalQuantity; final int id;

  InventoryPesticides({required this.totalQuantity,required this.id});

  factory InventoryPesticides.fromJson(Map<String, dynamic> json) {
    return InventoryPesticides(
       id: json['id'],
      totalQuantity: double.tryParse(json['total_quantity'].toString()) ?? 0.0,
    );
  }
}

class InventoryFertilizers {
  final double totalQuantity;
 final int id;
  InventoryFertilizers({required this.totalQuantity,required this.id});

  factory InventoryFertilizers.fromJson(Map<String, dynamic> json) {
    return InventoryFertilizers(
       id: json['id'],
      totalQuantity: double.tryParse(json['total_quantity'].toString()) ?? 0.0,
    );
  }
}

class InventorySeeds {
  final double totalQuantity;
 final int id;
  InventorySeeds({required this.totalQuantity,required this.id});

  factory InventorySeeds.fromJson(Map<String, dynamic> json) {
    return InventorySeeds(
       id: json['id'],
      totalQuantity: double.tryParse(json['total_quantity'].toString()) ?? 0.0,
    );
  }
}
