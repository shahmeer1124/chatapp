import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:get/get.dart';
import 'package:lechat/common/values/colors.dart';
import '../../../common/style/color.dart';
import 'controller.dart';

class SignInPage extends GetView<VideoCallController> {
  const SignInPage({super.key});
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.primarySecondaryBackground,
      body: Center(
        child: Column(
          children: [],
        ),
      ),
    );
  }
}
