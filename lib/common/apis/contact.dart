

import '../entities/contact.dart';
import '../utils/http.dart';

class ContactAPI {
  /// 翻页
  /// refresh 是否刷新
  static Future<ContactResponseEntity> post_contact() async {
    print("inside contact");
    var response = await HttpUtil().post(
      'api/contact',
    );
    print(response);
    return ContactResponseEntity.fromJson(response);
  }
}
