import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:get/get.dart';
import 'package:lechat/common/entities/user.dart';

import '../../common/entities/msg.dart';

class MessageState {
    RxList<QueryDocumentSnapshot<Msg>> msglist =
      <QueryDocumentSnapshot<Msg>>[].obs;
  var head_detail = UserItem().obs;
}

