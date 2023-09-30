import 'package:cloud_firestore/cloud_firestore.dart';

class Msgcontent {
  final String? token;
  final String? content;
  final String? type;
  final Timestamp? addtime;


  Msgcontent({
    this.token,
    this.content,
    this.type,
    this.addtime,
 
  });

  factory Msgcontent.fromFirestore(
    DocumentSnapshot<Map<String, dynamic>> snapshot,
    SnapshotOptions? options,
  ) {
    final data = snapshot.data();
    return Msgcontent(
      token: data?['token'],
      content: data?['content'],
      type: data?['type'],
      addtime: data?['addtime'],

    );
  }

  Map<String, dynamic> toFirestore() {
    return {
      if (token != null) "token": token,
      if (content != null) "content": content,
      if (type != null) "type": type,
      if (addtime != null) "addtime": addtime,

    };
  }
}
class Callcontent {
  final String? token;
  final String? to_token;
  final String? type;


  Callcontent({
    this.token,
    this.to_token,
    this.type,
 
  });

  factory Callcontent.fromFirestore(
    DocumentSnapshot<Map<String, dynamic>> snapshot,
    SnapshotOptions? options,
  ) {
    final data = snapshot.data();
    return Callcontent(
      token: data?['from_token'],
      to_token: data?['to_token'],
      type: data?['type'],
     
    );
  }

  Map<String, dynamic> toFirestore() {
    return {
      if (token != null) "from_token": token,
      if (to_token != null) "to_token": to_token,
      if (type != null) "type": type,
    };
  }
}
