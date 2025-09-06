import 'package:argiot/consumption_view.dart';
import 'package:argiot/land_details.dart';
import 'package:argiot/src/app/modules/expense/fuel.dart/consumption_purchase_binding.dart';
import 'package:argiot/src/app/modules/expense/fuel.dart/consumption_purchase_view.dart';
import 'package:argiot/src/app/modules/expense/fuel.dart/fertilizer_screen.dart';
import 'package:argiot/src/app/modules/expense/fuel.dart/machinery_entry_screen.dart';
import 'package:argiot/src/app/modules/expense/fuel.dart/vehicle_view.dart';
import 'package:argiot/guideline.dart';
import 'package:argiot/src/app/modules/subscription/payment_failed_screen.dart';
import 'package:argiot/src/app/modules/subscription/payment_screen.dart';
import 'package:argiot/src/app/modules/subscription/payment_success_screen.dart';
import 'package:argiot/src/app/modules/expense/add_expense_screen.dart';
import 'package:argiot/src/app/modules/expense/expense_overview_screen.dart';
import 'package:argiot/src/app/modules/expense/purchase_items_screen.dart';
import 'package:argiot/src/app/modules/forming/view/screen/crop_overview_screen.dart';
import 'package:argiot/src/app/modules/auth/view/screens/login_screen.dart';
import 'package:argiot/src/app/modules/auth/view/screens/splash_screen.dart';
import 'package:argiot/src/app/modules/bottombar/views/screens/home.dart';
import 'package:argiot/src/app/modules/forming/view/screen/crop_view.dart';
import 'package:argiot/src/app/modules/forming/view/screen/landi_add_page.dart';
import 'package:argiot/src/app/modules/task/view/screens/task_detail_view.dart';
import 'package:argiot/src/app/modules/subscription/subscription_plans_screen.dart';
import 'package:argiot/src/app/modules/subscription/subscription_usage_screen.dart';
import 'package:argiot/src/app/modules/vendor/vendor_customer_list_view.dart';
import 'package:argiot/src/app/modules/auth/view/screens/walkthrough_model.dart';
import 'package:get/get.dart';

import '../../bestschedule.dart';
import '../../fuel.dart';
import '../../map_view.dart';
import '../../test.dart';
import '../app/bindings/app_binding.dart';
import '../app/modules/auth/view/screens/otp_screen.dart';
import '../app/modules/expense/fuel.dart/fuel_entry_binding.dart';
import '../app/modules/expense/fuel.dart/fuel_entry_view.dart';
import '../app/modules/expense/fuel.dart/test.dart';
import '../app/modules/expense/fuel.dart/test_new.dart';
import '../app/modules/forming/controller/location_viewer_view.dart';
import '../app/modules/forming/view/screen/document_viewer_view.dart';
import '../app/modules/forming/view/screen/land_details_page.dart';
import '../app/modules/near_me/views/screen/view.dart';
import '../app/modules/notification/view/screen/notification_view.dart';
import '../app/modules/profile/views/screens/profile_view.dart';
import '../app/modules/registration/binding/registration_binding.dart';
import '../app/modules/registration/view/screen/regisster.dart';
import '../app/modules/sales/view/sales_list_view.dart';
import '../app/modules/task/view/screens/screen.dart';
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
      page: () => const CropViewPage(),
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
      // children: [
      //   GetPage(name: '/details', page: () => const SalesDetailView()),
      //   // GetPage(name: '/add', page: () => SalesAddEditView(isEdit: false)),
      //   // GetPage(name: '/edit', page: () => SalesAddEditView(isEdit: true)),
      // ],
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
    GetPage(
      name: Routes.purchaseItems,
      page: () => const PurchaseItemsScreen(),
      binding: InventoryBinding(),
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

    // Task routes
    GetPage(name: Routes.task, page: () => const TaskView(), binding: TaskBinding()),
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
      name: Routes.fuelList,
      page: () => FuelListScreen(),
      binding: FuelBindings(),
    ),
    GetPage(
      name: Routes.fuelPurchaseList,
      page: () => FuelPurchaseListScreen(),
    ),
    GetPage(
      name: Routes.addFuelPurchase,
      page: () => AddEditFuelPurchaseScreen(isEditing: false),
    ),
    GetPage(
      name: Routes.editFuelPurchase,
      page: () => AddEditFuelPurchaseScreen(isEditing: true),
    ),
    GetPage(
      name: Routes.fuelPurchaseDetails,
      page: () => FuelPurchaseDetailsScreen(),
    ),
    GetPage(
      name: Routes.landEdit,
      page: () => const LandEditView(),
      binding: LandBinding(),
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
    GetPage(
      name: '/inventory/:type/:id',
      page: () => const InventoryView(),
      binding: InventoryDetailBinding(),
    ),
  ];
}
