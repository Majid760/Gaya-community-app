import 'dart:io';

import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:connectycube_sdk/connectycube_sdk.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:gaya/components/check_for_app_update.dart';
import 'package:gaya/components/image_swiper.dart';
import 'package:gaya/components/show.full.picture.dart';
import 'package:gaya/model/chatroom.model.dart';
import 'package:gaya/model/community.model.dart';
import 'package:gaya/model/postType.model.dart';
import 'package:gaya/model/user.model.dart';
import 'package:gaya/services/media_cropping/view/image_cropping_photo_view.dart';
import 'package:gaya/services/media_cropping/view/video_editor_screen/video_crop_view.dart';
import 'package:gaya/services/media_cropping/view/video_editor_screen/video_editor_screen.dart';
import 'package:gaya/shared/view/widget/gaya_snackbar.dart';
import 'package:gaya/utils/language/translation.dart';
import 'package:gaya/utils/strings.dart';
import 'package:gaya/view/Auth/controller/login.controller.dart';
import 'package:gaya/view/Auth/screen/ask_name_screen.dart';
import 'package:gaya/view/Auth/screen/create.new.password.view.dart';
import 'package:gaya/view/Auth/screen/email_form_view.dart';
import 'package:gaya/view/Auth/screen/forget.password.email.dart';
import 'package:gaya/view/Auth/screen/gender_dob_form_view.dart';
import 'package:gaya/view/Auth/screen/gender_screen.dart';
import 'package:gaya/view/Auth/screen/login.view.dart';
import 'package:gaya/view/Auth/screen/name_email_password_register-view.dart';
import 'package:gaya/view/Auth/screen/register.view.dart';
import 'package:gaya/view/Auth/screen/verify_otp_screen.dart';
import 'package:gaya/view/bio.view.dart';
import 'package:gaya/view/chat/controllers/conversation_controller.dart';
import 'package:gaya/view/chat/views/chats/chats_screen.dart';
import 'package:gaya/view/chat/views/conversation/conversation_screen.dart';
import 'package:gaya/view/chat/views/group_detail/add_new_members_to_group_screen.dart';
import 'package:gaya/view/chat/views/group_detail/chat_detail_info_screen.dart';
import 'package:gaya/view/chat/views/group_detail/search_group_members.dart';
import 'package:gaya/view/comments/view/comment_with_post_screen.dart';
import 'package:gaya/view/community.created.view.dart';
import 'package:gaya/view/community/approval_membership/view/approve_user_view.dart';
import 'package:gaya/view/community/bindings/community_bindings.dart';
import 'package:gaya/view/community/community_analytics/community_analytics_screen.dart';
import 'package:gaya/view/community/community_invites/views/add_phone_no_view.dart';
import 'package:gaya/view/community/community_invites/views/invite_friends_view.dart';
import 'package:gaya/view/community/community_invites/views/invite_permission_view.dart';
import 'package:gaya/view/community/community_invites/views/invititation_sent_view.dart';
import 'package:gaya/view/community/controllers/secret_community_controller.dart';
import 'package:gaya/view/community/events/view/community_calendar_view.dart';
import 'package:gaya/view/community/views/secret_community_invitation_screen.dart';
import 'package:gaya/view/community_setting_view.dart';
import 'package:gaya/view/edit.profile.view.dart';
import 'package:gaya/view/home.view.dart';
import 'package:gaya/view/manage_community_topics_screen.dart';
import 'package:gaya/view/messaging/message.view.dart';
import 'package:gaya/view/messaging/personmessages.view.dart';
import 'package:gaya/view/notification.view.dart';
import 'package:gaya/view/notifications/views/see_all_friend_request_view.dart';
import 'package:gaya/view/other_user_profile/views/other.user.profile.dart';
import 'package:gaya/view/profile.view.dart';
import 'package:gaya/view/profile/friend_view.dart';
import 'package:gaya/view/profile/view/my_communities_search_view.dart';
import 'package:gaya/view/saved.posts.view.dart';
import 'package:gaya/view/seeall.mycommunities.dart';
import 'package:gaya/view/splash/controller/splash_screens_binding.dart';
import 'package:gaya/view/splash/view/screen/finding_communities_splash_screen.dart';
import 'package:gaya/view/splash/view/screen/new_splash_screen.dart';
import 'package:gaya/view/splash/view/screen/new_text_splash_screen.dart';
import 'package:gaya/view/splash/view/screen/splash_view_screen.dart';
import 'package:gaya/view/switch_view/views/switch.view.dart';
import 'package:gaya/view/topics.view.dart';
import 'package:gaya/widgets/group_view_widget/about.widget.dart';
import 'package:get/get.dart';

import '../bindings/create_community_bindings.dart';
import '../controller/firebase_analytics_controller.dart';
import '../model/create.post.model.dart';
import '../shared/service/firebase_analytics_services.dart';
import '../utils/enum.dart';
import '../view/Auth/controller/require.sigin.register.dart';
import '../view/Auth/screen/verfication.email.sent.view.dart';
import '../view/comments/bindings/comments_bindings.dart';
import '../view/comments/view/video_player_from_url.dart';
import '../view/community/approval_posts/view/post_approval_view.dart';
import '../view/community/communities/communities_view.dart';
import '../view/community/communities_archive/views/archive.dart';
import '../view/community/create_community/views/create_community_questionnaire_form.dart';
import '../view/community/create_community/views/create_community_view.dart';
import '../view/community/create_community/views/invite_friends_screen.dart';
import '../view/community/create_community/views/join_community_questionnaire_form.dart';
import '../view/community/edit_community/views/edit_community_view.dart';
import '../view/community/views/community_moderators_screen.dart';
import '../view/create_post/create.post.view.dart';
import '../view/group.view.dart';
import '../view/not_found_view.dart';
import '../view/post.confirmation.view.dart';
import '../view/search/bindings/search_bindings.dart';
import '../view/search/views/landing_search_screen.dart';
import '../view/search/views/search_screen.dart';
import '../view/seeall.interestcommunities.dart';
import '../view/switch_view/bindings/switch_view_binding.dart';
import '../view/user_matches/bindings/match_view_bindings.dart';
import '../view/user_matches/view/finding_a_match_screen.dart';
import '../view/user_matches/view/found_a_match_screen.dart';
import '../view/user_matches/view/match_screen.dart';

/// This class is only used when A user is logged in,
/// and we want to redirect him to a specific page.
class AuthGuardMiddleware extends GetMiddleware {
  final FirebaseAuth _auth = FirebaseAuth.instance;

  @override
  RouteSettings? redirect(String? route) {
    /// Redirection Implies only when user is logged in.
    if (isUserLoggedIn) {
      /// User is loggedIn from FirebaseAuth but we don't have any data in our database. then redirect to LOGIN view.
      if (!_isAppUserLoggedIn) {
        debugPrint('Redirecting to login');
        debugPrint('authUserData: ${_auth.currentUser}');
        return const RouteSettings(name: RouteHelper.login);
      }

      // // If user is logged In and phone number is entered but email is not entered register email view.
      // else if (!_isEmailAttached && currentUserPhoneNumber != null) {
      //   debugPrint('Redirecting to registerNameEmailPhone #$currentUserPhoneNumber');
      //   debugPrint('authUserData: ${_auth.currentUser}');
      //   return RouteSettings(
      //     name: RouteHelper.registerNameEmailPhone,
      //     arguments: {
      //       'phone': currentUserPhoneNumber,
      //     },
      //   );
      // }

      /// if his email is not verified then redirect to email sent view.
      else if (!_isEmailVerified && currentUserPhoneNumber == null) {
        debugPrint('authUserData: ${_auth.currentUser}');
        return const RouteSettings(
          name: RouteHelper.emailSent,
          arguments: {
            'page': FromPage.login,
          },
        );
      }

      /// If we don't have his name, dob, phone number then redirect to askNameFieldView
      else if (!_isNameEntered) {
        debugPrint('Redirecting to askNameFieldView $isUserLoggedIn $_isNameEntered $_isDobEntered $_isPhoneNumberEntered');
        debugPrint('appUserData:  name: ${UserModel.to.name}, dob: ${UserModel.to.dob}, phoneNumber: ${UserModel.to.phoneNumber}');
        debugPrint('authUserData: ${_auth.currentUser}');
        return const RouteSettings(name: RouteHelper.askNameFieldView);
      }
    }

    return null;
  }

  /// Related to AppUser
  UserModel get appUser => UserModel.to;

  /// returns true if appUser is not null and has a valid uid
  bool get _isAppUserLoggedIn => UserModel.to.uId != null;

  /// returns true if appUser is not null and has a valid name
  bool get _isNameEntered => UserModel.to.name.toString().isBlank == false;

  /// returns true if appUser is not null and has a valid dob
  bool get _isDobEntered => UserModel.to.dob != null;

  /// returns true if appUser is not null and has a valid phoneNumber
  bool get _isPhoneNumberEntered => UserModel.to.phoneNumber != null && UserModel.to.phoneNumber.toString().isBlank == false;

  /// Related to Firebase Auth
  /// returns true if user has attached email
  bool get _isEmailAttached =>
      _auth.currentUser?.providerData.any((element) => element.providerId.toString().toLowerCase() == "password") ?? false;

  /// returns true if email is verified
  bool get _isEmailVerified => _auth.currentUser?.emailVerified == true;

  /// returns true if user is logged in
  bool get isUserLoggedIn => _auth.currentUser != null;

  String? get currentUserId => _auth.currentUser?.uid;

  String? get currentUserEmail => _auth.currentUser?.email;

  String? get currentUserPhoneNumber => _auth.currentUser?.phoneNumber;
}

class RouteHelper {
  static const String notFound = '/notFound';
  static const String splash = '/splash';
  static const String onboarding1 = '/onboarding-1';
  static const String onboarding2 = '$onboarding1/onboarding-2';
  static const String onboarding3 = '$onboarding2/onboarding-3';
  static const String onBoardingSplash = '/onBoardingSplash';
  static const String splashBrose = '/splashBrowse';
  static const String topics = '/topics';
  static const String login = '/login';
  static const String register = '/register';
  static const String genderScreen = '/genderScreen';
  static const String registerEmail = '/registerEmail';
  static const String secretCommunityInvitation = '/secretCommunityInvitation';
  static const String verifyPhoneOTP = '/verifyPhoneOTP';
  static const String registerNameEmailPhone = "/registerNameEmailPhone";
  static const String registerDOBAndGender = '/registerDOBAndGender';
  static const String resetPassword = '/resetPassword';
  static const String resetEnterPhoneNumber = '/resetEnterPhoneNumber';
  static const String createNewPassword = '/createNewPassword';
  static const String switchView = '/switch';
  static const String home = '/home';
  static const String message = '/message';
  static const String chats = '/chats';
  static const String conversation = '/conversation';
  static const String newChat = '/newChat';
  static const String newGroup = '/newGroup';
  static const String chatDetailInfo = '/chatDetailInfo';
  static const String addOponentsToGroup = '/addOponentsToGroup';
  static const String searchGroupMembers = '/searchGroupMembers';

  static const String community = '/community';
  static const String notification = '/notification';
  static const String profile = '/profile';
  static const String recipedetails = '/recipedetails';
  static const String editProfile = '/EditProfile';
  static const String bio = '/bio';
  static const String createPost = '/CreatePost';
  static const String createRecipe = '/createRecipe';
  static const String personMessage = '/personMessage';
  static const String requireSignRegisterView = '/RequireSignRegisterView';
  static const String createCommunity = '/createCommunity';
  static const String editCommunity = '/editCommunity';
  static const String manageTopics = '/manageTopics';
  static const String communitySetting = '/communitySetting';
  static const String communitySuccessfullyJoined = '/communitySuccessfullyJoined';
  static const String communityModerator = "/communityModerator";
  static const String communityAnalytics = "/community-analytics";
  static const String invitePermission = "/invitePermission";
  static const String inviteFriends = "/inviteFriends";
  static const String addPhoneNo = "/addPhoneNo";
  static const String invitationSent = "/invitationSent";
  static const String commenting = '/Commenting';
  static const String publicProfile = '/publicProfile';
  static const String seeAllMyCommunities = "/seeAllMyCommunities";
  static const String seeAllInterestCommunities = "/seeAllInterestCommunities";
  static const String savedPosts = "/savedPosts";
  static const String about = "/about";
  static const String seeAllFriendRequests = "/seeAllFriendRequests";
  static const String seeArchivedCommunities = "/seeArchivedCommunities";

  static const String approvePosts = "/approvePosts";
  static const String approveUsers = "/approveUsers";
  static const String postConfirmation = '/postConfirmation';
  static const String emailSent = '/emailSent';
  static const String userNotLogin = '/userNotLogin';
  static const String userJoinedCommunities = '/UserJoinedCommunities';
  static const String askNameFieldView = '/askNameFieldView';
  static const String commentWithPostScreen = '/commentWithPostScreen';
  static const String landingSearchScreen = '/landingSearchScreen';

  //common
  static const String fullPicture = '/fullPicture';
  static const String multipleImages = '/multipleImages';
  static const String cropPhotoView = '/cropPhotoView';
  static const String cropVideoView = '/cropVideoView';
  static const String videoEditorView = '/videoEditorView';
  static const String videoPlayerView = '/videoPlayerView';
  static const String myFriendView = '/myFriendView';
  static const String myCommunitiesViewSearch = '/myCommunitiesViewSearch';
  static const String questionnaireForm = '/questionnaireForm';
  static const String joinCommunityQuestionnaireForm = '/joinCommunityQuestionnaireForm';

  static GetPage unknownRoute = GetPage(name: RouteHelper.notFound, page: () => const NotFoundView());
  static const String communityCalendar = '/communityCalendar';
  static const String userMatchesView = '/userMatchesView';
  static const String meetSomeOneView = '/meetSomeOneView';
  static const String matchedView = '/matchedView';
  static const String inviteFriendsScreen = '/inviteFriendsScreen';

  static List<GetPage> routes = [
    GetPage(
      name: seeAllInterestCommunities,
      page: () => SeeAllInterestCommunities(
        communityName: Get.arguments['communityName'],
      ),
    ),
    GetPage(
      name: seeAllMyCommunities,
      page: () {
        final arguments = Get.arguments as Map<String, dynamic>;
        final pinnedCommunities = arguments["pinnedCommunities"] as List<DocumentReference<Object?>>;
        return SeeAllMyCommunities(pinnedCommunities: pinnedCommunities);
      },
    ),
    GetPage(
      name: seeArchivedCommunities,
      page: () {
        return SeeArchivedCommunities();
      },
    ),

    // GetPage(name: onBoardingSplash, page: () => const OnBoardingSplashView()),
    GetPage(name: onBoardingSplash, page: () => const NewTextSplashScren()),
    GetPage(
      name: splash,
      page: () => const SplashView(),
      transition: Transition.noTransition,
    ),
    // new splash screen routes
    GetPage(
      name: onboarding1,
      page: () => const NewTextSplashScren(),
      children: [
        GetPage(
          binding: SplashScreenBindings(),
          name: "/onboarding-2",
          page: () => const NewWelComeSplashScreen(),
          children: [
            GetPage(
              name: "/onboarding-3",
              page: () => const FindingSplashScreen(),
            ),
          ],
        )
      ],
    ),

    // GetPage(
    //   name: splashBrose,
    //   page: () => const BrowseSplashScreen(),
    // ),
    GetPage(
      name: topics,
      page: () => const TopicsView(),
      // GetPage(name: login, page:()=>  NewGotCrownScreen()),
      // GetPage(name: login, page: () => const NewWelComeSplashScreen()),
    ),
    GetPage(
      name: login,
      page: () => const LoginView(),
    ),
    GetPage(
      name: register,
      page: () {
        final arguments = Get.arguments as Map<String, dynamic>?;
        return RegisterView(data: arguments?["data"]);
      },
    ),
    GetPage(
        name: genderScreen,
        page: () {
          final arguments = Get.arguments as Map<String, dynamic>?;
          return GenderScreen(data: arguments?["data"]);
        }),
    GetPage(
      name: registerEmail,
      page: () {
        final arguments = Get.arguments as Map<String, dynamic>?;
        return const EmailPhoneRegister();
      },
    ),
    GetPage(
      name: registerNameEmailPhone,
      page: () {
        final arguments = Get.arguments as Map<String, dynamic>;
        return NameEmailPasswordRegisterView(data: arguments);
      },
    ),

    GetPage(
      name: verifyPhoneOTP,
      page: () {
        final arguments = Get.arguments as Map<String, dynamic>;
        return VerifyPhoneNumberScreen(phoneNumber: arguments["phoneNumber"], isDeleteProcess: arguments["isDeleteProcess"]);
      },
    ),
    GetPage(
      name: registerDOBAndGender,
      page: () => DateAndGenderFormView(email: Get.arguments["email"]),
    ),
    GetPage(
      name: resetPassword,
      page: () => const ForgotPasswordView(),
    ),
    // GetPage(name: resetEnterPhoneNumber, page: () => const ForgetPasswordView()),
    GetPage(
      name: createNewPassword,
      page: () => const CreatePasswordView(),
    ),
    //nav bar.
    GetPage(
      name: switchView,
      middlewares: [AuthGuardMiddleware()],
      transition: Transition.noTransition,
      binding: SwitchViewBindings(),
      page: () => const SwitchView(),
    ),

    GetPage(
      name: home,
      page: () => const HomeView(),
    ),
    GetPage(
      name: message,
      page: () => const MessageView(),
    ),

    GetPage(
        name: chats,
        page: () {
          return const ChatScreen(); //const ChatsScreen();
        }),

    GetPage(binding: ConversationBindings(), name: conversation, page: () => const ConversationScreen()), //const ConversationScreen()),
    // GetPage(name: newChat, page: () => const NewChatScreen()),
    // GetPage(name: newGroup, page: () => const NewGroupScreen()),

    // GetPage(name: chatDetailInfo, page: () => const ChatDetailInfoScreen()),
    GetPage(
        name: chatDetailInfo,
        page: () {
          final arguments = Get.arguments as Map<String, dynamic>;
          final dialogId = arguments['dialogId'];
          return ChatDetailInfoScreen(dialogId: dialogId);
        }),
    // GetPage(name: addOponentsToGroup, page: () => const AddOccupantToGroupScreen()),
    // GetPage(name: searchGroupMembers, page: () => const SearchGroupMembersScreen()),
    GetPage(
        name: searchGroupMembers,
        page: () {
          final arguments = Get.arguments as Map<String, dynamic>;
          final dialogId = arguments['dialogId'];
          return SearchGroupMembersScreen(dialogId: dialogId);
        }),
    GetPage(
        name: addOponentsToGroup,
        page: () {
          final arguments = Get.arguments as Map<String, dynamic>;
          final dialogId = arguments['dialogId'];
          return AddOccupantToGroupScreen(dialogId: dialogId);
        }),
    // GetPage(name: message, page: () => const MessageView()),
    // GetPage(name: message, page: () => const ChatScreen()),
    GetPage(
      name: community,
      page: () => const CommunitiesView(),
    ),
    GetPage(
      name: communitySetting,
      page: () {
        final arguments = Get.arguments as Map<String, dynamic>;
        final communityId = arguments['communityId'];
        return CommunitySettingScreen(communityId: communityId);
      },
    ),
    GetPage(
      name: notification,
      page: () => const NotificationView(),
    ),
    GetPage(
      name: profile,
      page: () => const ProfileView(),
    ),
    GetPage(
      name: invitePermission,
      page: () {
        final arguments = Get.arguments as Map<String, dynamic>;
        return InvitatePermissionView(communityId: arguments['communityId']);
      },
    ),
    GetPage(
      name: inviteFriends,
      page: () {
        final arguments = Get.arguments as Map<String, dynamic>;
        // return ContactsView();
        return InviteFriendsView(communityId: arguments['communityId']);
      },
    ),
    GetPage(
      name: addPhoneNo,
      page: () {
        final arguments = Get.arguments as Map<String, dynamic>;
        return AddPhoneNoView(communityId: arguments['communityId']);
      },
    ),
    GetPage(
      name: invitationSent,
      page: () {
        final arguments = Get.arguments as Map<String, dynamic>;
        return InvitationSentView(communityId: arguments['communityId']);
      },
    ),
    GetPage(
      name: secretCommunityInvitation,

      /// having a binding with passing arguments
      binding: SecretCommunityBindings(),
      page: () => //const SecretCommunityFingerPrintTesting()
          const SecretCommunityInvitationScreen(),
    ),
    GetPage(
      name: editProfile,
      page: () {
        final arguments = Get.arguments as Map<String, dynamic>;
        return EditProfileView(userModel: arguments['userModel']);
      },
    ),
    GetPage(
      name: bio,
      page: () => const BioView(),
    ),
    GetPage(
      name: createPost,
      page: () {
        final arguments = Get.arguments as Map<String, dynamic>;
        return CreatePostView(
            communityModel: arguments['communityId'], from: arguments['fromHome'], commentData: arguments['CommentForPost']);
      },
    ),

    GetPage(
      binding: CommentBindings(),
      name: commentWithPostScreen,
      page: () => const CommentWithPostIOSScreen(),
    ),
    GetPage(
      name: personMessage,
      page: () {
        final arguments = Get.arguments as Map<String, dynamic>;
        return PersonMessageView(
            profilePicture: arguments['profilePicture'],
            name: arguments['name'],
            uid: arguments['uid'],
            chatRoomModel: arguments['chatRoom']);
      },
    ),
    GetPage(
      fullscreenDialog: true,
      transition: Transition.cupertinoDialog,
      name: requireSignRegisterView,
      page: () => const RequireSignRegisterView(userNotSigin: true),
    ),
    GetPage(
      name: editCommunity,
      page: () {
        final arguments = Get.arguments as Map<String, dynamic>;
        final communityId = arguments['communityId'];
        return EditCommunityScreen(communityId: communityId);
      },
    ),
    GetPage(
      name: manageTopics,
      page: () {
        final arguments = Get.arguments as Map<String, dynamic>;
        final communityId = arguments['communityId'];
        return ManageCommunityTopicsScreen(communityId: communityId);
      },
    ),
    GetPage(
      binding: CreateCommunityBindings(),
      name: createCommunity,
      page: () => CreateCommunityView(),
    ), //CreateCommunityView(),),
    GetPage(
      name: communityModerator,
      page: () {
        final arguments = Get.arguments as Map<String, dynamic>;
        return CommunityModeratorsScreen(communityId: arguments['communityId']);
      },
    ),
    GetPage(
      name: communityAnalytics,
      page: () {
        final arguments = Get.arguments as Map<String, dynamic>;
        return CommunityAnalyticsScreen(communityId: arguments['communityId']);
      },
    ),
    GetPage(
      name: publicProfile,
      page: () {
        final arguments = Get.arguments as Map<String, dynamic>;
        return PeopleProfileView(usermodel: arguments['userModel']);
      },
    ),
    GetPage(
      name: about,
      page: () {
        final arguments = Get.arguments as Map<String, dynamic>;
        final community = arguments['community'] as Community;
        return AboutGroupView(community: community);
      },
    ),
    GetPage(
      name: seeAllFriendRequests,
      page: () {
        return const SeeAllFriendRequest();
      },
    ),

    GetPage(
      name: savedPosts,
      page: () => const SavedPostsView(),
    ),
    // GetPage(
    //     name: approveUsers,
    //     binding: CommunityPendingPostsAndUsersBindings(),
    //     page: () {
    //       final arguments = Get.arguments as Map<String, dynamic>;

    //       // CommunityPendingPostsAndUsersBindings
    //       return ApproveUsersView(
    //         communityid: arguments['communityid'],
    //         communityName: arguments['communityName'],
    //       );
    //     }),
    GetPage(
      name: postConfirmation,
      page: () {
        final arguments = Get.arguments as Map<String, dynamic>;
        VoidCallback onSuccess = arguments["onSuccessCallback"] as VoidCallback;
        return PostConfirmationView(onSuccessCallback: onSuccess);
      },
    ),
    GetPage(
      name: emailSent,
      page: () {
        final arguments = Get.arguments as Map<String, dynamic>;
        return EmailVerifiedSentView(args: arguments);
      },
    ),
    GetPage(
      name: askNameFieldView,
      page: () {
        bool fromPhoneProvider = Get.arguments?["fromPhoneProvider"] ?? false;
        return AskNameFieldView(fromPhoneProvider: fromPhoneProvider);
      },
    ),
    GetPage(
      name: fullPicture,
      page: () {
        final arguments = Get.arguments as Map<String, dynamic>;
        return FullPicture(photo: arguments['photoUrl']);
      },
    ),
    GetPage(
      name: multipleImages,
      page: () {
        final arguments = Get.arguments as Map<String, dynamic>?;
        return PostImages(allImages: arguments?['allImages'] ?? []);
      },
    ),
    GetPage(
      name: communitySuccessfullyJoined,
      page: () {
        final arguments = Get.arguments as Map<String, dynamic>?;
        final community = arguments?['community'] as Community;
        return CommunityCreatedSuccessFullyView(community: community);
      },
    ),
    GetPage(
      name: approvePosts,
      page: () {
        final arguments = Get.arguments as Map<String, dynamic>;
        return PostApprovalView(communityId: arguments['communityId']);
      },
    ),

    GetPage(
      name: cropPhotoView,
      page: () {
        final arguments = Get.arguments as Map<String, dynamic>;
        CropRouteFrom cropRouteFrom = arguments['cropRouteFrom'] ?? CropRouteFrom.other;
        return CropPhotoView(galleryItems: arguments['files'], cropRoute: cropRouteFrom);
      },
    ),
    GetPage(
      name: cropVideoView,
      page: () {
        final arguments = Get.arguments as Map<String, dynamic>;
        final isFromMessageView = arguments['isFromMessageView'] ?? false;
        return CropVideoView(video: arguments['video'], isFromMessageView: isFromMessageView);
      },
    ),
    GetPage(
      name: videoEditorView,
      page: () {
        final arguments = Get.arguments as Map<String, dynamic>;
        return VideoEditorScreen(file: arguments['video']);
      },
    ),

    GetPage(
      name: videoPlayerView,
      page: () {
        final arguments = Get.arguments as Map<String, dynamic>;
        return VideoPlayerWithBackButtonFromUrl(url: arguments['url']);
      },
    ),
    GetPage(
      name: myCommunitiesViewSearch,
      page: () {
        final arguments = Get.arguments as Map<String, dynamic>;
        return const MyCommunitiesViewSearch();
      },
    ),
    GetPage(
        name: myFriendView,
        page: () {
          // final arguments = Get.arguments as Map<String, dynamic>;
          return const MyFriendView();
        }),

    GetPage(
        name: communityCalendar,
        page: () {
          final arguments = Get.arguments as Map<String, dynamic>;
          final communityId = arguments['communityId'] as String;
          final isEditable = arguments['isEditable'] as bool;
          return CommunityCalendarScreen(communityId: communityId, isEditable: isEditable);
        }),
    GetPage(
        name: questionnaireForm,
        page: () {
          return const CreateCommunityQuestionnaireForm();
        }),
    GetPage(
        name: joinCommunityQuestionnaireForm,
        page: () {
          final arguments = Get.arguments as Map<String, dynamic>;
          final communityName = arguments['communityName'];
          final communityId = arguments['communityId'];
          final onSubmit = arguments['onSubmit'];
          final shouldNavigate = arguments['shouldNavigate'];
          final onSuccess = arguments['onSuccess'];
          return JoinCommunityQuestionnaireForm(
              communityName: communityName,
              communityId: communityId,
              onSubmit: onSubmit,
              shouldNavigate: shouldNavigate,
              onSuccess: onSuccess);
        }),
    /* ----------------------- SEARCH SCREEN LANDING PAGE ----------------------- */
    GetPage(
      name: landingSearchScreen,
      binding: SearchBindings(),
      page: () => const LandingSearchScreen(),
    ),
    GetPage(name: MatchView.rootPath, binding: MatchViewBindings(), page: () => const MatchView(), children: [
      GetPage(
        name: FindingAMatchView.rootPath,
        page: () => const FindingAMatchView(),
      ),
      GetPage(name: FoundAMatchView.rootPath, page: () => const FoundAMatchView()),
    ]),

    /* -------------------------- INVITE FRIENDS SCREEN ------------------------- */
    GetPage(
      name: inviteFriendsScreen,
      page: () => const InviteFriendsScreen(),
    ),
  ];
}

class Routes {
  static final FirebaseAnalyticsService _analytics = AnalyticsController.to.instance;

  //
  // * posts related navigation.
  //
  /// * Goto post with comment screen [*required[CreatePostModel]]
  static Future postDetailsScreen({required Post post, required Community community}) async {
    _analytics.setScreen(RouteHelper.commentWithPostScreen);

    // Logging view post analytics event
    _analytics.logViewPost(
      communityId: community.communityId ?? '',
      postId: post.postid ?? '',
      userId: UserModel.to.uId ?? '',
    );

    return await Get.toNamed(
      RouteHelper.commentWithPostScreen,
      arguments: {"post": post, "community": community},
      preventDuplicates: false,
    );
  }

  static void notificationView() {
    _analytics.setScreen(RouteHelper.notification);
    Get.toNamed(RouteHelper.notification);
  }
  static void savedPostsView() {
    _analytics.setScreen(RouteHelper.savedPosts);
    Get.toNamed(RouteHelper.savedPosts);
  }

  //
  // * community related navigation.
  //

  /// * Goto community screen [*required[CreateCommunityModel]]
  static Future groupView({required Community? community, bool clearPreviousRoutes = false, bool shouldReplace = false}) async {
    _analytics.setScreen("GroupView/${community?.communityId}");

    debugPrint("4 GroupView/${community?.communityId}");

    if (community == null) return;
    if (clearPreviousRoutes == true) {
      debugPrint("7 GroupView/${community.communityId}");
      return await Get.offUntil(
          GetPageRoute(
            page: () => GroupView(communityModel: community),
            binding: CommunityViewBindings(communityId: community.communityId ?? "", community: community),
          ),
          (route) => route.isFirst);
    } else if (shouldReplace == true) {
      debugPrint("6 GroupView/${community.communityId}");
      return await Get.off(() => GroupView(communityModel: community),
          binding: CommunityViewBindings(communityId: community.communityId ?? "", community: community), preventDuplicates: false);
    }
    debugPrint("5 GroupView/${community.communityId}");
    return await Get.to(() => GroupView(communityModel: community),
        binding: CommunityViewBindings(communityId: community.communityId ?? "", community: community), preventDuplicates: false);
  }

  static Future seeAllInterestCommunitiesView({required String? communityName}) async {
    _analytics.setScreen("${RouteHelper.seeAllInterestCommunities}/$communityName");
    if (communityName == null) return;
    return await Get.toNamed(RouteHelper.seeAllInterestCommunities, arguments: {'communityName': communityName});
  }

  static void seeAllMyCommunitiesView({bool clearPreviousRoutes = false, List<DocumentReference<Object?>> pinnedCommunities = const []}) {
    _analytics.setScreen(RouteHelper.seeAllMyCommunities);
    Get.toNamed(RouteHelper.seeAllMyCommunities, arguments: {'pinnedCommunities': pinnedCommunities});
  }

  static void seeArchivedCommunitiesView() {
    Get.toNamed(RouteHelper.seeArchivedCommunities);
  }

  static Future createCommunityView({bool clearPreviousRoutes = false, required BuildContext ctx}) async {
    /// check if user has 10 crowns or more. if not then show error message and return.
    try {
      if ((UserModel.to.userTotalCrowns ?? 0) <= GayaRemoteConfig.to.minimumCrownsToCreateCommunity) {
        debugPrint(
            "User has less than 10 crowns. ${UserModel.to.userTotalCrowns} and remote: ${GayaRemoteConfig.to.minimumCrownsToCreateCommunity}");
        GayaSnackBar.show(
          context: ctx,
          type: GayaSnackBarType.problem,
          text: GayaStrings.you_need_atleast_10_crowns_create_community.tr,
        );
        return null;
      }
    } catch (_, s) {
      CrashlyticsController.to.instance.recordError("minimumCrownsToCreateCommunity is not set in remote config.", stackTrace: s);
    }

    /// Navigate to create community screen.
    _analytics.setScreen(RouteHelper.createCommunity);
    return await Get.toNamed(RouteHelper.createCommunity);
  }

  static Future communitySettingsView({required String communityId}) async {
    _analytics.setScreen("${RouteHelper.communitySetting}/$communityId");
    return await Get.toNamed(RouteHelper.communitySetting, arguments: {'communityId': communityId});
  }

  static void succesfullyJoinedCommunity({Community? community, bool shouldReplace = false}) {
    _analytics.setScreen("${RouteHelper.communitySuccessfullyJoined}/${community?.communityId}");
    Get.toNamed(RouteHelper.communitySuccessfullyJoined, arguments: {
      'community': community,
    });
  }

  static void editCommunityView({required String communityId}) {
    _analytics.setScreen("${RouteHelper.editCommunity}/$communityId");
    Get.toNamed(RouteHelper.editCommunity, arguments: {
      'communityId': communityId,
    });
  }

  static void manageCommunityTopicsView({required String communityId}) {
    _analytics.setScreen("${RouteHelper.manageTopics}/$communityId");
    Get.toNamed(RouteHelper.manageTopics, arguments: {
      'communityId': communityId,
    });
  }

  static void openCommunityAbout({required Community? community}) {
    _analytics.setScreen("${RouteHelper.about}/${community?.communityId}");
    Get.toNamed(RouteHelper.about, arguments: {
      'community': community,
    });
  }

  static void openSeeAllFriendRequests() {
    _analytics.setScreen(RouteHelper.seeAllFriendRequests);
    Get.toNamed(RouteHelper.seeAllFriendRequests);
  }

  static void openApprovePostsView({required String? communityId}) {
    _analytics.setScreen("${RouteHelper.approvePosts}/$communityId");
    Get.toNamed(RouteHelper.approvePosts, arguments: {'communityId': communityId});
  }

  static void communityModeratorView({required String communityId}) {
    _analytics.setScreen("${RouteHelper.communityModerator}/$communityId");

    Get.toNamed(RouteHelper.communityModerator, arguments: {'communityId': communityId});
  }

  // invoke to open community analytics screen with [communityId]
  static void communityAnalyticsView({required String communityId}) {
    _analytics.setScreen(RouteHelper.communityAnalytics);

    Get.toNamed(
      RouteHelper.communityAnalytics,
      arguments: {'communityId': communityId},
    );
  }

  static void openApproveUsersView({required String communityId, required String communityName}) async {
    _analytics.setScreen("${RouteHelper.approveUsers}/$communityId?communityName=$communityName");
    Get.to(() => ApproveUserView(
          communityId: communityId,
          communityName: communityName,
        ));
    // final args = {
    //   "communityid": communityId,
    //   "communityName": communityName,
    //   "communityModel": CreateCommunityModel(communityId: communityId, communityName: communityName)
    // };
    // Get.toNamed(RouteHelper.approveUsers, arguments: args);
    // ignore: void_checks
    /*   return await Get.to(
        () => ApproveUsersView(
              communityid: communityId ?? '',
              communityName: communityName ?? '',
            ),
        binding: CommunityPendingPostsAndUsersBindings(
            community: Community(
                communityId: communityId, communityName: communityName)));*/
  }

  static void postConfirmationView({required VoidCallback onSuccessCallback}) {
    _analytics.setScreen(RouteHelper.postConfirmation);

    Get.toNamed(RouteHelper.postConfirmation, arguments: {"onSuccessCallback": onSuccessCallback});
  }

  //
  // * auth related navigation.
  //
  static void splash() {
    _analytics.setScreen(RouteHelper.splash);

    Get.offAllNamed(RouteHelper.splash);
  }

  static void newWelcomeSplashScreen() {
    _analytics.setScreen(RouteHelper.onboarding2);
    Get.offAllNamed(RouteHelper.onboarding2);
  }

  static void newFindingCommunitiesSplashScreen() {
    _analytics.setScreen(RouteHelper.onboarding2);
    Get.offAllNamed(RouteHelper.onboarding3);
  }

  static void onBoardingSplash() {
    _analytics.setScreen(RouteHelper.onBoardingSplash);

    Get.offAllNamed(RouteHelper.onBoardingSplash);
  }

  static void splashBrowse() {
    _analytics.setScreen(RouteHelper.splashBrose);

    Get.offAllNamed(RouteHelper.splashBrose);
  }

  static void switchView({int initialIndex = 0}) {
    // Logging current tab (tab changed) analytics event
    AnalyticsController.to.instance.logCurrentTab(
      index: initialIndex,
      userId: UserModel.to.uId ?? '',
    );

    Get.offAllNamed(
      RouteHelper.switchView,
      arguments: {'initialIndex': initialIndex},
    );
  }

  static Future loginView({bool clearPreviousRoutes = false}) async {
    // openNewSplashTextScreen();
    _analytics.setScreen(RouteHelper.login);

    if (clearPreviousRoutes == true) {
      return await Get.offAllNamed(RouteHelper.login);
    }
    return Get.toNamed(RouteHelper.login);
  }

  static Future registerEmailView({bool clearPreviousRoutes = false}) async {
    _analytics.setScreen(RouteHelper.registerEmail);
    return Get.toNamed(RouteHelper.registerEmail);
  }

  // static Future secretCommunityInvitationView({bool clearPreviousRoutes = false}) async {
  //   return Get.toNamed(RouteHelper.secretCommunityInvitation);
  // }
  /// * Goto secret community invitation screen [*required[CreateCommunityModel]]
  static Future secretCommunityInvitationView({required Community? community}) async {
    if (community == null) return;
    _analytics.setScreen(RouteHelper.secretCommunityInvitation);

    Get.toNamed(RouteHelper.secretCommunityInvitation, arguments: {"community": community});
    // return await Get.to(() => SecretCommunityInvitationScreen(community: community));
  }

  /// [isDeleteProcess] is used to delete the user account from the app. If it is true, then the user will be redirected to the delete account screen.
  static Future verifyPhoneOTPView({required String phoneNumber, bool clearPreviousRoutes = false, bool isDeleteProcess = false}) async {
    _analytics.setScreen(RouteHelper.verifyPhoneOTP);
    return Get.toNamed(
      RouteHelper.verifyPhoneOTP,
      arguments: {"phoneNumber": phoneNumber, 'isDeleteProcess': isDeleteProcess},
    );
  }

  static Future registerNameEmailPhone({required String phoneNumber, bool clearPreviousRoutes = false}) async {
    _analytics.setScreen(RouteHelper.registerNameEmailPhone);

    return Get.toNamed(RouteHelper.registerNameEmailPhone, arguments: {"phone": phoneNumber});
  }

  static Future birthDayScreen({DateTime? dob, String? email}) async {
    _analytics.setScreen(RouteHelper.genderScreen);

    Map<String, dynamic> args = {};
    if (email != null) {
      args = {
        "data": {'dob': dob, 'email': email},
      };
    }
    return Get.toNamed(RouteHelper.genderScreen, arguments: args);
  }

  static Future register({String? gender, DateTime? dob, String? email}) async {
    _analytics.setScreen(RouteHelper.register);

    Map<String, dynamic> args = {};
    if (email != null) {
      args = {
        "data": {'dob': dob, 'gender': gender, 'email': email},
      };
    }
    return Get.toNamed(RouteHelper.register, arguments: args);
  }

  /// Send [data] to have custom arguments.
  static Future emailSentView({required FromPage? fromPage, bool replace = false /*, Map<String, dynamic>? data*/
      }) async {
    _analytics.setScreen(RouteHelper.emailSent);

    /* if (data != null) {
      Get.toNamed(RouteHelper.emailSent, arguments: data);
      return;
    }*/
    if (replace) {
      Get.offAndToNamed(RouteHelper.emailSent, arguments: {'page': fromPage});
    } else {
      Get.toNamed(RouteHelper.emailSent, arguments: {'page': fromPage});
    }
  }

  static Future registerDOBAndGenderView({String? email, String? password, String? name, bool clearPreviousRoutes = false}) async {
    _analytics.setScreen(RouteHelper.registerDOBAndGender);

    return Get.toNamed(RouteHelper.registerDOBAndGender, arguments: {'email': email});
  }

  static Future askNameFieldView({bool fromPhoneProvider = false}) async {
    _analytics.setScreen(RouteHelper.askNameFieldView);

    return Get.offAndToNamed(RouteHelper.askNameFieldView, arguments: {'fromPhoneProvider': fromPhoneProvider});
  }

  static Future createNewPassword() async {
    _analytics.setScreen(RouteHelper.createNewPassword);

    return Get.offAndToNamed(RouteHelper.createNewPassword);
  }

  static void resetPasswordView() {
    _analytics.setScreen(RouteHelper.resetPassword);

    Get.toNamed(RouteHelper.resetPassword);
  }

  static void topicView({bool clearPreviousRoutes = false}) {
    _analytics.setScreen(RouteHelper.topics);

    Get.toNamed(RouteHelper.topics);
  }

  //
  // * profile related navigation.
  //
  static void editProfile({required UserModel userModel}) {
    try {
      _analytics.setScreen(RouteHelper.editProfile);
      Get.toNamed(RouteHelper.editProfile, arguments: {'userModel': userModel});
    } catch (e) {
      print('dkdkkddkdk');
    }
  }

  static Future<void> openBioView() async {
    _analytics.setScreen(RouteHelper.bio);

    return Get.toNamed(RouteHelper.bio);
  }

  /// * Goto profile screen [*required[uid]] if uid is current user uid then goto profile screen else goto public profile screen
  static void viewProfile({required String? uid, UserModel? model, bool shouldReplace = false}) {
    print('viewProfile: $uid');
    _analytics.setScreen('${RouteHelper.profile}/${(uid ?? model?.uId)}');

    if (uid == null) return;

    /// * if model is null then create new model
    model ??= UserModel(uId: uid);

    /// * assign uid to model
    model.uId = uid;
    if (shouldReplace) {
      UserModel.to.uId == uid
          ? Get.offAndToNamed(RouteHelper.profile)
          : Get.offAndToNamed(RouteHelper.publicProfile, arguments: {'userModel': model});
    } else {
      UserModel.to.uId == uid ? Get.toNamed(RouteHelper.profile) : Get.toNamed(RouteHelper.publicProfile, arguments: {'userModel': model});
    }
  }

  //
  // * chat-rooms navigation
  //
  /// * Goto community screen [*required  [UserModel], [ChatRoomModel]
  static void personMessages({required UserModel person, required ChatRoomModel chatroom}) {
    _analytics.setScreen("${RouteHelper.personMessage}/${chatroom.chatRoomId}");

    String? name = person.name;
    String? profilePicture = person.profilePicture;
    String? uid = person.uId;

    if (uid == null) return;
    Get.toNamed(RouteHelper.personMessage, arguments: {
      'name': name ??
          (person.gender == null
              ? anonymousUser
              : person.gender == 'male'
                  ? anonymousBoy
                  : person.gender == 'female'
                      ? anonymousGirl
                      : anonymousUser),
      'profilePicture': profilePicture ?? "",
      'uid': uid,
      'chatRoom': chatroom,
    });
  }

  //
  // * common navigation
  //
  static void openFullPicture({required String? imageUrl}) {
    _analytics.setScreen(RouteHelper.fullPicture);
    // Logging view picture analytics event
    _analytics.logViewPicture(
      urls: [imageUrl ?? ""],
      userId: UserModel.to.uId ?? '',
    );

    Get.toNamed(RouteHelper.fullPicture, arguments: {'photoUrl': imageUrl});
  }

  static void openMultipleImages({required List<dynamic>? urls}) async {
    _analytics.setScreen(RouteHelper.multipleImages);
    Get.toNamed(
      RouteHelper.multipleImages,
      arguments: {'allImages': urls},
    );
  }

  static void createPost(
      {required Community? community, required PostCreationFrom from, bool replace = false, PostReplyDataType? commentData}) {
    _analytics.setScreen("${RouteHelper.createPost}/${community?.communityId ?? ""}");

    final Map<String, dynamic> args = {'communityId': community, 'fromHome': from, 'CommentForPost': commentData};
    if (replace) {
      Get.offAndToNamed(RouteHelper.createPost, arguments: args);
    } else {
      Get.toNamed(RouteHelper.createPost, arguments: args);
    }
  }

  static Future<List<File>> cropPhotoView({bool clearPreviousRoutes = false, required List<File> imageFile}) async {
    _analytics.setScreen(RouteHelper.cropPhotoView);

    // Logging crop image analytics event
    _analytics.cropImage(
      userId: UserModel.to.uId ?? '',
    );

    List<File> files = await Get.toNamed(RouteHelper.cropPhotoView, arguments: {"files": imageFile});
    return files;
  }

  static Future<File?> cropVideoView({bool clearPreviousRoutes = false, required File video, bool isFromMessageView = false}) async {
    _analytics.setScreen(RouteHelper.cropVideoView);
    try {
      File editedVideo = await Get.toNamed(RouteHelper.cropVideoView, arguments: {"video": video, "isFromMessageView": isFromMessageView});
      return editedVideo;
    } catch (e) {
      return null;
    }
  }

  static Future videoEditorView({bool clearPreviousRoutes = false, required File video}) async {
    _analytics.setScreen(RouteHelper.videoEditorView);

    return Get.toNamed(RouteHelper.videoEditorView, arguments: {"video": video});
  }

  static Future requiredLoginView() async {
    _analytics.setScreen(RouteHelper.requireSignRegisterView);

    Get.toNamed(RouteHelper.requireSignRegisterView);
  }

  static Future openImages({required List<String> urls, required int index, required BuildContext ctx}) async {
    _analytics.setScreen("zoom_image_view");
    return Get.to(() => PicSwiper(index: index, pics: urls), opaque: false, transition: Transition.fade, fullscreenDialog: true);
    return Navigator.of(ctx).push(MaterialPageRoute(builder: (_) => PicSwiper(index: index, pics: urls), fullscreenDialog: true));
  }

  static Future videoPlayerView({required String url}) async {
    try {
      return Get.toNamed(RouteHelper.videoPlayerView, arguments: {"url": url});
    } catch (e) {
      debugPrint(e.toString());
    }
  }

  static void myFriendView({String? url}) async {
    try {
      _analytics.setScreen("friends-view-search");
      return Get.toNamed(RouteHelper.myFriendView, arguments: {"url": url});
    } catch (e) {
      debugPrint(e.toString());
    }
  }

  static Future myCommunitiesViewSearch({String? uid}) async {
    try {
      return Get.toNamed(RouteHelper.myCommunitiesViewSearch, arguments: {"url": uid});
    } catch (e) {
      debugPrint(e.toString());
    }
  }

// community invites screens below
  static void openInvitePermission({required String communityId}) async {
    _analytics.setScreen("InvitatePermissionView/$communityId");
    // ignore: void_checks
    return await Get.to(() => InvitatePermissionView(communityId: communityId),
        binding: CommunityInvitesBindings(communityId: communityId));

    // Get.toNamed(RouteHelper.invitePermission, arguments: {
    //   'communityId': communityId,
    // });
  }

  static void openInviteFriends({required String? communityId}) {
    _analytics.setScreen("${RouteHelper.inviteFriends}/${communityId ?? ""}");
    Get.toNamed(RouteHelper.inviteFriends, arguments: {
      'communityId': communityId,
    });
  }

  static void openChatDetailInfo({required String dialogId}) {
    Get.toNamed(RouteHelper.chatDetailInfo, arguments: {
      'dialogId': dialogId,
    });
  }

  static void openSearchGroupChatMembers({required String dialogId}) {
    Get.toNamed(RouteHelper.searchGroupMembers, arguments: {
      'dialogId': dialogId,
    });
  }

  static void openAddPhoneNo({required String? communityId}) {
    _analytics.setScreen("${RouteHelper.addPhoneNo}/${communityId ?? ""}");
    Get.toNamed(RouteHelper.addPhoneNo, arguments: {
      'communityId': communityId,
    });
  }

  static void openInvitationSent({required String? communityId}) {
    _analytics.setScreen("InvitationSentView/${communityId ?? ""}");
    // Get.toNamed(RouteHelper.invitationSent, arguments: {
    //   'communityId': communityId,
    // });

    Get.offUntil(
        GetPageRoute(
          page: () => InvitationSentView(communityId: communityId ?? ''),
        ), (route) {
      return route.settings.name == '/GroupView';
    });

    // Get.offUntil(
    //     GetPageRoute(
    //       page: () => InvitationSentView(communityId: communityId ?? ''),
    //     ),
    //         (route) => route.isFirst);
  }

  static void communityCalendarView({required String communityId, required bool isEditable}) {
    _analytics.setScreen("${RouteHelper.communityCalendar}/$communityId");

    Get.toNamed(RouteHelper.communityCalendar, arguments: {'communityId': communityId, 'isEditable': isEditable});
  }

  static void gotoQuestionnaireForm() {
    _analytics.setScreen(RouteHelper.questionnaireForm);
    Get.toNamed(RouteHelper.questionnaireForm);
  }

  ///[shouldNavigate] is used to navigate to inside community incase if its public community
  static Future<void> gotoJoinCommunityQuestionnaireForm(
      {required String communityName,
      required String communityId,
      required Function onSubmit,
      required bool shouldNavigate,
      VoidCallback? oSuccess}) async {
    _analytics.setScreen("${RouteHelper.joinCommunityQuestionnaireForm}/$communityId");
    await Get.toNamed(RouteHelper.joinCommunityQuestionnaireForm, arguments: {
      'communityName': communityName,
      'communityId': communityId,
      'onSubmit': onSubmit,
      'shouldNavigate': shouldNavigate,
      "onSuccess": oSuccess
    });
  }

// new splash screens routes methods
  static void openNewSplashTextScreen() {
    debugPrint("going to 1");
    Get.toNamed(RouteHelper.onboarding1);
  }

  static void openNewSplashWelcomeScreen() {
    debugPrint("going to 1");
    Get.toNamed(RouteHelper.onboarding2);
  }

  static void openNewSplashFindingCommunityScrenn() {
    Get.toNamed(RouteHelper.onboarding3);
  }

  ////// chat module screens routing below //////
  // navigation to single conversation by removing all routes till switch view
  static void openConversationAndRemoveCreateGroupChat(CubeDialog chatModel) async {
    await Get.offNamedUntil(
      RouteHelper.conversation,
      (route) => route.settings.name == '/switch',
      arguments: {"dialog": chatModel},
    );

    // Get.offUntil(
    //     GetPageRoute(
    //       page: () => const UbaidConversationScreen(),
    //     ), (route) {
    //   print('Route before navigation is: ${route.settings.name}');
    //   return route.settings.name == '/switch';
    // });
  }

  // navigation to single conversation by removing all routes till switch view
  static void openConversationAndRemovePreviousConversationRouteIfOpen(CubeDialog chatModel, {bool shouldReplace = false}) async {
    try {
      /// Case: when messages opened but not conversation screen
      if (ConversationController.isRegistered(chatModel.dialogId ?? "-1")) {
        print("‼️deleting conversation controller");
        Get.delete<ConversationController>(tag: chatModel.dialogId ?? ("-1"));
      }

      {
        Get.toNamed(
          RouteHelper.conversation,
          arguments: {"dialog": chatModel},
          preventDuplicates: false,
        );
      }
    } catch (_) {}
  }

  // navigation to single conversation by removing all routes till switch view
  static void openAllChatsScreenAndRemoveGroupsviewAfterExit() {
    Get.offUntil(
        GetPageRoute(
          page: () => const ChatScreen(),
        ), (route) {
      print('Route before navigation is: ${route.settings.name}');
      return route.settings.name == '/switch';
    });
  }

  static void gotoUserMatchesView() {
    _analytics.setScreen(MatchView.rootPath);
    Get.toNamed(MatchView.rootPath);
  }

  static void gotoMeetSomeOneView() {
    _analytics.setScreen(FindingAMatchView.path);
    Get.toNamed(FindingAMatchView.path);
  }

  static void gotoMatchedView() {
    _analytics.setScreen(FoundAMatchView.path);
    Get.toNamed(FoundAMatchView.path);
  }

  static void gotoSearchScreen() {
    // showCupertinoDialog(
    //   context: context,
    //   builder: (_) => const SearchScreen(),
    // );
    Get.to(() => const SearchScreen());
  }

  /// Invoke method to open invite friends screen for [community]
  static void goToInviteFriendsScreen({required Community community}) {
    Get.toNamed(
      RouteHelper.inviteFriendsScreen,
      arguments: {"community": community},
    );
  }
}
