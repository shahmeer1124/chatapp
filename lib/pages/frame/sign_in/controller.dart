import 'dart:convert';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:firebase_messaging/firebase_messaging.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:flutter_easyloading/flutter_easyloading.dart';
import 'package:fluttertoast/fluttertoast.dart';
import 'package:get/get.dart';
import 'package:google_sign_in/google_sign_in.dart';
import 'package:lechat/common/apis/apis.dart';
import 'package:lechat/common/entities/entities.dart';
import 'package:lechat/common/routes/names.dart';
import 'package:lechat/pages/frame/sign_in/state.dart';
import '../../../common/store/user.dart';

class SignInController extends GetxController {
  final FirebaseMessaging _firebaseMessaging = FirebaseMessaging.instance;

  SignInController();
  final db = FirebaseFirestore.instance;
  final title = "LeChat .";
  final state = SignInState();
  final GoogleSignIn _googleSignIn = GoogleSignIn(scopes: ['openid']);
  void handleSignIn(String type) async {
    try {
      if (type == 'phone number') {
        print('you are login with phone number');
      } else if (type == 'google') {
        var user = await _googleSignIn.signIn();
        String? fcmToken = await _firebaseMessaging.getToken();
        if (user != null) {
          String? displayname = user.displayName;
          String email = user.email;
          String id = user.id;
          String photourl = user.photoUrl ?? 'assets/icons/google.png';
          LoginRequestEntity loginpanelListRequestEntity = LoginRequestEntity();
          loginpanelListRequestEntity.avatar = photourl;
          loginpanelListRequestEntity.fcmtoken = fcmToken;
          loginpanelListRequestEntity.name = displayname;
          loginpanelListRequestEntity.email = email;
          loginpanelListRequestEntity.open_id = id;
          loginpanelListRequestEntity.type = 2;
          final _gauthentication = await user.authentication;
          final credential = GoogleAuthProvider.credential(
              idToken: _gauthentication.idToken,
              accessToken: _gauthentication.accessToken);
          await FirebaseAuth.instance.signInWithCredential(credential);

          asyncPostalldata(loginpanelListRequestEntity, id, displayname!, email,
              photourl, fcmToken!);
        }
      } else {
        print("login type not sure");
      }
    } catch (e) {
      if (kDebugMode) {
        print(".....error with login$e......");
      }
    }
  }

  asyncPostalldata(
      LoginRequestEntity loginRequestEntity,
      String id,
      String displayname,
      String email,
      String photourl,
      String fcmToken) async {
    print('loginresponseentity${jsonEncode(loginRequestEntity)}');
    EasyLoading.show(
        indicator: CircularProgressIndicator(),
        maskType: EasyLoadingMaskType.clear,
        dismissOnTap: true);
    var result = await UserAPI.Login(params: loginRequestEntity);
    print('apiresultfromserver${result}');
    if (result.code == 0) {
      var userbase = await db
          .collection("users")
          .withConverter(
              fromFirestore: UserData.fromFirestore,
              toFirestore: (UserData userdata, options) =>
                  userdata.toFirestore())
          .where('id', isEqualTo: id)
          .get();
      if (userbase.docs.isEmpty) {
        final data = SignInData(
            id: id,
            name: displayname,
            email: email,
            photourl: photourl,
            location: '',
            fcmtoken: fcmToken,
            addtime: Timestamp.now(),
            token: result.data!.token);
        await db
            .collection("users")
            .withConverter(
                fromFirestore: SignInData.fromFirestore,
                toFirestore: (SignInData userdata, options) =>
                    userdata.toFirestore())
            .add(data);
      }
      await UserStore.to.saveProfile(result.data!);
      EasyLoading.dismiss();
    } else {
      EasyLoading.dismiss();
      Fluttertoast.showToast(
          msg: "Internet Error",
          toastLength: Toast.LENGTH_SHORT,
          gravity: ToastGravity.CENTER,
          timeInSecForIosWeb: 1,
          backgroundColor: Colors.red,
          textColor: Colors.white,
          fontSize: 16.0);
    }
    Get.offAllNamed(AppRoutes.Message, parameters: {
      "token": result.data!.token!,
    });
  }
}
