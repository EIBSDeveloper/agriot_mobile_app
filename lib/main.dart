import 'dart:io';

import 'package:argiot/firebase_options.dart';
import 'package:argiot/src/app/modules/expense/controller/expense_isolate.dart';
import 'package:argiot/src/app.dart';
import 'package:firebase_core/firebase_core.dart';
import 'package:flutter/material.dart';
import 'package:get_storage/get_storage.dart';

Future<void> main() async {
  ExpenseIsolate.initialize();
  WidgetsFlutterBinding.ensureInitialized();
   if (Platform.isAndroid) {
    // GoogleMapsFlutterPlatform.instance.useAndroidViewSurface = true;
  }
  await GetStorage.init();
  await Firebase.initializeApp(options: DefaultFirebaseOptions.currentPlatform);
  runApp(const App());
}
 