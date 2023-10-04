import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:cached_network_image/cached_network_image.dart';
import 'package:lechat/common/style/color.dart';
import 'package:lechat/common/values/server.dart';
import '../../../../common/entities/msgcontent.dart';
import 'package:intl/intl.dart';

Widget rightChatItem(Msgcontent item) {
  var imagepath = null;
  if (item.type == 'image') {
   imagepath= item.content?.replaceAll('http://localhost/', SERVER_API_URL);
  }
  String formattedTime = DateFormat('h:mm a').format(item.addtime!.toDate());

  return Container(
    padding: EdgeInsets.only(left: 15.w, top: 10.w, right: 15.w, bottom: 10.w),
    child: Row(
      mainAxisAlignment: MainAxisAlignment.end,
      children: [
        Container(
          margin: EdgeInsets.only(right: 10.w, top: 0.w),
          constraints: BoxConstraints(
            maxWidth: 0.8.sw, // Maximum width is 80% of the screen width
          ),
          decoration: BoxDecoration(
            color: Color.fromARGB(255, 22, 30, 146),
            borderRadius: BorderRadius.all(
              Radius.circular(5.w),
            ),
          ),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.end,
            children: [
              item.type == 'text'
                  ? Padding(
                      padding: EdgeInsets.all(10.w),
                      child: Text(
                        "${item.content}",
                        softWrap: true, // Allow text to wrap if it's too long
                        style: appstyle(13, Colors.white, FontWeight.normal),
                      ),
                    )
                  : GestureDetector(
                      onTap: () {
                        // Get.toNamed(AppRoutes.Photoimgview,
                        //     parameters: {'url': item.content ?? ''});
                      },
                      child: CachedNetworkImage(
                        imageUrl: imagepath,
                        width: 0.8.sw, // Set the maximum width for images
                        fit: BoxFit.cover, // Adjust the fit as needed
                      ),
                    ),
              Container(
                width: 100,
                child: Row(
                  mainAxisAlignment: MainAxisAlignment.end,
                  children: [
                    Padding(
                      padding: EdgeInsets.only(bottom: 6.w, right: 3),
                      child: Text(
                        formattedTime,
                        style: appstyle(13, Colors.grey, FontWeight.normal),
                      ),
                    ),
                    Padding(
                      padding: EdgeInsets.only(right: 5.w, bottom: 5.w),
                      child: Icon(
                        Icons.done,
                        color: Colors.blue,
                        size: 16.0,
                      ),
                    ),
                  ],
                ),
              )
            ],
          ),
        ),
      ],
    ),
  );
}
