
import 'package:get/get.dart';

// Filter
class LocationController extends GetxController {
  RxDouble latitude = 0.0.obs;
  RxDouble longitude = 0.0.obs;
  RxDouble tempLatitude = 0.0.obs;
  RxDouble tempLongitude = 0.0.obs;
  RxInt locationChange = 0.obs;
  RxString errLatitude = "".obs;
  RxString address = "".obs;

}
