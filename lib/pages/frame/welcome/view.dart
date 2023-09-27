import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:lechat/common/values/colors.dart';
import 'package:lechat/pages/frame/welcome/controller.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';

class WelcomePage extends GetView<WelcomeController> {
  const WelcomePage({super.key});

  Widget _buildpageTitle(String title) {
    return Container(
      margin: EdgeInsets.only(
        top: 350,
      ),
      child: Text(
        title,
        textAlign: TextAlign.center,
        style:  TextStyle(
            color: AppColors.primaryElementText,
            fontFamily: "Montserrat",
            fontWeight: FontWeight.bold,
            fontSize: 45.sp),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.primaryElement,
      body: Container(
          width: 360.w, height: 780.h, child: _buildpageTitle(controller.title)),
    );
  }
}
