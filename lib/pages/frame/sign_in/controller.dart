import 'dart:convert';
import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:flutter_easyloading/flutter_easyloading.dart';
import 'package:get/get.dart';
import 'package:google_sign_in/google_sign_in.dart';
import 'package:lechat/pages/frame/sign_in/state.dart';
import 'package:fluttertoast/fluttertoast.dart';
import '../../../common/apis/user.dart';
import '../../../common/entities/user.dart';
import '../../../common/routes/names.dart';
import '../../../common/store/user.dart';

class SignInController extends GetxController {
  SignInController();
  final title = 'Chatty.';
  final state = SignInState();
  final GoogleSignIn _googleSignIn = GoogleSignIn(scopes: ['openid']);

  void handleSignIn(String type) async {
    // 1: email 2:google 3: facebook 4: apple
    try {
      if (type == "phone number") {
        if (kDebugMode) {
          print(".. login with phone number");
        }
      } else if (type == 'google') {
        print("google login pressed");
        var user = await _googleSignIn.signIn();

        if (user != null) {
          print('meinphotourllaya${user.photoUrl}');
          String? displayName = user.displayName;
          String email = user.email;
          String id = user.id;
          String photoUrl = user.photoUrl ?? "assets/icons/google.png";
          LoginRequestEntity loginRequestEntity = LoginRequestEntity();
          loginRequestEntity.avatar = photoUrl;
          loginRequestEntity.name = displayName;
          loginRequestEntity.email = email;
          loginRequestEntity.open_id = id;
          loginRequestEntity.type = 2;
          print(jsonEncode(loginRequestEntity));

          asyncPostallData(loginRequestEntity);
        }
      } else {
        if (kDebugMode) {
          print("Type not specified");
        }
      }
    } catch (e) {
      if (kDebugMode) {
        print('... error with login $e');
      }
    }
  }

  asyncPostallData(LoginRequestEntity loginRequestEntity) async {
    EasyLoading.show(
      indicator: const CircularProgressIndicator(),
      maskType: EasyLoadingMaskType.clear,
    );
    var result = await UserAPI.Login(params: loginRequestEntity);
    if (result.code == 0) {
      await UserStore.to.saveProfile(result.data!);
      EasyLoading.dismiss();
    } else {
      EasyLoading.dismiss();
      Fluttertoast.showToast(
          msg: "Network Error",
          toastLength: Toast.LENGTH_SHORT,
          gravity: ToastGravity.CENTER,
          timeInSecForIosWeb: 1,
          backgroundColor: Colors.red,
          textColor: Colors.white,
          fontSize: 16.0);
    }
    Get.offAllNamed(AppRoutes.Message);
  }
}
