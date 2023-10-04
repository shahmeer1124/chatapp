import 'package:flutter/material.dart';
import 'package:flutter/src/widgets/framework.dart';
import 'package:get/get.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import '../controller.dart';
import 'chat_left_item.dart';
import 'chat_right_item.dart';

class ChatList extends GetView<ChatController> {
  const ChatList({super.key});

  @override
  Widget build(BuildContext context) {
    return Obx(() => Container(
          color: Color(0xFF1B1A2F),
          padding: EdgeInsets.only(bottom: 50.h),
          child: GestureDetector(
            onTap: () {
              controller.closeAllPop();
            },
            child: CustomScrollView(
              reverse: true,
              controller: controller.msgScrolling,
              slivers: [
                SliverPadding(
                    padding:
                        EdgeInsets.symmetric(horizontal: 0.w, vertical: 30.h),
                    sliver: SliverList(
                      delegate: SliverChildBuilderDelegate((context, index) {
                        var item = controller.state.msgcontentList[index];
                        if (controller.token == item.token) {
                          return rightChatItem(item);
                        }
                        return LeftChatItem(item);
                      }, childCount: controller.state.msgcontentList.length),
                    )),
                SliverPadding(
                  padding: EdgeInsets.symmetric(horizontal: 0.w, vertical: 0.w),
                  sliver: SliverToBoxAdapter(
                    child: controller.state.isLoading.value
                        ? Align(
                            alignment: Alignment.center,
                            child: Text(
                              'Loading',
                              style: TextStyle(color: Colors.white),
                            ),
                          )
                        : Container(),
                  ),
                )
              ],
            ),
          ),
        ));
  }
}
