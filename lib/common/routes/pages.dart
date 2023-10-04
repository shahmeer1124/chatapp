
import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:lechat/pages/messages/videocall/index.dart';
import '../../pages/contacts/index.dart';
import '../../pages/frame/sign_in/index.dart';
import '../../pages/frame/welcome/index.dart';
import '../../pages/messages/chat/index.dart';
import '../../pages/messages/index.dart';
import '../../pages/messages/voicecall/index.dart';
import '../../pages/profile/index.dart';
import '../middlewares/router_auth.dart';
import 'routes.dart';

class AppPages {
  static const INITIAL = AppRoutes.INITIAL;
  static final RouteObserver<Route> observer = RouteObservers();
  static List<String> history = [];
 
  static final List<GetPage> routes = [
    // about app bootup
    GetPage(
      name: AppRoutes.INITIAL,
      page: () => const WelcomePage(),
      binding: WelcomeBindings(),
    ),
    GetPage(
      name: AppRoutes.SIGN_IN,
      page: () => SignInPage(),
      binding: SignInBinding(),
    ),

    // 需要登录
    // GetPage(
    //   name: AppRoutes.Application,
    //   page: () => ApplicationPage(),
    //   binding: ApplicationBinding(),
    //   middlewares: [
    //     RouteAuthMiddleware(priority: 1),
    //   ],
    // ),

    // 最新路由
    // GetPage(name: AppRoutes.EmailLogin, page: () => EmailLoginPage(), binding: EmailLoginBinding()),
    // GetPage(name: AppRoutes.Register, page: () => RegisterPage(), binding: RegisterBinding()),
    // GetPage(name: AppRoutes.Forgot, page: () => ForgotPage(), binding: ForgotBinding()),
    // GetPage(name: AppRoutes.Phone, page: () => PhonePage(), binding: PhoneBinding()),
    // GetPage(name: AppRoutes.SendCode, page: () => SendCodePage(), binding: SendCodeBinding()),
    // 首页
    GetPage(name: AppRoutes.Contact, page: () => ContactPage(), binding: ContactBinding()),
    //Message Page
    GetPage(name: AppRoutes.Message, page: () =>const MessagePage(), binding: MessageBinding()
    ,middlewares: [
       RouteAuthMiddleware(priority: 1),
     ],
     ),
    //Profile page
    GetPage(name: AppRoutes.Profile, page: () => ProfilePage(), binding: ProfileBinding()),
    // Chat Controller
    GetPage(name: AppRoutes.Chat, page: () => ChatPage(), binding: ChatBinding()),

    // GetPage(name: AppRoutes.Photoimgview, page: () => PhotoImgViewPage(), binding: PhotoImgViewBinding()),
    GetPage(name: AppRoutes.VoiceCall, page: () => VoiceCallViewPage(), binding: VoiceCallViewBinding()),
    GetPage(name: AppRoutes.VideoCall, page: () => VideoCallPage(), binding: VideoCallBinding()),
  ];
}
