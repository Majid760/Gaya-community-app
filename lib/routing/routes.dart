// import 'package:firebase_auth/firebase_auth.dart';
// import 'package:flutter/material.dart';
// import 'package:gaya/model/user.model.dart';
// import 'package:gaya/view/Auth/screen/Forgot_password_Otp.dart';
// import 'package:gaya/view/Auth/screen/ask_name_screen.dart';
// import 'package:gaya/view/Auth/screen/create.new.password.view.dart';
// import 'package:gaya/view/Auth/screen/email_form_view.dart';
// import 'package:gaya/view/Auth/screen/forget.password.email.dart';
// import 'package:gaya/view/Auth/screen/gender_dob_form_view.dart';
// import 'package:gaya/view/Auth/screen/login.view.dart';
// import 'package:gaya/view/Auth/screen/name_email_password_register-view.dart';
// import 'package:gaya/view/Auth/screen/register.view.dart';
// import 'package:gaya/view/bio.view.dart';
// import 'package:gaya/view/communities.view.dart';
// import 'package:gaya/view/community_setting_view.dart';
// import 'package:gaya/view/create.community.view.dart';
// import 'package:gaya/view/create.recipe.view.dart';
// import 'package:gaya/view/edit.profile.view.dart';
// import 'package:gaya/view/edit_community_screen.dart';
// import 'package:gaya/view/home.view.dart';
// import 'package:gaya/view/messaging/message.view.dart';
// import 'package:gaya/view/messaging/personmessages.view.dart';
// import 'package:gaya/view/notification.view.dart';
// import 'package:gaya/view/other.user.profile.dart';
// import 'package:gaya/view/profile.view.dart';
// import 'package:gaya/view/saved.posts.view.dart';
// import 'package:gaya/view/seeall.interestcommunities.dart';
// import 'package:gaya/view/seeall.mycommunities.dart';
// import 'package:gaya/view/splash.view.dart';
// import 'package:gaya/view/switch.view.dart';
// import 'package:gaya/view/topics.view.dart';
// import 'package:gaya/widgets/group_view_widget/about.widget.dart';
//
// import '../view/Auth/controller/require.sigin.register.dart';
// import '../view/Auth/screen/verfication.email.sent.view.dart';
// import '../view/approve.posts.view.dart';
// import '../view/approve.users.view.dart';
// import '../view/create.post.view.dart';
// import '../view/post.confirmation.view.dart';
// import '../view/view.recipe.detail.view.dart';
//
// const String splash = 'splash';
// const String topics = 'topics';
// const String login = 'login';
// const String register = 'register';
// const String registerNameEmailPhone = "register_name_email_phone";
// const String registerEmail = 'registerEmail';
// const String registerDOBAndGender = 'registerDOBAndGender';
// const String resetPassword = 'resetPassword';
// const String resetEnterPhoneNumber = 'resetEnterPhoneNumber';
// // const String emailSentView = 'emailSentView';
// const String createNewPassword = 'createNewPassword';
// const String switchView = 'switch';
// const String home = 'home';
// const String message = 'message';
// const String community = 'community';
// const String notification = 'notification';
// const String profile = 'profile';
// const String recipedetails = 'recipedetails';
// const String editProfile = 'EditProfile';
// const String bio = 'bio';
// const String createPost = 'CreatePost';
// const String createRecipe = 'createRecipe';
// const String personMessage = 'personMessage';
// const String requireSignRegisterView = 'RequireSignRegisterView';
// const String createCommunity = 'createCommunity';
// const String editCommunity = 'editCommunity';
// const String communitySetting = 'communitySetting';
// // const String postWithComments = 'postWithComments';
// const String commenting = 'Commenting';
// const String publicProfile = 'publicProfile';
// const String seeAllMyCommunities = "seeAllMyCommunities";
// const String seeAllInterestCommunities = "seeAllInterestCommunities";
// const String savedPosts = "savedPosts";
// const String about = "about";
// const String approvePosts = "approvePosts";
// const String approveUsers = "approveUsers";
// const String postConfirmation = ' postConfirmation';
// const String emailSent = 'emailSent';
// const String userNotLogin = 'userNotLogin';
// const String userJoinedCommunities = 'UserJoinedCommunities';
// // const String userWithoutommunities = 'userWithoutommunities';
// const String askNameFieldView = 'askNameFieldView';
//
// Route<dynamic>? generateRoutes(RouteSettings settings) {
//   switch (settings.name) {
//     case seeAllInterestCommunities:
//       Map<String, dynamic> arguments = settings.arguments as Map<String, dynamic>;
//       return MaterialPageRoute(builder: (context) => SeeAllInterestCommunities(communityName: arguments['communityName']));
//     case seeAllMyCommunities:
//       return MaterialPageRoute(builder: (context) => const SeeAllMyCoummunities());
//     case splash:
//       return MaterialPageRoute(builder: (context) => const SplashView());
//     case topics:
//       return MaterialPageRoute(builder: (context) => const TopicsView());
//     case login:
//       return MaterialPageRoute(builder: (context) => const LoginView());
//     case register:
//       Map<String, dynamic> arguments = settings.arguments as Map<String, dynamic>;
//       return MaterialPageRoute(builder: (context) => RegisterView(data: arguments["data"]));
//     case registerNameEmailPhone:
//       Map<String, dynamic> arguments = settings.arguments as Map<String, dynamic>;
//       return MaterialPageRoute(builder: (context) => NameEmailPasswordRegisterView(data: arguments));
//     case registerEmail:
//       return MaterialPageRoute(builder: (context) => const EmailPhoneRegister());
//     case registerDOBAndGender:
//       Map<String, dynamic>? arguments = settings.arguments as Map<String, dynamic>?;
//       return MaterialPageRoute(builder: (context) => DateAndGenderFormView(email: arguments?["email"]));
//     case resetPassword:
//       Map<String, dynamic> arguments = settings.arguments as Map<String, dynamic>;
//       return MaterialPageRoute(
//           builder: (context) => ForgetPasswordView(phoneNumber: arguments['phoneNumber'], verificationId: arguments['verificationId']));
//     // case emailSentView:
//     //   final argss = settings.arguments as Map<String, dynamic>;
//     //   return MaterialPageRoute(builder: (context) => VerficationEmailView(args: argss));
//     case resetEnterPhoneNumber:
//       return MaterialPageRoute(builder: (context) => const ForgetPasswordPhoneView());
//     case createNewPassword:
//       return MaterialPageRoute(builder: (context) => const CreatePasswordView());
//     case switchView:
//       // In case of when users have no name route to ask name field view
//       if (FirebaseAuth.instance.currentUser != null && UserModel.to.name == null || UserModel.to.name?.isEmpty == true) {
//         debugPrint('guarded with profile name in routes');
//         return MaterialPageRoute(builder: (context) => const AskNameFieldView());
//       }
//       final arguments = settings.arguments as Map<String, dynamic>?;
//       int index = 0;
//       if (arguments != null) {
//         index = arguments['initialIndex'];
//       }
//       return PageRouteBuilder(
//         pageBuilder: (_, __, ___) => SwitchView(initialIndex: index),
//         transitionDuration: const Duration(milliseconds: 400),
//         transitionsBuilder: (_, a, __, c) => FadeTransition(opacity: a, child: c),
//       );
//     case home:
//       return MaterialPageRoute(builder: (context) => const HomeView());
//     case message:
//       return MaterialPageRoute(builder: (context) => MessageView());
//     case community:
//       return MaterialPageRoute(builder: (context) => const CommunityView());
//     case communitySetting:
//       return MaterialPageRoute(builder: (context) => const CommunitySettingScreen());
//     case notification:
//       return MaterialPageRoute(builder: (context) => NotificationView());
//     case profile:
//       return MaterialPageRoute(builder: (context) => ProfileView());
//     case recipedetails:
//       Map<String, dynamic> arguments = settings.arguments as Map<String, dynamic>;
//
//       return MaterialPageRoute(
//           builder: (context) => RecipeDetailView(
//                 postImage: arguments['postImage'],
//                 recipeDirections: arguments['directions'],
//                 recipeIngredients: arguments['ingredients'],
//                 preparationTime: arguments['preparationTime'],
//                 recipeName: arguments['recipeName'],
//                 totalTime: arguments['totalTime'],
//               ));
//
//     case editProfile:
//       Map<String, dynamic> arguments = settings.arguments as Map<String, dynamic>;
//       return MaterialPageRoute(
//           builder: (context) => EditProfileView(
//               profilePic: arguments['profilePic'],
//               fullName: arguments['fullName'],
//               bio: arguments['bio'],
//               dob: arguments['dob'],
//               gender: arguments['gender']));
//     case bio:
//       return MaterialPageRoute(builder: (context) => const BioView());
//     case createPost:
//       Map<String, dynamic> arguments = settings.arguments as Map<String, dynamic>;
//       return MaterialPageRoute(
//           builder: (context) => CreatePostView(
//                 communityModel: arguments['communityId'],
//                 fromHome: arguments['fromHome'],
//               ));
//     case createRecipe:
//       Map<String, dynamic> arguments = settings.arguments as Map<String, dynamic>;
//       return MaterialPageRoute(
//           builder: (context) => CreateRecipeView(
//                 communityId: arguments['cId'],
//               ));
//     case personMessage:
//       Map<String, dynamic> arguments = settings.arguments as Map<String, dynamic>;
//       return MaterialPageRoute(
//           builder: (context) => PersonMessageView(
//                 profilePicture: arguments['profilePicture'],
//                 name: arguments['name'],
//                 uid: arguments['uid'],
//                 chatRoomModel: arguments['chatRoom'],
//               ));
//     case requireSignRegisterView:
//       return MaterialPageRoute(builder: (context) => const RequireSignRegisterView());
//     case editCommunity:
//       return MaterialPageRoute(builder: (context) => const EditCommunityScreen());
//     case createCommunity:
//       return MaterialPageRoute(builder: (context) => CreateCommunityView());
//     // case postWithComments:
//     //   Map<String, dynamic> arguments = settings.arguments as Map<String, dynamic>;
//     //   return MaterialPageRoute(
//     //       builder: (context) => PostVithCommentsView(
//     //             userModel: arguments['userModel'],
//     //             postModel: arguments['postModel'],
//     //             communityModel: arguments['communityModel'],
//     //           ));
//
//     // case commenting:
//     //   Map<String, dynamic> arguments =
//     //       settings.arguments as Map<String, dynamic>;
//     //   return MaterialPageRoute(
//     //       builder: (context) => CommentingView(
//
//     //           ));
//
//     case publicProfile:
//       Map<String, dynamic> arguments = settings.arguments as Map<String, dynamic>;
//
//       return MaterialPageRoute(
//           builder: (context) => PeopleProfileView(
//                 usermodel: arguments['userModel'],
//               ));
//
//     case about:
//       Map<String, dynamic> arguments = settings.arguments as Map<String, dynamic>;
//
//       return MaterialPageRoute(
//           builder: (context) => AboutGroupView(
//                 communityId: arguments['communityId'],
//                 communityDescription: arguments['communityDescription'],
//               ));
//
//     case savedPosts:
//       return MaterialPageRoute(builder: (context) => const SavedPostsView());
//
//     case approvePosts:
//       Map<String, dynamic> arguments = settings.arguments as Map<String, dynamic>;
//
//       return MaterialPageRoute(
//           builder: (context) => ApprovePostsView(
//                 communityId: arguments['communityId'],
//               ));
//
//     case approveUsers:
//       Map<String, dynamic> arguments = settings.arguments as Map<String, dynamic>;
//       return MaterialPageRoute(
//           builder: (context) => ApproveUsersView(
//                 communityid: arguments['communityid'],
//                 communityName: arguments['communityName'],
//               ));
//
//     case postConfirmation:
//       Map<String, dynamic>? arguments = settings.arguments as Map<String, dynamic>?;
//
//       VoidCallback onSuccess = arguments!["onSuccessCallback"] as VoidCallback;
//
//       return MaterialPageRoute(builder: (context) => PostConfirmationView(onSuccessCallback: onSuccess));
//
//     case emailSent:
//       final argss = settings.arguments as Map<String, dynamic>;
//       return MaterialPageRoute(builder: (context) => EmailVerifiedSentView(args: argss));
//
//     // case userWithoutommunities:
//     //   return MaterialPageRoute(builder: (context) => UserWithoutommunities());
//     case askNameFieldView:
//       return MaterialPageRoute(builder: (context) => const AskNameFieldView());
//     default:
//       throw ('This route does not exist');
//   }
// }
