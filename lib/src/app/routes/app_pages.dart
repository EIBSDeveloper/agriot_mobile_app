import 'package:argiot/src/app/modules/document/binding/document_viewer_binding.dart';
import 'package:argiot/src/app/modules/expense/binding/fuel_inventory_binding.dart';
import 'package:argiot/src/app/modules/expense/view/screens/fuel_inventory_view.dart';
import 'package:argiot/src/app/modules/map_view/bindings/land_map_view_binding.dart';
import 'package:argiot/src/app/modules/profile/views/screens/profile_edit_view.dart';
import 'package:argiot/src/app/modules/task/controller/schedule_binding.dart';
import 'package:argiot/src/app/modules/task/view/screens/schedule_list_page.dart';
import 'package:argiot/src/app/modules/guideline/binding/guideline_binding.dart';
import 'package:argiot/src/app/modules/guideline/view/screen/guidelines_view.dart';
import 'package:argiot/src/app/modules/sales/bindings/new_sales_binding.dart';
import 'package:argiot/src/app/modules/sales/view/new_sales_details_view.dart';
import 'package:argiot/src/app/modules/auth/view/screens/login_page.dart';
import 'package:argiot/src/app/modules/expense/view/screens/add_expense_screen.dart';
import 'package:argiot/src/app/modules/sales/view/add_deduction_view.dart';
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
import 'package:argiot/src/app/modules/bottombar/views/screens/home.dart';
import 'package:argiot/src/app/modules/forming/view/screen/crop_view.dart';
import 'package:argiot/src/app/modules/forming/view/screen/landi_add_page.dart';
import 'package:argiot/src/app/modules/task/view/screens/task_detail_view.dart';
import 'package:argiot/src/app/modules/subscription/view/screens/subscription_plans_screen.dart';
import 'package:argiot/src/app/modules/subscription/view/screens/subscription_usage_screen.dart';
import 'package:argiot/src/app/modules/vendor_customer/view/screens/vendor_customer_list_view.dart';
import 'package:argiot/src/app/modules/auth/view/screens/walkthrough_model.dart';
import 'package:argiot/src/app/modules/vendor_customer/view/screens/add_vendor_customer_view.dart';
import 'package:argiot/src/app/modules/vendor_customer/view/screens/vendor_customer_details_view.dart';
import 'package:get/get.dart';

import '../modules/task/view/screens/schedule_details_page.dart';
import '../modules/map_view/view/screens/land_map_view.dart';
import '../modules/sales/view/new_sales_view.dart';
import '../bindings/app_binding.dart';
import '../modules/auth/view/screens/otp_page.dart';
import '../modules/expense/binding/fuel_entry_binding.dart';
import '../modules/expense/view/screens/fuel_entry_view.dart';
import '../modules/inventory/view/purchase_items_screen.dart';
import '../modules/forming/controller/location_viewer_view.dart';
import '../modules/document/view/document_viewer_view.dart';
import '../modules/forming/view/screen/land_details_page.dart';
import '../modules/near_me/views/screen/view.dart';
import '../modules/notification/view/screen/notification_view.dart';
import '../modules/profile/views/screens/profile_view.dart';
import '../modules/registration/binding/registration_binding.dart';
import '../modules/registration/view/screen/regisster.dart';
import '../modules/sales/view/sales_list_view.dart';
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
      page: () => GuidelinesView(),
      binding: GuidelineBinding(),
    ),

    // GetPage(
    //   name: "/myEdit",
    //   page: () => SalesFormScreen(),
    //   binding: SalesBindings(),
    // ),
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
      page: () => const AddVendorCustomerView(),
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

    // GetPage(
    //   name: Routes.landEdit,
    //   page: () => const LandEditView(),
    //   binding: LandBinding(),
    // ),
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
      name: '/schedules',
      page: () => const ScheduleListPage(),
      binding: ScheduleBinding(),
    ),
    GetPage(
      name: '/schedule-details',
      page: () => ScheduleDetailsPage(
        landId: Get.arguments['landId'],
        cropId: Get.arguments['cropId'],
        scheduleId: Get.arguments['scheduleId'],
      ),
      binding: ScheduleBinding(),
    ),
    GetPage(
      name: '/fuel-expenses-entry',
      page: () => const FuelEntryView(),
      binding: FuelEntryBinding(),
    ),
    GetPage(
      name: '/machinery_entry',
      page: () => const MachineryEntryScreen(),
      binding: FuelEntryBinding(),
    ),
    GetPage(
      name: '/vehicle_entry',
      page: () => const VehicleView(),
      binding: FuelEntryBinding(),
    ),
    GetPage(
      name: '/fertilizer_entry',
      page: () => const FertilizerScreen(),
      binding: FuelEntryBinding(),
    ),
    GetPage(
      name: '/consumption-purchase',
      page: () => const ConsumptionPurchaseView(),
      binding: ConsumptionPurchaseBinding(),
    ),
    GetPage(
      name: '/fuel_inventory',
      page: () => const FuelInventoryView(),
      binding: FuelInventoryBinding(),
    ),
    // GetPage(
    //   name: '/inventory/:type/:id',
    //   page: () => const InventoryView(),
    //   binding: InventoryDetailBinding(),
    // ),
  ];
}