import 'package:awesome_notifications/awesome_notifications.dart';
import 'package:firebase_core/firebase_core.dart';
import 'package:firebase_messaging/firebase_messaging.dart';
import 'package:flutter/material.dart';
import 'package:flutter_background_service/flutter_background_service.dart';
import 'package:get/get.dart';
import 'package:lechat/common/services/services.dart';
import 'package:lechat/common/store/store.dart';
import 'package:lechat/firebase_options.dart';
import 'dart:async';
import 'package:flutter_background_service_android/flutter_background_service_android.dart';

import 'common/routes/names.dart';

class Global {
  static Future init() async {
    WidgetsFlutterBinding.ensureInitialized();
    await Firebase.initializeApp(
      options: DefaultFirebaseOptions.currentPlatform,
    );
    await Get.putAsync<StorageService>(() => StorageService().init());
    Get.put<UserStore>(UserStore());

    initializeService();
  }
}

Future<void> initializeService() async {
  final service = FlutterBackgroundService();
  await service.configure(
    iosConfiguration: IosConfiguration(),
    androidConfiguration: AndroidConfiguration(
      initialNotificationContent: '',
      initialNotificationTitle: '',
      onStart: onStart,
      isForegroundMode: true, // Set this to true for a Foreground Service
    ),
  );
  AwesomeNotifications().initialize(null, [
    NotificationChannel(
      channelKey: 'call_channel',
      channelName: 'call_channel',
      channelDescription: 'channel of calling',
      defaultColor: Colors.redAccent,
      ledColor: Colors.white,
      importance: NotificationImportance.Max,
      channelShowBadge: true,
      locked: true,
      defaultRingtoneType: DefaultRingtoneType.Ringtone,
    )
  ]);
  FirebaseMessaging.onBackgroundMessage(backgroundHandler);

  await service.startService();
}

@pragma('vm:entry-point')
void onStart(ServiceInstance service) async {
  await Firebase.initializeApp(
    options: DefaultFirebaseOptions.currentPlatform,
  );
  await Get.putAsync<StorageService>(() => StorageService().init());
  Get.put<UserStore>(UserStore());
  if (service is AndroidServiceInstance) {
    service.on('setAsForeground').listen((event) {
      service.setAsForegroundService();
    });
    service.on('setAsBackground').listen((event) {
      service.setAsBackgroundService();
    });
  }
  service.on('stopService').listen((event) {
    service.stopSelf();
  });
}

Future<void> backgroundHandler(RemoteMessage message) async {
  print('background handler activated');
  String? titlemessage = message.notification!.title;
  String? body = message.notification!.body;
  if (body == 'message:Incoming Call') {
    AwesomeNotifications().createNotification(
        content: NotificationContent(
          id: 123,
          channelKey: 'call_channel',
          color: Colors.white,
          title: titlemessage,
          body: body,
          category: NotificationCategory.Call,
          wakeUpScreen: true,
          fullScreenIntent: true,
          autoDismissible: false,
          backgroundColor: Colors.orange,
        ),
        actionButtons: [
          NotificationActionButton(
              key: "Accept",
              label: 'Accept Call',
              autoDismissible: true,
              color: Colors.green),
          NotificationActionButton(
              key: "Reject",
              label: 'Reject Call',
              autoDismissible: true,
              color: Colors.red)
        ]);
  }
  AwesomeNotifications().setListeners(
      onActionReceivedMethod: (ReceivedAction action) async {
    if (action.buttonKeyPressed == 'Reject') {
      
    } else if (action.buttonKeyPressed == 'Accept') {}
  });
}
