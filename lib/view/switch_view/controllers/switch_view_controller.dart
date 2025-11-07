import 'dart:async';

import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:connectivity_plus/connectivity_plus.dart';
import 'package:connectycube_sdk/connectycube_sdk.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:gaya/controller/firebase_analytics_controller.dart';
import 'package:gaya/controller/gaya_shared_controller.dart';
import 'package:gaya/model/user.model.dart';
import 'package:gaya/routing/getx_route_methods.dart';
import 'package:gaya/services/services.dart';
import 'package:gaya/utils/enum.dart';
import 'package:gaya/view/Auth/controller/require.sigin.register.dart';
import 'package:gaya/view/chat/utils/pref_util.dart';
import 'package:gaya/view/chat/views/chats/chats_screen.dart';
import 'package:gaya/view/create_post/create.post.view.dart';
import 'package:gaya/view/home.view.dart';
import 'package:gaya/view/profile.view.dart';
import 'package:get/get.dart';
import 'package:provider/provider.dart';

import '../../../components/check_for_app_update.dart';
import '../../../components/snackbar.component.dart';
import '../../../controller/communities.controller.dart';
import '../../../controller/message.controller.dart';
import '../../../services/notification/fcm_listeners.dart';
import '../../../services/notification/fcm_service.dart';
import '../../../utils/const.dart';
import '../../../utils/language/translation.dart';
import '../../Auth/controller/login.controller.dart';
import '../../chat/controllers/chat_controller.dart';
import '../../community/communities/communities_view.dart';
import '../../feed/controller/feeds_view_controller.dart';
import '../../feed/controller/for_you_controller.dart';
import '../../messaging/message.view.dart';

class SwitchViewBindings extends Bindings {
  int initialIndex;
  final BuildContext? context;

  SwitchViewBindings({this.initialIndex = 0, this.context});

  @override
  void dependencies() {
    final arguments = Get.arguments;
    if (arguments != null) {
      initialIndex = arguments['initialIndex'];
    }
    Get.lazyPut<SwitchViewController>(() => SwitchViewController(initialIndex: initialIndex, context: context));
    // Get.lazyPut<FeedPostsController>(() => FeedPostsController(), fenix: true);
    Get.lazyPut<ForYouFeedController>(() => ForYouFeedController(), fenix: true);
    Get.lazyPut<FeedPageViewController>(() => FeedPageViewController(), fenix: true);

    // Get.lazyPut(() => QuestionnaireController());
  }
}

class SwitchViewController extends GetxController with WidgetsBindingObserver {
  static SwitchViewController get to => Get.find();
  final int initialIndex;
  final BuildContext? context;
  final AnalyticsController analyticsController = Get.find();

  SwitchViewController({this.initialIndex = 0, this.context});

  final _selectedIndex = 0.obs;

  int get selectedIndex => _selectedIndex.value;

  /// StreamSubscription for app user to listen to changes
  StreamSubscription? appUserStreamSubscription;

  final _commonServices = Services.to;
  List<Widget> screens = [
    const HomeView(),
    GayaRemoteConfig.to.isConnectyCubeEnabled ? const ChatScreen() : const MessageView(),
    const CreatePostView(from: PostCreationFrom.Home, communityModel: null),
    const CommunitiesView(),
    const ProfileView(canPop: false),
  ];

  void setIndex(int index, BuildContext? ctx) {
    /// check if previous and new index are same
    ///
    /// Check if previous index is notification and they are more than zero
    /// make it clear.
    if (selectedIndex == 2 && selectedIndex != index && unreadNotificationCount > 0) {
      _commonServices.markAllNotificationsAsRead();
    }

    /// check index of notification, show permission if needed
    if (index == 2) {
      return;
      // if(FirebaseAuth.instance.currentUser?.uid == null){
      //   Get.toNamed(RouteHelper.requireSignRegisterView);}
      // else{
      //   Routes.createPost(from: PostCreationFrom.Home, community: null);
      // }
    }

    /// Scroll to tops.
    if (index == 0 && _selectedIndex.value == index) {
      if (FirebaseAuth.instance.currentUser?.uid == null) {
        Get.find<ForYouFeedController>().scrollToTop();
        return;
      } else {
        Get.find<FeedPageViewController>().scrollToTop();
        return;
      }
    } else if (index == 1 && _selectedIndex.value == index) {
      if (ctx == null) return;
      Provider.of<MessageController>(ctx, listen: false).scrollToTop();
      return;
    } else if (index == 3 && _selectedIndex.value == index) {
      if (ctx == null) return;
      Provider.of<CommunitiesController>(ctx, listen: false).scrollToTop();
      return;
    }

    if (FirebaseAuth.instance.currentUser?.uid == null) {
      if (index == 2 || index == 4 || index == 1) {
        Get.toNamed(RouteHelper.requireSignRegisterView);
        return;
      }
    }

    ///haptic feedback

    if (index == 1) {
      ChatController.to().getAllUpdatedChatListIfNeeded();
    }

    //analytics
    analyticsController.instance.setScreen(index == 0
        ? '/homefeed'
        : index == 1
            ? '/messages'
            : index == 2
                ? '/CreatePost'
                : index == 3
                    ? '/communities'
                    : '/profile');

    _selectedIndex.value = index;
    HapticFeedback.lightImpact();
  }

  /// A variable to check if the user is inactive for more than 30 minutes
  DateTime inactiveTime = DateTime.now();

  final _commonService = Services.to;

  /// Notification listener COUNT
  void listenToUnreadNotificationCount() {
    _unreadNotificationCount.bindStream(_commonService.getUnreadNotification());
  }

  final RxInt _unreadNotificationCount = 0.obs;
  final RxInt _unreadMessageCount = 0.obs;

  int get unreadMessageCount => _unreadMessageCount.value;

  set unreadMessageCount(int value) {
    /// we don't want to show -ve count
    if (value < 0) {
      value = 0;
    }
    _unreadMessageCount.value = value;
  }

  int get unreadNotificationCount => _unreadNotificationCount.value;

  /// Unread Message Listener COUNT

  @override
  void dispose() {
    WidgetsBinding.instance.removeObserver(this);

    super.dispose();
  }

  final _fcmListener = FCMListeners.init();
  final _connectivity = Connectivity();

  @override
  Future<void> onInit() async {
    super.onInit();
    WidgetsBinding.instance.addObserver(this);

    setIndex(initialIndex, context ?? Get.context);
    listenToUnreadNotificationCount();
    GayaSharedController.to.initDynamicLinks();

    // Subscribe to user data changes (for user block status) (ie. isActive)
    subscribeToAppUser();

    if (kIsWeb) {
      return;
    }
    //checks for version update from remote config
    WidgetsBinding.instance.addPostFrameCallback((_) async {
      /// To Receive FCM messages from CC
      CubeChatConnection.instance.markInactive();

      /// Starts listening to new FCM messages
      _fcmListener.startListeningToNewMessages();

      // Only after at least the action method is set, the notification events are delivered
      FirebaseMessagingService.instance.init();
    });

    connectivityStateSubscription = _connectivity.onConnectivityChanged.listen((connectivityType) {
      if (AppLifecycleState.resumed != appState) return;

      if (connectivityType != ConnectivityResult.none) {
        log("chatConnectionState = ${CubeChatConnection.instance.chatConnectionState}");
        bool isChatDisconnected = CubeChatConnection.instance.chatConnectionState == CubeChatConnectionState.Closed ||
            CubeChatConnection.instance.chatConnectionState == CubeChatConnectionState.ForceClosed;

        if (isChatDisconnected && CubeChatConnection.instance.currentUser != null) {
          CubeChatConnection.instance.relogin();
        }
      }
    });

    appState = WidgetsBinding.instance.lifecycleState;

    ////////////// connectycube ended ///////////////

    /// COMMENTED For INFLUENCE BAR
    /// check and update influence streak of user
    checkAndUpdateUserInfluenceStreak();
  }

  /// check and update influence streak of user
  void checkAndUpdateUserInfluenceStreak() async {
    UserModel userModel = UserModel.to;
    if (FirebaseAuth.instance.currentUser?.uid == null || userModel.uId == null) return;
    DateTime todayDate = DateTime.now();
    if (isUserStreakNull(userModel, todayDate)) {
      _commonServices.updateUserProfileInDb({
        'streakDaysCount': 1,
        'lastVisitDate': todayDate.millisecondsSinceEpoch,
      });
      UserModel.to.update(
        userModel.copyWith(lastVisitDate: todayDate, streakDaysCount: 1),
      );
    } else if (isUserActiveDayDifferenceIsLessThan1AndDayIsSame(userModel, todayDate)) {
      UserModel.to.update(
        userModel.copyWith(
          lastVisitDate: todayDate,
        ),
      );
    } else if (isUserActiveDayDifferenceIsLessThan1AndDayIsNotSame(userModel, todayDate)) {
      _commonServices.updateUserProfileInDb({
        'streakDaysCount': (userModel.streakDaysCount ?? 0) + 1,
        'lastVisitDate': todayDate.millisecondsSinceEpoch,
      });
      UserModel.to.update(
        userModel.copyWith(lastVisitDate: todayDate, streakDaysCount: userModel.streakDaysCount ?? 0 + 1),
      );
    } else if (isUserActiveDayDifferenceIs1(userModel, todayDate)) {
      _commonServices.updateUserProfileInDb({
        'streakDaysCount': (userModel.streakDaysCount ?? 0) + 1,
        'lastVisitDate': todayDate.millisecondsSinceEpoch,
      });
      UserModel.to.update(
        userModel.copyWith(lastVisitDate: todayDate, streakDaysCount: userModel.streakDaysCount ?? 0 + 1),
      );
    } else if (isUserActiveDayDifferenceIsGreaterThan1(userModel, todayDate)) {
      _commonServices.updateUserProfileInDb({
        'streakDaysCount': 1,
        'lastVisitDate': todayDate.millisecondsSinceEpoch,
      });
      UserModel.to.update(
        userModel.copyWith(lastVisitDate: todayDate, streakDaysCount: 1),
      );
    }
  }

  /// invoke to subscribe to user (firestore) data changes
  void subscribeToAppUser() {
    // Checking whether if user signed in or not
    if (FirebaseAuth.instance.currentUser?.uid == null) return;

    appUserStreamSubscription ??= FirebaseFirestore.instance
        .collection('users')
        .doc(FirebaseAuth.instance.currentUser!.uid)
        .snapshots()
        .listen(onUserDataListenCallback);
  }

  /// Boolean variable to check if user is already logged out
  bool isAlreadyLoggedOut = false;

  /// Callback for user data changes
  void onUserDataListenCallback(DocumentSnapshot<Map<String, dynamic>> userDocSnapshot) async {
    if (userDocSnapshot.exists) {
      bool isActive = userDocSnapshot.data()?['isActive'] ?? true;

      // If isActive is false, then user is blocked, need to logout
      if (!isActive && !isAlreadyLoggedOut) {
        isAlreadyLoggedOut = true;
        // User is blocked
        if (FirebaseAuth.instance.currentUser != null) {
          await Provider.of<LoginController>(context ?? Get.context!, listen: false).logout(context ?? Get.context!);
          snackBar(context ?? Get.context!, GayaStrings.your_account_has_been_blocked.tr, kRedColor);
        }
      }
    }
  }

  late StreamSubscription<ConnectivityResult> connectivityStateSubscription;
  AppLifecycleState? appState;

  @override
  void didChangeAppLifecycleState(AppLifecycleState state) {
    super.didChangeAppLifecycleState(state);
    if (state == AppLifecycleState.resumed) {
      if (inactiveTime.difference(DateTime.now()).inMinutes > 30) {
        Routes.switchView(initialIndex: _selectedIndex.value);
      }
      SharedPrefs.instance.init().then((sharedPrefs) {
        CubeUser? user = sharedPrefs.getUser();

        if (user?.id != null) {
          if (!CubeChatConnection.instance.isAuthenticated()) {
            CubeChatConnection.instance.login(user!);
          }
        }
      });
    } else if (state == AppLifecycleState.inactive) {
      inactiveTime = DateTime.now();
    } else if (state == AppLifecycleState.paused) {
      inactiveTime = DateTime.now();
      if (CubeChatConnection.instance.isAuthenticated()) {
        // CubeChatConnection.instance.markInactive();
      }
    } else if (state == AppLifecycleState.detached) {
      inactiveTime = DateTime.now();
    }
  }

  navigateToRequiredSignIn(BuildContext ctx) =>
      Get.to(() => const RequireSignRegisterView(userNotSigin: true), transition: Transition.cupertinoDialog, fullscreenDialog: true);

  @override
  onClose() {
    super.onClose();
    WidgetsBinding.instance.removeObserver(this);

    connectivityStateSubscription.cancel();
    appUserStreamSubscription?.cancel().whenComplete(() {
      appUserStreamSubscription = null;
    });
  }
}

extension UserStreakExtension on SwitchViewController {
  // check if userModel.lastVisitDate is null or not maintained any streak in past
  bool isUserStreakNull(UserModel userModel, DateTime todayDate) {
    return userModel.lastVisitDate == null ? true : false;
  }

  // check if user is active today and the day check is same as last visit date and userModel.lastVisitDate != null
  bool isUserActiveDayDifferenceIsLessThan1AndDayIsSame(UserModel userModel, DateTime todayDate) {
    return (userModel.lastVisitDate != null &&
            todayDate.difference(userModel.lastVisitDate!).inDays < 1 &&
            todayDate.day == userModel.lastVisitDate!.day)
        ? true
        : false;
  }

  // check if user is active today and the today day check is not same as last visit date and userModel.lastVisitDate != null
  bool isUserActiveDayDifferenceIsLessThan1AndDayIsNotSame(UserModel userModel, DateTime todayDate) {
    return (userModel.lastVisitDate != null &&
            todayDate.difference(userModel.lastVisitDate!).inDays < 1 &&
            todayDate.day != userModel.lastVisitDate!.day)
        ? true
        : false;
  }

  // check if user userModel.lastVisitDate != null and streak day difference == 1
  bool isUserActiveDayDifferenceIs1(UserModel userModel, DateTime todayDate) {
    print('---> ${DateTime.now().difference(userModel.lastVisitDate!).inDays}');
    return (userModel.lastVisitDate != null && todayDate.difference(userModel.lastVisitDate!).inDays == 1) ? true : false;
  }

  // check if user userModel.lastVisitDate != null and streak day difference > 1
  bool isUserActiveDayDifferenceIsGreaterThan1(UserModel userModel, DateTime todayDate) {
    return (userModel.lastVisitDate != null && (todayDate.difference(userModel.lastVisitDate!).inDays > 1)) ? true : false;
  }
}
