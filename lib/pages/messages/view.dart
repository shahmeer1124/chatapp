import 'package:cached_network_image/cached_network_image.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:get/get.dart';
import 'package:lechat/common/utils/date.dart';
import 'package:lechat/common/values/colors.dart';
import '../../common/entities/message.dart';
import '../../common/routes/names.dart';
import 'controller.dart';

class MessagePage extends GetView<MessageController> {
  const MessagePage({super.key});

  Widget _headBar() {
    return Center(
      child: Container(
        width: 320.w,
        height: 44.w,
        margin: EdgeInsets.only(top: 20.h, bottom: 20.h),
        child: Row(
          children: [
            Stack(
              children: [
                GestureDetector(
                  onTap: () {
                    controller.goprofile();
                  },
                  child: Container(
                    width: 44.h,
                    height: 44.h,
                    decoration: BoxDecoration(
                        color: AppColors.primarySecondaryBackground,
                        borderRadius: BorderRadius.all(
                          Radius.circular(22.h),
                        ),
                        boxShadow: [
                          BoxShadow(
                              color: Colors.grey.withOpacity(0.1),
                              spreadRadius: 1,
                              blurRadius: 2,
                              offset: Offset(0, 1))
                        ]),
                    child: controller.state.head_detail.value.avatar == null
                        ? const Image(
                            image:
                                AssetImage('assets/images/account_header.png'))
                        : CachedNetworkImage(
                            imageUrl:
                                controller.state.head_detail.value.avatar!,
                            height: 44.w,
                            width: 44.w,
                            imageBuilder: (context, ImageProvider) => Container(
                              decoration: BoxDecoration(
                                borderRadius: BorderRadius.all(
                                  Radius.circular(22.w),
                                ),
                                image: DecorationImage(
                                    image: ImageProvider, fit: BoxFit.cover),
                              ),
                            ),
                            errorWidget: (context, url, error) => const Image(
                                image: AssetImage(
                                    'assets/images/account_header.png')),
                          ),
                  ),
                ),
                Positioned(
                    bottom: 5.w,
                    right: 0.w,
                    height: 14.w,
                    child: Container(
                      width: 14.w,
                      height: 14.w,
                      decoration: BoxDecoration(
                          color: AppColors.primaryElementStatus,
                          borderRadius: BorderRadius.all(Radius.circular(12)),
                          border: Border.all(
                              width: 2.w, color: AppColors.primaryElementText)),
                    ))
              ],
            )
          ],
        ),
      ),
    );
  }

  Widget _headTabs() {
    return Container(
      height: 48.h,
      decoration: const BoxDecoration(
          color: AppColors.primarySecondaryBackground,
          borderRadius: BorderRadius.all(Radius.circular(5))),
      width: 320.w,
      padding: EdgeInsets.all(4.w),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          GestureDetector(
            onTap: () {
              controller.goTabStatus();
            },
            child: Container(
              decoration: controller.state.tabstatus.value == true
                  ? BoxDecoration(
                      color: AppColors.primaryBackground,
                      boxShadow: [
                        BoxShadow(
                            color: Colors.grey.withOpacity(0.1),
                            spreadRadius: 2,
                            blurRadius: 3,
                            offset: Offset(2, 3))
                      ],
                      borderRadius: const BorderRadius.all(Radius.circular(5)))
                  : const BoxDecoration(),
              width: 150.w,
              height: 40.w,
              child: Row(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Text(
                    'Chats',
                    style: TextStyle(
                        color: AppColors.primaryThreeElementText,
                        fontWeight: FontWeight.normal,
                        fontSize: 14.sp),
                  ),
                ],
              ),
            ),
          ),
          GestureDetector(
            onTap: () {
              controller.goTabStatus();
            },
            child: Container(
              decoration: controller.state.tabstatus.value == true
                  ? const BoxDecoration()
                  : BoxDecoration(
                      color: AppColors.primaryBackground,
                      boxShadow: [
                        BoxShadow(
                            color: Colors.grey.withOpacity(0.1),
                            spreadRadius: 2,
                            blurRadius: 3,
                            offset: Offset(2, 3))
                      ],
                      borderRadius: const BorderRadius.all(Radius.circular(5))),
              width: 150.w,
              height: 40.w,
              child: Row(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Text(
                    'Call',
                    style: TextStyle(
                        color: AppColors.primaryThreeElementText,
                        fontWeight: FontWeight.normal,
                        fontSize: 14.sp),
                  ),
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget chatListItem(Message item) {
    return Container(
      padding: EdgeInsets.only(top: 10.h, left: 0.w, right: 0.w, bottom: 10.h),
      child: InkWell(
        onTap: () {
          if (item.doc_id != null) {
            Get.toNamed(AppRoutes.Chat, arguments: {
              "doc_id": item.doc_id!,
              "to_token": item.token!,
              "to_name": item.name!,
              "to_avatar": item.avatar!,
              "to_online": item.online.toString()
            });
          }
        },
        child: Row(
          children: [
            Container(
              margin: EdgeInsets.only(top: 0.h, left: 0.w, right: 10.w),
              width: 44.h,
              height: 44.h,
              decoration: BoxDecoration(
                  color: AppColors.primarySecondaryBackground,
                  borderRadius: BorderRadius.all(
                    Radius.circular(22.h),
                  ),
                  boxShadow: [
                    BoxShadow(
                        color: Colors.grey.withOpacity(0.1),
                        spreadRadius: 1,
                        blurRadius: 2,
                        offset: const Offset(0, 1))
                  ]),
              child: item.avatar == null
                  ? const Image(
                      image: AssetImage('assets/images/account_header.png'))
                  : CachedNetworkImage(
                      imageUrl: item.avatar!,
                      imageBuilder: (context, imageProvider) => Container(
                        decoration: BoxDecoration(
                          borderRadius: BorderRadius.all(Radius.circular(22.w)),
                          image: DecorationImage(
                            image: imageProvider,
                            fit: BoxFit.cover,
                          ),
                        ),
                      ),
                      placeholder: (context, url) =>
                          CircularProgressIndicator(),
                      errorWidget: (context, url, error) => Icon(Icons.error),
                    ),
            ),
            Container(
              child: Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                crossAxisAlignment: CrossAxisAlignment.center,
                children: [
                  SizedBox(
                    width: 175.w,
                    height: 44.w,
                    child: Column(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          '${item.name!}',
                          overflow: TextOverflow.clip,
                          maxLines: 1,
                          softWrap: true,
                          style: TextStyle(
                              fontFamily: "Avenir",
                              fontWeight: FontWeight.bold,
                              color: AppColors.thirdElement,
                              fontSize: 14.sp),
                        ),
                        Text(
                          '${item.last_msg}',
                          overflow: TextOverflow.clip,
                          maxLines: 1,
                          softWrap: true,
                          style: TextStyle(
                              fontFamily: "Avenir",
                              fontWeight: FontWeight.normal,
                              color: AppColors.primarySecondaryElementText,
                              fontSize: 12.sp),
                        )
                      ],
                    ),
                  ),
                  SizedBox(
                    width: 86.w,
                    height: 44.w,
                    child: Column(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      crossAxisAlignment: CrossAxisAlignment.end,
                      children: [
                        Text(
                          item.last_time == null
                              ? ""
                              : duTimeLineFormat(
                                  (item.last_time as Timestamp).toDate()),
                          overflow: TextOverflow.clip,
                          maxLines: 1,
                          softWrap: true,
                          style: TextStyle(
                              fontFamily: "Avenir",
                              fontWeight: FontWeight.bold,
                              color: AppColors.thirdElement,
                              fontSize: 14.sp),
                        ),
                        item.msg_num == 0
                            ? Container()
                            : Container(
                                decoration: const BoxDecoration(
                                    color: Colors.red,
                                    borderRadius:
                                        BorderRadius.all(Radius.circular(10))),
                                padding: EdgeInsets.only(left: 4.w, right: 4.w),
                                child: Text(
                                  '${item.msg_num}',
                                  overflow: TextOverflow.clip,
                                  maxLines: 1,
                                  softWrap: true,
                                  style: TextStyle(
                                      fontFamily: "Avenir",
                                      fontWeight: FontWeight.bold,
                                      color: AppColors.thirdElement,
                                      fontSize: 14.sp),
                                ),
                              )
                      ],
                    ),
                  )
                ],
              ),
            )
          ],
        ),
      ),
    );
  }

  Widget callListItem(CallMessage item) {
    return Container(
      padding: EdgeInsets.only(top: 10.h, left: 0.w, right: 0.w, bottom: 10.h),
      child: InkWell(
        onTap: () {
          // if (item.doc_id != null) {
          //   Get.toNamed(AppRoutes.Chat, arguments: {
          //     "doc_id": item.doc_id!,
          //     "to_token": item.token!,
          //     "to_name": item.name!,
          //     "to_avatar": item.avatar!,
          //     "to_online": '0'
          //   });
          // }
        },
        child: Row(
          children: [
            Container(
              margin: EdgeInsets.only(top: 0.h, left: 0.w, right: 10.w),
              width: 44.h,
              height: 44.h,
              decoration: BoxDecoration(
                  color: AppColors.primarySecondaryBackground,
                  borderRadius: BorderRadius.all(
                    Radius.circular(22.h),
                  ),
                  boxShadow: [
                    BoxShadow(
                        color: Colors.grey.withOpacity(0.1),
                        spreadRadius: 1,
                        blurRadius: 2,
                        offset: const Offset(0, 1))
                  ]),
              child: item.avatar == null
                  ? const Image(
                      image: AssetImage('assets/images/account_header.png'))
                  : CachedNetworkImage(
                      imageUrl: item.avatar!,
                      imageBuilder: (context, imageProvider) => Container(
                        decoration: BoxDecoration(
                          borderRadius: BorderRadius.all(Radius.circular(22.w)),
                          image: DecorationImage(
                            image: imageProvider,
                            fit: BoxFit.cover,
                          ),
                        ),
                      ),
                      placeholder: (context, url) =>
                          CircularProgressIndicator(),
                      errorWidget: (context, url, error) => Icon(Icons.error),
                    ),
            ),
            Container(
              child: Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                crossAxisAlignment: CrossAxisAlignment.center,
                children: [
                  SizedBox(
                    width: 175.w,
                    height: 44.w,
                    child: Column(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          '${item.name!}',
                          overflow: TextOverflow.clip,
                          maxLines: 1,
                          softWrap: true,
                          style: TextStyle(
                              fontFamily: "Avenir",
                              fontWeight: FontWeight.bold,
                              color: AppColors.thirdElement,
                              fontSize: 14.sp),
                        ),
                        Text(
                          '${item.call_time}',
                          overflow: TextOverflow.clip,
                          maxLines: 1,
                          softWrap: true,
                          style: TextStyle(
                              fontFamily: "Avenir",
                              fontWeight: FontWeight.normal,
                              color: AppColors.primarySecondaryElementText,
                              fontSize: 12.sp),
                        )
                      ],
                    ),
                  ),
                  SizedBox(
                    width: 86.w,
                    height: 44.w,
                    child: Column(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      crossAxisAlignment: CrossAxisAlignment.end,
                      children: [
                        Text(
                          item.last_time == null
                              ? ""
                              : duTimeLineFormat(
                                  (item.last_time as Timestamp).toDate()),
                          overflow: TextOverflow.clip,
                          maxLines: 1,
                          softWrap: true,
                          style: TextStyle(
                              fontFamily: "Avenir",
                              fontWeight: FontWeight.bold,
                              color: AppColors.thirdElementText,
                              fontSize: 14.sp),
                        ),
                      ],
                    ),
                  )
                ],
              ),
            )
          ],
        ),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Obx(() => SafeArea(
              child: Stack(
            alignment: Alignment.center,
            children: [
              CustomScrollView(
                slivers: [
                  SliverAppBar(
                    pinned: true,
                    title: _headBar(),
                  ),
                  SliverPadding(
                    padding:
                        EdgeInsets.symmetric(vertical: 0.w, horizontal: 20.w),
                    sliver: SliverToBoxAdapter(
                      child: _headTabs(),
                    ),
                  ),
                  SliverPadding(
                      padding:
                          EdgeInsets.symmetric(vertical: 0.w, horizontal: 20.w),
                      sliver: controller.state.tabstatus.value
                          ? SliverList(
                              delegate:
                                  SliverChildBuilderDelegate((context, index) {
                              var item = controller.state.msgslist[index];
                              return chatListItem(item);
                            }, childCount: controller.state.msgslist.length))
                          : SliverList(
                              delegate:
                                  SliverChildBuilderDelegate((context, index) {
                              var item = controller.state.calllist[index];
                              return callListItem(item);
                            }, childCount: controller.state.calllist.length)))
                ],
              )
            ],
          ))),
      floatingActionButton: FloatingActionButton(
          child: Padding(
              padding: EdgeInsets.all(10),
              child: Image.asset(
                'assets/icons/contact.png',
              )),
          onPressed: () {
            Get.toNamed(AppRoutes.Contact);
          }),
    );
  }
}
