import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_messaging/firebase_messaging.dart';
import 'package:flutter/material.dart';
import 'package:flutter_easyloading/flutter_easyloading.dart';
import 'package:get/get.dart';
import 'package:lechat/common/apis/apis.dart';
import 'package:lechat/common/entities/base.dart';
import 'package:lechat/common/entities/chatcall.dart';
import 'package:lechat/common/routes/names.dart';
import 'package:lechat/pages/messages/state.dart';
import '../../common/entities/message.dart';
import '../../common/entities/msg.dart';
import '../../common/store/user.dart';

class MessageController extends GetxController {
  MessageController();
  final state = MessageState();
  final db = FirebaseFirestore.instance;
  final token = UserStore.to.profile.token;
  void getProfile() async {
    var profile = await UserStore.to.profile;
    state.head_detail.value = profile;
    state.head_detail.refresh();
  }

  void goprofile() async {
    await Get.toNamed(AppRoutes.Profile, arguments: state.head_detail.value);
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
    } else {
      asyncLoadCallData();
    }
    EasyLoading.dismiss();
  }

  Future<void> asyncLoadCallData() async {
    var from_chatcall = await db
        .collection('chatcall')
        .withConverter(
            fromFirestore: ChatCall.fromFirestore,
            toFirestore: (ChatCall msg, options) => msg.toFirestore())
        .where('from_token', isEqualTo: token)
        .limit(30)
        .get();
    var to_chatcall = await db
        .collection('chatcall')
        .withConverter(
            fromFirestore: ChatCall.fromFirestore,
            toFirestore: (ChatCall msg, options) => msg.toFirestore())
        .where('to_token', isEqualTo: token)
        .limit(30)
        .get();
    state.calllist.clear();
    if (from_chatcall.docs.isNotEmpty) {
      await addChatCall(from_chatcall.docs);
    }

    if (to_chatcall.docs.isNotEmpty) {
      await addChatCall(to_chatcall.docs);
    }
    state.calllist.value.sort((a, b) {
      if (b.last_time == null) {
        return 0;
      }
      if (a.last_time == null) {
        return 0;
      }
      return b.last_time!.compareTo(a.last_time!);
    });
  }

  addChatCall(List<QueryDocumentSnapshot<ChatCall>> data) {
    data.forEach((element) {
      var item = element.data();
      CallMessage message = CallMessage();
      message.doc_id = element.id;
      message.last_time = item.last_time;
      message.call_time = item.call_time;
      if (item.from_token == token) {
        message.name = item.to_name;
        message.avatar = item.to_avatar;
        message.token = item.to_token;
      } else {
        message.name = item.from_name;
        message.avatar = item.from_avatar;
        message.token = item.from_token;
      }
      state.calllist.add(message);
    });
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
      await addMessages(from_messages.docs);
    }

    if (to_messages.docs.isNotEmpty) {
      await addMessages(to_messages.docs);
    }
    state.msgslist.value.sort((a, b) {
      if (b.last_time == null) {
        return 0;
      }
      if (a.last_time == null) {
        return 0;
      }
      return b.last_time!.compareTo(a.last_time!);
    });
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
    getProfile();
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
    if (fcmtoken != null) {
      BindFcmTokenRequestEntity bindFcmTokenRequestEntity =
          BindFcmTokenRequestEntity();
      bindFcmTokenRequestEntity.fcmtoken = fcmtoken;
      await ChatAPI.bind_fcmtoken(params: bindFcmTokenRequestEntity);
    }
  }
}
