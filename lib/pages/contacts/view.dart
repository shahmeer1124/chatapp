import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:get/get.dart';
import 'package:lechat/common/values/colors.dart';

import 'contactlist/contact_list.dart';
import 'controller.dart';

class ContactPage extends GetView<ContactController> {
  const ContactPage({super.key});

  AppBar _buildAppbar() {
    return AppBar(
      title: Text(
        "Contact",
        style: TextStyle(
            color: AppColors.primaryText,
            fontSize: 16.sp,
            fontWeight: FontWeight.normal),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: _buildAppbar(),
     
      body: Container(
        height: 780.h,
        width: 360.w,
        child: ContactList(),
      )
    );
  }
}
