import 'dart:async';
import 'dart:convert';

import 'package:agora_rtc_engine/agora_rtc_engine.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:crypto/crypto.dart';
import 'package:http/http.dart' as http;

import 'package:flutter/material.dart';
import 'package:flutter_easyloading/flutter_easyloading.dart';
import 'package:get/get.dart';
import 'package:just_audio/just_audio.dart';
import 'package:lechat/common/apis/apis.dart';
import 'package:lechat/common/entities/chat.dart';
import 'package:lechat/common/entities/chatcall.dart';
import 'package:lechat/common/entities/entities.dart';
import 'package:lechat/pages/messages/videocall/state.dart';
import 'package:permission_handler/permission_handler.dart';
import '../../../common/store/user.dart';
import '../../../common/values/server.dart';

class VideoCallController extends GetxController {
  VideoCallController();
  final state = VideoCallState();
  final player = AudioPlayer();
  late String token = UserStore.to.msgtoken;
  late String to_token;
  late String fromother;
  int call_s = 0;
  int call_m = 0;
  int call_h = 0;
  late final Timer calltimer;

  String AppId = APPID;
  final db = FirebaseFirestore.instance;
  final profile_token = UserStore.to.profile.token;
  late final RtcEngine engine;

  @override
  void onInit() {
    var data = Get.parameters;
    state.to_name.value = data['to_name'] ?? "";
    state.to_avatar.value = data['to_avatar'] ?? "";
    state.call_role.value = data['call_role'] ?? "";
    state.doc_id.value = data['doc_id'] ?? "";
    state.to_token.value = data['to_token'] ?? "";

    print('tokenprinter${state.to_token.value}');
    initEngine();
    super.onInit();
  }

  Future<void> sendPushNotification(String title, String message) async {
    String? fcmToken = await getFCMTokenFromFirestore();
    Map<String, dynamic> notification = {
      'notification': {
        'title': title,
        'body': 'message:${message}',
        "click_action": "Print('hello wordls')"
      },
      'data': {
        "click_action": "FLUTTER_NOTIFICATION_CLICK",
        "id": "1",
        "status": "done",
        "to_name": state.to_name.value.toString(),
        "to_avatar": state.to_avatar.toString(),
        "to_token": state.to_token.toString()
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

  Future<String?> getFCMTokenFromFirestore() async {
    print('tokenchecker${to_token}');
    final usersCollectionRef = FirebaseFirestore.instance.collection('users');
    final userSnapshot = await usersCollectionRef
        .where('token', isEqualTo: to_token.toString())
        .get();

    if (userSnapshot.docs.isNotEmpty) {
      final userData = userSnapshot.docs[0].data();
      final fcmToken = userData['fcmtoken'] as String?;
      print('fcmtokenprinter$fcmToken');
      return fcmToken;
    }

    return null; // Return null if no matching user is found
  }

  Future<void> initEngine() async {
    await player.setAsset("assets/Sound_Horizon.mp3");
    engine = createAgoraRtcEngine();
    await engine.initialize(RtcEngineContext(appId: AppId));
    engine.registerEventHandler(RtcEngineEventHandler(
        onError: (ErrorCodeType error, String msg) {
      print("[on error ] err $error , , msg: $msg");
    }, onJoinChannelSuccess: (RtcConnection conntection, int elapsed) {
      state.isJoined.value = true;
    }, onUserJoined:
            (RtcConnection conntection, int remoteid, int elapsed) async {
      state.isShowAvatar.value = false;
      state.onRemoteUID.value = remoteid;
      await player.pause();
      callTime();
    }, onLeaveChannel: (RtcConnection connection, RtcStats stats) {
      state.isJoined.value = false;
      state.onRemoteUID.value = 0;
      state.isShowAvatar.value = true;
    }, onRtcStats: (RtcConnection connection, RtcStats stats) {
      String duration = formatCallDuration(stats.duration!);
      state.calltime.value = duration;
    }));
    await engine.enableVideo();
    print("yhantktoayahai");
    await engine.setVideoEncoderConfiguration(const VideoEncoderConfiguration(
        dimensions: VideoDimensions(width: 640, height: 360),
        frameRate: 15,
        bitrate: 0));
    await engine.startPreview();
    state.isReadyPreview.value = true;
    await joinChannel();
    if (state.call_role == 'anchor') {
      await sendNotification('video');
      await player.play();
    }
  }

  void callTime() {
    calltimer = Timer.periodic(Duration(seconds: 1), (timer) {
      call_s = call_s + 1;
      if (call_s > 60) {
        call_s = 0;
        call_m = call_m + 1;
      }
      if (call_m > 60) {
        call_h = call_h + 1;
      }
      var h = call_h < 10 ? "0$call_h" : "$call_h";
      var m = call_m < 10 ? "0$call_m" : "$call_m";
      var s = call_s < 10 ? "0$call_s" : "$call_s";
      if (call_h == 0) {
        state.calltime.value = "$m:$s";
        state.callTimeNum.value = "$call_m m and $call_s";
      } else {
        state.calltime.value = "$h:$m:$s";
        state.callTimeNum.value = "$call_h h $call_m m and $call_s";
      }
    });
  }

  Future<void> sendNotification(String call_type) async {
    print('yes this get called');
    CallRequestEntity callRequestEntity = CallRequestEntity();
    callRequestEntity.call_type = call_type;
    callRequestEntity.to_token = state.to_token.value;
    callRequestEntity.to_avatar = state.to_avatar.value;
    callRequestEntity.doc_id = state.doc_id.value;
    callRequestEntity.to_name = state.to_name.value;
    print('message going to toke${state.to_token.value}');
    var res = await ChatAPI.call_notifications(params: callRequestEntity);
    if (res.code == 0) {
      print('notification success');
    } else {
      print('notification unsuccessful');
    }
  }

  String formatCallDuration(int seconds) {
    int hours = seconds ~/ 3600;
    int minutes = (seconds % 3600) ~/ 60;
    int remainingSeconds = seconds % 60;

    String formattedHours = hours.toString().padLeft(2, '0');
    String formattedMinutes = minutes.toString().padLeft(2, '0');
    String formattedSeconds = remainingSeconds.toString().padLeft(2, '0');

    if (hours > 0) {
      return '$formattedHours:$formattedMinutes:$formattedSeconds';
    } else {
      return '$formattedMinutes:$formattedSeconds';
    }
  }

  Future<String> getToken() async {
    if (state.call_role == 'anchor') {
      state.channelId.value = md5
          .convert(utf8.encode("${profile_token}_${state.to_token}"))
          .toString();
    } else {
      state.channelId.value = md5
          .convert(utf8.encode("${state.to_token}_${profile_token}"))
          .toString();
    }
    CallTokenRequestEntity callTokenRequestEntity = CallTokenRequestEntity();
    callTokenRequestEntity.channel_name = state.channelId.value;
    print('channel_id_is_this${state.channelId.value}');
    var res = await ChatAPI.call_token(params: callTokenRequestEntity);
    if (res.code == 0) {
      return res.data!;
    }
    return "";
  }

  Future<void> joinChannel() async {
    await [Permission.microphone, Permission.camera].request();
    EasyLoading.show(
        indicator: CircularProgressIndicator(),
        maskType: EasyLoadingMaskType.clear,
        dismissOnTap: true);
    String token = await getToken();
    if (token.isEmpty) {
      EasyLoading.dismiss();
      Get.back();
      return;
    }
    await engine.joinChannel(
        token: token,
        channelId: state.channelId.value,
        uid: 0,
        options: ChannelMediaOptions(
          clientRoleType: ClientRoleType.clientRoleBroadcaster,
          channelProfile: ChannelProfileType.channelProfileCommunication,
        ));
    EasyLoading.dismiss();
  }

  void leaveChannel() async {
    print('leavechannelcalled');
    EasyLoading.show(
      indicator: CircularProgressIndicator(),
      maskType: EasyLoadingMaskType.clear,
      dismissOnTap: true,
    );
    await player.pause();
    state.isJoined.value = false;
    state.switchCamera.value = true;
    EasyLoading.dismiss();
    Get.back();
  }

  Future<void> switchCamera() async {
    await engine.switchCamera();
    state.switchCamera.value = !state.switchCamera.value;
  }

  Future<void> addCallTime() async {
    var profile = UserStore.to.profile;
    var msgData = ChatCall(
        from_token: profile.token,
        to_token: state.to_token.value,
        from_name: profile.name,
        to_name: state.to_name.value,
        from_avatar: profile.avatar,
        to_avatar: state.to_avatar.value,
        call_time: state.callTimeNum.value,
        type: "video",
        last_time: Timestamp.now());
    await db
        .collection("chatcall")
        .withConverter(
            fromFirestore: ChatCall.fromFirestore,
            toFirestore: (ChatCall msg, options) => msg.toFirestore())
        .add(msgData);
    String sendContent = "call time ${state.callTimeNum.value} 📽";
    saveMessage(sendContent);
  }
  
  saveMessage(String sendContent) async {
    if (state.doc_id.value.isEmpty) {
      return;
    }
    final content = Msgcontent(
        token: profile_token,
        content: sendContent,
        type: "text",
        addtime: Timestamp.now());
    await db
        .collection("message")
        .doc(state.doc_id.value)
        .collection('msglist')
        .withConverter(
            fromFirestore: Msgcontent.fromFirestore,
            toFirestore: (Msgcontent msg, options) => msg.toFirestore())
        .add(content);
    var messageRes = await db
        .collection("message")
        .doc(state.doc_id.value)
        .withConverter(
            fromFirestore: Msg.fromFirestore,
            toFirestore: (Msg msg, options) => msg.toFirestore())
        .get();
    if (messageRes.data() != null) {
      var item = messageRes.data()!;
      int to_msg_num = item.to_msg_num == null ? 0 : item.to_msg_num!;
      int from_msg_num = item.from_msg_num == null ? 0 : item.from_msg_num!;
      if (item.from_token == profile_token) {
        from_msg_num = from_msg_num + 1;
      } else {
        to_msg_num = to_msg_num + 1;
      }
      await db.collection("message").doc(state.doc_id.value).update({
        "to_msg_num":to_msg_num,
        "from_msg_num":from_msg_num,
        "last_msg":sendContent,"last_time":Timestamp.now()
      });
    }
  }

  void alldispose() async {
    if (state.call_role == 'anchor') {
      addCallTime();
    }
    await player.pause();
    await engine.leaveChannel();
    await engine.release();
    await player.stop();
  }

  @override
  void onClose() {
    alldispose();
    super.onClose();
  }
}
