import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:cached_network_image/cached_network_image.dart';

import '../../../../common/entities/msgcontent.dart';
import '../../../../common/style/color.dart';

// Widget LeftChatItem(Msgcontent item) {
//   return Container(
//     padding: EdgeInsets.only(left: 15.w, top: 10.w, right: 15.w, bottom: 10.w),
//     child: Row(
//       mainAxisAlignment: MainAxisAlignment.start,
//       children: [
//         ConstrainedBox(
//           constraints: BoxConstraints(
//               // maxHeight: 40.w,
//               // maxWidth: 230.w,
//               ),
//           child: Container(
//             margin: EdgeInsets.only(right: 10.w, top: 0.w),
//             padding: EdgeInsets.only(
//                 left: 10.w, top: 10.w, right: 10.w, bottom: 10.w),
//             decoration: BoxDecoration(
//                 color: Colors.orange,
//                 borderRadius: BorderRadius.all(
//                   Radius.circular(10.w),
//                 )),
//             child: item.type == 'text'
//                 ? Text(
//                     "${item.content}",
//                     style: TextStyle(color: Colors.white, fontSize: 18),
//                   )
//                 : ConstrainedBox(
//                     child: GestureDetector(
//                       onTap: () {},
//                       child: CachedNetworkImage(
//                         imageUrl: "${item.content}",
//                         height: 50,
//                         width: 50,
//                       ),
//                     ),
//                     constraints: BoxConstraints(
//                       maxWidth: 90.w,
//                     ),
//                   ),
//           ),
//         )
//       ],
//     ),
//   );
// }

Widget LeftChatItem(Msgcontent item) {
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
                    imageUrl: "${item.content}",
                    height: 50,
                    width: 50,
                    fit: BoxFit.cover, // Adjust the fit as needed
                  ),
                ),
        )
      ],
    ),
  );
}
