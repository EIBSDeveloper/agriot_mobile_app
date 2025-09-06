import 'package:argiot/land_details.dart';
import 'package:argiot/src/app/modules/expense/expense_controller.dart';
import 'package:argiot/src/app/modules/expense/expense_repository.dart';
import 'package:argiot/src/app/controller/storage_service.dart';
import 'package:argiot/src/app/utils/http/http_service.dart';
import 'package:argiot/src/app/modules/task/view/screens/task_details_controller.dart';
import 'package:argiot/src/app/modules/subscription/subscription_controller.dart';
import 'package:argiot/src/app/modules/vendor/vendor_customer_controller.dart';
import 'package:argiot/src/app/modules/vendor/vendor_customer_repository.dart';
import 'package:get/get.dart';
import 'package:get_storage/get_storage.dart';
import '../../../consumption_controller.dart';
import '../controller/user_limit.dart';
import '../modules/inventory/controller/inventory_controller.dart';
import '../modules/auth/view/screens/walkthrough_model.dart';
import '../controller/app_controller.dart';
import '../controller/network_contoller.dart';
import '../modules/auth/controller/splash_controller.dart';
import '../modules/auth/repository/auth_repository.dart';
import '../modules/bottombar/contoller/bottombar_contoller.dart';
import '../modules/dashboad/controller/controller.dart';
import '../modules/dashboad/repostory/repostory.dart';
import '../modules/forming/controller/crop_controller.dart';
import '../modules/forming/controller/crop_details_controller.dart';
import '../modules/forming/controller/forming_controller.dart';
import '../modules/forming/controller/land_controller.dart';
import '../modules/forming/controller/land_detail_controller.dart';
import '../modules/forming/repostroy/forming_repository.dart';
import '../modules/forming/view/screen/document_viewer_controller.dart';
import '../modules/near_me/controller/controllers.dart';
import '../modules/near_me/repostory/near_me_repository.dart';
import '../modules/notification/Repository/notification_repository.dart';
import '../modules/notification/controller/notification_controller.dart';
import '../modules/profile/controller/controller.dart';
import '../modules/registration/binding/registration_binding.dart';
import '../modules/registration/controller/kyc_controller.dart';
import '../modules/registration/controller/land_controller.dart';
import '../modules/registration/controller/land_picker_controller.dart';
import '../modules/registration/controller/location_picker_controller.dart';
import '../modules/registration/repostrory/crop_service.dart';
import '../modules/registration/repostrory/land_service.dart';
import '../modules/sales/controller/controller.dart';
import '../modules/sales/controller/repostroty.dart';
import '../modules/task/controller/controller.dart';
import '../modules/task/repostory/task_repository.dart';

class AppBinding implements Bindings {
  @override
  void dependencies() {
    // Initialize fundamental services first

    Get.put(AppDataController(), permanent: true);
    Get.put(GetStorage(), permanent: true);
    Get.put(GetConnect(), permanent: true);

    //Service
    Get.put(NetworkController(), permanent: true);
    Get.lazyPut(() => StorageService(), fenix: true);
    Get.lazyPut(() => HttpService(), fenix: true);

    RegistrationBinding().dependencies();
    Get.lazyPut(() => AuthRepository(), fenix: true);
    Get.put(UserLimitController(), permanent: true);
  }
}

class HomeBinding implements Bindings {
  @override
  void dependencies() {
    Get.lazyPut(() => BottomBarContoller());
    Get.lazyPut(() => DashboardRepository());
    Get.lazyPut(() => DashboardController());
    Get.lazyPut<FormingRepository>(() => FormingRepository());
    Get.lazyPut<FormingController>(() => FormingController());
    Get.lazyPut<LandDetailController>(() => LandDetailController());
    Get.lazyPut<TaskRepository>(() => TaskRepository());
    Get.lazyPut<TaskController>(() => TaskController());
    Get.lazyPut(() => ExpenseController());
    Get.lazyPut(() => ExpenseRepository());
    Get.lazyPut<VendorCustomerController>(() => VendorCustomerController());
    Get.lazyPut<VendorCustomerRepository>(() => VendorCustomerRepository());
    // Get.lazyPut<AddressService>(() => AddressService());
    Get.lazyPut<InventoryController>(() => InventoryController(), fenix: true);
  }
}

class DashboardBinding implements Bindings {
  @override
  void dependencies() {
    Get.lazyPut(() => DashboardRepository());
    Get.lazyPut(() => DashboardController());
  }
}

class FormingBinding implements Bindings {
  @override
  void dependencies() {
    Get.lazyPut<FormingRepository>(() => FormingRepository());
    Get.lazyPut<FormingController>(() => FormingController());
    Get.lazyPut<LandDetailController>(() => LandDetailController());
  }
}

class TaskBinding implements Bindings {
  @override
  void dependencies() {
    Get.lazyPut<TaskRepository>(() => TaskRepository());
    Get.lazyPut<TaskController>(() => TaskController());
  }
}

class SalesBinding implements Bindings {
  @override
  void dependencies() {
    Get.lazyPut(() => SalesRepository());
    Get.lazyPut(() => SalesController());
  }
}

class DocumentViewerBinding implements Bindings {
  @override
  void dependencies() {
    Get.lazyPut<DocumentViewerController>(() => DocumentViewerController());
  }
}

class ExpenseBinding implements Bindings {
  @override
  void dependencies() {
    Get.lazyPut(() => ExpenseController());
    Get.lazyPut(() => ExpenseRepository());
  }
}

class NotificationBinding extends Bindings {
  @override
  void dependencies() {
    Get.lazyPut<NotificationController>(() => NotificationController());
    Get.lazyPut<NotificationRepository>(() => NotificationRepository());
  }
}

class ProfileBinding implements Bindings {
  @override
  void dependencies() {
    Get.lazyPut<ProfileRepository>(() => ProfileRepository());
    Get.lazyPut<ProfileController>(() => ProfileController());
  }
}

class ProfileEditBinding implements Bindings {
  @override
  void dependencies() {
    Get.lazyPut<ProfileEditController>(() => ProfileEditController());
    // Get.lazyPut<AddressService>(() => AddressService());
  }
}

class SubscriptionBinding implements Bindings {
  @override
  void dependencies() {
    Get.lazyPut(() => SubscriptionController());
  }
}

class TaskDetailsBinding implements Bindings {
  @override
  void dependencies() {
    final arguments = Get.arguments as Map<String, dynamic>? ?? {};

    final taskId = arguments['taskId'] as int;

    Get.lazyPut(() => TaskDetailsController(taskId: taskId));
  }
}

class VendorCustomerBinding extends Bindings {
  @override
  void dependencies() {
    Get.lazyPut<VendorCustomerController>(() => VendorCustomerController());
    Get.lazyPut<VendorCustomerRepository>(() => VendorCustomerRepository());
    // Get.lazyPut<AddressService>(() => AddressService());
  }
}

class CropBinding implements Bindings {
  @override
  void dependencies() {
    Get.lazyPut<LocationPickerController>(
      () => LocationPickerController(),
      fenix: false,
    );
    Get.lazyPut<LandService>(() => LandService(), fenix: false);
    Get.lazyPut<RegLandController>(() => RegLandController(), fenix: false);
    Get.lazyPut<CropService>(() => CropService(), fenix: false);
    Get.lazyPut<CropController>(() => CropController(), fenix: false);
  }
}

class CropDetailsBinding implements Bindings {
  @override
  void dependencies() {
    Get.lazyPut(() => FormingRepository());
    Get.lazyPut(() => CropDetailsController());
  }
}

class LandAddBinding implements Bindings {
  @override
  void dependencies() {
    Get.lazyPut<LandService>(() => LandService(), fenix: false);
    // Get.lazyPut<AddressService>(() => AddressService(), fenix: false);
    Get.lazyPut<KycController>(() => KycController(), fenix: false);
    Get.lazyPut<LandController>(() => LandController());
  }
}

class LocationViewerBinding implements Bindings {
  @override
  void dependencies() {
    Get.lazyPut<LandPickerController>(
      () => LandPickerController(),
      fenix: false,
    );
    Get.lazyPut<LocationPickerController>(
      () => LocationPickerController(),
      fenix: false,
    );
  }
}

class LandPickerViewerBinding implements Bindings {
  @override
  void dependencies() {
    Get.lazyPut<LandPickerController>(
      () => LandPickerController(),
      fenix: false,
    );
  }
}

class SplashBinding extends Bindings {
  @override
  void dependencies() {
    Get.lazyPut<SplashController>(() => SplashController());
  }
}

class NearMeBinding implements Bindings {
  @override
  void dependencies() {
    Get.lazyPut(() => NearMeRepository());
    Get.lazyPut(() => NearMeController());
  }
}

class WalkthroughBinding implements Bindings {
  @override
  void dependencies() {
    Get.lazyPut<WalkthroughController>(() => WalkthroughController());
  }
}

class InventoryBinding implements Bindings {
  @override
  void dependencies() {
    
    Get.lazyPut<InventoryController>(() => InventoryController(), fenix: true);
  }
}

class LandBinding implements Bindings {
  @override
  void dependencies() {
    Get.lazyPut(() => KycController());
    Get.lazyPut(() => InventoryCommonController());
    Get.lazyPut(() => LandRepository());
    Get.lazyPut(() => LandEditController());
  }
}

class ConsumptionBinding extends Bindings {
  @override
  void dependencies() {
    Get.lazyPut(() => ConsumptionController());
  }
}
