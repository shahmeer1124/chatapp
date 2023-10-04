import 'package:get/get.dart';

class VideoCallState {
  RxBool isJoined = false.obs;
  RxBool openMicrophone = true.obs;
  RxBool enableSpeaker = true.obs;
  RxString calltime = "00.00".obs;
  RxString callStatus = "not connected".obs;
  RxString callTimeNum = "not connected".obs;

  RxBool isReadyPreview = false.obs;
  RxBool isShowAvatar = true.obs;
  RxBool switchCamera = true.obs;
  RxInt onRemoteUID = 0.obs;

  var to_name = ''.obs;
  var to_token = ''.obs;
  var to_avatar = ''.obs;
  var doc_id = ''.obs;
  var call_role = 'audience'.obs;
  var channelId = ''.obs;
}
