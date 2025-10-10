import 'package:get/get.dart';
import 'package:get_storage/get_storage.dart';

import '../modules/auth/model/verify_otp.dart';
import 'app_controller.dart';

class StorageService extends GetxService {
  final GetStorage _box = GetStorage();

  @override
  Future<void> onInit() async {
    super.onInit();
    // await GetStorage.init();
    await _box.writeIfNull('isLoggedIn', false);
  }

  Future<void> saveUserData(VerifyOtp data) async {
    await _box.write('userId', data.farmerID);
    await _box.write('isManager', data.isManager);
    await _box.write('managerID', data.managerID);
    await updateUser(data: data);
  }

  Future<void> updateLoginState(bool status) async {
    await _box.write('isLoggedIn', status);
    await updateUser();
  }

  Future<bool> getLoginState() async {
    bool? status = _box.read('isLoggedIn');
    return status ?? false;
  }

  Future<void> updateUser({VerifyOtp? data}) async {
    AppDataController appData = Get.put(AppDataController());
    appData.farmerId.value =
        data?.farmerID.toString() ?? _box.read('userId').toString();
    var read = _box.read('isManager');
    var isManager2 = data?.isManager;
    var val = isManager2 ?? read??false;
    appData.isManager.value = val;
    appData.managerID.value =
        (data?.managerID?.toString()) ??
        _box.read('managerID')?.toString() ??
        '';
    appData.update();
    return;
  }

  bool get isLoggedIn => _box.read('isLoggedIn') ?? false;

  Future<void> clear() async {
    await _box.erase();
  }
}
