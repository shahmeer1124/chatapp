import 'package:agora_rtc_engine/agora_rtc_engine.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import '../../../common/values/colors.dart';
import 'controller.dart';

class VideoCallPage extends GetView<VideoCallController> {
  const VideoCallPage({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.primary_bg,
      body: SafeArea(
        child: Obx(() => Container(
            child: controller.state.isReadyPreview.value
                ? Stack(
                    children: [
                      controller.state.onRemoteUID.value == 0
                          ? Container()
                          : AgoraVideoView(
                              controller: VideoViewController.remote(
                                  rtcEngine: controller.engine,
                                  canvas: VideoCanvas(
                                      uid: controller.state.onRemoteUID.value),
                                  connection: RtcConnection(
                                      channelId:
                                          controller.state.channelId.value))),
                      Positioned(
                          top: 30.h,
                          right: 15.w,
                          child: SizedBox(
                            width: 120.w,
                            height: 170.w,
                            child: AgoraVideoView(
                                controller: VideoViewController(
                                    rtcEngine: controller.engine,
                                    canvas: VideoCanvas(uid: 0))),
                          )),
                      controller.state.isShowAvatar.value
                          ? Container()
                          : Positioned(
                              child: Column(
                              children: [
                                Container(
                                  child: Text(
                                    controller.state.calltime.value,
                                    style: TextStyle(
                                        color: AppColors.primaryElementText,
                                        fontSize: 14.sp,
                                        fontWeight: FontWeight.normal),
                                  ),
                                )
                              ],
                            )),
                      Positioned(
                          bottom: 80.w,
                          left: 30.w,
                          right: 30.w,
                          child: Row(
                            mainAxisAlignment: MainAxisAlignment.center,
                            children: [
                              Column(
                                children: [
                                  GestureDetector(
                                    onTap: () {
                                      controller.state.isJoined.value == true
                                          ? controller.leaveChannel()
                                          : controller.joinChannel();
                                    },
                                    child: Container(
                                      padding: EdgeInsets.all(15.w),
                                      decoration: BoxDecoration(
                                          color: controller.state.isJoined.value
                                              ? AppColors.primaryElementBg
                                              : AppColors.primaryElementStatus,
                                          borderRadius: BorderRadius.all(
                                              Radius.circular(30.w))),
                                      width: 60.w,
                                      height: 60.h,
                                      child: controller.state.isJoined.value
                                          ? Image.asset(
                                              "assets/icons/a_phone.png")
                                          : Image.asset(
                                              "assets/icons/a_telephone.png"),
                                    ),
                                  ),
                                  Container(
                                    margin: EdgeInsets.only(top: 10.h),
                                    child: Text(
                                      controller.state.isJoined.value
                                          ? "Disconnect"
                                          : "Connecting",
                                      style: TextStyle(
                                          color: AppColors.primaryElementText,
                                          fontSize: 12.sp,
                                          fontWeight: FontWeight.normal),
                                    ),
                                  )
                                ],
                              )
                            ],
                          )),
                      controller.state.isShowAvatar.value
                          ? Positioned(
                              top: 10.h,
                              left: 30.w,
                              right: 30.w,
                              child: Column(
                                children: [
                                  Container(
                                    width: 70.w,
                                    height: 70.w,
                                    margin: EdgeInsets.only(top: 150.h),
                                    decoration: BoxDecoration(
                                        borderRadius:
                                            BorderRadius.circular(10.w),
                                        color: AppColors.primaryElementText),
                                    child: Image.network(
                                      controller.state.to_avatar.value,
                                      fit: BoxFit.fill,
                                    ),
                                  ),
                                  Container(
                                    margin: EdgeInsets.only(top: 6.h),
                                    child: Text(
                                      controller.state.to_name.value,
                                      style: TextStyle(
                                          color: AppColors.primaryElementText,
                                          fontSize: 18.sp,
                                          fontWeight: FontWeight.normal),
                                    ),
                                  )
                                ],
                              ))
                          : Container()
                    ],
                  )
                : Container())),
      ),
    );
  }
}
