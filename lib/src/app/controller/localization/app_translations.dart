import 'package:argiot/src/app/controller/localization/languges/english.dart';
import 'package:argiot/src/app/controller/localization/languges/hindi.dart';
import 'package:argiot/src/app/controller/localization/languges/tamil.dart';
import 'package:get/get.dart';

class AppTranslations extends Translations {
  @override
  Map<String, Map<String, String>> get keys => {
    'ta_IN': Tamil.list,
    'hi_IN': Hindi.list,
    'en_US': English.list,
  };
}
