import 'dart:async';
import 'dart:convert';
import 'dart:math';

import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:connectycube_sdk/connectycube_chat.dart';
import 'package:crypto/crypto.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:firebase_messaging/firebase_messaging.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:gaya/controller/app_config_controller.dart';
import 'package:gaya/controller/firebase_analytics_controller.dart';
import 'package:gaya/routing/getx_route_methods.dart';
import 'package:gaya/shared/view/widget/gaya_snackbar.dart';
import 'package:gaya/utils/language/translation.dart';
import 'package:gaya/utils/local.storage.dart';
import 'package:gaya/utils/logger.dart';
import 'package:gaya/view/chat/controllers/chat_controller.dart';
import 'package:gaya/view/chat/utils/configs.dart' as config;
import 'package:gaya/view/chat/utils/pref_util.dart';
import 'package:get/get.dart';
import 'package:google_sign_in/google_sign_in.dart';
import 'package:sign_in_with_apple/sign_in_with_apple.dart';

import '../../../components/check_for_app_update.dart';
import '../../../model/user.model.dart';
import '../../../services/notification/fcm_service.dart';
import '../../../services/services.dart';
import '../../../utils/exception_handler/exception_handler_string.dart';
import '../../../utils/strings.dart';
import '../service/authentication_services.dart';

enum FromPage { login, resetPassword }

class LoginController extends ChangeNotifier {
  final TextEditingController email = TextEditingController();
  final TextEditingController password = TextEditingController();

  final GlobalKey<FormState> resetPasswordFormKey = GlobalKey<FormState>();

  final GlobalKey<FormState> resetPasswordFormKeyPhone = GlobalKey<FormState>();
  final GlobalKey<FormState> resetPasswordFormKeyEmail = GlobalKey<FormState>();
  final GlobalKey<FormState> createPasswordKey = GlobalKey<FormState>();

  final commonService = Services();
  final crashlytics = CrashlyticsController.to;
  final performance = PerformanceController.to.instance;

  // style
  TextStyle? verifyPasswordStyle;
  Color? buttonBackgroundColorVerifyPassword;
  VoidCallback? onPressedverifyPassword;
  bool isActive = true;
  bool isLoading = false;
  bool isLoginButtonLoading = false;
  var isCodeEntered = false;
  var isResetLoading = false;
  var isEmailSent = false;
  bool isloadingReset = false;
  bool isPasswordVisible = false;
  String? signInErrorMsg;
  String? signUpErrorMsg;
  String? socialSignInError;
  String? resetPasswordErrorMsg;

  // done by mak
  FirebaseAuth get auth => FirebaseAuth.instance;
  final FirebaseMessaging _firebaseMessaging = FirebaseMessaging.instance;

  User? get authUser => auth.currentUser;
  final GoogleSignIn googleSignIn = GoogleSignIn();
  final AuthenticationServices authServices = AuthenticationServices();
  GoogleSignInAccount? _googleSignInAccount;

  GoogleSignInAccount? get googleSignInAccount => _googleSignInAccount;
  String phoneCode = '+972';

  Stream<User?> get authChanges => auth.authStateChanges();

  // sign up page (dob  and gender part here)
  DateTime? dateOfBirth;
  String? gender;

  customDispose() {
    signInErrorMsg = null;
    signUpErrorMsg = null;
    socialSignInError = null;
    resetPasswordErrorMsg = null;
    phoneCode = '+972';
  }

  @override
  void dispose() {
    signInErrorMsg = null;
    signUpErrorMsg = null;
    socialSignInError = null;
    resetPasswordErrorMsg = null;
    super.dispose();
  }

  // link with phone
  // link phone with email
  Future<bool> linkPhoneWithEmail({required BuildContext context, required Map<String, dynamic> data}) async {
    bool isLinkedSuccessfully = false;
    try {
      isLoading = true;
      notifyListeners();
      await isUserAlreadyExists(data['email']);
      final credential = EmailAuthProvider.credential(email: data['email'], password: data['password']);
      UserCredential userCredentials = await auth.currentUser!.linkWithCredential(credential);
      if (userCredentials.user != null) {
        final user = userCredentials.user;
        Map<String, dynamic> userData = {
          'name': data['name'],
          'email': data['email'],
          'dob': data['dob'],
          'gender': data['gender'],
          'bio': '',
          'profilePic': '',
          'coverphoto': '',
          'interests': [],
          'uid': user!.uid,
          'admin': false,
          'phoneNumber': data['phone'],
          'createdAt': FieldValue.serverTimestamp(),
          'fm_token': '',
          'isActive': true
        };
        await authServices.addUser(userData);

        // Logging user creation event to analytics
        AnalyticsController.to.instance.logCreateUser(
          userId: user.uid,
          userName: data['fullName'],
          userEmail: data['email'],
        );

        UserModel.to.update(UserModel.fromMap(userData, userId: user.uid));
        // connectycube login
        _loginWithCC(context);
        await userCredentials.user?.updateDisplayName(data['name']);
        isLoading = false;
        signInErrorMsg = null;
        signUpErrorMsg = null;
        socialSignInError = null;
        resetPasswordErrorMsg = null;
        isLinkedSuccessfully = true;
        notifyListeners();
      }
    } on FirebaseAuthException catch (error) {
      isLoading = false;
      signInErrorMsg = ExceptionHandler.getMsgAuthException(error.code);
      notifyListeners();
      // gayaAlertDialog(context: context, title: "Login Failed", content: ExceptionHandler.getMsgAuthException(error.code));
    } on FirebaseException catch (error) {
      crashlytics.instance.recordError(e, reason: "FirebaseException linkPhoneWithEmail: ${error.message}");
      isLoading = false;
      signInErrorMsg = ExceptionHandler.getMsgFirebaseException(error.code);
      notifyListeners();
      // gayaAlertDialog(context: context, title: "Login Failed", content: ExceptionHandler.getMsgFirebaseException(error.code));
    } catch (e, s) {
      isLoading = false;
      signInErrorMsg = somethingWrong;
      crashlytics.instance.recordError(e, reason: "linkPhoneWithEmail ", stackTrace: s);

      notifyListeners();
    }
    return isLinkedSuccessfully;
  }

  Future<bool> isUserAlreadyExists(String email) async {
    final isUserExist = await authServices.isUserExistsByEmail(email);
    if (isUserExist == false) {
      return isUserExist;
    }
    //user already exists exception
    throw FirebaseAuthException(code: 'email-already-in-use', message: 'The email address is already in use by another account.');
  }

  Future<void> _loginWithCC(BuildContext? context) async {
    final cubeUser = await connectyCubeLogin(
      context ?? Get.context!,
      CubeUser(login: FirebaseAuth.instance.currentUser?.uid, password: FirebaseAuth.instance.currentUser?.uid),
      saveUser: true,
    );
  }

  // register user
  Future<void> register({
    required BuildContext context,
    required Map<String, dynamic> data,
  }) async {
    try {
      performance.startRegisterLoadTime();
      // required String userEmail, required String userPassword, String? fullName, String? phone
      isLoading = true;
      // just used for resend email
      email.text = data['email'];
      debugPrint('yes set email${email.text}');
      notifyListeners();
      UserCredential userCredentials = await auth.createUserWithEmailAndPassword(email: data['email'], password: data['password']);
      if (userCredentials.user != null) {
        final user = userCredentials.user;
        Map<String, dynamic> userData = {
          'name': data['fullName'],
          'email': data['email'],
          'dob': data['dob'],
          'gender': data['gender'],
          // 'password': EncryptData.encryptData(password: password.value.text),
          'bio': '',
          'profilePic': '',
          'coverphoto': '',
          'interests': [],
          'uid': user!.uid,
          'admin': false,
          'phoneNumber': data['phone'],
          'createdAt': DateTime.now(),
          'fm_token': '',
          'isActive': true,
        };
        await authServices.addUser(userData);

        // Logging user creation event to analytics
        AnalyticsController.to.instance.logCreateUser(
          userId: user.uid,
          userName: data['fullName'],
          userEmail: data['email'],
        );

        UserModel.to.update(UserModel.fromMap(userData, userId: user.uid));
        // connectycube login
        _loginWithCC(context);

        await userCredentials.user?.updateDisplayName(data['fullName']);
        isLoading = false;
        signUpErrorMsg = null;
        notifyListeners();
        if (user.emailVerified == true) {
          Routes.switchView();
          // Navigator.popUntil(context, (route) => route.isFirst);
          // Navigator.pushReplacementNamed(context, route.switchView);
        } else if (user.emailVerified == false) {
          await sendVerificationEmailAndLogout();
          Routes.emailSentView(fromPage: FromPage.login);
          // Navigator.of(context).pushReplacementNamed(route.emailSent, arguments: {"page": FromPage.login});
        }
        // just for asking interest when user signup
        GetInterestStorageController getStorage = Get.find<GetInterestStorageController>();
        await getStorage.removeGetStorage();
      }

      // UserCredential user =
      //     await FirebaseAuth.instance.createUserWithEmailAndPassword(email: email.text.trim(), password: password.text.trim());
      // Get.toNamed(route.emailSent, arguments: {
      //   'userCredentials': user,
      //   'isFromLogn': false,
      // });
      // await addUserdetails();
      // email.clear();
      // password.clear();
      signInErrorMsg = null;
      signUpErrorMsg = null;
      socialSignInError = null;
      resetPasswordErrorMsg = null;
      notifyListeners();
      performance.stopRegisterLoadTime();
    } on FirebaseAuthException catch (error) {
      crashlytics.instance.recordError(e, reason: "register ${error.message}");
      isLoading = false;
      signUpErrorMsg = ExceptionHandler.getMsgAuthException(error.code);
      notifyListeners();
      // gayaAlertDialog(context: context, title: "Registration Failed", content: ExceptionHandler.getMsgAuthException(error.code));
    } on FirebaseException catch (error) {
      crashlytics.instance.recordError(e, reason: "register ${error.message}");
      isLoading = false;
      signUpErrorMsg = ExceptionHandler.getMsgFirebaseException(error.code);
      notifyListeners();
      // gayaAlertDialog(context: context, title: "Registration Failed", content: ExceptionHandler.getMsgFirebaseException(error.code));
    } catch (error, s) {
      crashlytics.instance.recordError(e, reason: "register ", stackTrace: s);

      isLoading = false;
      signUpErrorMsg = somethingWrong;
      notifyListeners();
      email.clear();
      password.clear();
      // gayaAlertDialog(context: context, title: "Registration Failed", content: somethingWrong);
    }
  }

  // get user map data

  // signin with and email and password
  Future<void> loginWithEmailAndPassword({required BuildContext context}) async {
    try {
      performance.startLoginLoadTime();
      isLoginButtonLoading = true;
      notifyListeners();
      UserCredential userCredentials = await auth.signInWithEmailAndPassword(email: email.text.trim(), password: password.text);
      if (userCredentials.user != null) {
        final user = userCredentials.user;

        // Logging user login analytics event
        AnalyticsController.to.instance.logLogin(
          userId: userCredentials.user?.uid ?? '',
        );

        //getting myappuser and setting for global singleton
        UserModel? myAppuser = await authServices.getUserById(user?.uid);

        if (myAppuser == null || myAppuser.uId == null) {
          await authServices.addUserUIDOnly();
        }
        UserModel.to.update(myAppuser);
        // connectycube login
        _loginWithCC(context);

        //fcm token
        String? fcmToken = await _firebaseMessaging.getToken();
        Map<String, dynamic> updatedData = {'fm_token': fcmToken ?? ''};
        await authServices.updateUser(userId: user!.uid, updatedData: updatedData);

        if (auth.currentUser?.emailVerified == true) {
          Routes.splash();
          email.clear();
          password.clear();
        } else if (auth.currentUser?.emailVerified == false) {
          await sendVerificationEmailAndLogout();
          Routes.emailSentView(fromPage: FromPage.login);
        } else {
          Routes.splash();
        }
      }
      email.clear();
      password.clear();
      password.clear();
      isLoading = false;
      isLoginButtonLoading = false;
      signInErrorMsg = null;
      signUpErrorMsg = null;
      socialSignInError = null;
      resetPasswordErrorMsg = null;
      notifyListeners();
      performance.stopLoginLoadTime();
    } on FirebaseAuthException catch (error) {
      crashlytics.instance.recordError(error, reason: "login:${email.text}, ${error.message} ");

      isLoading = false;
      isLoginButtonLoading = false;
      signInErrorMsg = ExceptionHandler.getMsgAuthException(error.code);
      notifyListeners();
      // gayaAlertDialog(context: context, title: "Login Failed", content: ExceptionHandler.getMsgAuthException(error.code));
    } on FirebaseException catch (error) {
      crashlytics.instance.recordError(error, reason: "login:${email.text}, ${error.message} ");
      isLoading = false;
      isLoginButtonLoading = false;
      signInErrorMsg = ExceptionHandler.getMsgFirebaseException(error.code);
      notifyListeners();
      // gayaAlertDialog(context: context, title: "Login Failed", content: ExceptionHandler.getMsgFirebaseException(error.code));
    } catch (error, s) {
      debugPrint("err $error");
      isLoading = false;
      isLoginButtonLoading = false;
      signInErrorMsg = somethingWrong;
      notifyListeners();
      crashlytics.instance.recordError(e, reason: "login:${email.text} ", stackTrace: s);
      // gayaAlertDialog(context: context, title: "Login Failed", content: somethingWrong);
    }
  }

  Completer<void>? _taskCompleter;
  Future<void>? _currentTask;
  final bool _isTaskRunning = false;

  Future<CubeUser?> connectyCubeLogin(BuildContext context, CubeUser user, {bool saveUser = false, dynamic isFromDeepLink}) async {
    if (!GayaRemoteConfig.to.isConnectyCubeEnabled) return null;
    if (_currentTask != null) {
      _cancelTask();
    }
    _taskCompleter = Completer<void>();
    _currentTask = await Future.sync(() {
      return loginToCC(context, user, saveUser: saveUser, isFromDeepLink: isFromDeepLink);
    }).then((_) {}).catchError((error) {}).whenComplete(() {
      _taskCompleter = null;
      _currentTask = null;
    });
    return ChatController.to().currentUser;
  }

  void _cancelTask() {
    if (_isTaskRunning && _taskCompleter?.isCompleted == false) {
      _taskCompleter?.completeError('Canceled');
    }
  }

  // login to connectycube
  Future<void> loginToCC(BuildContext context, CubeUser user, {bool saveUser = false, dynamic isFromDeepLink}) async {
    if (isFromDeepLink != null && ChatController.to().currentUser == null) {
      await Future.delayed(const Duration(seconds: 4));
    }
    init(config.APP_ID, config.AUTH_KEY, config.AUTH_SECRET);
    await createSession(user).then((cubeSession) async {
      var tempUser = user;
      user = cubeSession.user!..password = tempUser.login; //tempUser.password;
      if (saveUser) {
        SharedPrefs.instance.init().then((sharedPrefs) {
          sharedPrefs.saveNewUser(user);
        });
      }
      await _loginToCubeChat(context, user, isFromDeepLink);
    }).catchError((error) {});
    // }
  }

  Future<void> _loginToCubeChat(BuildContext context, CubeUser user, dynamic isFromDeepLink) async {
    try {
      final firebaseToken = await FirebaseAuth.instance.currentUser?.getIdToken();
      if (firebaseToken == null) {
        throw Exception('Firebase token is null');
      }
      CubeChatConnectionSettings.instance.totalReconnections = 5;
      if (!CubeChatConnection.instance.isAuthenticated()) {
        await CubeChatConnection.instance.login(user).then((cubeUser) async {
          await ChatController.to().getAllChatListAndUpdateCurrentUser(cubeUser);
          // PushNotificationsManager.instance.init();
          // FcmHelper.initConnectycubeNotifications();
          if (isFromDeepLink != null && isFromDeepLink != '') {
            // showAlertDialog(context, 'isFromDeepLink', user);
            subscribeToDialog(isFromDeepLink).then((value) async {
              Routes.openConversationAndRemovePreviousConversationRouteIfOpen(value, shouldReplace: true);
            }).catchError((error) {
              log("error is: $error");
            });
          }
        }).catchError((error) {
          log("error is: $error");
        });
      } else {
        await ChatController.to().getAllChatListAndUpdateCurrentUser(user);
        // PushNotificationsManager.instance.init();
        // FcmHelper.initConnectycubeNotifications();

        if (isFromDeepLink != null && isFromDeepLink != '') {
          subscribeToDialog(isFromDeepLink).then((value) async {
            Routes.openConversationAndRemovePreviousConversationRouteIfOpen(value, shouldReplace: true);
          }).catchError((error) {
            log("error is: $error");
          });
        }
      }
    } catch (_) {
      log("error is: $_");
    }
  }

  // send the email for verification and logout
  Future<void> sendVerificationEmailAndLogout() async {
    await auth.currentUser?.sendEmailVerification();
    // auth.signOut();
  }

  Future<OAuthCredential?> reAuthenticateGoogle() async {
    try {
      final googleSignInAccount = await googleSignIn.signIn();
      final googleSignInAuthentication = await googleSignInAccount!.authentication;
      final credential = GoogleAuthProvider.credential(
        accessToken: googleSignInAuthentication.accessToken,
        idToken: googleSignInAuthentication.idToken,
      );
      return credential;
    } catch (_) {}
    return null;
  }

  Future<AuthCredential?> reAuthenticateOTP({required String verificationId, required String smsCode}) async {
    try {
      AuthCredential credential = PhoneAuthProvider.credential(
        verificationId: verificationId, // Replace with the verification ID you used for phone authentication
        smsCode: smsCode, // Replace with the SMS code provided by the user
      );

      return credential;
    } catch (_) {}
    return null;
  }

  Future<void> sendOTP() async {}

  Future<OAuthCredential?> reAuthenticateApple() async {
    try {
      final rawNonce = generateNonce();
      final nonce = sha256ofString(rawNonce);
      // Request credential for the currently signed in Apple account.
      final appleSignInAccount = await SignInWithApple.getAppleIDCredential(scopes: [AppleIDAuthorizationScopes.email], nonce: nonce);
      final credential = OAuthProvider('apple.com')
          .credential(idToken: appleSignInAccount.identityToken, accessToken: appleSignInAccount.authorizationCode, rawNonce: rawNonce);
      return credential;
    } catch (_) {}
    return null;
  }

  // login with Google
  Future<void> logInWithGoogle({required BuildContext context}) async {
    try {
      performance.startLoginLoadTime();
      isLoading = true;
      notifyListeners();
      _googleSignInAccount = await googleSignIn.signIn();
      if (_googleSignInAccount != null) {
        final googleAuth = await _googleSignInAccount!.authentication;

        final credentials = GoogleAuthProvider.credential(
          accessToken: googleAuth.accessToken,
          idToken: googleAuth.idToken,
        );
        final userCredential = await auth.signInWithCredential(credentials);

        final User? user = userCredential.user;
        if (user != null) {
          // Logging user login analytics event
          AnalyticsController.to.instance.logLogin(
            userId: userCredential.user?.uid ?? '',
          );

          UserModel? userModel = await authServices.getUserById(user.uid);

          // checking whether user already don't have an account
          if (userModel == null) {
            await authServices.addUserDetails(user);
            userModel = await authServices.getUserById(user.uid);

            // Logging user creation event to analytics
            AnalyticsController.to.instance.logCreateUser(
              userId: userModel?.uId,
              userName: userModel?.name,
              userEmail: user.email,
            );
          }

          UserModel.to.update(userModel);
          // connectycube login
          _loginWithCC(context);

          // go to splash screen only if we have name and dob
          if (userModel?.dob == null ||
              userModel?.phoneNumber == null ||
              userModel?.phoneNumber!.trim() == '' ||
              userModel?.name == null ||
              userModel?.name?.trim().isEmpty == true) {
            Routes.askNameFieldView();
          } else {
            Routes.splash();
          }
        }
        isLoading = false;
        signInErrorMsg = null;
        signUpErrorMsg = null;
        socialSignInError = null;
        resetPasswordErrorMsg = null;
        notifyListeners();
      } else {
        debugPrint("Inside If Statement: ");
        debugPrint("No Account Selected: ");
        isLoading = false;
        notifyListeners();
      }
      performance.stopLoginLoadTime();
    } on PlatformException catch (e) {
      crashlytics.instance.recordError(e, reason: "login:${email.text}, ");

      debugPrint('platform exceptin occured during google login with this error code: ${e.code}');
      isLoading = false;
      socialSignInError = somethingWrong;
      notifyListeners();
      // await gayaAlertDialog(context: context, title: "Login Failed", content: '${e.code}\n${e.message!}');
    } on FirebaseAuthException catch (error) {
      isLoading = false;
      socialSignInError = ExceptionHandler.getMsgAuthException(error.code);
      notifyListeners();
      // gayaAlertDialog(context: context, title: "Login Failed", content: ExceptionHandler.getMsgAuthException(error.code));
    } on FirebaseException catch (error) {
      isLoading = false;
      socialSignInError = ExceptionHandler.getMsgFirebaseException(error.code);
      notifyListeners();
      // gayaAlertDialog(context: context, title: "Login Failed", content: ExceptionHandler.getMsgFirebaseException(error.code));
    } catch (error) {
      isLoading = false;
      socialSignInError = error.toString();
      notifyListeners();
      email.clear();
      password.clear();
      gayaAlertDialog(context: context, title: GayaStrings.login_failed.tr, content: error.toString());
    }
  }

  // login with app
  Future<UserModel?> signInWithAppleFirebase(BuildContext context) async {
    isLoading = true;
    notifyListeners();
    performance.startLoginLoadTime();
    try {
      final rawNonce = generateNonce();
      final nonce = sha256ofString(rawNonce);
      // Request credential for the currently signed in Apple account.
      final appleCredential = await SignInWithApple.getAppleIDCredential(
          scopes: [AppleIDAuthorizationScopes.email, AppleIDAuthorizationScopes.fullName], nonce: nonce);
      final oauthCredential = OAuthProvider("apple.com").credential(idToken: appleCredential.identityToken, rawNonce: rawNonce);
      final authResult = await auth.signInWithCredential(oauthCredential);
      final user = authResult.user;
      UserModel? myAppUser;

      if (user != null) {
        // Logging user login analytics event
        AnalyticsController.to.instance.logLogin(
          userId: authResult.user?.uid ?? '',
        );

        myAppUser = await authServices.getUserById(user.uid);

        // checking whether user already don't have an account
        if (myAppUser == null) {
          final firstLastName = appleCredential.givenName != null && appleCredential.familyName != null
              ? '${appleCredential.givenName} ${appleCredential.familyName}'
              : appleCredential.givenName;
          await authServices.addUserDetails(user, name: firstLastName);
          myAppUser = await authServices.getUserById(user.uid);

          // Logging user creation event to analytics
          AnalyticsController.to.instance.logCreateUser(
            userId: myAppUser?.uId,
            userName: myAppUser?.name,
            userEmail: myAppUser?.email,
          );
        }

        UserModel.to.update(myAppUser);
        // connectycube login
        _loginWithCC(context);
      }
      isLoading = false;
      signInErrorMsg = null;
      signUpErrorMsg = null;
      socialSignInError = null;
      resetPasswordErrorMsg = null;
      notifyListeners();
      performance.stopLoginLoadTime();
      debugPrint("apple login successfull ${myAppUser?.toMap()}}");
      return myAppUser;
    } on SignInWithAppleAuthorizationException catch (error) {
      crashlytics.instance.recordError(error, reason: "signInWithAppleFirebase ");

      isLoading = false;
      socialSignInError = ExceptionHandler.getMsgAuthException(error.code.name);
      notifyListeners();
    } on SignInWithAppleNotSupportedException catch (error) {
      crashlytics.instance.recordError(error, reason: "signInWithAppleFirebase ");

      isLoading = false;
      socialSignInError = error.message;
      notifyListeners();
    } on PlatformException catch (e) {
      crashlytics.instance.recordError(e, reason: "signInWithAppleFirebase");

      debugPrint('platform exceptin occured during apple login with this error code: ${e.code}');
      isLoading = false;
      socialSignInError = somethingWrong;
      notifyListeners();
    } on FirebaseAuthException catch (error) {
      crashlytics.instance.recordError(error, reason: "signInWithAppleFirebase ${error.code}", stackTrace: error.stackTrace);
      isLoading = false;
      socialSignInError = ExceptionHandler.getMsgAuthException(error.code);
      notifyListeners();
    } on FirebaseException catch (error) {
      crashlytics.instance.recordError(error, reason: "signInWithAppleFirebase ${error.code}", stackTrace: error.stackTrace);

      isLoading = false;
      socialSignInError = ExceptionHandler.getMsgFirebaseException(error.code);
      notifyListeners();
    } catch (error, s) {
      crashlytics.instance.recordError(error, reason: "signInWithAppleFirebase ", stackTrace: s);

      debugPrint("err $error");
      isLoading = false;
      socialSignInError = somethingWrong;
      notifyListeners();
      email.clear();
      password.clear();
    }
    return null;
  }

  String sha256ofString(String input) {
    final bytes = utf8.encode(input);
    final digest = sha256.convert(bytes);
    return digest.toString();
  }

  String generateNonce([int length = 32]) {
    const charset = '0123456789ABCDEFGHIJKLMNOPQRSTUVXYZabcdefghijklmnopqrstuvwxyz-._';
    final Random random = Random.secure();
    return List.generate(length, (index) {
      charset[random.nextInt(charset.length)];
    }).join();
  }

  Future<bool?> sendVerificationEmail({required BuildContext context, UserCredential? user}) async {
    final myUser = user?.user ?? authUser;
    bool isSent = false;
    try {
      await myUser?.sendEmailVerification();
      isSent = true;
      GayaSnackBar.show(context: context, type: GayaSnackBarType.other, text: 'Email verification resent successfully!');
    } catch (_) {
      isSent = true;
    }
    return isSent;
  }

  // reset password function
  Future<bool?> resetPassword({required BuildContext context, bool isResend = false}) async {
    try {
      isResetLoading = true;
      notifyListeners();
      await auth.sendPasswordResetEmail(email: email.value.text);
      // snackBar(context, "Your Account not found", Colors.deepOrange);
      isResetLoading = false;
      notifyListeners();
      if (isResend) {
        GayaSnackBar.show(context: context, type: GayaSnackBarType.other, text: 'Email resent successfully!');
      }
      resetPasswordErrorMsg = null;
      notifyListeners();
      return true;
    } on FirebaseAuthException catch (error) {
      isResetLoading = false;
      resetPasswordErrorMsg = ExceptionHandler.getMsgAuthException(error.code);
      notifyListeners();
      // gayaAlertDialog(context: context, title: "Login Failed", content: ExceptionHandler.getMsgAuthException(error.code));
    } catch (error, s) {
      isResetLoading = false;
      resetPasswordErrorMsg = somethingWrong;

      crashlytics.instance.recordError(error, reason: "Reset password ", stackTrace: s);

      notifyListeners();
      // gayaAlertDialog(context: context, title: "Login Failed", content: somethingWrong);
    }
    return null;
  }

  // reset the isEmailSent after a successful message is shown and moved to the back
  void resetIsEmailField() {
    email.clear();
    notifyListeners();
  }

  Future<UserModel?> getUserById(String? userId) async {
    if (userId == null) return null;
    return await authServices.getUserById(userId);
  }

  // logout
  bool isLogoutLoading = false;
  Future<void> logout(BuildContext context) async {
    try {
      if (auth.currentUser != null) {
        isLogoutLoading = true;
        notifyListeners();
        await FirebaseMessagingService.instance.clearFcmToken();
        UserModel.to.update(UserModel());
        final providerData = auth.currentUser!.providerData;
        if (providerData.isNotEmpty) {
          switch (providerData.first.providerId) {
            case 'google.com':
              await auth.signOut();
              await googleSignIn.signOut();
              break;
            case 'apple.com':
              await auth.signOut();
              break;
            default:
              await auth.signOut();
          }
        } else {
          await googleSignIn.signOut();
          await auth.signOut();
        }
        // Logging user logout analytics event
        AnalyticsController.to.instance.logLogout(userId: auth.currentUser?.uid ?? '');
        AppConfigurationController.to.resetOnLogInOrOut(); // delete RAM data
        // signout from connectioncube, destroy session and clear shared preferences
        signOut().then(
          (voidValue) {
            MyLoggerServices.to.print('successfully signout from connection cube.');
          },
        ).catchError(
          (onError) {
            MyLoggerServices.to.print('error while signout from connection cube.');
          },
        ).whenComplete(() {
          try {
            // CubeSessionManager.instance.deleteActiveSession();
            CubeChatConnection.instance.destroy();
            // CubeChatConnection.instance.logout();
            // PushNotificationsManager.instance.unsubscribe();
            // FcmHelper.unsubscribe();

            SharedPrefs.instance.deleteUser();
            MyLoggerServices.to.print('all done on signout from connection cube.');
            ChatController.to().clearAllChatList();
          } catch (e) {}
        });
        isLogoutLoading = false;
        notifyListeners();
        Routes.loginView(clearPreviousRoutes: true);
      } else {
        Routes.loginView(clearPreviousRoutes: true);
      }
    } catch (error) {
      debugPrint("err $error");
      Routes.loginView(clearPreviousRoutes: true);
    }
  }

  Future<dynamic> gayaAlertDialog({required BuildContext context, required String title, String? content}) {
    return showDialog(context: context, builder: (builder) => AlertDialog(title: Text(title), content: Text(content ?? '')));
  }

  //is password visible
  bool passwordVisibility() {
    isPasswordVisible = !isPasswordVisible;
    notifyListeners();
    return isPasswordVisible;
  }

  // validation phone and email
  // to check that entered phone number is valid
  bool isPhoneNumberValid = true;

  void changePhoneValidation(bool flag) {
    isPhoneNumberValid = flag;
    notifyListeners();
  }

  Future<void> createUserEntryInFirestore({required Map<String, dynamic> payload}) async {
    if (FirebaseAuth.instance.currentUser == null) return;
    final String name = payload['name'] ?? '';
    Map<String, dynamic> userData = {
      'bio': '',
      'email': FirebaseAuth.instance.currentUser!.email ?? '',
      'profilePic': '',
      'coverphoto': '',
      'interests': [],
      'uid': FirebaseAuth.instance.currentUser!.uid,
      'admin': false,
      'phoneNumber': FirebaseAuth.instance.currentUser!.phoneNumber ?? '',
      'createdAt': FieldValue.serverTimestamp(),
      'fm_token': '',
      'isActive': true,
      ...payload,
    };
    await authServices.addUser(userData);
    if (name.isBlank == false) {
      authUser?.updateDisplayName(name);
    }

    UserModel.to.update(UserModel.fromMap(userData, userId: FirebaseAuth.instance.currentUser!.uid));
  }
}
