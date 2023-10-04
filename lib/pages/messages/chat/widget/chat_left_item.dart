import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:cached_network_image/cached_network_image.dart';
import 'package:lechat/common/values/server.dart';

import '../../../../common/entities/msgcontent.dart';
import '../../../../common/style/color.dart';


Widget LeftChatItem(Msgcontent item) {
   var imagepath = null;
  if (item.type == 'image') {
    print('imagedata${item.content}');
   imagepath= item.content?.replaceAll('http://localhost/', SERVER_API_URL);
  }
  return Container(
    padding: EdgeInsets.only(left: 15.w, top: 10.w, right: 15.w, bottom: 10.w),
    child: Row(
      mainAxisAlignment: MainAxisAlignment.start,
      children: [
        Container(
          margin: EdgeInsets.only(right: 10.w, top: 0.w),
          constraints: BoxConstraints(
            maxWidth: 0.8.sw, // Maximum width is 80% of the screen width
          ),
          decoration: BoxDecoration(
            color: Color.fromARGB(255, 66, 68, 78),
            borderRadius: BorderRadius.all(
              Radius.circular(5.w),
            ),
          ),
          child: item.type == 'text'
              ? Padding(
                  padding: EdgeInsets.all(10.w),
                  child: Text(
                    "${item.content}",
                    style: appstyle(13, Colors.white, FontWeight.normal),
                  ),
                )
              : GestureDetector(
                  onTap: () {},
                  child: CachedNetworkImage(
                    imageUrl: imagepath,
                    width: 0.8.sw,
                    fit: BoxFit.cover, // Adjust the fit as needed
                  ),
                ),
        )
      ],
    ),
  );
}
