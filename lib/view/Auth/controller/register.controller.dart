import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:firebase_messaging/firebase_messaging.dart';
import 'package:flutter/material.dart';
import 'package:gaya/controller/topics.controller.dart';
import 'package:gaya/model/user.model.dart';
import 'package:gaya/routing/getx_route_methods.dart';
import 'package:gaya/services/services.dart';
import 'package:gaya/utils/language/translation.dart';
import 'package:gaya/utils/logger.dart';
import 'package:gaya/view/Auth/controller/login.controller.dart';
import 'package:get/get.dart';
import 'package:provider/provider.dart';

class RegisterController extends ChangeNotifier {
  final TextEditingController name = TextEditingController();
  final TextEditingController email = TextEditingController();
  final TextEditingController password = TextEditingController();
  final GlobalKey<FormState> registerFormKey = GlobalKey<FormState>();
  final GlobalKey<FormState> registerEmail = GlobalKey<FormState>();

  final TextEditingController phoneNumberController = TextEditingController();
  bool IsLoading = false;
  bool isLoadingEmail = false;
  bool isPasswordVisible = false;

  TextStyle? style;
  VoidCallback? onPressed;
  Color? buttonBackgroundColor;

  TextStyle? styleEmail;
  Color? buttonBackgroundColorEmail;
  VoidCallback? onPressedEmail;

  String phoneCode = '+972';

  Services service = Services();
  bool fromSignUp = true;

  RegisterController() {
    // getuserNames();
  }

  Future<void> register(BuildContext context) async {
    try {
      IsLoading = true;
      notifyListeners();
      UserCredential user =
          await FirebaseAuth.instance.createUserWithEmailAndPassword(email: email.text.trim(), password: password.text.trim());
      // Routes.emailSentView(fromPage: null, data: {'userCredentials': user, 'isFromLogn': false});
      Routes.emailSentView(fromPage: FromPage.login);
      await addUserdetails();

      user.user?.sendEmailVerification();

      name.clear();
      email.clear();
      password.clear();
    } on FirebaseAuthException catch (e) {
      MyLoggerServices.to.print(e);
      String? errorMessage;
      switch (e.code) {
        case 'email-already-in-use':
          errorMessage = GayaStrings.email_already_registered.tr;
          break;
        case 'invalid-email':
          errorMessage = GayaStrings.invalid_email.tr;
          break;
        case 'operation-not-allowed':
          errorMessage = GayaStrings.operation_not_allowed.tr;
          break;
        case 'weak-password':
          errorMessage = GayaStrings.weak_password.tr;
      }

      showDialog(
        context: context,
        builder: (builder) {
          return AlertDialog(
            title: Text(GayaStrings.registration_failed.tr),
            content: Text(errorMessage ?? ''),
          );
        },
      );
    } finally {
      IsLoading = false;
      notifyListeners();
    }
  }

  //get all the users username
  Future<QuerySnapshot?> getuserNames(BuildContext context) async {
    List saveUser = [];
    QuerySnapshot username = await FirebaseFirestore.instance.collection('users').get().then((snapshot) {
      saveUser.clear();
      for (var i in snapshot.docs) {
        UserModel userModel = UserModel.fromMap(i.data(), userId: i.id);
        // log(userModel.name.toString());
        saveUser.add(userModel.name);
      }

      if (saveUser.contains(name.text)) {
        showDialog(
            context: context,
            builder: (builder) {
              return AlertDialog(
                title: Text(GayaStrings.registration_failed.tr),
                content: Text(GayaStrings.user_name_already_exists.tr),
              );
            });
      } else {
        register(context);
      }

      return snapshot;
    });
    return username;
  }

  //get all the users username
  Future<QuerySnapshot?> getAllEmails(BuildContext context) async {
    List emailOfUsers = [];
    QuerySnapshot username = await FirebaseFirestore.instance.collection('users').get().then((snapshot) {
      emailOfUsers.clear();
      for (var i in snapshot.docs) {
        UserModel userModel = UserModel.fromMap(i.data());
        emailOfUsers.add(userModel.email);
      }
      if (emailOfUsers.contains(email.text)) {
        showDialog(
            context: context,
            builder: (builder) {
              return AlertDialog(title: Text(GayaStrings.registration_failed.tr), content: Text(GayaStrings.email_already_exists.tr));
            });
      } else {
        Routes.register(email: email.text);
      }
      return snapshot;
    });
    return username;
  }

//add the user details while signup

  Future addUserdetails() async {
    FirebaseAuth fireAuth = FirebaseAuth.instance;
    User? user = fireAuth.currentUser;
    await FirebaseFirestore.instance.collection('users').doc(user!.uid).set({
      'name': name.text,
      'email': email.text,
      // 'password': EncryptData.encryptData(password: password.value.text),
      'bio': '',
      'profilePic': '',
      'coverphoto': '',
      'interests': [],
      'uid': user.uid,
      'admin': false,
      'phoneNumber': "$phoneCode${phoneNumberController.text}",
      'createdAt': DateTime.now(),
      'fm_token': await FirebaseMessaging.instance.getToken(),
      'isActive': true, 
    });
  }

  Future updateInterests(BuildContext context) async {
    List<Map<String, dynamic>> interestsList = [];
    final topicController = Provider.of<TopicsController>(context, listen: false);

    for (var i in topicController.selectedItems) {
      interestsList.add({
        'icon': i.image,
        'title': i.title,
      });
    }

    await service.updateUserDetails(interestsList);
  }

  //is password visible
  bool passwordVisibility() {
    isPasswordVisible = !isPasswordVisible;
    notifyListeners();
    return isPasswordVisible;
  }
}
