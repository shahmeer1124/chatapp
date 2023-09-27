import 'dart:convert';

import 'package:agora_rtc_engine/agora_rtc_engine.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:http/http.dart' as http;

import 'package:flutter/material.dart';
import 'package:flutter_easyloading/flutter_easyloading.dart';
import 'package:get/get.dart';
import 'package:just_audio/just_audio.dart';
import 'package:lechat/pages/messages/voicecall/state.dart';
import 'package:permission_handler/permission_handler.dart';

import '../../../common/store/user.dart';
import '../../../common/values/server.dart';

class VoiceCallController extends GetxController {
  VoiceCallController();
  final state = VoiceCallState();
  final player = AudioPlayer();
  late String token = UserStore.to.msgtoken;
  late String to_token;
  late String fromother;

  String AppId = APPID;
  final db = FirebaseFirestore.instance;
  final profile_token = UserStore.to.profile.token;
  late final RtcEngine engine;

  @override
  void onInit() {
    var data = Get.parameters;
    state.to_name.value = data['to_name'] ?? "";
    state.to_avatar.value = data['to_avatar'] ?? "";
    to_token = data['to_token'] ?? '';
    fromother = data['fromother'] ?? '';

    super.onInit();
    if (fromother != 'no') {
      sendPushNotification(state.to_name.value.toString(), "Incoming Call");
    }
    initEngine();
  }

  Future<void> sendPushNotification(String title, String message) async {
    String? fcmToken = await getFCMTokenFromFirestore();
    List<Future<void>> futures = [];
    Map<String, dynamic> notification = {
      'notification': {'title': title, 'body': 'message:${message}',"click_action": "Print('hello wordls')"},
      'data': {
        "click_action": "FLUTTER_NOTIFICATION_CLICK",
        "id": "1",
        "status": "done",
        "to_name":state.to_name.value.toString(),
        "to_avatar":state.to_avatar.toString(),
        "to_token":state.to_token.toString()
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
      print("onConnectionjoinedbyusers ${conntection.toJson()}");
      state.isJoined.value = true;
    }, onUserJoined:
            (RtcConnection conntection, int remoteid, int elapsed) async {
      await player.pause();
    }, onLeaveChannel: (RtcConnection connection, RtcStats stats) {
      print("user left the room");
      state.isJoined.value = false;
    }, onRtcStats: (RtcConnection connection, RtcStats stats) {
      String duration = formatCallDuration(stats.duration!);
      state.calltime.value = duration;
    }));
    await engine.enableAudio();
    await engine.setClientRole(role: ClientRoleType.clientRoleBroadcaster);
    await engine.setAudioProfile(
        scenario: AudioScenarioType.audioScenarioGameStreaming,
        profile: AudioProfileType.audioProfileDefault);
    await joinChannel();
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

  Future<void> joinChannel() async {
    await Permission.microphone.request();
    EasyLoading.show(
        indicator: CircularProgressIndicator(),
        maskType: EasyLoadingMaskType.clear,
        dismissOnTap: true);
    await engine.joinChannel(
        token:
            '007eJxTYLBnP6OUcnPBl7MXV51snrfp5vvoDLXQQnXPkq5fJQ91d31TYEgzTLRMSkwzSE4zMTdJTk6xSEqzNLQ0MUoxtTSwTDYzYP4gmNoQyMiQn/6ImZEBAkF8Noac1OSMxBIGBgBhpiKn',
        channelId: 'lechat',
        uid: 0,
        options: ChannelMediaOptions(
          clientRoleType: ClientRoleType.clientRoleBroadcaster,
          channelProfile: ChannelProfileType.channelProfileCommunication,
        ));
    EasyLoading.dismiss();
  }

  void leaveChannel() async {
    EasyLoading.show(
      indicator: CircularProgressIndicator(),
      maskType: EasyLoadingMaskType.clear,
      dismissOnTap: true,
    );
    await player.pause();
    state.isJoined.value = false;
    EasyLoading.dismiss();
    Get.back();
  }

  void alldispose() async {
    await player.pause();
    await engine.leaveChannel();
    await engine.release();
    await player.stop();
  }

  @override
  void dispose() {
    alldispose();
    // TODO: implement dispose
    super.dispose();
  }

  @override
  void onClose() {
    alldispose();
    super.onClose();
  }
}
