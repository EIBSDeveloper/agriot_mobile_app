import 'package:argiot/src/app/modules/auth/view/screens/walkthrough_view.dart';

import 'package:argiot/src/app/modules/expense/binding/fuel_inventory_binding.dart';
import 'package:argiot/src/app/modules/expense/view/screens/purchase_details.dart';
import 'package:argiot/src/app/modules/map_view/bindings/land_map_view_binding.dart';
import 'package:argiot/src/app/modules/profile/views/screens/profile_edit_view.dart';
import 'package:argiot/src/app/modules/task/controller/schedule_binding.dart';
import 'package:argiot/src/app/modules/task/view/screens/schedule_list_page.dart';
import 'package:argiot/src/app/modules/guideline/binding/guideline_binding.dart';
import 'package:argiot/src/app/modules/guideline/view/screen/guidelines_view.dart';
import 'package:argiot/src/app/modules/sales/bindings/new_sales_binding.dart';
import 'package:argiot/src/app/modules/sales/view/screens/new_sales_details_view.dart';
import 'package:argiot/src/app/modules/auth/view/screens/login_page.dart';
import 'package:argiot/src/app/modules/expense/view/screens/add_expense_screen.dart';

import 'package:argiot/src/app/modules/expense/view/consumption_view.dart';
import 'package:argiot/src/app/modules/expense/binding/consumption_purchase_binding.dart';
import 'package:argiot/src/app/modules/expense/view/screens/consumption_purchase_view.dart';
import 'package:argiot/src/app/modules/expense/view/screens/fertilizer_screen.dart';
import 'package:argiot/src/app/modules/expense/view/screens/machinery_entry_screen.dart';
import 'package:argiot/src/app/modules/expense/view/screens/vehicle_view.dart';
import 'package:argiot/src/app/modules/subscription/view/screens/payment_failed_screen.dart';
import 'package:argiot/src/app/modules/subscription/view/screens/payment_screen.dart';
import 'package:argiot/src/app/modules/subscription/view/screens/payment_success_screen.dart';
import 'package:argiot/src/app/modules/expense/view/screens/expense_overview_screen.dart';
import 'package:argiot/src/app/modules/forming/view/screen/crop_overview_screen.dart';
import 'package:argiot/src/app/modules/auth/view/screens/splash_screen.dart';
import 'package:argiot/src/app/modules/home/views/screens/home.dart';
import 'package:argiot/src/app/modules/forming/view/screen/crop_view.dart';
import 'package:argiot/src/app/modules/forming/view/screen/landi_add_page.dart';
import 'package:argiot/src/app/modules/task/view/screens/task_detail_view.dart';
import 'package:argiot/src/app/modules/subscription/view/screens/subscription_plans_screen.dart';
import 'package:argiot/src/app/modules/subscription/view/screens/subscription_usage_screen.dart';
import 'package:argiot/src/app/modules/vendor_customer/view/screens/vendor_customer_list_view.dart';
import 'package:argiot/src/app/modules/vendor_customer/view/screens/add_vendor_customer_view.dart';
import 'package:argiot/src/app/modules/vendor_customer/view/screens/vendor_customer_details_view.dart';
import 'package:get/get.dart';

import '../modules/attendence/bindings/attendence_binding.dart';
import '../modules/attendence/view/screens/add_attendence_screen.dart';
import '../modules/attendence/view/screens/attendence_list_screen.dart';
import '../modules/document/document.dart';
import '../modules/employee/bindings/employee_advance_binding.dart';
import '../modules/employee/bindings/employee_manager_binding.dart';
import '../modules/employee/bindings/update_employee_payouts_binding.dart';
import '../modules/employee/view/screen/employee_advance_controller.dart';
import '../modules/employee/view/screen/employee_details_view.dart';
import '../modules/employee/view/screen/employee_manager_view.dart';
import '../modules/employee/view/screen/update_employee_payouts_view.dart';
import '../modules/expense/binding/cunsumption_detail_binding.dart';
import '../modules/expense/view/screens/consumption_details.dart';
import '../modules/manager/bindings/manager_binding.dart';
import '../modules/manager/view/screen/create_manager_screen.dart';
import '../modules/payouts/bindings/payout_binding.dart';
import '../modules/payouts/view/screens/add_payout_screen.dart';
import '../modules/payouts/view/screens/payout_list_screen.dart';
import '../modules/sales/view/screens/add_deduction_view.dart';
import '../modules/task/view/screens/schedule_details_page.dart';
import '../modules/map_view/view/screens/land_map_view.dart';
import '../modules/sales/view/screens/new_sales_view.dart';
import '../bindings/app_binding.dart';
import '../modules/auth/view/screens/otp_page.dart';
import '../modules/expense/binding/fuel_entry_binding.dart';
import '../modules/expense/view/screens/fuel_entry_view.dart';
import '../modules/inventory/view/purchase_items_screen.dart';
import '../modules/forming/controller/location_viewer_view.dart';
import '../modules/forming/view/screen/land_details_page.dart';
import '../modules/near_me/views/screen/view.dart';
import '../modules/notification/view/screen/notification_view.dart';
import '../modules/profile/views/screens/profile_view.dart';
import '../modules/registration/binding/registration_binding.dart';
import '../modules/registration/view/screen/regisster.dart';
import '../modules/sales/view/screens/sales_list_view.dart';
import '../modules/task/view/screens/task_view.dart';
import 'app_routes.dart';

class AppPages {
  static final routes = [
    // Auth routes
    GetPage(
      name: Routes.splash,
      page: () => const SplashScreen(),
      binding: SplashBinding(),
    ),
    GetPage(name: Routes.login, page: () => const LoginPage()),
    GetPage(name: Routes.otp, page: () => const OtpPage()),
    GetPage(
      name: Routes.register,
      page: () => const Registration(),
      binding: RegistrationBinding(),
    ),
    GetPage(
      name: Routes.walkthrough,
      page: () => const WalkthroughView(),
      binding: WalkthroughBinding(),
    ),

    // Main app routes
    GetPage(
      name: Routes.home,
      page: () => const Home(),
      binding: HomeBinding(),
    ),

    // Land management routes
    GetPage(
      name: Routes.addLand,
      page: () => LandViewPage(),
      binding: LandAddBinding(),
    ),
    GetPage(
      name: Routes.landDetail,
      page: () => const LandDetailView(),
      binding: FormingBinding(),
    ),

    // Crop management routes
    GetPage(
      name: Routes.addCrop,
      page: () => const CropView(),
      binding: CropBinding(),
    ),
    GetPage(
      name: Routes.cropOverview,
      page: () => const CropOverviewScreen(),
      binding: CropDetailsBinding(),
    ),

    // Sales routes
    GetPage(
      name: Routes.sales,
      page: () => const SalesListView(),
      binding: SalesBinding(),
    ),

    GetPage(
      name: Routes.guidelines,
      page: () => const GuidelinesView(),
      binding: GuidelineBinding(),
    ),

    GetPage(
      name: Routes.salesDetails,
      page: () => const NewSalesDetailsView(),
      binding: NewSalesBinding(),
    ),
    GetPage(
      name: Routes.newSales,
      page: () => const NewSalesView(),
      binding: NewSalesBinding(),
    ),

    GetPage(
      name: Routes.addDeduction,
      page: () => AddDeductionView(),
      binding: NewSalesBinding(),
    ),
    // Expense routes
    GetPage(
      name: Routes.expense,
      page: () => const ExpenseOverviewScreen(),
      binding: ExpenseBinding(),
    ),
    GetPage(
      name: Routes.addExpense,
      page: () => AddExpenseScreen(),
      binding: ExpenseBinding(),
    ),

    // Vendor/Customer routes
    GetPage(
      name: Routes.vendorCustomer,
      page: () => const VendorCustomerListView(),
      binding: VendorCustomerBinding(),
    ),
    GetPage(
      name: Routes.addVendorCustomer,
      page: () =>  AddVendorCustomerView(),
      binding: VendorCustomerBinding(),
    ),
    GetPage(
      name: Routes.vendorCustomerDetails,
      page: () => const VendorCustomerDetailsView(),
      binding: VendorCustomerBinding(),
    ),

    // Other feature routes
    GetPage(
      name: Routes.notification,
      page: () => const NotificationView(),
      binding: NotificationBinding(),
    ),
    GetPage(
      name: Routes.locationViewer,
      page: () => const LocationViewerView(),
      binding: LocationViewerBinding(),
    ),
    GetPage(
      name: Routes.docViewer,
      page: () => const DocumentViewerView(),
      binding: DocumentViewerBinding(),
    ),
    GetPage(
      name: Routes.nearMe,
      page: () => NearMeScreen(),
      binding: NearMeBinding(),
    ),
    GetPage(name: Routes.marketList, page: () => MarketListScreen()),
    GetPage(
      name: Routes.placeDetailsList,
      page: () => PlaceDetailsListScreen(),
    ),
    GetPage(name: Routes.workersList, page: () => WorkersListScreen()),
    GetPage(
      name: Routes.rentalDetailsList,
      page: () => RentalDetailsListScreen(),
    ),

    // Profile routes
    GetPage(
      name: Routes.profile,
      page: () => const ProfileView(),
      binding: ProfileBinding(),
    ),
    GetPage(
      name: Routes.profileEdit,
      page: () => const ProfileEditView(),
      binding: ProfileEditBinding(),
    ),
    GetPage(
      name: Routes.purchaseItems,
      page: () => const PurchaseItemsScreen(),
      binding: InventoryBinding(),
    ),
    // Task routes
    GetPage(
      name: Routes.task,
      page: () => const TaskView(),
      binding: TaskBinding(),
    ),
    GetPage(
      name: Routes.taskDetail,
      page: () => const TaskDetailView(),
      binding: TaskDetailsBinding(),
    ),

    // Subscription routes
    GetPage(
      name: Routes.subscriptionUsage,
      page: () => const SubscriptionUsageScreen(),
      binding: SubscriptionBinding(),
    ),
    GetPage(
      name: Routes.subscriptionPlans,
      page: () => const SubscriptionPlansScreen(),
      binding: SubscriptionBinding(),
    ),
    GetPage(
      name: Routes.subscriptionPayment,
      page: () => const PaymentScreen(),
      binding: SubscriptionBinding(),
    ),
    GetPage(
      name: Routes.paymentSuccess,
      page: () => const PaymentSuccessScreen(),
    ),
    GetPage(
      name: Routes.paymentFailed,
      page: () => const PaymentFailedScreen(),
    ),

    GetPage(
      name: Routes.addDocument,
      page: () => const AddDocumentView(),
      binding: DocumentBinding(),
    ),
    GetPage(
      name: Routes.fuelConsumption,
      page: () => ConsumptionView(),
      binding: ConsumptionBinding(),
    ),
    GetPage(
      name: Routes.landMapView,
      page: () => const LandMapView(),
      binding: LandMapViewBinding(),
    ),
    // lib/routes/app_pages.dart (add these routes)
    GetPage(
      name: Routes.schedules,
      page: () => const ScheduleListPage(),
      binding: ScheduleBinding(),
    ),
    GetPage(
      name: Routes.scheduleDeatils,
      page: () => const ScheduleDetailsPage(),
      binding: ScheduleBinding(),
    ),
    GetPage(
      name: Routes.addFuel,
      page: () => const FuelEntryView(),
      binding: FuelEntryBinding(),
    ),
    GetPage(
      name: Routes.addMachinery,
      page: () => const MachineryEntryScreen(),
      binding: FuelEntryBinding(),
    ),
    GetPage(
      name: Routes.addVehicle,
      page: () => const VehicleView(),
      binding: FuelEntryBinding(),
    ),
    GetPage(
      name: Routes.addInventoryItem,
      page: () => const FertilizerScreen(),
      binding: FuelEntryBinding(),
    ),
    GetPage(
      name: Routes.consumptionPurchaseList,
      page: () => const ConsumptionPurchaseView(),
      binding: ConsumptionPurchaseBinding(),
    ),
    GetPage(
      name: Routes.inventoryPurchaseDetail,
      page: () => const PurchaseDetails(),
      binding: FuelInventoryBinding(),
    ),
    GetPage(
      name: Routes.inventoryConsumptionDetails,
      page: () => const ConsumptionDetails(),
      binding: CunsumptionDetailBinding(),
    ),
    GetPage(
      name: Routes.employeeManager,
      page: () => const EmployeeManagerView(),
      binding: EmployeeManagerBinding(),
    ),
    GetPage(
      name: Routes.employeeDetails,
      page: () => const EmployeeDetailsView(),
      binding: EmployeeDetailsBinding(),
    ),
    GetPage(
      name: Routes.updateEmployeePayouts,
      page: () => const UpdateEmployeePayoutsView(),
      binding: UpdateEmployeePayoutsBinding(),
      transition: Transition.rightToLeftWithFade,
    ),
     GetPage(
      name: Routes.updateEmployeeAdvance,
      page: () => const UpdateEmployeeAdvanceView(),
      binding: EmployeeAdvanceBinding(),
      transition: Transition.cupertino,
    ),
   
  GetPage(
      name: Routes.employeeAdd,
      page: () => const CreateManagerScreen(),
      binding: /*EmployeeAdd(),*/ ManagerBinding(),
    ),
    
    GetPage(
      name: Routes.addAttendence,
      page: () =>  AddAttendenceScreen(),
      binding: AttendenceBinding(),
    ),

    GetPage(
      name: Routes.attendencelistscreen,
      page: () => const Attendancelistscreen(),
      binding: AttendenceBinding(),
    ),
       GetPage(
      name: Routes.addPayout,
      page: () => AddpayoutScreen(),
      binding: PayoutBinding(),
    ),

    GetPage(
      name: Routes.payoutlistscreen,
      page: () => const Payoutlistscreen(),
      binding: PayoutBinding(),
    ),
    // GetPage(
    //   name: '/inventory/:type/:id',
    //   page: () => const InventoryView(),
    //   binding: InventoryDetailBinding(),
    // ),
  ];
}
