import 'dart:async';
import 'package:awesome_notifications/awesome_notifications.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_messaging/firebase_messaging.dart';
import 'package:flutter/material.dart';
import 'package:flutter_easyloading/flutter_easyloading.dart';
import 'package:get/get.dart';
import 'package:intl/date_symbol_data_local.dart';
import 'package:async/async.dart';
import 'package:lechat/common/apis/apis.dart';
import 'package:lechat/common/entities/base.dart';
import 'package:lechat/common/routes/names.dart';
import 'package:lechat/pages/messages/state.dart';
import '../../common/entities/message.dart';
import '../../common/entities/msg.dart';
import '../../common/store/user.dart';
import 'package:pull_to_refresh/pull_to_refresh.dart';

class MessageController extends GetxController {
  MessageController();

  final state = MessageState();
  final db = FirebaseFirestore.instance;
  final token = UserStore.to.profile.token;

  void goprofile() async {
    await Get.toNamed(AppRoutes.Profile);
  }

  goTabStatus() {
    EasyLoading.show(
      indicator: CircularProgressIndicator(),
      maskType: EasyLoadingMaskType.clear,
      dismissOnTap: true,
    );
    state.tabstatus.value = !state.tabstatus.value;
    if (state.tabstatus.value) {
      asyncLoadMsgData();
    } else {}
  }

  asyncLoadMsgData() async {
    var from_messages = await db
        .collection('message')
        .withConverter(
            fromFirestore: Msg.fromFirestore,
            toFirestore: (Msg msg, options) => msg.toFirestore())
        .where('from_token', isEqualTo: token)
        .get();
    var to_messages = await db
        .collection('message')
        .withConverter(
            fromFirestore: Msg.fromFirestore,
            toFirestore: (Msg msg, options) => msg.toFirestore())
        .where('to_token', isEqualTo: token)
        .get();
    state.msgslist.clear();
    if (from_messages.docs.isNotEmpty) {
      print('msglength${from_messages.docs.length}');
      await addMessages(from_messages.docs);
    }

    if (to_messages.docs.isNotEmpty) {
      print('msglength2${to_messages.docs.length}');

      await addMessages(to_messages.docs);
    }
  }

  addMessages(List<QueryDocumentSnapshot<Msg>> data) {
    data.forEach((element) {
      var item = element.data();
      Message message = Message();
      message.doc_id = element.id;
      message.last_time = item.last_time;
      message.msg_num = item.msg_num;
      message.last_msg = item.last_msg;
      if (item.from_token == token) {
        message.name = item.to_name;
        message.avatar = item.to_avatar;
        message.token = item.to_token;
        message.online = item.to_online;
        message.msg_num = item.to_msg_num;
      } else {
        message.name = item.from_name;
        message.avatar = item.from_avatar;
        message.token = item.from_token;
        message.online = item.from_online;
        message.msg_num = item.from_msg_num;
      }
      state.msgslist.add(message);
    });
  }

  @override
  void onReady() {
    firebaseMessageSetup();
    super.onReady();
  }

  @override
  void onInit() {
    _snapShots();
    super.onInit();
  }

  _snapShots() {
    var token = UserStore.to.profile.token;
    final toMessageRef = db
        .collection('message')
        .withConverter(
            fromFirestore: Msg.fromFirestore,
            toFirestore: (Msg msg, options) => msg.toFirestore())
        .where('to_token', isEqualTo: token);
    final fromMessageRef = db
        .collection('message')
        .withConverter(
            fromFirestore: Msg.fromFirestore,
            toFirestore: (Msg msg, options) => msg.toFirestore())
        .where('from_token', isEqualTo: token);
    toMessageRef.snapshots().listen((event) {
      asyncLoadMsgData();
    });
    fromMessageRef.snapshots().listen((event) {
      asyncLoadMsgData();
    });
  }

  firebaseMessageSetup() async {
    String? fcmtoken = await FirebaseMessaging.instance.getToken();
    print('my device fcm token is $fcmtoken');
    if (fcmtoken != null) {
      BindFcmTokenRequestEntity bindFcmTokenRequestEntity =
          BindFcmTokenRequestEntity();
      bindFcmTokenRequestEntity.fcmtoken = fcmtoken;
      await ChatAPI.bind_fcmtoken(params: bindFcmTokenRequestEntity);
    }
  }

  // void onrefresh() {
  //   asyncLoadAllData().then((_) {
  //     refreshController.refreshCompleted(resetFooterState: true);
  //   }).catchError((_) {
  //     refreshController.refreshFailed();
  //   });
  // }

  // @override
  // void onInit() {
  //   asyncLoadAllData();
  //   FirebaseMessaging.onMessage.listen((RemoteMessage message) {
  //     String? titlemessage = message.notification!.title;
  //     String? body = message.notification!.body;

  //     if (body == 'message:Incoming Call') {
  //       AwesomeNotifications().createNotification(
  //           content: NotificationContent(
  //             id: 123,
  //             channelKey: 'call_channel',
  //             color: Colors.white,
  //             title: titlemessage,
  //             body: body,
  //             category: NotificationCategory.Call,
  //             wakeUpScreen: true,
  //             fullScreenIntent: true,
  //             autoDismissible: false,
  //             backgroundColor: Colors.orange,
  //           ),
  //           actionButtons: [
  //             NotificationActionButton(
  //                 key: "Accept",
  //                 label: 'Accept Call',
  //                 autoDismissible: true,
  //                 color: Colors.green),
  //             NotificationActionButton(
  //                 key: "Reject",
  //                 label: 'Reject Call',
  //                 autoDismissible: true,
  //                 color: Colors.red)
  //           ]);
  //     }
  //     AwesomeNotifications().setListeners(
  //       onActionReceivedMethod: (ReceivedAction action) async {
  //         if (action.buttonKeyPressed == 'Reject') {
  //           print('Call reject');
  //         } else if (action.buttonKeyPressed == 'Accept') {
  //           // Extract data from the payload
  //           Map<String, dynamic> payloadData = action.payload ?? {};

  //           // Access the data you sent in the payload
  //           String toName = payloadData['to_name'] ?? '';
  //           String toAvatar = payloadData['to_avatar'] ?? '';
  //           String docId = payloadData['doc_id'] ?? '';
  //           String toToken = payloadData['to_token'] ?? '';

  //           // Now you can use the extracted data as needed
  //           print('Received notification with data:');
  //           print('to_name: $toName');
  //           print('to_avatar: $toAvatar');
  //           print('doc_id: $docId');
  //           print('to_token: $toToken');

  //           // You can navigate to your desired screen with this data
  //           Get.toNamed(AppRoutes.VoiceCall, parameters: {
  //             "to_name": toName,
  //             "to_avatar": toAvatar,
  //             "to_token": toToken,
  //             "from_other": "no"
  //           });
  //         }
  //       },
  //     );
  //   });
  //   super.onInit();
  // }

  // void onloading() {
  //   asyncLoadAllData().then((_) {
  //     refreshController.loadComplete();
  //   }).catchError((_) {
  //     refreshController.loadFailed();
  //   });
  // }

  // asyncLoadAllData() async {
  //   token = UserStore.to.msgtoken;
  //   print('thisisthetoken$token');
  //   initializeDateFormatting();
  //   Set<String> addedDocumentIds = Set<String>();

  //   fromTokenSubscription = db
  //       .collection('message')
  //       .withConverter(
  //           fromFirestore: Msg.fromFirestore,
  //           toFirestore: (Msg msg, options) => msg.toFirestore())
  //       .where('from_token', isEqualTo: token)
  //       .snapshots()
  //       .listen((fromSnapshot) {
  //     if (fromSnapshot.docs.isNotEmpty) {
  //       _incomingMessagesController.add(fromSnapshot.docs);
  //       for (var doc in fromSnapshot.docs) {
  //         String documentId = doc.id;
  //         if (!addedDocumentIds.contains(documentId)) {
  //           state.msglist.add(doc); // Add the received data to state.msglist
  //           addedDocumentIds.add(documentId);
  //         }
  //       }
  //     }
  //   });
  //   toTokenSubscription = db
  //       .collection('message')
  //       .withConverter(
  //           fromFirestore: Msg.fromFirestore,
  //           toFirestore: (Msg msg, options) => msg.toFirestore())
  //       .where('to_token', isEqualTo: token)
  //       .snapshots()
  //       .listen((toSnapshot) {
  //     if (toSnapshot.docs.isNotEmpty) {
  //       _outgoingMessagesController.add(toSnapshot.docs);
  //       for (var doc in toSnapshot.docs) {
  //         String documentId = doc.id;
  //         if (!addedDocumentIds.contains(documentId)) {
  //           state.msglist.add(doc); // Add the received data to state.msglist
  //           addedDocumentIds.add(documentId);
  //         }
  //       }
  //     }
  //   });
  // }
}
