import 'dart:async';
import 'dart:convert';
import 'dart:developer';
import 'dart:io';

import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:firebase_storage/firebase_storage.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:gaya/components/snackbar.component.dart';
import 'package:gaya/controller/firebase_analytics_controller.dart';
import 'package:gaya/controller/topics.controller.dart';
import 'package:gaya/model/user.model.dart';
import 'package:gaya/routing/getx_route_methods.dart';
import 'package:gaya/services/notification/notification_api/notification_api.dart';
import 'package:gaya/services/services.dart';
import 'package:gaya/shared/service/media_service/file_picking_service.dart';
import 'package:gaya/shared/service/super_admin/super_admin_services.dart';
import 'package:gaya/shared/view/widget/gaya_snackbar.dart';
import 'package:gaya/utils/collections.dart';
import 'package:gaya/utils/const.dart';
import 'package:gaya/utils/local.storage.dart';
import 'package:gaya/utils/logger.dart';
import 'package:gaya/view/Auth/service/authentication_services.dart';
import 'package:get/get.dart';
import 'package:image_picker/image_picker.dart';
import 'package:intl/intl.dart';
import 'package:permission_handler/permission_handler.dart';
import 'package:provider/provider.dart';
import 'package:uuid/uuid.dart';

import '../model/topic.model.dart';
import '../services/storage_servies.dart';
import '../shared/service/permission_service/device_permission.dart';
import '../utils/language/translation.dart';
import '../view/other_user_profile/models/profile_watch.dart';

class ProfileController extends ChangeNotifier {
  TextEditingController nameController = TextEditingController();
  TextEditingController bioController = TextEditingController();
  TextEditingController dobController = TextEditingController();

  double? percentage;
  double? coverPercentage;
  QuerySnapshot? snapShotData;
  Services service = Services();
  final _firestore = FirebaseFirestore.instance;
  GlobalKey nameGlobalKey = GlobalKey();

  List changeIntersts = [];
  List senderIds = [];
  List recieverIds = [];
  int numberOfUnreadMessages = 0;
  List currentUserSenderIds = [];
  List currentUserRecieverIds = [];
  DocumentSnapshot? requestSnapShot;
  String? time;
  final today = DateTime(DateTime.now().year, DateTime.now().month, DateTime.now().day);
  final yesterday = DateTime(DateTime.now().year, DateTime.now().month, DateTime.now().day - 1);
  late DateTime dateTime;
  DocumentSnapshot? userDetails;
  File? image;
  File? coverimage;
  File? messageImage;
  String? messageUrl;
  bool isFriend = true;

  FirebaseAuth get firebaseAuth => FirebaseAuth.instance;

  User? get authUser => firebaseAuth.currentUser;
  final AuthenticationServices authServices = AuthenticationServices();
  bool unreadMessagesAvailable = false;
  final CollectionReference _chatRoomCollection = FirebaseFirestore.instance.collection("chatrooms");
  bool unReadNotificationsAvailable = false;
  bool isLoading = false;

  final GetStorageController _getStorage = GetStorageController();

  // timer functionality
/*  Future<void> loadRemainingTime() async {
    await _getStorage.initStorage();

    final String? usersString = _getStorage.box.read('complimentedUser_${UserModel.to.uId}_');

    if (usersString != null) {
      final List<ComplimentSavedUser> savedUsers = ComplimentSavedUser.fromJsonList(usersString);
      final DateTime currentTime = DateTime.now();

      users = savedUsers;
      savedUsers.removeWhere((user) => currentTime.difference(user.startTime).inHours > 24);

      if (users.isNotEmpty) {
        json.encode(savedUsers.map((user) => user.toJson()).toList());
      }
    }
  }*/

  bool _checkIfAlreadyGivenCompliment(String otherUserId) {
    int? time = _getStorage.box.read<int>(_makeComplimentKey(otherUserId));
    // if time is null I've not visit other user profile in past 24 hours
    if (time == null) {
      return false;
    }

    // dateTime when I viewed other user profile
    DateTime viewedTime = DateTime.fromMillisecondsSinceEpoch(time);
    // dateTime now
    DateTime nowTime = DateTime.now();
    // returning true if viewedTime is in past 24 hours else false.
    return nowTime.difference(viewedTime).inHours < 24;
  }

  Future<void> startComplimentTime({
    required ComplimentSavedUser user,
    required BuildContext context,
    required String compliment,
  }) async {
    if (_checkIfAlreadyGivenCompliment(user.id)) {
      // User already gave a compliment within 24 hours
      GayaSnackBar.show(context: context, type: GayaSnackBarType.notification, text: GayaStrings.already_added_complement.tr);
      return;
    }

    _getStorage.box.write(_makeComplimentKey(user.id), DateTime.now().millisecondsSinceEpoch);
    notifyListeners();
    sendCompliments(
      compliment: compliment,
      senderUid: firebaseAuth.currentUser?.uid,
      dateTime: user.startTime,
      otherUid: user.id,
    );

    // Logging user giving compliment analytics event
    AnalyticsController.to.instance.logCompliment(
      complimentGiverId: UserModel.to.uId ?? '',
      compliment: compliment,
      complimentReceiverId: user.id,
    );
    // Logging special feature usage analytics event
    AnalyticsController.to.instance.logSpecialFeatureUsage(
      userId: UserModel.to.uId ?? '',
      featureName: 'user_compliment',
    );

    GayaSnackBar.show(
      context: context,
      type: GayaSnackBarType.send,
      text: GayaStrings.compliment_added_success.tr,
    );
  }

  Future<void> sendCompliments({
    required String compliment,
    required String? senderUid,
    required dateTime,
    required String otherUid,
  }) async {
    final complimentCollectionRef = FirebaseFirestore.instance
        .collection(ComplimentStrings.userCollection)
        .doc(otherUid)
        .collection(ComplimentStrings.complimentCollection)
        .doc(senderUid) // Use senderUid as the document ID
        .collection(ComplimentStrings.allCompliments); // Use compliment as the collection name

    // Add a new document with the 'senderUid' and 'createdOn' fields
    await complimentCollectionRef.add({
      ComplimentStrings.senderUId: senderUid,
      ComplimentStrings.createdOn: DateTime.now(),
      ComplimentStrings.compliment: compliment,
    });
  }

  // image cropping service

  Future acceptFriendRequest(String frienshipDocId) async {
    try {
      _firestore.collection(friendship).doc(frienshipDocId).update({'isaccepted': true});
      EngagementScoreController.to.instance.onAcceptRequest(fromUserId: frienshipDocId);
    } catch (_) {}
  }

  //Pick the image from the camera

  // {
  Future imagePicker(BuildContext context) async {
    try {
      XFile? imagePick = await ImagePicker().pickImage(source: ImageSource.gallery, imageQuality: 50);
      if (imagePick != null) {
        File convertedFile = File(imagePick.path);
        image = convertedFile;
        if (image != null) {
          List<File> croppedImage = await Routes.cropPhotoView(imageFile: <File>[image!]);
          if (croppedImage.isNotEmpty) {
            image = croppedImage.first;
          }
        }
        if (context.mounted) {
          // Logging pick image or video analytics event
          AnalyticsController.to.instance.logPickImageVideo(
            pickType: 'image',
            userId: UserModel.to.uId ?? '',
          );

          notifyListeners();
          return true;
        }
      } else {
        return;
      }
    } on PlatformException catch (e) {
      if (DevicePermissionUtils.isDenied(e.message ?? e.code)) {
        openAppSettings();
      }
    } catch (e) {
      log(e.toString());
    }
  }

  // by mak => this function takes the image from gallery with permissin etc
  final MediaService _mediaService = MediaService();

  Future<void> pickImageFromGallery({required BuildContext context, int imageQuality = 50}) async {
    try {
      isLoading = true;
      notifyListeners();
      // List<XFile>? files = await _mediaService.pickImageFromGallery(context: context, imageQuality: imageQuality);
      XFile? file = await ImagePicker().pickImage(source: ImageSource.gallery, imageQuality: 50);
      if (file != null) {
        File convertedFile = File(file.path);
        List<File> croppedImage = await Routes.cropPhotoView(imageFile: <File>[convertedFile!]);
        if (croppedImage.isNotEmpty) {
          image = croppedImage.first;
        }
        await uploadProfile(context);
      }
      isLoading = false;
      notifyListeners();
    } on PlatformException catch (e) {
      log(e.toString());
      isLoading = false;
      notifyListeners();
    } catch (e) {
      log(e.toString());
      isLoading = false;
      notifyListeners();
    }
  }

  // by mak => picking image from camera with proper permission handling etc
  Future<void> pickImageFromCamera({required BuildContext context, int imageQuality = 50, bool isUploadAuto = false}) async {
    try {
      notifyListeners();
      // XFile? file = await _mediaService.pickImageFromCamera(context: context, imageQuality: imageQuality);
      XFile? file = await ImagePicker().pickImage(source: ImageSource.camera, imageQuality: 50);
      if (file != null && file.path.isNotEmpty) {
        File convertedFile = File(file.path);
        image = convertedFile;
        List<File> files = await Routes.cropPhotoView(imageFile: <File>[image!]);
        if (files.isNotEmpty) {
          image = files.first;
        }
      }
      if (isUploadAuto) {
        await uploadProfile(context);
      }
      notifyListeners();
    } on PlatformException catch (e) {
      log(e.toString());
      notifyListeners();
    } catch (e) {
      log(e.toString());
      notifyListeners();
    }
  }

//coverPhoto
  Future<bool> imagePickerCover(BuildContext context) async {
    bool isSelected = false;
    try {
      XFile? imagePick = await ImagePicker().pickImage(source: ImageSource.gallery, imageQuality: 50);
      if (imagePick != null) {
        File convertedFile = File(imagePick.path);
        coverimage = convertedFile;
        List<File> croppedImage = await Routes.cropPhotoView(imageFile: <File>[coverimage!]);
        if (croppedImage.isNotEmpty) {
          coverimage = croppedImage.first;
          isSelected = true;
        } else {
          coverimage = null;

          return isSelected;
        }
        await uploadcoverphoto(context);

        // Logging pick image or video analytics event
        AnalyticsController.to.instance.logPickImageVideo(
          pickType: 'image',
          userId: UserModel.to.uId ?? '',
        );

        notifyListeners();
      }
    } on PlatformException {
      MyLoggerServices.to.print('error in image picker');
    } catch (e) {
      MyLoggerServices.to.print('error during image picking');
    }

    return isSelected;
  }

  // }

  Future messagingImage(BuildContext context) async {
    try {
      XFile? imagePick = await ImagePicker().pickImage(source: ImageSource.gallery, imageQuality: 50);
      if (imagePick != null) {
        File convertedFile = File(imagePick.path);
        image = convertedFile;
        List<File> files = await Routes.cropPhotoView(imageFile: <File>[image!]);
        if (files.isNotEmpty) {
          image = files.first;
        }
        await uploadProfile(context);

        // Logging pick image or video analytics event
        AnalyticsController.to.instance.logPickImageVideo(
          pickType: 'image',
          userId: UserModel.to.uId ?? '',
        );
        notifyListeners();
      } else {
        return;
      }
    } on PlatformException catch (e) {
      log(e.toString());
    }
  }

  //upload image in message
  Future<void> uploadMessageImage(BuildContext context) async {
    User user = firebaseAuth.currentUser!;
    UploadTask uploadTask = FirebaseStorage.instance.ref().child('messagesImages').child(const Uuid().v1()).putFile(messageImage!);

    StreamSubscription listenEvent = uploadTask.snapshotEvents.listen((data) {
      percentage = (data.bytesTransferred / data.totalBytes);
      notifyListeners();

      if (data.state == TaskState.success) {
        percentage = null;

        // snackBar(
        //   context,
        //   'Profile image uploaded successfully',
        //   kprimaryColor,
        // );
        notifyListeners();
        log('Our image uploading done');
      }

      log('This is our uploading image task : ${percentage.toString()}');
    });

    TaskSnapshot taskSnapshot = await uploadTask;
    String downloadUrl = await taskSnapshot.ref.getDownloadURL();
    listenEvent.cancel();
    log(downloadUrl);

    //upload the data
    await FirebaseFirestore.instance.collection('users').doc(user.uid).update(({
          'profilePic': downloadUrl,
        }));
  }

  resetFields() {
    coverimage = null;
    notifyListeners();
  }

  //upload the profile image to the firebase storage
  Future<void> uploadProfile(BuildContext context) async {
    UserModel userModel = UserModel.to;
    User user = firebaseAuth.currentUser!;
    UploadTask uploadTask = StoragePaths.userAvatar(user.uid).putFile(image!);
    // FirebaseStorage.instance
    //     .ref()
    //     .child('profilePic')
    //     .child(Uuid().v1())
    //     .putFile(image!);

    StreamSubscription listenEvent = uploadTask.snapshotEvents.listen((data) {
      percentage = (data.bytesTransferred / data.totalBytes);
      notifyListeners();
      if (data.state == TaskState.success) {
        percentage = null;
        snackBar(context, GayaStrings.profile_uploaded_success.tr, kprimaryColor);
        notifyListeners();
        log('Our image uploading done');
      }
      log('This is our uploading image task : ${percentage.toString()}');
    });
    TaskSnapshot taskSnapshot = await uploadTask;
    String downloadUrl = await taskSnapshot.ref.getDownloadURL();
    if (downloadUrl.isNotEmpty) {
      UserModel.to.update(userModel.copyWith(profilePicture: downloadUrl));
    }
    listenEvent.cancel();
    log(downloadUrl);
    //upload the data
    await FirebaseFirestore.instance.collection('users').doc(user.uid).update(({'profilePic': downloadUrl}));
    FirebaseAuth.instance.currentUser!.updatePhotoURL(downloadUrl);
  }

  //upload cover photo
  Future<void> uploadcoverphoto(BuildContext context) async {
    User user = firebaseAuth.currentUser!;
    UploadTask uploadTask = StoragePaths.userCoverPhoto(user.uid).putFile(coverimage!);
    // FirebaseStorage.instance
    //     .ref()
    //     .child('coverphoto')
    //     .child(Uuid().v1())
    //     .putFile(coverimage!);
    StreamSubscription listenEventCover = uploadTask.snapshotEvents.listen((data) {
      coverPercentage = (data.bytesTransferred / data.totalBytes);
      notifyListeners();

      if (data.state == TaskState.success) {
        coverPercentage = null;
        snackBar(context, GayaStrings.cover_img_upload.tr, kprimaryColor);
        notifyListeners();
        log('Our image uploading done');
      }
      log('This is our uploading image task : ${coverPercentage.toString()}');
    });

    TaskSnapshot taskSnapshot = await uploadTask;
    String downloadUrl = await taskSnapshot.ref.getDownloadURL();
    listenEventCover.cancel();
    log(downloadUrl);

    //upload the data
    await FirebaseFirestore.instance.collection('users').doc(user.uid).update(({'coverphoto': downloadUrl}));
    final myUser = UserModel.to;
    myUser.coverPhoto = downloadUrl;
    UserModel.to.update(myUser);
  }

  //get user friendship details
  Future<QuerySnapshot?> getRequests() async {
    FirebaseAuth firebaseInstance = FirebaseAuth.instance;

    User? user = firebaseInstance.currentUser;
    if (user == null) return null;
    snapShotData = await FirebaseFirestore.instance
        .collection('friendship')
        .where('Recieveruid', isEqualTo: user.uid)
        .where('isaccepted', isEqualTo: false)
        .get();
    for (var friends in snapShotData!.docs) {
      log(friends['senderName']);
      log(friends['createdOn'].toString());
    }
    return snapShotData;
  }

  //convert time stamp to date
  convertToDate(var input) {
    Timestamp timestamp = input;
    dateTime = timestamp.toDate();
    dateTime.isAfter(DateTime.now().subtract(const Duration(days: 1))) ? 'Today' : DateFormat.yMd().format(dateTime);
    time = DateFormat.jms().format(dateTime);
  }

//get user details
  Future<DocumentSnapshot?> getuseProfileDetails() async {
    return await service.getUserDetailsServices();
  }

  Future getUserDetails() async {
    User? user = firebaseAuth.currentUser;
    if (user == null) return null;

    userDetails = await FirebaseFirestore.instance.collection('users').doc(user.uid).get();
  }

// update the name and bio
  Future<void> updateUserDetails(BuildContext context, DateTime? dob, String? gender) async {
    try {
      isLoading = true;
      notifyListeners();
      // final batch = FirebaseFirestore.instance.batch();
      final myAppUser = FirebaseAuth.instance.currentUser;
      if (myAppUser == null) return;
      List<Map<String, dynamic>> interestsList = [];
      final topicController = Provider.of<TopicsController>(context, listen: false);
      for (TopicsModel i in topicController.selectedItems) {
        interestsList.add({'icon': i.image, 'title': i.title});
      }
      // done by mak
      UserModel userModel = UserModel.to;
      Map<String, dynamic> updatedData = {};

      if (nameController.text.trim().isNotEmpty) {
        updatedData['name'] = nameController.text;
      }
      if (dob != null) {
        updatedData['dob'] = dob;
      }
      if (gender != null && gender.isNotEmpty) {
        updatedData['gender'] = gender;
      }
      if (image != null) {
        await uploadProfile(context);
        // Logging user profile update event to analytics
        AnalyticsController.to.instance.logUpdateProfile(
          updationType: 'profileImage',
          userId: userModel.uId,
          userName: userModel.name,
          userEmail: userModel.email,
        );
      }
      updatedData['bio'] = bioController.text;
      updatedData['interests'] = interestsList;
      await _firestore.collection('users').doc(myAppUser.uid).set(updatedData, SetOptions(merge: true));
      await myAppUser.updateDisplayName(nameController.text);

      // Logging change name analytics event
      AnalyticsController.to.instance.logChangeName(
        oldName: UserModel.to.name ?? "",
        newName: updatedData['name'],
        type: 'user',
      );

      // Logging analytics event
      if (userModel.bio != bioController.text) {
        // Logging user profile update event to analytics
        AnalyticsController.to.instance.logUpdateProfile(
          updationType: 'bio',
          userId: userModel.uId,
          userName: userModel.name,
          userEmail: userModel.email,
        );
      }

      userModel.copyWith(dob: dob, gender: gender, interests: topicController.selectedItems);
      topicController.selectedItems.clear();
      UserModel.to.update(userModel);
      isLoading = false;
      notifyListeners();

      // Logging user profile update event to analytics
      AnalyticsController.to.instance.logUpdateProfile(
        updationType: 'profile',
        userId: userModel.uId,
        userName: userModel.name,
        userEmail: userModel.email,
      );
      MyLoggerServices.to.print('updated interest :=>> ${UserModel.to.interests}');
    } catch (e) {
      isLoading = false;
      notifyListeners();
      log('exception during user profile updating');
    }
  }

  //get other user details
  Future<DocumentSnapshot?> getOtherUserProfileDetails(String uid) async {
    return service.getOtherUserDetailsServices(uid);
  }

//get my userCommunites count
  Future<int> getMyCommunitiesCount() async {
    return await service.getMyCommunitesCount();
  }

  //get other userCommunites count
  Future<int> getOtherUserCommunityCount(String otherUserUid) async {
    return service.getOtherUserCommunitiesCount(otherUserUid);
  }

  //get other user friends count
  Future<int> getOtherUserFriendsCount(String otherUserUid) async {
    return service.getOtherUserFriendCount(otherUserUid);
  }

  //get the current user friends count
  Future<int> getCurrentUsersFriendCount() async {
    return service.currentUserFriendCount();
  }

//Report the user
//   Future reportUser(String reportedPersonUid, BuildContext context) async {
//     if(FirebaseAuth.instance.currentUser == null) return null;
//
//     final docId = uuid.v1();
//     try {
//       UserReportModel reportModel = UserReportModel(
//           reportedByUid: FirebaseAuth.instance.currentUser!.uid,
//           reportedUserUid: reportedPersonUid);
//       await FirebaseFirestore.instance
//           .collection(userReport)
//           .doc(docId)
//           .set(reportModel.toMap());
//
//       showDialog(
//           context: context,
//           builder: (context) {
//             return ReportDialogue();
//           });
//     } catch (e) {
//       snackBar(context, "Unable to report the post", kRedColor);
//     }
//   }

  Future<bool> checkCurrentUserReportedThatUserAlready(String reportedPersonUid) async {
    try {
      log('this is reported person uid => $reportedPersonUid');
      DocumentSnapshot? snapshot = await FirebaseFirestore.instance.collection(userReport).doc(reportedPersonUid).get();
      // .where("reportedUid", isEqualTo: FirebaseAuth.instance.currentUser!.uid)
      // .where("reportedPersonUid", isEqualTo: reportedPersonUid)
      // .get();
      return snapshot.exists;
    } catch (e) {
      log('exception caught during status of current user reported! this is error=>${e.toString()}');
      return false;
    }
  }

  Future<bool> banUnbanAUser({required String userId, bool isAlreadyBanned = false}) async {
    try {
      if (isAlreadyBanned) {
        await SuperAdminServices.instance.unBanUser(userId: userId);
      } else {
        await SuperAdminServices.instance.banUser(userId: userId);
      }
      return true;
    } catch (e) {
      return false;
    }
  }

  void newMessages() {
    if (FirebaseAuth.instance.currentUser == null || kDebugMode) return;
    String? userUid = FirebaseAuth.instance.currentUser?.uid;
    if (userUid == null) return;
    _chatRoomCollection.where("isReadReceiver", isEqualTo: false).where("userIds", arrayContains: userUid).snapshots().listen((snapshot) {
      if (snapshot.size > 0) {
        // log("Unread Messages Found");
        for (var documentSnapshot in snapshot.docs) {
          if (documentSnapshot.get("lastMesgUserId") != userUid) {
            numberOfUnreadMessages = numberOfUnreadMessages + 1;
            notifyListeners();
            // log("Count of unread messages: $numberOfUnreadMessages");
          }
        }
        if (numberOfUnreadMessages > 0) {
          unreadMessagesAvailable = true;
          numberOfUnreadMessages = 0;
          notifyListeners();
          // log("Count of unread messages set to Zero: $numberOfUnreadMessages");
        } else {
          unreadMessagesAvailable = false;
          notifyListeners();
          // log("Count of unread messages set to Zero: $numberOfUnreadMessages");
        }
      } else {
        // log("No Unread Messages Found");
        unreadMessagesAvailable = false;
        notifyListeners();
      }
    });
  }

  void newNotifications() {
    if (FirebaseAuth.instance.currentUser == null || kDebugMode) return;

    String userUid = FirebaseAuth.instance.currentUser!.uid;
    FirebaseFirestore.instance
        .collection("users")
        .doc(userUid)
        .collection("notifications")
        .where("isRead", isEqualTo: false)
        .snapshots()
        .listen((snapshot) {
      if (snapshot.size > 0) {
        // log("Unread Notifications Found:");
        unReadNotificationsAvailable = true;
        notifyListeners();
      } else {
        // log("No Unread Notifications Found:");
        unReadNotificationsAvailable = false;
        notifyListeners();
      }
    });
  }

  //UNFRIEND THE FRIEND
  Future<QuerySnapshot?> unFriend(String otherUserUid) async {
    try {
      _firestore.collection(friendship).doc(otherUserUid).delete();
      final friendshipDoc = await _firestore
          .collection(friendship)
          .where(
            Filter.and(
              Filter.or(
                Filter('senderUid', isEqualTo: otherUserUid),
                Filter('Recieveruid', isEqualTo: otherUserUid),
              ),
              Filter.or(
                Filter('senderUid', isEqualTo: firebaseAuth.currentUser!.uid),
                Filter('Recieveruid', isEqualTo: firebaseAuth.currentUser!.uid),
              ),
            ),
          )
          .get();

      if (friendshipDoc.size > 0) {
        await friendshipDoc.docs.first.reference.delete();
        // create the friendship
        isRequestSend = false;
      }

      // Logging un friend event to analytics
      AnalyticsController.to.instance.logUnFriend(
        friendUserId: otherUserUid,
        userId: firebaseAuth.currentUser!.uid,
      );
    } catch (e) {
      debugPrint(e.toString());
    }
    return null;
  }

  // create the friendship
  bool isRequestSend = false;

  Future<void> createFriendShip(
    String receiverId,
    String? recieverName,
    String? senderName,
    String? senderProfile,
    String? fcmToken,
  ) async {
    try {
      if (!isRequestSend) {
        isRequestSend = true;
        EngagementScoreController.to.instance.onSendRequest(toUserId: receiverId);
        // notifyListeners();
        User? user = FirebaseAuth.instance.currentUser;
        final participants = [receiverId, user!.uid]..sort();
        final snapshotData = await FirebaseFirestore.instance.collection('friendship').doc(participants.join()).get();
        if (!snapshotData.exists) {
          await FirebaseFirestore.instance.collection('friendship').doc(participants.join()).set({
            'isaccepted': false,
            'senderName': senderName ?? '',
            'senderUid': user.uid,
            'Recieveruid': receiverId,
            'RecieverName': recieverName ?? '',
            'createdOn': DateTime.now(),
            'senderProfile': senderProfile
          });

          // Logging friend request send event to analytics
          AnalyticsController.to.instance.logFriendRequestSend(
            receiverId: receiverId,
            senderId: user.uid,
          );

          // Logging friend request receive event to analytics
          AnalyticsController.to.instance.logFriendRequestReceive(
            receiverId: receiverId,
            senderId: user.uid,
          );

          if (fcmToken != null) {
            FcmUserModel fcmUserModel = FcmUserModel(
              name: senderName ?? 'Gaya User',
              uId: user.uid,
              profilePicture: senderProfile ?? '',
              messageTitle: GayaStrings.friend_request.tr,
              messageContent: "${senderName ?? UserModel.to.name} ${GayaStrings.dash_has_sent_you_friend_request.tr}",
              receiverFcm: fcmToken,
            );

            await NotificationApiHitting().callOnFcmApiForProfileNotifications(fcmUserModel);
          }
          isRequestSend = false;
          notifyListeners();
        }
      }
    } catch (e) {
      isRequestSend = false;
      notifyListeners();
      debugPrint('error thrown during creating friendship');
    }
  }

  // update
  Future<void> updateUserData({required String userId, required Map<String, dynamic> userData}) async {
    try {
      UserModel userModel = UserModel.to;
      final userName = userData['name'];
      final dob = userData['dob'];
      final phoneNumber = userData['phoneNumber'];
      final gender = userData['gender'];

      await authServices.updateUser(userId: userId, updatedData: userData);
      authUser?.updateDisplayName(userName);
      UserModel.to.update(
        userModel.copyWith(
          name: userName,
          dob: dob,
          phoneNumber: phoneNumber,
          gender: gender,
        ),
      );
      debugPrint("user name updated successfully ${UserModel.to.dob}");
    } on FirebaseAuthException catch (error) {
      debugPrint("error thrown during updating name: error code :=> ${error.code} and error message :=>${error.message} ");
    } on FirebaseException catch (error) {
      debugPrint("error thrown during updating name: error code :=> ${error.code} and error message :=>${error.message} ");
    } catch (error) {
      debugPrint("error thrown during updating name: error message :=> ${error.toString()} ");
    }
  }

  /* ---------------- VISIT USER PROFILE (PROFILE WATCH) API'S ---------------- */
  Future<void> addUserProfileViewedCount({
    required String otherUserProfileId,
  }) async {
    // checking whether I already visited the other user profile in past 24 hours
    bool alreadyViewedProfileIn24Hours = _checkAlreadyViewedProfileIn24Hours(otherUserProfileId);

    // if I already viewed profile of other user in past 24 hours do nothing.
    if (alreadyViewedProfileIn24Hours) {
      return;
    }

    DateTime profileViewedTime = DateTime.now();

    // updating other user profile view status locally (GetStorage)
    await _getStorage.box.write(
      'watch_$otherUserProfileId',
      profileViewedTime.millisecondsSinceEpoch,
    );

    // updating other user profile view status remotely (Firestore)
    await _firestore.collection('userProfileWatches').doc().set(
          ProfileWatch(
            userWhoViewedProfileId: FirebaseAuth.instance.currentUser!.uid,
            userWhoseProfileViewedId: otherUserProfileId,
            visitedTime: profileViewedTime,
          ).toMap(),
        );
  }

  /// Invoke to check whether I already visited the other user profile in
  /// past 24 hours
  bool _checkAlreadyViewedProfileIn24Hours(String otherUserProfileId) {
    int? time = _getStorage.box.read<int>('watch_$otherUserProfileId');

    // if time is null I've not visit other user profile in past 24 hours
    if (time == null) {
      return false;
    }

    // dateTime when I viewed other user profile
    DateTime viewedTime = DateTime.fromMillisecondsSinceEpoch(time);
    // dateTime now
    DateTime nowTime = DateTime.now();
    // returning true if viewedTime is in past 24 hours else false.
    return nowTime.difference(viewedTime).inHours < 24;
  }

  String _makeComplimentKey(otherUserId) => 'complimentedUser_${UserModel.to.uId}_$otherUserId';
}

class ComplimentSavedUser {
  final String id;
  final String name;
  final DateTime startTime;

  ComplimentSavedUser({required this.id, required this.name, required this.startTime});

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'name': name,
      'startTime': startTime.toString(),
    };
  }

  static ComplimentSavedUser fromJson(Map<String, dynamic> json) {
    return ComplimentSavedUser(
      id: json['id'],
      name: json['name'],
      startTime: DateTime.parse(json['startTime']),
    );
  }

  static List<ComplimentSavedUser> fromJsonList(String jsonString) {
    final List<dynamic> jsonList = json.decode(jsonString);
    return jsonList.map((json) => fromJson(json)).toList();
  }

  static String toJsonList(List<ComplimentSavedUser> users) {
    return json.encode(users.map((user) => user.toJson()).toList());
  }
}

class ComplimentStrings {
  static String userCollection = 'users';
  static String complimentCollection = 'compliments';
  static String allCompliments = 'all_compliments';

  static String complimentTxt = 'compliment';
  static String senderUId = 'senderUid';
  static String createdOn = 'createdOn';
  static String compliment = 'compliment';
}
