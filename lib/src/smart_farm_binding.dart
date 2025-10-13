import 'package:argiot/src/chat_repository.dart';
import 'package:argiot/src/smart_farm_controller.dart';
import 'package:get/get.dart';

class SmartFarmBinding extends Bindings {
  @override
  void dependencies() {
    Get.lazyPut<ChatRepository>(() => ChatRepository());

    Get.lazyPut<SmartFarmController>(
      () => SmartFarmController(repository: Get.find<ChatRepository>()),
    );
  }
}
