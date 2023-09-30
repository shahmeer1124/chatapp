import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';
import 'package:flutter_easyloading/flutter_easyloading.dart';
import 'package:get/get.dart';
import 'package:lechat/pages/contacts/state.dart';

import '../../common/apis/contact.dart';
import '../../common/entities/contact.dart';
import '../../common/entities/msg.dart';
import '../../common/store/user.dart';

class ContactController extends GetxController {
  ContactController();
  final token = UserStore.to.profile.token;
  final db = FirebaseFirestore.instance;
  final state = ContactState();

  @override
  onReady() {
    asyncLoadAllData();
    super.onReady();
  }

  void goChat(ContactItem contactItem) async {
    print('to_user_token${contactItem.token}');
    var from_messages = await db
        .collection("message")
        .withConverter(
            fromFirestore: Msg.fromFirestore,
            toFirestore: (Msg msg, options) => msg.toFirestore())
        .where("from_token", isEqualTo: token)
        .where("to_token", isEqualTo: contactItem.token)
        .get();

    var to_messages = await db
        .collection("message")
        .withConverter(
            fromFirestore: Msg.fromFirestore,
            toFirestore: (Msg msg, options) => msg.toFirestore())
        .where("from_token", isEqualTo: contactItem.token)
        .where("to_token", isEqualTo: token)
        .get();

    if (from_messages.docs.isEmpty && to_messages.docs.isEmpty) {
        print('againtokencheckcup1${contactItem.token}');

      // If both lists are empty, create a new message document
      var profile = UserStore.to.profile;
      var msgdata = Msg(
        from_token: profile.token,
        to_token: contactItem.token,
        from_avatar: profile.avatar,
        to_avatar: contactItem.avatar,
        from_name: profile.name,
        to_name: contactItem.name,
        from_online: profile.online,
        to_online: contactItem.online,
        last_msg: '',
        last_time: Timestamp.now(),
        msg_num: 0,
      );
      var doc_id = await db
          .collection("message")
          .withConverter(
              fromFirestore: Msg.fromFirestore,
              toFirestore: (Msg msg, options) => msg.toFirestore())
          .add(msgdata);
      Get.toNamed("/chat", arguments: {
        
        "doc_id": doc_id.id,
        "to_token": contactItem.token ?? '',
        "to_name": contactItem.name ?? '',
        'to_avatar': contactItem.avatar ?? '',
        "to_online": contactItem.online.toString()
      });
    } else {
      if (from_messages.docs.isNotEmpty &&
          from_messages.docs.first.id.isNotEmpty) {
        print('againtokencheckcup${contactItem.token}');
        // Check if the 'from_messages' list is not empty
        Get.toNamed("/chat", arguments: {
          "doc_id": from_messages.docs.first.id,
          "to_token": contactItem.token ?? '',
          "to_name": contactItem.name ?? '',
          'to_avatar': contactItem.avatar ?? '',
          "to_online": contactItem.online.toString()
        });
      }
      if (to_messages.docs.isNotEmpty && to_messages.docs.first.id.isNotEmpty) {
        // Check if the 'to_messages' list is not empty
        Get.toNamed("/chat", arguments: {
          "doc_id": to_messages.docs.first.id,
          "to_token": contactItem.token ?? '',
          "to_name": contactItem.name ?? '',
          'to_avatar': contactItem.avatar ?? '',
          "to_online": contactItem.online.toString()
        });
      }
    }
  }

  // void goChat(ContactItem contactItem) async {
  //   var from_messages = await db
  //       .collection("message")
  //       .withConverter(
  //           fromFirestore: Msg.fromFirestore,
  //           toFirestore: (Msg msg, options) => msg.toFirestore())
  //       .where("from_token", isEqualTo: token)
  //       .where("to_token", isEqualTo: contactItem.token)
  //       .get();

  //   var to_messages = await db
  //       .collection("message")
  //       .withConverter(
  //           fromFirestore: Msg.fromFirestore,
  //           toFirestore: (Msg msg, options) => msg.toFirestore())
  //       .where("from_token", isEqualTo: contactItem.token)
  //       .where("to_token", isEqualTo: token)
  //       .get();

  //   if (from_messages.docs.isEmpty && to_messages.docs.isEmpty) {
  //     var profile = UserStore.to.profile;
  //     var msgdata = Msg(
  //         from_token: profile.token,
  //         to_token: contactItem.token,
  //         from_avatar: profile.avatar,
  //         to_avatar: contactItem.avatar,
  //         from_name: profile.name,
  //         to_name: contactItem.name,
  //         from_online: profile.online,
  //         to_online: contactItem.online,
  //         last_msg: '',
  //         last_time: Timestamp.now(),
  //         msg_num: 0);
  //     var doc_id = await db
  //         .collection("message")
  //         .withConverter(
  //             fromFirestore: Msg.fromFirestore,
  //             toFirestore: (Msg msg, options) => msg.toFirestore())
  //         .add(msgdata);
  //     Get.toNamed("/chat", arguments: {
  //       "doc_id": doc_id.id,
  //       "to_token": contactItem.token ?? '',
  //       "to_name": contactItem.name ?? '',
  //       'to_avatar': contactItem.avatar ?? '',
  //       "to_online": contactItem.online.toString()
  //     });
  //   } else {
  //     if(from_messages.docs.first.id.isNotEmpty){

  //     Get.toNamed("/chat", arguments: {
  //       "doc_id": from_messages.docs.first.id,
  //       "to_token": contactItem.token ?? '',
  //       "to_name": contactItem.name ?? '',
  //       'to_avatar': contactItem.avatar ?? '',
  //       "to_online": contactItem.online.toString()
  //     });
  //     }
  //     if(to_messages.docs.first.id.isNotEmpty){

  //     Get.toNamed("/chat", arguments: {
  //       "doc_id": to_messages.docs.first.id,
  //       "to_token": contactItem.token ?? '',
  //       "to_name": contactItem.name ?? '',
  //       'to_avatar': contactItem.avatar ?? '',
  //       "to_online": contactItem.online.toString()
  //     });
  //     }
  //   }
  // }

  asyncLoadAllData() async {
    EasyLoading.show(
      indicator: CircularProgressIndicator(),
      maskType: EasyLoadingMaskType.clear,
      dismissOnTap: true,
    );
    state.contactlist.clear();
    var result = await ContactAPI.post_contact();
    print('dataincoming${result.data!.length}');
    if (result.code == -1) {
      state.contactlist.addAll(result.data!);
    }
    EasyLoading.dismiss();
  }
}
