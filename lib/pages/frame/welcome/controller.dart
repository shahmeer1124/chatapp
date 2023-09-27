import 'package:get/get.dart';
import 'package:lechat/common/routes/names.dart';
import 'package:lechat/pages/frame/welcome/state.dart';

class WelcomeController extends GetxController {
  WelcomeController();
  final title = "LeChat .";
  final state = WelcomeState();
  @override
  void onReady() {
    Future.delayed(
        Duration(seconds: 3), () => Get.offAllNamed(AppRoutes.Message));
    super.onReady();
  }
}
