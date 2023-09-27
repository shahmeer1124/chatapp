import 'dart:convert';

import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:lechat/common/entities/entities.dart';
import 'package:lechat/common/store/store.dart';
import 'package:lechat/pages/messages/chat/state.dart';
import '../../../common/entities/msgcontent.dart';
import '../../../common/routes/names.dart';
import 'package:http/http.dart' as http;

class ChatController extends GetxController {
  ChatController();

  var listener;
  late String token = UserStore.to.msgtoken;
  late UserItem name = UserStore.to.profile;

  final db = FirebaseFirestore.instance;
  ScrollController msgScrolling = ScrollController();
  late String doc_id;
  final state = ChatState();
  final textController = TextEditingController();
  void gomore() {
    state.more_status.value = state.more_status.value ? false : true;
  }

  @override
  void onReady() {
    super.onReady();

    var messages = db
        .collection('message')
        .doc(doc_id)
        .collection('msglist')
        .withConverter(
            fromFirestore: Msgcontent.fromFirestore,
            toFirestore: (Msgcontent msgcontent, options) =>
                msgcontent.toFirestore())
        .orderBy('addtime', descending: false);
    state.msgcontentList.clear();
    listener = messages.snapshots().listen((event) {
      for (var change in event.docChanges) {
        switch (change.type) {
          case DocumentChangeType.added:
            if (change.doc.data() != null) {
              var messageContent = change.doc.data()!;
              if (messageContent.token != token) {
                markMessageAsSeen(doc_id, change.doc.id);
              }
              state.msgcontentList.insert(0, messageContent);
            }
            break;
          case DocumentChangeType.modified:
            break;
          case DocumentChangeType.removed:
            break;
        }
      }
    }, onError: (error) => print(error));
  }

  Future<void> markMessageAsSeen(String docId, String messageId) async {
    await db
        .collection('message')
        .doc(docId)
        .collection("msglist")
        .doc(messageId)
        .update({'isSeen': true});
    await db.collection('message').doc(docId).update({'last_msg_seen': true});
  }

  sendMessage() async {
    String sendcontent = textController.text;
    textController.clear();
    final content = Msgcontent(
      token: token,
      content: sendcontent,
      type: 'text',
      addtime: Timestamp.now(),
    );

    // Add the message to the database
    await db
        .collection('message')
        .doc(doc_id)
        .collection("msglist")
        .withConverter(
            fromFirestore: Msgcontent.fromFirestore,
            toFirestore: (Msgcontent msgcontent, options) =>
                msgcontent.toFirestore())
        .add(content)
        .then((value) {
      // Get.focusScope?.unfocus();
    });
    sendPushNotification(name.name.toString(), sendcontent);
    await db.collection("message").doc(doc_id).update({
      'last_msg': sendcontent,
      'last_time': Timestamp.now(),
      'last_message_token': token,
      'last_msg_seen': false
    });
  }

  Future<String?> getFCMTokenFromFirestore() async {
    print('tokenchecker${state.to_token}');
    final usersCollectionRef = FirebaseFirestore.instance.collection('users');
    final userSnapshot = await usersCollectionRef
        .where('token', isEqualTo: state.to_token.toString())
        .get();

    if (userSnapshot.docs.isNotEmpty) {
      final userData = userSnapshot.docs[0].data();
      final fcmToken = userData['fcmtoken'] as String?;
      print('fcmtokenprinter$fcmToken');
      return fcmToken;
    }

    return null; // Return null if no matching user is found
  }

  Future<void> sendPushNotification(String title, String message) async {
    String? fcmToken = await getFCMTokenFromFirestore();
    List<Future<void>> futures = [];

    Map<String, dynamic> notification = {
      'notification': {'title': title, 'body': 'message:${message}'},
      'data': {
        "click_action": "FLUTTER_NOTIFICATION_CLICK",
        "id": "1",
        "status": "done"
      },
      'to': fcmToken,
    };
    String url = 'https://fcm.googleapis.com/fcm/send';
    Map<String, String> headers = {
      'Content-Type': 'application/json',
      'Authorization':
          'key=AAAAUZ4qyhg:APA91bHCN0v2yWsBEcXRk1FzouUh0qypYzdpQ9W4oc1sHTnvRn3Lntmp0BbY0A0vsUkVsLkGKPFu5GfH-Upco4O4QilgtumXq9zwcDWg0SjKFEpM_ilxdw8hDyn1Js5rKaKQrZi9z8V6',
    };

    http.Response response = await http.post(Uri.parse(url),
        headers: headers, body: json.encode(notification));
    if (response.statusCode == 200) {
      print('Push notification sent successfully to $fcmToken');
    } else {
      print(
          'Failed to send push notification to $fcmToken. Error: ${response.body}');
    }

    print("Push notifications sent successfully.");
  }

  void audioCall() {
    state.more_status.value = false;
    Get.toNamed(AppRoutes.VoiceCall, parameters: {
      "to_name": state.to_name.value,
      "to_avatar": state.to_avatar.value,
      "doc_id":doc_id,
      "to_token":state.to_token.value
    });
  }

  @override
  void onInit() {
    super.onInit();
    var data = Get.arguments;
    print("......this is all the data that is received...... ${data}");
    doc_id = data['doc_id']!;
    print('haitoken$token');
    state.to_token.value = data['to_token'] ?? "";
    state.to_name.value = data['to_name'] ?? "";
    state.to_avatar.value = data['to_avatar'] ?? "";
    state.to_online.value = data['to_online'] ?? "1";
  }
}
