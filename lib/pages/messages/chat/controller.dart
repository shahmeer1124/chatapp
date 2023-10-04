import 'dart:convert';
import 'dart:io';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';
import 'package:flutter/scheduler.dart';
import 'package:fluttertoast/fluttertoast.dart';
import 'package:get/get.dart';
import 'package:image_picker/image_picker.dart';
import 'package:lechat/common/apis/apis.dart';
import 'package:lechat/common/entities/entities.dart';
import 'package:lechat/common/store/store.dart';
import 'package:lechat/pages/messages/chat/state.dart';
import 'package:permission_handler/permission_handler.dart';
import '../../../common/entities/msgcontent.dart';
import '../../../common/routes/names.dart';
import 'package:http/http.dart' as http;

class ChatController extends GetxController {
  ChatController();

  var listener;
  var isLoadMore = true;
  late String doc_id;
  File? _photo;
  final ImagePicker _imagePicker = ImagePicker();
  final state = ChatState();
  final db = FirebaseFirestore.instance;
  ScrollController msgScrolling = ScrollController();
  final textController = TextEditingController();
  final token = UserStore.to.profile.token;

  void closeAllPop() {
    Get.focusScope?.unfocus();
    state.more_status.value = false;
  }

  Future imgFromGallery() async {
    try {
      final pickedFile =
          await _imagePicker.pickImage(source: ImageSource.gallery);
      if (pickedFile != null) {
        _photo = File(pickedFile.path);
        uploadFile();
      } else {}
    } catch (e) {}
  }

  Future uploadFile() async {
    var result = await ChatAPI.upload_img(file: _photo);

    if (result.code == 0) {
      sendImageMessage(result.data!);
    } else {
      Fluttertoast.showToast(
          msg: "Sending Image error",
          toastLength: Toast.LENGTH_SHORT,
          gravity: ToastGravity.CENTER,
          timeInSecForIosWeb: 1,
          backgroundColor: Colors.red,
          textColor: Colors.white,
          fontSize: 16.0);
    }
  }

  void sendImageMessage(String url) async {
    final content = Msgcontent(
      token: token,
      content: url,
      type: 'image',
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
        .then((DocumentReference documentReference) {});
    var messageResult = await db
        .collection('message')
        .doc(doc_id)
        .withConverter(
            fromFirestore: Msg.fromFirestore,
            toFirestore: (Msg msg, options) => msg.toFirestore())
        .get();
    if (messageResult.data() != null) {
      var item = messageResult.data()!;
      int to_msg_num = item.to_msg_num == null ? 0 : item.to_msg_num!;
      int from_msg_num = item.from_msg_num == null ? 0 : item.from_msg_num!;
      if (item.from_token == token) {
        from_msg_num = from_msg_num + 1;
      } else {
        to_msg_num = to_msg_num + 1;
      }
      await db.collection('message').doc(doc_id).update({
        "to_msg_num": to_msg_num,
        "from_msg_num": from_msg_num,
        "last_msg": "📷",
        "last_time": Timestamp.now()
      });
    }
  }

  void gomore() {
    state.more_status.value = state.more_status.value ? false : true;
  }

  @override
  void onReady() {
    super.onReady();
    state.msgcontentList.clear();
    var messages = db
        .collection('message')
        .doc(doc_id)
        .collection('msglist')
        .withConverter(
            fromFirestore: Msgcontent.fromFirestore,
            toFirestore: (Msgcontent msgcontent, options) =>
                msgcontent.toFirestore())
        .orderBy('addtime', descending: true)
        .limit(15);
    listener = messages.snapshots().listen((event) {
      List<Msgcontent> tempMsgList = <Msgcontent>[];
      for (var change in event.docChanges) {
        switch (change.type) {
          case DocumentChangeType.added:
            if (change.doc.data() != null) {
              tempMsgList.add(change.doc.data()!);
            }
            break;
          case DocumentChangeType.modified:
            break;
          case DocumentChangeType.removed:
            break;
        }
      }
      tempMsgList.reversed.forEach((element) {
        state.msgcontentList.value.insert(0, element);
      });
      state.msgcontentList.refresh();
      if (msgScrolling.hasClients) {
        msgScrolling.animateTo(msgScrolling.position.minScrollExtent,
            duration: const Duration(milliseconds: 300), curve: Curves.easeOut);
      }
      msgScrolling.addListener(() {
        if ((msgScrolling.offset + 20) >
            (msgScrolling.position.maxScrollExtent)) {
          if (isLoadMore) {
            state.isLoading.value = true;
            isLoadMore = false;
            asyncLoadMoreData();
          }
        }
      });
    }, onError: (error) => print(error));
  }

  Future<void> asyncLoadMoreData() async {
    final messages = await db
        .collection('message')
        .doc(doc_id)
        .collection('msglist')
        .withConverter(
            fromFirestore: Msgcontent.fromFirestore,
            toFirestore: (Msgcontent msg, options) => msg.toFirestore())
        .orderBy('addtime', descending: true)
        .where('addtime', isLessThan: state.msgcontentList.value.last.addtime)
        .limit(10)
        .get();
    if (messages.docs.isNotEmpty) {
      print('databhihai');
      messages.docs.forEach((element) {
        var data = element.data();
        state.msgcontentList.add(data);
      });
    }
    SchedulerBinding.instance.addPostFrameCallback((timeStamp) {
      isLoadMore = true;
    });
    state.isLoading.value = false;
  }

  void sendMessage() async {
    String sendcontent = textController.text;
    if (sendcontent.isEmpty) {
      Fluttertoast.showToast(
          msg: "Content is Empty",
          toastLength: Toast.LENGTH_SHORT,
          gravity: ToastGravity.CENTER,
          timeInSecForIosWeb: 1,
          backgroundColor: Colors.black,
          textColor: Colors.white,
          fontSize: 16.0);
      return;
    }
    textController.clear();
    final content = Msgcontent(
      token: token,
      content: sendcontent,
      type: 'text',
      addtime: Timestamp.now(),
    );
    await db
        .collection('message')
        .doc(doc_id)
        .collection("msglist")
        .withConverter(
            fromFirestore: Msgcontent.fromFirestore,
            toFirestore: (Msgcontent msgcontent, options) =>
                msgcontent.toFirestore())
        .add(content)
        .then((DocumentReference documentReference) {});
    var messageResult = await db
        .collection('message')
        .doc(doc_id)
        .withConverter(
            fromFirestore: Msg.fromFirestore,
            toFirestore: (Msg msg, options) => msg.toFirestore())
        .get();
    if (messageResult.data() != null) {
      var item = messageResult.data()!;
      int to_msg_num = item.to_msg_num == null ? 0 : item.to_msg_num!;
      int from_msg_num = item.from_msg_num == null ? 0 : item.from_msg_num!;
      if (item.from_token == token) {
        from_msg_num = from_msg_num + 1;
      } else {
        to_msg_num = to_msg_num + 1;
      }
      await db.collection('message').doc(doc_id).update({
        "to_msg_num": to_msg_num,
        "from_msg_num": from_msg_num,
        "last_msg": sendcontent,
        "last_time": Timestamp.now()
      });
    }
    sendNotification('message');
  }

  Future<void> sendNotification(String call_type) async {
    print('yes this get called');
    CallRequestEntity callRequestEntity = CallRequestEntity();
    callRequestEntity.call_type = call_type;
    callRequestEntity.to_token = state.to_token.value;
    callRequestEntity.to_avatar = state.to_avatar.value;
    callRequestEntity.doc_id = doc_id;
    callRequestEntity.to_name = state.to_name.value;
    print('message going to toke${state.to_token.value}');
    var res = await ChatAPI.call_notifications(params: callRequestEntity);
    if (res.code == 0) {
      print('notification success');
    } else {
      print('notification unsuccessful');
    }
  }

  Future<String?> getFCMTokenFromFirestore() async {
    final usersCollectionRef = FirebaseFirestore.instance.collection('users');
    final userSnapshot = await usersCollectionRef
        .where('token', isEqualTo: state.to_token.toString())
        .get();

    if (userSnapshot.docs.isNotEmpty) {
      final userData = userSnapshot.docs[0].data();
      final fcmToken = userData['fcmtoken'] as String?;
      return fcmToken;
    }

    return null; // Return null if no matching user is found
  }

  Future<void> sendPushNotification(String title, String message) async {
    String? fcmToken = await getFCMTokenFromFirestore();

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
      "call_role": "anchor",
      "to_token": state.to_token.value,
      "doc_id": doc_id
    });
  }

  void videoCall() async {
    state.more_status.value = false;
    bool micStatus = await requestPermission(Permission.microphone);
    bool camStatus = await requestPermission(Permission.camera);
    if (GetPlatform.isAndroid && micStatus && camStatus) {
      Get.toNamed(AppRoutes.VideoCall, parameters: {
        "to_name": state.to_name.value,
        "to_avatar": state.to_avatar.value,
        "call_role": "anchor",
        "to_token": state.to_token.value,
        "doc_id": doc_id
      });
    } else {
      Get.toNamed(AppRoutes.VideoCall, parameters: {
        "to_name": state.to_name.value,
        "to_avatar": state.to_avatar.value,
        "call_role": "anchor",
        "to_token": state.to_token.value,
        "doc_id": doc_id
      });
    }
  }

  Future<bool> requestPermission(Permission permission) async {
    var permissionStatus = await permission.status;
    if (permissionStatus != PermissionStatus.granted) {
      var status = permission.request();
      if (status != PermissionStatus.granted) {
        Fluttertoast.showToast(
            msg: "Please enable permission to continue",
            toastLength: Toast.LENGTH_SHORT,
            gravity: ToastGravity.CENTER,
            timeInSecForIosWeb: 1,
            backgroundColor: Colors.red,
            textColor: Colors.white,
            fontSize: 16.0);
        if (GetPlatform.isAndroid) {
          await openAppSettings();
        }

        return false;
      }
    }
    return true;
  }

  @override
  void onInit() {
    super.onInit();
    var data = Get.arguments;
    doc_id = data['doc_id']!;
    state.to_token.value = data['to_token'] ?? "";
    state.to_name.value = data['to_name'] ?? "";
    state.to_avatar.value = data['to_avatar'] ?? "";
    state.to_online.value = data['to_online'] ?? "1";
    clearMsgNum(doc_id);
  }

  clearMsgNum(String doc_id) async {
    var messageResult = await db
        .collection('message')
        .doc(doc_id)
        .withConverter(
            fromFirestore: Msg.fromFirestore,
            toFirestore: (Msg msg, options) => msg.toFirestore())
        .get();
    if (messageResult.data() != null) {
      var item = messageResult.data()!;
      int to_msg_num = item.to_msg_num == null ? 0 : item.to_msg_num!;
      int from_msg_num = item.from_msg_num == null ? 0 : item.from_msg_num!;
      if (item.from_token == token) {
        to_msg_num = 0;
      } else {
        from_msg_num = 0;
      }
      await db.collection('message').doc(doc_id).update({
        "to_msg_num": to_msg_num,
        "from_msg_num": from_msg_num,
      });
    }
  }

  @override
  void onClose() {
    listener.cancel();
    clearMsgNum(doc_id);
    msgScrolling.dispose();
    textController.dispose();
    super.onClose();
  }
}
