import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:get/get.dart';
import 'package:lechat/common/values/colors.dart';
import '../../common/routes/names.dart';
import 'chat/widget/message_list.dart';
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
                        ? Image(
                            image:
                                AssetImage('assets/images/account_header.png'))
                        : Text('Hi'),
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

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: SafeArea(
        child: CustomScrollView(
          slivers: [
            SliverAppBar(
              pinned: true,
              title: _headBar(),
            ),
            SliverFillRemaining(
              child: MessageList(),
            ),
          ],
        ),
      ),
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
