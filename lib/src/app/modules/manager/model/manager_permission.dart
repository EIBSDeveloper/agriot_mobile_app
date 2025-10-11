
import 'package:argiot/src/app/modules/manager/model/best_schedule_permission.dart';
import 'package:argiot/src/app/modules/manager/model/dashboard_permission.dart';
import 'package:argiot/src/app/modules/manager/model/inventory_permission.dart';
import 'package:argiot/src/app/modules/manager/model/module_permission.dart';


class ManagerPermission {
    final DashboardPermission? dashboard;
    final ModulePermission? land;
    final ModulePermission? crop;
    final ModulePermission? schedule;
    final BestSchedulePermission? bestSchedule;
    final ModulePermission? expense;
    final ModulePermission? vendor;
    final ModulePermission? sales;
    final ModulePermission? customer;
    final InventoryPermission? fuel;
    final InventoryPermission? vehicle;
    final InventoryPermission? machinery;
    final InventoryPermission? tools;
    final InventoryPermission? pesticides;
    final InventoryPermission? fertilizer;
    final InventoryPermission? seeds;
    final ModulePermission? employee;
    final ModulePermission? attendance;
    final ModulePermission? payouts;
    final ModulePermission? advance;
    final ModulePermission? users;
    final ModulePermission? role;

    ManagerPermission({
        this.dashboard,
        this.land,
        this.crop,
        this.schedule,
        this.bestSchedule,
        this.expense,
        this.vendor,
        this.sales,
        this.customer,
        this.fuel,
        this.vehicle,
        this.machinery,
        this.tools,
        this.pesticides,
        this.fertilizer,
        this.seeds,
        this.employee,
        this.attendance,
        this.payouts,
        this.advance,
        this.users,
        this.role,
    });

    factory ManagerPermission.fromJson(Map<String, dynamic> json) => ManagerPermission(
        dashboard: json["dashboard"] == null ? null : DashboardPermission.fromJson(json["dashboard"]),
        land: json["land"] == null ? null : ModulePermission.fromJson(json["land"]),
        crop: json["crop"] == null ? null : ModulePermission.fromJson(json["crop"]),
        schedule: json["schedule"] == null ? null : ModulePermission.fromJson(json["schedule"]),
        bestSchedule: json["best_schedule"] == null ? null : BestSchedulePermission.fromJson(json["best_schedule"]),
        expense: json["expense"] == null ? null : ModulePermission.fromJson(json["expense"]),
        vendor: json["vendor"] == null ? null : ModulePermission.fromJson(json["vendor"]),
        sales: json["sales"] == null ? null : ModulePermission.fromJson(json["sales"]),
        customer: json["customer"] == null ? null : ModulePermission.fromJson(json["customer"]),
        fuel: json["fuel"] == null ? null : InventoryPermission.fromJson(json["fuel"]),
        vehicle: json["vehicle"] == null ? null : InventoryPermission.fromJson(json["vehicle"]),
        machinery: json["machinery"] == null ? null : InventoryPermission.fromJson(json["machinery"]),
        tools: json["tools"] == null ? null : InventoryPermission.fromJson(json["tools"]),
        pesticides: json["pesticides"] == null ? null : InventoryPermission.fromJson(json["pesticides"]),
        fertilizer: json["fertilizer"] == null ? null : InventoryPermission.fromJson(json["fertilizer"]),
        seeds: json["seeds"] == null ? null : InventoryPermission.fromJson(json["seeds"]),
        employee: json["employee"] == null ? null : ModulePermission.fromJson(json["employee"]),
        attendance: json["attendance"] == null ? null : ModulePermission.fromJson(json["attendance"]),
        payouts: json["payouts"] == null ? null : ModulePermission.fromJson(json["payouts"]),
        advance: json["advance"] == null ? null : ModulePermission.fromJson(json["advance"]),
        users: json["users"] == null ? null : ModulePermission.fromJson(json["users"]),
        role: json["role"] == null ? null : ModulePermission.fromJson(json["role"]),
    );

    Map<String, dynamic> toJson() => {
        "dashboard": dashboard?.toJson(),
        "land": land?.toJson(),
        "crop": crop?.toJson(),
        "schedule": schedule?.toJson(),
        "best_schedule": bestSchedule?.toJson(),
        "expense": expense?.toJson(),
        "vendor": vendor?.toJson(),
        "sales": sales?.toJson(),
        "customer": customer?.toJson(),
        "fuel": fuel?.toJson(),
        "vehicle": vehicle?.toJson(),
        "machinery": machinery?.toJson(),
        "tools": tools?.toJson(),
        "pesticides": pesticides?.toJson(),
        "fertilizer": fertilizer?.toJson(),
        "seeds": seeds?.toJson(),
        "employee": employee?.toJson(),
        "attendance": attendance?.toJson(),
        "payouts": payouts?.toJson(),
        "advance": advance?.toJson(),
        "users": users?.toJson(),
        "role": role?.toJson(),
    };
}
