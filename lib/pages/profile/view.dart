import 'package:cached_network_image/cached_network_image.dart';
import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:get/get.dart';
import 'package:lechat/common/style/color.dart';
import 'package:lechat/common/values/colors.dart';
import 'controller.dart';

class ProfilePage extends GetView<ProfileController> {
  const ProfilePage({super.key});

  AppBar _buildAppBar() {
    return AppBar(
      title: Text(
        "Profile",
        style: TextStyle(
            color: AppColors.primaryText,
            fontSize: 16.sp,
            fontWeight: FontWeight.normal),
      ),
    );
  }

  Widget _buildProfilePhoto() {
    return Stack(
      children: [
        Container(
          margin: EdgeInsets.only(top: 22),
          width: 120.w,
          height: 120.w,
          decoration: BoxDecoration(
              boxShadow: [
                BoxShadow(
                    color: Colors.grey.withOpacity(0.1),
                    spreadRadius: 1,
                    blurRadius: 2,
                    offset: Offset(0, 1))
              ],
              color: AppColors.primarySecondaryBackground,
              borderRadius: BorderRadius.all(Radius.circular(60.w))),
          child: controller.state.head_detail.value.avatar != null
              ? CachedNetworkImage(
                  imageUrl: controller.state.head_detail.value.avatar!,
                  height: 120.w,
                  width: 120.w,
                  imageBuilder: (context, ImageProvider) => Container(
                    decoration: BoxDecoration(
                      borderRadius: BorderRadius.all(
                        Radius.circular(60.w),
                      ),
                      image: DecorationImage(
                          image: ImageProvider, fit: BoxFit.cover),
                    ),
                  ),
                  errorWidget: (context, url, error) => const Image(
                      image: AssetImage('assets/images/account_header.png')),
                )
              : Image(
                  height: 120.h,
                  width: 120.w,
                  image: AssetImage(
                    'assets/images/account_header.png',
                  ),
                  fit: BoxFit.cover,
                ),
        ),
        // Positioned(
        //     bottom: 0.w,
        //     right: 0.w,
        //     height: 35.w,
        //     child: GestureDetector(
        //       child: Container(
        //         padding: EdgeInsets.all(7.w),
        //         height: 35.w,
        //         width: 35.w,
        //         decoration: BoxDecoration(
        //             color: AppColors.primaryElement,
        //             borderRadius: BorderRadius.all(Radius.circular(40.w))),
        //         child: Image.asset('assets/icons/edit.png'),
        //       ),
        //     ))
      ],
    );
  }

  Widget _buildCompletebutton() {
    return GestureDetector(
      child: Container(
        margin: EdgeInsets.only(top: 60.h, bottom: 30.h),
        width: 295.w,
        height: 44.h,
        decoration: BoxDecoration(
            boxShadow: [
              BoxShadow(
                  color: Colors.grey.withOpacity(0.1),
                  spreadRadius: 1,
                  blurRadius: 2,
                  offset: Offset(0, 1))
            ],
            color: AppColors.primaryElement,
            borderRadius: BorderRadius.all(Radius.circular(05.w))),
        child: Row(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Text(
              "Complete",
              textAlign: TextAlign.center,
              style: TextStyle(
                  color: AppColors.primaryElementText,
                  fontSize: 14.sp,
                  fontWeight: FontWeight.normal),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildLogoutButton() {
    return GestureDetector(
      child: Container(
        margin: EdgeInsets.only(top: Get.height * 0.5, bottom: 30.h),
        width: 295.w,
        height: 44.h,
        decoration: BoxDecoration(
            boxShadow: [
              BoxShadow(
                  color: Colors.grey.withOpacity(0.1),
                  spreadRadius: 1,
                  blurRadius: 2,
                  offset: Offset(0, 1))
            ],
            color: AppColors.primarySecondaryElementText.withOpacity(0.3),
            borderRadius: BorderRadius.all(Radius.circular(20.w))),
        child: Row(
          mainAxisAlignment: MainAxisAlignment.start,
          children: [
            SizedBox(
              width: 10,
            ),
            Icon(
              Icons.arrow_forward_ios,
            ),
            SizedBox(
              width: 120,
            ),
            Text(
              "Logout",
              textAlign: TextAlign.center,
              style: TextStyle(
                  color: Colors.black,
                  fontSize: 14.sp,
                  fontWeight: FontWeight.normal),
            ),
          ],
        ),
      ),
      onTap: () {
        Get.defaultDialog(
            title: "Are you sure to Logout?",
            onConfirm: () {
              controller.goLogOut();
            },
            onCancel: () {},
            content: Container(),
            textConfirm: "Confirm",
            textCancel: "Cancel",
            confirmTextColor: Colors.white);
      },
    );
  }

  Widget _buildNameSection() {
    return Padding(
      padding: const EdgeInsets.only(top: 20.0, bottom: 20.0),
      child: Text(
        controller.state.head_detail.value.name.toString(),
        style: TextStyle(
          color: AppColor.primaryText,
          fontWeight: FontWeight.bold,
          fontSize: 24.sp,
        ),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: _buildAppBar(),
      body: SafeArea(
          child: CustomScrollView(
        slivers: [
          SliverToBoxAdapter(
            child: Container(
              child: Column(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                crossAxisAlignment: CrossAxisAlignment.center,
                children: [
                  _buildProfilePhoto(),
                  _buildNameSection(),
                  // _buildCompletebutton(),
                  _buildLogoutButton()
                ],
              ),
            ),
          )
        ],
      )),
    );
  }
}
