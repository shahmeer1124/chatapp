import 'package:firebase_core/firebase_core.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:intl/date_symbol_data_local.dart';
import 'package:lechat/common/services/services.dart';
import 'package:lechat/common/store/store.dart';
import 'package:lechat/firebase_options.dart';
import 'dart:async';

class Global {
  static Future init() async {
    WidgetsFlutterBinding.ensureInitialized();
    await Firebase.initializeApp(
      options: DefaultFirebaseOptions.currentPlatform,
    );
    await initializeDateFormatting('en_US', null);
    await Get.putAsync<StorageService>(() => StorageService().init());
    Get.put<UserStore>(UserStore());
    Get.put<ConfigStore>(ConfigStore());

  }
}
