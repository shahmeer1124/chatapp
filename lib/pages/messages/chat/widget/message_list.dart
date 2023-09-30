import 'package:flutter/material.dart';
import 'package:flutter/src/widgets/framework.dart';
import 'package:get/get.dart';
import 'package:lechat/common/style/color.dart';
import 'package:pull_to_refresh/pull_to_refresh.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:cached_network_image/cached_network_image.dart';
import '../../../../common/entities/msg.dart';
import '../../../../common/utils/date.dart';
import '../../../../common/values/colors.dart';
import '../../controller.dart';

class MessageList extends GetView<MessageController> {
  const MessageList({super.key});

  Widget MsgListItem(QueryDocumentSnapshot<Msg> item) {
    return Container(
      padding: EdgeInsets.only(top: 10.w, left: 15.w, right: 15.w),
      child: InkWell(
        onTap: () {
          var to_uid = '';
          var to_name = '';
          var to_avatar = '';

          if (item.data().from_token == controller.token) {
            to_uid = item.data().to_token ?? '';
            to_name = item.data().to_name ?? '';
            to_avatar = item.data().to_avatar ?? '';
          } else {
            to_uid = item.data().from_token ?? '';
            to_name = item.data().from_name ?? '';
            to_avatar = item.data().from_avatar ?? '';
          }

          Get.toNamed('/chat', arguments: {
            'doc_id': item.id,
            'to_token': to_uid,
            'to_name': to_name,
            'to_avatar': to_avatar,
            'to_online': '1'
          });
        },
        child: Row(
          mainAxisAlignment: MainAxisAlignment.start,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Container(
              padding: EdgeInsets.only(top: 0.w, left: 0.w, right: 15.w),
              child: SizedBox(
                width: 54.w,
                height: 54.w,
                child: CachedNetworkImage(
                  imageUrl: item.data().from_token == controller.token
                      ? item.data().to_avatar!
                      : item.data().from_avatar!,
                  imageBuilder: ((context, imageProvider) => Container(
                        width: 54.w,
                        height: 54.w,
                        decoration: BoxDecoration(
                            borderRadius: BorderRadius.all(Radius.circular(54)),
                            image: DecorationImage(
                                image: imageProvider, fit: BoxFit.cover)),
                      )),
                  errorWidget: ((context, url, error) => const Image(
                      image: AssetImage('assets/images/feature-1.png'))),
                ),
              ),
            ),
            Container(
              decoration: const BoxDecoration(
                  border: Border(
                      bottom: BorderSide(width: 1, color: Color(0xe5e5e5)))),
              padding: EdgeInsets.only(top: 5.w, left: 0.w, right: 0.w),
              child: Row(
                crossAxisAlignment: CrossAxisAlignment.center,
                children: [
                  SizedBox(
                    width: 180.w,
                    height: 48.w,
                    child: Column(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          item.data().from_token == controller.token
                              ? item.data().to_name!
                              : item.data().from_name!,
                          overflow: TextOverflow.clip,
                          maxLines: 1,
                          style: const TextStyle(
                              fontFamily: 'Avenir',
                              fontWeight: FontWeight.bold,
                              color: AppColors.thirdElement,
                              fontSize: 16),
                        ),
                        Text(
                          item.data().last_msg! ?? '',
                          overflow: TextOverflow.clip,
                          maxLines: 1,
                          style: const TextStyle(
                              fontFamily: 'Avenir',
                              fontWeight: FontWeight.normal,
                              fontSize: 14,
                              color: AppColors.thirdElement),
                        ),
                      ],
                    ),
                  ),
                  SizedBox(
                    width: 60.w,
                    height: 54.w,
                    child: Column(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      crossAxisAlignment: CrossAxisAlignment.end,
                      children: [
                        Text(
                          duTimeLineFormat(
                              (item.data().last_time as Timestamp).toDate()),
                          overflow: TextOverflow.clip,
                          maxLines: 1,
                          style: const TextStyle(
                              fontSize: 12,
                              fontFamily: 'Avenir',
                              fontWeight: FontWeight.bold,
                              color: AppColors.thirdElementText),
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
    return CustomScrollView(
      slivers: [
        SliverPadding(
          padding: EdgeInsets.symmetric(horizontal: 0.w, vertical: 0.w),
          sliver: StreamBuilder<QuerySnapshot>(
            stream: controller.db
                .collection('message')
                .withConverter(
                    fromFirestore: Msg.fromFirestore,
                    toFirestore: (Msg msg, options) => msg.toFirestore())
                .where('from_token', isEqualTo: controller.token)
                .snapshots(),
            builder: (context, fromSnapshot) {
              if (!fromSnapshot.hasData) {
                return SliverToBoxAdapter(child: CircularProgressIndicator());
              }

              final incomingMessages = fromSnapshot.data!.docs;

              return StreamBuilder<QuerySnapshot<Msg>>(
                stream: controller.db
                    .collection('message')
                    .withConverter(
                        fromFirestore: Msg.fromFirestore,
                        toFirestore: (Msg msg, options) => msg.toFirestore())
                    .where('from_token', isEqualTo: controller.token)
                    .snapshots(),
                builder: (context, fromSnapshot) {
                  if (!fromSnapshot.hasData) {
                    return SliverToBoxAdapter(
                        child: CircularProgressIndicator());
                  }

                  final incomingMessages = fromSnapshot.data!.docs;

                  return StreamBuilder<QuerySnapshot<Msg>>(
                    stream: controller.db
                        .collection('message')
                        .withConverter(
                            fromFirestore: Msg.fromFirestore,
                            toFirestore: (Msg msg, options) =>
                                msg.toFirestore())
                        .where('to_token', isEqualTo: controller.token)
                        .snapshots(),
                    builder: (context, toSnapshot) {
                      if (!toSnapshot.hasData) {
                        return SliverToBoxAdapter(
                            child: CircularProgressIndicator());
                      }

                      final outgoingMessages = toSnapshot.data!.docs;
                      final messages = [
                        ...incomingMessages,
                        ...outgoingMessages
                      ];

                      return SliverList(
                        delegate: SliverChildBuilderDelegate((context, index) {
                          var item = messages[index];
                          return MsgListItem(item);
                        }, childCount: messages.length),
                      );
                    },
                  );
                },
              );
            },
          ),
        ),
      ],
    );
  }
}
