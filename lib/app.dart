import 'package:firebase_crashlytics/firebase_crashlytics.dart';
import 'package:firebase_phone_auth_handler/firebase_phone_auth_handler.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:flutter_mentions/flutter_mentions.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:gaya/view/chat/controllers/queue_message_controller.dart';
import 'package:get/get.dart';
import 'package:provider/provider.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:uuid/uuid.dart';

import 'bindings/initializing_dependencies.dart';
import 'components/pick.image.component.dart';
import 'controller/app_config_controller.dart';
import 'controller/block_controller.dart';
import 'controller/communities.controller.dart';
import 'controller/create.post.controller.dart';
import 'controller/firebase_analytics_controller.dart';
import 'controller/gaya_shared_controller.dart';
import 'controller/group.controller.dart';
import 'controller/homepage.controller.dart';
import 'controller/message.controller.dart';
import 'controller/notification.controller.dart';
import 'controller/profile.controller.dart';
import 'controller/report_controller.dart';
import 'controller/topics.controller.dart';
import 'model/user.model.dart';
import 'routing/getx_route_methods.dart';
import 'services/services.dart';
import 'shared/service/facebook_analytics_service.dart';
import 'shared/service/mentioning_service/mentioning_user.dart';
import 'shared/service/service/version_platform_services.dart';
import 'utils/flavors/flavors.dart';
import 'utils/helpers.functions.dart';
import 'utils/language/translation.dart';
import 'utils/local.storage.dart';
import 'utils/logger.dart';
import 'utils/scroll_behaviour.dart';
import 'utils/textstyles.dart';
import 'view/Auth/controller/login.controller.dart';
import 'view/chat/controllers/chat_controller.dart';
import 'view/share/controllers/instagram_story_share_controller.dart';

class GayaApp extends StatelessWidget {
  const GayaApp({super.key});

  @override
  Widget build(BuildContext context) {
    return GetBuilder<LocalizationController>(
      builder: (localizeController) {
        return MultiProvider(
          providers: [
            ChangeNotifierProvider<TopicsController>(create: (context) => TopicsController()),
            ChangeNotifierProvider<LoginController>(create: (context) => LoginController()),
            ChangeNotifierProvider<HomePageController>(create: (context) => HomePageController()),
            ChangeNotifierProvider<CommunitiesController>(create: (context) => CommunitiesController()),
            ChangeNotifierProvider<GroupController>(create: (context) => GroupController()),
            ChangeNotifierProvider<NotificationController>(create: (context) => NotificationController()),
            ChangeNotifierProvider<ProfileController>(create: (context) => ProfileController()),
            ChangeNotifierProvider<PickImage>(create: (context) => PickImage()),
            ChangeNotifierProvider<CreatePostController>(create: (context) => CreatePostController()),
            ChangeNotifierProvider<MessageController>(create: (context) => MessageController()),
            ChangeNotifierProvider<HelpersFunctions>(create: (context) => HelpersFunctions()),
          ],

          /// firebase phone auth handler - OTP firebase
          child: FirebasePhoneAuthProvider(
            /// flutter mentions
            child: Portal(
              child: GetMaterialApp(
                textDirection: TextDirection.ltr,
                translationsKeys: AppTranslation.translations,
                locale: localizeController.getLastSelectedLanguageCode(),
                fallbackLocale: localizeController.fallbackLanguage,
                defaultTransition: Transition.cupertino,
                theme: GayaTheme.themeData(context),
                getPages: RouteHelper.routes,
                unknownRoute: RouteHelper.unknownRoute,
                initialRoute: splash,
                navigatorObservers: [AnalyticsController.to.instance.observer],
                debugShowCheckedModeBanner: F.isDev,
                scrollBehavior: const ScrollBehaviorModified(),
                initialBinding: InitializingDependency(),
                builder: (ctx, child) {
                  ScreenUtil.init(
                    ctx,
                    splitScreenMode: true,
                    designSize: const Size(375, 812),
                    minTextAdapt: true,
                  );
                  return _Unfocus(
                    child: child ?? const SizedBox.shrink(),
                  );
                },
              ),
            ),
          ),
        );
      },
    );
  }
}

var uuid = const Uuid();

/// Service locators
Future<void> serviceLocators() async {
  Get.lazyPut(() => GetStorageController(), fenix: true);
  FirebaseBindings.init();

  Get.lazyPut(() => LocalizationController(getStorage: Get.find()));
  Get.lazyPut(() => MyLoggerServices(), fenix: true);
  Get.lazyPut(() => VersionPlatformServices(), fenix: true);
  Get.lazyPut(() => UserModel(), fenix: true);
  Get.lazyPut(() => Services(), fenix: true);
  Get.lazyPut(() => AppConfigurationController(), fenix: true);
  Get.lazyPut(() => GayaSharedController(versionPlatform: Get.find()), fenix: true);
  Get.lazyPut(() => ReportController());
  Get.lazyPut(() => BlockController());
  Get.lazyPut(() => UserMentionedService(), fenix: true);
  Get.lazyPut(() => InstagramStoryShareController(), fenix: true);
  // Get.lazyPut(() => ChatController(), fenix: true);
  Get.lazyPut(() => QueueMessageController(), fenix: true);
  Get.put(ChatController());

  // Initializing facebook analytics
  await FacebookAnalyticsService().init();
}

/// Initial route (either splash or onBoarding)
String splash = RouteHelper.splash;

/// this function just used to enusre theat user entered the first time in application
/// based on that we show the splash screen (onboard splash screen or just simple splash screen)
/// need to be convert into service class (later)
Future<void> getEntry() async {
  try {
    SharedPreferences preferences = await SharedPreferences.getInstance();
    // status means user entered the first time in app or multiple times before
    final entryStatus = preferences.getInt('userEntryStatus');
    if (entryStatus == null || entryStatus == 0) {
      await preferences.setInt('userEntryStatus', 1);
      splash = RouteHelper.onBoardingSplash;
    } else {
      await preferences.setInt('userEntryStatus', 1);
      splash = RouteHelper.splash;
    }
  } catch (e) {
    debugPrint(e.toString());
  }
}

/// Invoke to init crashlytics
Future<void> initCrashlytics() async {
  if (kDebugMode) return;
  try {
    FlutterError.onError = (errorDetails) {
      // If you wish to record a "non-fatal" exception, please use `FirebaseCrashlytics.instance.recordFlutterError` instead
      FirebaseCrashlytics.instance.recordFlutterFatalError(errorDetails);
    };
    PlatformDispatcher.instance.onError = (error, stack) {
      // If you wish to record a "non-fatal" exception, please remove the "fatal" parameter
      FirebaseCrashlytics.instance.recordError(error, stack, fatal: true);
      return true;
    };
  } catch (_) {}
}

/// A widget that unfocus everything when tapped.
///
/// This implements the "Unfocus when tapping in empty space" behavior for the
/// entire application.
class _Unfocus extends StatelessWidget {
  const _Unfocus({Key? key, required this.child}) : super(key: key);

  final Widget child;

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      behavior: HitTestBehavior.opaque,
      onTap: () => FocusManager.instance.primaryFocus?.unfocus(),
      child: child,
    );
  }
}
