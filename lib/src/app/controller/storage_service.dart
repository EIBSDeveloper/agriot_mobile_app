import 'package:get/get.dart';
import 'package:get_storage/get_storage.dart';

import 'app_controller.dart';

class StorageService extends GetxService {
  final GetStorage _box = GetStorage();

  @override
  Future<void> onInit() async {
    super.onInit();
    // await GetStorage.init();
    await _box.writeIfNull('isLoggedIn', false);
  }

  Future<void> saveUserData(String user) async {
    await _box.write('userId', user);
    await updateUser();
  }

  Future<void> updateLoginState(bool status) async {
    await _box.write('isLoggedIn', status);
    await updateUser();
  }

  Future<bool> getLoginState() async {
    bool? status = _box.read('isLoggedIn');

    return status ?? false;
  }

  Future<void> updateUser({String? userid}) async {
    AppDataController appData = Get.put(AppDataController());
    appData.farmerId.value = userid ?? _box.read('userId').toString();
    return;
  }

  String? get token => _box.read('token');
  int? get userid => _box.read('userId');

  bool get isLoggedIn => _box.read('isLoggedIn') ?? false;

  Future<void> clear() async {
    await _box.erase();
  }
  String getUserId() => _box.read('userId') ?? "10";

}
