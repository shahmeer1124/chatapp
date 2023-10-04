import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:get/get.dart';
import 'package:lechat/common/entities/entities.dart';
import 'package:lechat/common/entities/user.dart';

import '../../common/entities/msg.dart';

class MessageState {
  RxList<QueryDocumentSnapshot<Msg>> msglist =
      <QueryDocumentSnapshot<Msg>>[].obs;
  RxList<Message> msgslist = <Message>[].obs;
  RxList<CallMessage> calllist = <CallMessage>[].obs;

  var head_detail = UserItem().obs;
  RxBool tabstatus = true.obs;
}
