import 'dart:async';
import 'package:firebase_messaging/firebase_messaging.dart';
import 'package:flutter/material.dart';
import 'package:flutter_easyloading/flutter_easyloading.dart';
import 'package:flutter_local_notifications/flutter_local_notifications.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:get/get.dart';
import 'package:lechat/common/routes/routes.dart';
import 'package:lechat/common/style/style.dart';

import 'common/utils/FirebaseMassagingHandler.dart';
import 'global.dart';

Future<void> main() async {
  await Global.init();
  await firebaseChatInit().whenComplete(() => FirebaseMassagingHandler.config());
  runApp(const MyApp());
}

Future firebaseChatInit() async {
  FirebaseMessaging.onBackgroundMessage(
      FirebaseMassagingHandler.firebaseMessagingBackground);
  if (GetPlatform.isAndroid) {
    FirebaseMassagingHandler.flutterLocalNotificationsPlugin
        .resolvePlatformSpecificImplementation<
            AndroidFlutterLocalNotificationsPlugin>()!
        .createNotificationChannel(FirebaseMassagingHandler.channel_call);
    FirebaseMassagingHandler.flutterLocalNotificationsPlugin
        .resolvePlatformSpecificImplementation<
            AndroidFlutterLocalNotificationsPlugin>()!
        .createNotificationChannel(FirebaseMassagingHandler.channel_message);
  }
}
// Upgrading Flutter to 3.13.6 from 3.10.5 in C:\src\flutter...
class MyApp extends StatelessWidget {
  const MyApp({super.key});
  @override
  Widget build(BuildContext context) {
    return ScreenUtilInit(
      designSize: const Size(360, 780),
      builder: (context, child) {
        return GetMaterialApp(
          title: 'Flutter Demo',
          theme: AppTheme.light,
          debugShowCheckedModeBanner: false,
          initialRoute: AppPages.INITIAL,
          getPages: AppPages.routes,
          builder: EasyLoading.init(),
      
        );
      },
    );
  }
}
