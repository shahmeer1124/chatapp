import 'package:get/get.dart';
import 'package:google_sign_in/google_sign_in.dart';
import 'package:lechat/common/store/store.dart';
import 'package:lechat/pages/profile/state.dart';

class ProfileController extends GetxController {
  ProfileController();
  final state = ProfileState();

  void goLogOut() async {
    await GoogleSignIn().signOut();
    await UserStore.to.onLogout();
  }

  @override
  void onInit() {
    var userItem = Get.arguments;
    if (userItem != null) {
      state.head_detail.value = userItem;
    }
    super.onInit();
  }
}
