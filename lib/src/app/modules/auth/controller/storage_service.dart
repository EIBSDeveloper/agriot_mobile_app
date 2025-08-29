
import 'package:get/get.dart';
import 'package:get_storage/get_storage.dart';

import '../../../controller/app_controller.dart';

class StorageService extends GetxService {
  final GetStorage _box = GetStorage();

  @override
  Future<void> onInit() async {
    super.onInit();
    await GetStorage.init();
    await _box.writeIfNull('isLoggedIn', false);
  }

  Future<void> saveUserData(int user, String token) async {
    await _box.write('isLoggedIn', true);
    await _box.write('token', token);
    await _box.write('userId', user);
    await updateUser();
  }

  Future<void> updateUser({String? userid, String? tocken}) async {
    AppDataController appData = Get.put(AppDataController());
    appData.userId.value = userid ?? _box.read('userId').toString();
    return;
  }

  // UserData? get user {
  //   final userJson = _box.read('user');
  //   if (userJson != null) {
  //     return UserData.fromJson(userJson);
  //   }
  //   return null;
  // }

  String? get token => _box.read('token');
  int? get userid => _box.read('userId');

  bool get isLoggedIn => _box.read('isLoggedIn') ?? false;

  Future<void> clear() async {
    await _box.erase();
  }

  String getUserId() {
    return _box.read('userId') ?? "10";
  }
}
