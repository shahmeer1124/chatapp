import 'package:cached_network_image/cached_network_image.dart';

import 'package:flutter/material.dart';
import 'package:flutter/src/widgets/framework.dart';
import 'package:get/get.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:lechat/common/style/color.dart';
import 'package:lechat/pages/messages/chat/widget/chat_list.dart';

import '../../../common/values/colors.dart';
import 'controller.dart';

class ChatPage extends GetView<ChatController> {
  const ChatPage({super.key});

  AppBar _buildAppBar() {
    return AppBar(
      iconTheme: IconThemeData(
        color: Colors.white, // Set your custom color here
      ),
      backgroundColor: Color(0xFF202123),
      title: Obx(() {
        return Container(
          child: Text(
            "${controller.state.to_name}",
            overflow: TextOverflow.clip,
            maxLines: 1,
            style: TextStyle(
                fontFamily: "Avenir",
                fontWeight: FontWeight.bold,
                color: AppColors.primaryElement,
                fontSize: 16.sp),
          ),
        );
      }),
      actions: [
        Container(
          margin: EdgeInsets.only(right: 20.w),
          child: Stack(
            alignment: Alignment.center,
            children: [
              Container(
                width: 44.w,
                height: 44.w,
                child: CachedNetworkImage(
                    imageUrl: controller.state.to_avatar.value,
                    imageBuilder: ((context, imageProvider) => Container(
                          decoration: BoxDecoration(
                              borderRadius: BorderRadius.circular(22.w),
                              image: DecorationImage(image: imageProvider)),
                        )),
                    errorWidget: (context, url, error) => Image(
                          image: AssetImage("assets/images/account_header.png"),
                        )),
              ),
              Positioned(
                  bottom: 5.w,
                  right: 0.w,
                  child: Container(
                    width: 14.w,
                    height: 14.w,
                    decoration: BoxDecoration(
                        color: controller.state.to_online.value == "1"
                            ? AppColors.primaryElementStatus
                            : AppColors.primarySecondaryElementText,
                        borderRadius: BorderRadius.circular(12.w),
                        border: Border.all(
                            width: 2, color: AppColors.primaryElementText)),
                  ))
            ],
          ),
        ),
      ],
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
        appBar: _buildAppBar(),
        body: Obx(() {
          return SafeArea(
              child: Stack(
            children: [
              ChatList(),
              Positioned(
                  bottom: 0.h,
                  child: Container(
                    width: 360.w,
                    padding:
                        EdgeInsets.only(left: 20.w, bottom: 10.h, right: 20.w),
                    child: Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        Container(
                          width: 270.w,
                          padding: EdgeInsets.only(
                              top: 10.h, bottom: 10.h, left: 5.w),
                          decoration: BoxDecoration(
                              color: Color(0xFF353641),
                              borderRadius: BorderRadius.circular(5.w),
                              border: Border.all(
                                  color:
                                      AppColors.primarySecondaryElementText)),
                          child: Row(
                            children: [
                              Container(
                                width: 220.w,
                                child: TextField(
                                  style: appstyle(
                                      18, Colors.white, FontWeight.normal),
                                  controller: controller.textController,
                                  decoration: InputDecoration(
                                      focusedBorder: const OutlineInputBorder(
                                          borderSide: BorderSide(
                                              color: Colors.transparent)),
                                      disabledBorder: const OutlineInputBorder(
                                          borderSide: BorderSide(
                                              color: Colors.transparent)),
                                      border: const OutlineInputBorder(
                                          borderSide: BorderSide(
                                              color: Colors.transparent)),
                                      enabledBorder: const OutlineInputBorder(
                                          borderSide: BorderSide(
                                              color: Colors.transparent)),
                                      hintText: 'Message ...',
                                      hintStyle: const TextStyle(
                                          color: AppColors
                                              .primarySecondaryElementText),
                                      contentPadding: EdgeInsets.only(
                                          left: 15.w, top: 0.w, bottom: 0.w)),
                                  autofocus: false,
                                  keyboardType: TextInputType.multiline,
                                ),
                              ),
                              GestureDetector(
                                child: Container(
                                  width: 40.w,
                                  height: 40.w,
                                  child: Icon(
                                    Icons.send_outlined,
                                    size: 26,
                                    color: Colors.white,
                                  ),
                                ),
                                onTap: () {
                                  controller.sendMessage();
                                },
                              )
                            ],
                          ),
                        ),
                        GestureDetector(
                          onTap: () {
                            controller.gomore();
                          },
                          child: Container(
                            padding: EdgeInsets.all(8.w),
                            decoration: BoxDecoration(
                                boxShadow: [
                                  BoxShadow(
                                      color: Colors.grey.withOpacity(0.2),
                                      spreadRadius: 2,
                                      blurRadius: 2,
                                      offset: Offset(1, 1))
                                ],
                                color: AppColors.primaryElement,
                                borderRadius: BorderRadius.circular(40.w)),
                            height: 40.w,
                            width: 40.w,
                            child: Image.asset("assets/icons/add.png"),
                          ),
                        ),
                      ],
                    ),
                  )),
              controller.state.more_status.value == true
                  ? Positioned(
                      right: 20.w,
                      bottom: 70.h,
                      height: 200.h,
                      width: 40.w,
                      child: Column(
                        mainAxisAlignment: MainAxisAlignment.spaceAround,
                        children: [
                          GestureDetector(
                            onTap: () {},
                            child: Container(
                              padding: EdgeInsets.all(10.h),
                              decoration: BoxDecoration(
                                  color: AppColors.primaryBackground,
                                  boxShadow: [
                                    BoxShadow(
                                        color: Colors.grey.withOpacity(0.2),
                                        spreadRadius: 2,
                                        blurRadius: 2,
                                        offset: Offset(1, 2))
                                  ],
                                  borderRadius: BorderRadius.circular(40.w)),
                              height: 40.h,
                              width: 40.h,
                              child: Image.asset("assets/icons/file.png"),
                            ),
                          ),
                          GestureDetector(
                            onTap: () {
                              print('yahicallhuahai');
                              controller.imgFromGallery();
                            },
                            child: Container(
                              padding: EdgeInsets.all(10.h),
                              decoration: BoxDecoration(
                                  color: AppColors.primaryBackground,
                                  boxShadow: [
                                    BoxShadow(
                                        color: Colors.grey.withOpacity(0.2),
                                        spreadRadius: 2,
                                        blurRadius: 2,
                                        offset: Offset(1, 2))
                                  ],
                                  borderRadius: BorderRadius.circular(40.w)),
                              height: 40.h,
                              width: 40.h,
                              child: Image.asset("assets/icons/photo.png"),
                            ),
                          ),
                          GestureDetector(
                            onTap: () {
                              controller.audioCall();
                            },
                            child: Container(
                              padding: EdgeInsets.all(10.h),
                              decoration: BoxDecoration(
                                  color: AppColors.primaryBackground,
                                  boxShadow: [
                                    BoxShadow(
                                        color: Colors.grey.withOpacity(0.2),
                                        spreadRadius: 2,
                                        blurRadius: 2,
                                        offset: Offset(1, 2))
                                  ],
                                  borderRadius: BorderRadius.circular(40.w)),
                              height: 40.h,
                              width: 40.h,
                              child: Image.asset("assets/icons/call.png"),
                            ),
                          ),
                          GestureDetector(
                            onTap: () {
                              controller.videoCall();
                            },
                            child: Container(
                              padding: EdgeInsets.all(10.h),
                              decoration: BoxDecoration(
                                  color: AppColors.primaryBackground,
                                  boxShadow: [
                                    BoxShadow(
                                        color: Colors.grey.withOpacity(0.2),
                                        spreadRadius: 2,
                                        blurRadius: 2,
                                        offset: Offset(1, 2))
                                  ],
                                  borderRadius: BorderRadius.circular(40.w)),
                              height: 40.h,
                              width: 40.h,
                              child: Image.asset("assets/icons/video.png"),
                            ),
                          )
                        ],
                      ))
                  : Container()
            ],
          ));
        }));
  }
}
