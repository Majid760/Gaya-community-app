// ignore_for_file: use_build_context_synchronously
import 'dart:async';
import 'dart:io';

import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:firebase_storage/firebase_storage.dart';
import 'package:flutter/material.dart';
import 'package:flutter/scheduler.dart';
import 'package:flutter/services.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:gaya/components/button.component.dart';
import 'package:gaya/components/snackbar.component.dart';
import 'package:gaya/controller/app_config_controller.dart';
import 'package:gaya/controller/crowns_controller.dart';
import 'package:gaya/controller/firebase_analytics_controller.dart';
import 'package:gaya/model/community.model.dart';
import 'package:gaya/model/create.post.model.dart';
import 'package:gaya/model/local/crown_payload.dart';
import 'package:gaya/model/postType.model.dart';
import 'package:gaya/model/save.post.model.dart';
import 'package:gaya/routing/getx_route_methods.dart';
import 'package:gaya/shared/service/cache_service/cache_services.dart';
import 'package:gaya/shared/service/crown_service/crown_services.dart';
import 'package:gaya/shared/service/google_vision/safe_search_services.dart';
import 'package:gaya/shared/service/media_service/file_picking_service.dart';
import 'package:gaya/utils/collections.dart';
import 'package:gaya/utils/const.dart';
import 'package:gaya/utils/enum.dart';
import 'package:gaya/utils/language/translation.dart';
import 'package:gaya/utils/logger.dart';
import 'package:gaya/utils/theme/app_spaces.dart';
import 'package:gaya/utils/theme/app_typography.dart';
import 'package:gaya/view/community/controllers/community_feed_controller.dart';
import 'package:gaya/view/create_post/widgets/post_poll_widgets/add_poll_button_widget.dart';
import 'package:gaya/view/create_post/widgets/post_poll_widgets/poll_tile_widget.dart';
import 'package:gaya/view/feed/controller/for_you_controller.dart';
import 'package:gaya/view/feed/controller/post_controller.dart';
import 'package:get/get.dart';
import 'package:image_picker/image_picker.dart';
import 'package:video_player/video_player.dart';

import '../app.dart';
import '../model/communities.memebers.model.dart';
import '../model/user.model.dart';
import '../services/notification/notification_api/notification_api.dart';
import '../services/services.dart';
import '../utils/textstyles.dart';

class CreatePostController extends ChangeNotifier {
  final FirebaseFirestore _firestore = FirebaseFirestore.instance;

//TextEditing controller
  TextEditingController aboutPostController = TextEditingController();
  TextEditingController documentTextField = TextEditingController();
  String? communityAdmin;
  bool postWithVibes = false;
  bool postWithPoll = false;
  Map<String, dynamic> postType = {};

  final MediaService filePickerService = MediaService();

  List communityList = [];
  List onlyVideos = [];
  UserModel userModel = UserModel.to;
  CrownServices crownServices = CrownServices();
  bool switchAnon = false;
  VideoPlayerController? videoPlayerController;
  List<VideoPlayerController> homePostvideoPlayerController = [];

  List<String> multipleImagesDownloadLinks = [];

  String? videoDownloadLink;
  String? pdfDocumentDownloadLink;
  String? pdfDocumentThumbnailDownloadLink;
  bool documentUploadStatus = false;
  String? pdfTitle;
  double? videoUploadingPercentage;
  File? videoFile;
  List<Community> selectedCommunity = [];
  List<String> toalMembers = [];
  int indexe = 0;
  bool isVideoPlaying = false;
  List<File> images = [];
  List<Widget> pollTiles = [];
  List<TextEditingController> pollController = [];

  /// Topics that were chosen  while creating a post
  List<String> preSelectedTopics = [];

  //public or private selection
  communityType type = communityType.Public;

  get getType => type;

  communityType setType(communityType setType) {
    type = setType;
    notifyListeners();
    return type;
  }

  bool isPostWithVibe(bool state) {
    postWithVibes = state;
    if (!state) {
      postType = {};
    }
    notifyListeners();
    return postWithVibes;
  }

  bool isPostWithPoll(bool state) {
    postWithPoll = state;
    notifyListeners();
    return postWithPoll;
  }

  //this method is for to add 2 poll tiles initially.
  addTwoPollTilesInitially() {
    TextEditingController controller1 = TextEditingController();
    pollController.add(controller1);
    pollTiles.add(PostTile(
      controller: controller1,
      hintText: '${GayaStrings.option.tr} 1',
    ));
    TextEditingController controller2 = TextEditingController();
    pollController.add(controller2);
    pollTiles.add(PostTile(
      controller: controller2,
      hintText: '${GayaStrings.option.tr} 2',
    ));
    pollTiles.add(const PollButtonWidget());
  }

  //this method is for to add more poll tiles.
  addPostTileClickOnAddMore() {
    pollTiles.removeLast();
    TextEditingController controller = TextEditingController();
    pollController.add(controller);
    pollTiles.add(PostTile(
      controller: controller,
      hintText: '${GayaStrings.option.tr} ${pollTiles.length + 1}',
    ));
    if (pollTiles.length < 4) {
      pollTiles.add(const PollButtonWidget());
    }
    notifyListeners();
  }

  //this method is for to check that poll title controller is not empty when posting.
  bool isAnyControllerEmpty() {
    return pollController.any((controller) => controller.text.isEmpty);
  }

  //this method is for to create the post with poll.
  postWithPollCreation() {
    final postId = uuid.v1();
    List<Options> optionsList = [];

    for (TextEditingController controller in pollController) {
      Options option = Options(
        id: optionsList.length + 1,
        title: controller.text,
        counts: 0, // You can set the counts value as needed
      );
      optionsList.add(option);
    }
    return PostWithPoll(postType: PostCreationFrom.poll.name, id: postId, question: aboutPostController.text, options: optionsList);
  }

  setPostVibeType(Map<String, dynamic> type) {
    postType = type;
    notifyListeners();
  }

  updateDocumentUploadStatus() {
    documentUploadStatus = true;
    notifyListeners();
  }

  Community? get currentSelectedCommunity => selectedCommunity.firstOrNull;

  @override
  void dispose() {
    videoPlayerController?.dispose();
    for (var controller in homePostvideoPlayerController) {
      controller.dispose();
    }

    for (var controller in pollController) {
      controller.dispose();
    }
    videoUploadingPercentage = null;
    videoDownloadLink = null;

    videoFile = null;
    aboutPostController.clear();

    super.dispose();
  }

  // OnWillPop function to check is pop enable or not
  bool get isOldState =>
      switchAnon == false &&
      videoFile == null &&
      images.isEmpty &&
      aboutPostController.text.isEmpty &&
      selectedCommunity.isEmpty &&
      pdfFiles.isEmpty &&
      pdfThumbnail == null &&
      postWithVibes == false &&
      postType.isEmpty &&
      postWithPoll == false &&
      pollController.isEmpty;

  resetState({bool isPostTypeOnly = false}) {
    if (isPostTypeOnly) {
      postWithPoll = false;
      postType = {};
      postWithVibes = false;
      aboutPostController.clear();
      for (var controller in pollController) {
        controller.clear();
      }
      pollController = [];
      return;
    }
    switchAnon = false;
    aboutPostController.clear();
    for (var controller in pollController) {
      controller.clear();
    }
    pollController = [];
    if (videoPlayerController != null) {
      videoPlayerController = null;
    }
    selectedCommunity = [];
    videoFile = null;
    images = [];
    pdfThumbnail = null;
    pdfFiles = [];
    postWithVibes = false;
    postType = {};
    documentUploadStatus = false;
    postWithPoll = false;
    pollController = [];
    videoDownloadLink = null;
    multipleImagesDownloadLinks = [];
  }

  //Variables
  String? profilePicture;
  String? name;
  List ingredients = [];
  List directions = [];
  String? totalTime;
  String? preparationTime;

  bool isloadingPost = false;
  List<bool> firebaseVideoPlaying = [];
  File? image;
  String? downloadUrl;

  Color color = kBaseGrey;

  List<Community> userCommuniteis = [];

  String? sendCommunityId;

  int currentVideoIndex = 0;

//instance
  Services services = Services();
  final FirebaseAuth _firebaseAuth = FirebaseAuth.instance;

  //recipe screen switcher
  createRecipeEnum view = createRecipeEnum.one;

  get getRecipeView => view;

  createRecipeEnum setRecipeView(createRecipeEnum setView) {
    view = setView;
    notifyListeners();
    return view;
  }

//user details
  Future userDetails() async {
    try {
      await services.getUserDetailsServices();
      UserModel userModel = UserModel.fromSnapshot(services.getUserDetails!);
      profilePicture = userModel.profilePicture;
      name = userModel.name;
    } catch (_) {
      debugPrint("Error in getting user details ${_.toString()}");
    }

    notifyListeners();
  }

//pick image
  Future pickImage(
    BuildContext context,
  ) async {
    try {
      XFile? imagePick = await ImagePicker().pickImage(source: ImageSource.gallery, imageQuality: 50);
      if (imagePick != null) {
        File convertedFile = File(imagePick.path);
        image = convertedFile;

        // Logging pick image or video analytics event
        AnalyticsController.to.instance.logPickImageVideo(
          pickType: 'image',
          userId: UserModel.to.uId ?? '',
        );

        notifyListeners();
      } else {
        return;
      }
    } on PlatformException catch (_) {
      // log(e.toString());
    }
  }

  ///Upload the image to firebase fireStorage - Uploads images to path ['post pictures'],
  ///Before uploading, checking if its violent or not.
  Future<List<String>> uploadPostImage(BuildContext context) async {
    /// Check if the image is violent
    File? violentPicture = await hasAnyViolentImage();

    /// If the image is violent, show a dialog and return
    if (violentPicture != null) {
      if (context.mounted == false) return [];
      showDialog(
        context: context,
        builder: (BuildContext ctx) {
          return AlertDialog(
            title: Center(child: Text(GayaStrings.violent_content.tr, style: GayaTypography.titleSemiBold)),
            content: SingleChildScrollView(
              child: Column(
                mainAxisSize: MainAxisSize.min,
                mainAxisAlignment: MainAxisAlignment.center,
                crossAxisAlignment: CrossAxisAlignment.center,
                children: [
                  Image.file(violentPicture, height: 200, width: 200, fit: BoxFit.cover),
                  SizedBox(height: MySpaces.gap6.r),
                  Text(
                    GayaStrings.violent_content_description.tr,
                    textAlign: TextAlign.center,
                    style: GayaTypography.body2.copyWith(height: 1),
                  ),
                  SizedBox(height: MySpaces.gap6.r),
                  GayaButton(
                    primaryColor: kprimaryColor,
                    title: GayaStrings.continue_txt.tr,
                    textStyle: CustomTypography.body4StyleWhite,
                    borderColor: const Color.fromRGBO(255, 255, 255, 0.0),
                    height: 40.h,
                    width: double.infinity,
                    onPressed: () => Navigator.pop(context),
                  )
                ],
              ),
            ),
          );
        },
      );
      return [];
    }

    try {
      Reference ref;

      for (var images in images) {
        //bool isViolent = await isImageViolent(imageFile);

        ref = FirebaseStorage.instance.ref().child('post pictures').child(uuid.v1());
        await ref.putFile(images).whenComplete(() async {
          await ref.getDownloadURL().then((value) {
            multipleImagesDownloadLinks.add(value);
          });
        });
      }
    } catch (e) {
      // log("Error in uploading images");
    }

    images.clear();

    debugPrint("multiple images are $multipleImagesDownloadLinks");

    return multipleImagesDownloadLinks;
  }

  Future<File?> hasAnyViolentImage() async {
    File? violentImageFile;
    for (var image in images) {
      bool isViolent = await SafeServicesSearch.isImageViolent(image);
      if (isViolent) {
        violentImageFile = image;
        break;
      }
    }

    return violentImageFile;
  }

  String? adminUid;

//checking whether the current users posting in admin or not
  Future<QuerySnapshot?> getAdmin(communityId) async {
    return await FirebaseFirestore.instance
        .collection("communities")
        .doc(communityId)
        .collection("communityMembers")
        .where("isAdmin", isEqualTo: true)
        .get()
        .then((value) {
      if (value.docs.isEmpty) {
        return null;
      }
      CommunityMembership communitiesMemebers = CommunityMembership.fromMap(
        value.docs[0].data(),
      );

      adminUid = communitiesMemebers.userUid.toString();
      notifyListeners();

      return value;
    });
  }

  //UPLOAD THE POST DETAILS TO THE FIREBASE
  Future postInCommunity(BuildContext context, Community communityModel,
      {required PostCreationFrom from, Map<String, dynamic>? mapPostTypeData, PostType? postTypeData}) async {
    User? user = _firebaseAuth.currentUser;
    if (user == null) return;
    isloadingPost = true;
    notifyListeners();

    /// check if author can post directly by checking [isPostApprovalNeeded], [isAdmin], [isModerator]
    final bool isPostApprove = (communityModel.canUserPostDirectly);
    try {
      if (videoFile != null) {
        await uploadVideoToFirebase(context, videoFile);
      } else if (pdfFiles.isNotEmpty) {
        await uploadDocumentToFirebase(context, pdfFiles.first);
        File? file = await generateThumbnailFile(url: pdfFiles.first.path);
        if (file != null) {
          // ignore: use_build_context_synchronously
          await uploadDocumentThumbnailToFirebase(context, file);
        }
      } else if (images.isNotEmpty) {
        final uploadedImages = await uploadPostImage(context);
        if (uploadedImages.isEmpty) {
          isloadingPost = false;
          notifyListeners();
          return;
        }
      }
      List<Map<String, dynamic>> documentFiles = [];
      if (pdfDocumentDownloadLink != null && pdfDocumentThumbnailDownloadLink != null) {
        documentFiles = [];
        documentFiles.add({
          'title': documentTextField.text.isEmpty ? '' : documentTextField.text.trim(),
          'fileUrl': pdfDocumentDownloadLink,
          'fileName': pdfFiles.first.path.split("/").last,
          'thumbnail': pdfDocumentThumbnailDownloadLink
        });
      }
      UserModel userData = UserModel.to;

      final postId = uuid.v1();
      Post postModel = Post(
          postedBy: UserModel.to,
          community: communityModel,
          memberId: user.uid,
          postTopicList: preSelectedTopics,
          multipleImages: [...multipleImagesDownloadLinks],
          postDescription: aboutPostController.text.trim().isEmpty ? '' : aboutPostController.text.trim(),
          totaltime: totalTime ?? '',
          postPicture: downloadUrl ?? '',
          postCreatedOn: DateTime.now(),
          communityId: communityModel.communityId,
          approve: isPostApprove,
          postid: postId,
          isDeleted: false,
          isPostedAnonymously: switchAnon,
          video: videoDownloadLink ?? '',
          pdfFiles: documentFiles,
          postReplyVibeData: mapPostTypeData,
          postTypeData: postTypeData);
      await services.setPostDetails(postModel.toMap(), postModel.postid.toString());
      // logging create post event
      AnalyticsController.to.instance.logCreatePost(
        communityId: communityModel.communityId ?? '',
        userId: user.uid,
        postId: postId,
        withMedia: multipleImagesDownloadLinks.isNotEmpty || downloadUrl != null || videoDownloadLink != null || documentFiles.isNotEmpty,
      );

      UserModel? adminData = await services.getUserById(communityModel.adminUid, forcefullyServer: true);

      // if the current user is not admin then send notification to admin abot approving the new post
      if (!isPostApprove && adminData != null) {
        final fcmcCommunityModel = FcmCreateCommunityModel(
          communityId: communityModel.communityId,
          communityName: communityModel.communityName,
          communityDescription: communityModel.communityDescription ?? '',
          CommunityPic: communityModel.CommunityPic ?? '',
          coverPicture: communityModel.coverPicture ?? '',
          adminUid: communityModel.adminUid ?? '',
          messageContent: GayaStrings.new_post_waiting_for_approval.tr,
          messageTitle: "${GayaStrings.new_post_in_community.tr} ${communityModel.communityName}",
          receiverFcm: adminData.fm_token ?? '',
        );

        await NotificationApiHitting().callOnFcmApiForCommunityNotifications(fcmcCommunityModel);

        await services.addNotification(
            isRead: false,
            communityId: communityModel.communityId,
            body: GayaStrings.new_post_waiting_for_approval.tr,
            receiverUserID: adminData.uId ?? '',
            senderId: userData.uId ?? "",
            title: "${GayaStrings.new_post_in_community.tr} ${communityModel.communityName}",
            time: DateTime.now().toString(),
            type: "communityPostRequest",
            userImage: communityModel.CommunityPic ?? '');
      } else {
        /// post is approved as user is admin
        try {
          debugPrint("sending notification to admin");
          ForYouFeedController postControllerStream = Get.find<ForYouFeedController>();

          if (AppConfigurationController.to.isHiddenCommunityV2(communityId: communityModel.communityId) == false) {
            postControllerStream.addAPostLocally(postModel);
          }
        } catch (_) {}
      }

      EngagementScoreController.to.instance.onPostCreated(communityId: communityModel.communityId ?? "");
      AppConfigurationController.to.updateLastPostCreatedAt(communityId: communityModel.communityId ?? "");
      isloadingPost = false;
      notifyListeners();

      if (adminUid == user.uid || communityModel.isPostApprovalNeeded != true || (communityModel.moderators?.contains(user.uid) ?? false)) {
        SchedulerBinding.instance.addPostFrameCallback((timeStamp) async {
          if (from == PostCreationFrom.Community || from == PostCreationFrom.FeedDetail || from == PostCreationFrom.CommunityCreation) {
            if (CommunityFeedController.isRegistered(tag: communityModel.communityId)) {
              await Future.delayed(400.milliseconds);
              CommunityFeedController.to(tag: communityModel.communityId).resetController(context: context, communityModel: communityModel);
            }
          }
          if (postTypeData?.typeOfPost == PostCreationFrom.postReply) {
            /// pop comment screen
            Navigator.pop(context);
          }

          Navigator.pop(context);
        });
      } else {
        SchedulerBinding.instance.addPostFrameCallback((timeStamp) {
          Routes.postConfirmationView(onSuccessCallback: () {
            if (Get.isRegistered<CommunityFeedController>(tag: communityModel.communityId)) {
              CommunityFeedController.to(tag: communityModel.communityId).resetController(context: context, communityModel: communityModel);

              /// confirmation screen
              Navigator.pop(context);

              /// create post screen
              Navigator.pop(context);
            } else if (from == PostCreationFrom.FeedDetail) {
              /// confirmation screen
              Navigator.pop(context);

              /// create post screen
              Navigator.pop(context);
            } else {
              Routes.groupView(community: communityModel, clearPreviousRoutes: true);
            }
          });
        });
      }

      image = null;
      downloadUrl = '';

      view = createRecipeEnum.one;
      images.clear();
      videoFile = null;

      notifyListeners();

      //morePostAvailable(context, communityModel.communityId!);
    } catch (e) {
      isloadingPost = false;
      notifyListeners();
      // log("Due to this reason , post failed! ${e.toString()}");
      snackBar(context, GayaStrings.post_failed.tr, kprimaryColor);
    } finally {
      switchAnon = false;
      images = [];
      isloadingPost = false;
      pdfDocumentDownloadLink = null;
      pdfDocumentThumbnailDownloadLink = null;
      pdfFiles = [];
      multipleImagesDownloadLinks = [];
    }
  }

  //UPDATE THE NEW POST IN COMMUNITY BY ENABLING THE BOOL
  Future morePostAvailable(BuildContext context, String communityId) async {
    return; // deprecated notification badge
  }

  //like the a post in the community
  Future likePost(
    String postId,
    String communityId,
  ) async {
    // User? user = _firebaseAuth.currentUser;

    // LikePostModel likeModel = LikePostModel(userUid: user!.uid, likeDocID: uuid.v1());
    services.likeOnPost(
      postId,
      communityId,
    );
  }

  //crown a post in save post module

  Future<PostReaction> crownPost(
    String? postId, {
    UserModel? receiverUser,
    required String communityId,
  }) async {
    String currentUserId = FirebaseAuth.instance.currentUser?.uid ?? "";
    PostReaction operationPerformed = PostReaction.idle;
    if (postId == null) return operationPerformed;

    //db operation
    bool isSuccess = await crownAPost(postId, receiverUser?.uId ?? '', currentUserId);

    // Invoke to log crown post event
    AnalyticsController.to.instance.logCrownPost(
      communityId: communityId,
      postId: postId,
      userId: UserModel.to.uId ?? '',
    );

    if (isSuccess) {
      if (receiverUser != null) {
        _commonService.increaseInfluencePointOnCrownReward(receiverUser.uId);
      }
      EngagementScoreController.to.instance.onCrown(postId: postId, communityId: communityId);
      userModel.userDailyCrowns = (userModel.userDailyCrowns != null) ? userModel.userDailyCrowns! - 1 : userModel.userDailyCrowns;
      final CrownsController crownsController = Get.find();

      if (userModel.userDailyCrowns == 0) {
        crownsController.getCrownServerTimeStamp();
      } else {
        crownsController.updateCurrentUser();
      }
    }
    //send notification
    // if (receiverUser != null) sendLikeNotification(postId: postId, user: receiverUser);
    operationPerformed = PostReaction.like;

    notifyListeners();
    if (receiverUser != null) sendCrownNotification(postId: postId, user: receiverUser, communityId: communityId);
    // _updateHomeFeedPost();
    return operationPerformed;
  }

  Future<bool> crownAPost(String postId, String receiverId, String currentUserId) async {
    final payload = CrownPayload(postId: postId, senderId: currentUserId, receiverId: receiverId);

    return await crownServices.crownOnPost(payload: payload);
  }

  final Services _commonService = Services();
  final _notificationApiHitting = NotificationApiHitting();

  Future<void> sendCrownNotification({required String postId, required UserModel user, required String communityId}) async {
    //don't send notification if the user is the same.
    if (userModel.uId == user.uId) return;

    //send fcm notification
    // await _notificationApiHitting.callOnFcmApiSendPushNotifications(gaya_message: postIsLikedNotification, fcmToken: user.fm_token);

    UserModel? userData = await _commonService.getUserById(user.uId, forcefullyServer: true);

    final fcmPostModel = FcmCreatePostModel(
      postid: postId,
      messageContent: "${userModel.name} ${GayaStrings.dash_has_crowned_post.tr}",
      messageTitle: GayaStrings.post_is_crowned_notification.tr,
      receiverFcm: userData?.fm_token ?? '',
      communityId: communityId,
    );

    _notificationApiHitting.callOnFcmApiForPostRelatedNotifications(fcmPostModel
        // gaya_message: "${usermodel.name} sent you a new message.", fcmToken: otherChatParticipantFcmToken
        );

    //store notification
    _commonService.addNotification(
        posId: postId,
        isRead: false,
        body: "${userModel.name} ${GayaStrings.dash_has_crowned_post.tr}",
        receiverUserID: user.uId ?? '',
        senderId: UserModel.to.uId!,
        title: UserModel.to.name ?? "Gaya User",
        time: DateTime.now().toString(),
        type: "postCrowned",
        userImage: UserModel.to.profilePicture ?? "");
  }

  //save the post
  Future savePost(
    String postId,
  ) async {
    User? user = _firebaseAuth.currentUser;
    SavePostModel saveModel = SavePostModel(userUid: user!.uid, saveDocID: uuid.v1());
    services.savePost(postId, saveModel.toMap(), saveModel.saveDocID!);
  }

  get getColor => color;

  checkWhetherSomeThingWritten() {
    if (aboutPostController.text.isEmpty) {
      color = kprimaryColor;
      notifyListeners();
    } else {
      color = kBaseGrey;
      notifyListeners();
    }
  }

  _clearPostTypeToDefault({bool notify = true}) {
    // postType = {};
    // postWithVibes = false;

    resetState(isPostTypeOnly: true);

    if (notify) {
      notifyListeners();
    }
  }

  onChanged(String value) {
    if (value.isEmpty) {
      color = kBaseGrey;

      /// In case if user has written something and then deleted it
      /// then we need to clear the post type to default
      _clearPostTypeToDefault(notify: false);
    } else {
      color = kprimaryColor;
    }

    notifyListeners();
  }

//get all the user communnites
  Future<QuerySnapshot?> getAllUserCommunities() async {
    Community? communites;
    User? user = FirebaseAuth.instance.currentUser;
    QuerySnapshot? userAllCommunities =
        await FirebaseFirestore.instance.collection('users').doc(user!.uid).collection('communities').get().then((snapshot) {
      communityList.clear();
      for (var i in snapshot.docs) {
        communites = Community.fromMap(i.data());

        communityList.add(communites!.communityId);
      }

      if (communityList.isNotEmpty && communityList.length < 10) {
        FirebaseFirestore.instance.collection('communities').where("communityId", whereIn: communityList).get().then((value) {
          // log(value.docs.length.toString());
          userCommuniteis.clear();
          for (var i in value.docs) {
            Community userCommunites = Community.fromMap(i.data());

            userCommuniteis.add(userCommunites);

            notifyListeners();
          }
          return value;
        });
      } else if (communityList.length > 10) {
        for (var community in communityList) {
          FirebaseFirestore.instance.collection('communities').doc(community).get().then((communitySnap) {
            if (communitySnap.exists && communitySnap.data() != null) {
              Community userCommunities = Community.fromMap(communitySnap.data()!);

              userCommuniteis.add(userCommunities);

              notifyListeners();
            }
          });
        }
      }
      // log("Community list is ${communityList}");

      return snapshot;
    });

    return userAllCommunities;
  }

  //toggle the switch button
  toggleSwitch(bool value) {
    switchAnon = value;
    notifyListeners();
  }

  Future<QuerySnapshot?> communityMembers(String communityId) async {
    return FirebaseFirestore.instance
        .collection("communities")
        .doc(communityId)
        .collection("communityMembers")
        .where("morePosts", isEqualTo: true)
        .where("userUid", isEqualTo: FirebaseAuth.instance.currentUser!.uid)
        .get();
  }

  //GET THE COMMUNITY MEMBERS
  Future<QuerySnapshot?> totalCommunityMembers(String communityId) async {
    return await FirebaseFirestore.instance.collection(communities).doc(communityId).collection(communityMembersCollection).get();
  }

  // UPDATE THE SELECTED COMMUNITY
  selectedCommunityUpdate() {
    selectedCommunity;
    notifyListeners();
  }

  //GET THE VIDEO FROM THE GALLERY OF THE IMAGE
  Future getVideo(BuildContext context) async {
    try {
      final XFile? video = await ImagePicker().pickVideo(source: ImageSource.gallery, maxDuration: const Duration(minutes: 1));

      if (video != null) {
        // Logging pick image or video analytics event
        AnalyticsController.to.instance.logPickImageVideo(
          pickType: 'video',
          userId: UserModel.to.uId ?? '',
        );
        File file = File(video.path);
        videoFile = file;
        File? croppedVideo = await Routes.cropVideoView(video: videoFile!);
        if (croppedVideo == null) {
          videoFile = null;
          return;
        }
        videoFile = croppedVideo;
        loadVideoPlayer(videoFile!);
        images.clear();

        // Logging pick image or video analytics event
        AnalyticsController.to.instance.logPickImageVideo(
          pickType: 'video',
          userId: UserModel.to.uId ?? '',
        );

        notifyListeners();
      } else {
        MyLoggerServices.to.print('No video picked');
      }
    } catch (e) {
      debugPrint('error during video picking!');
    }
  }

  List<File> pdfFiles = [];

  //GET THE Document FROM STORAGE
  Future getPdfDocument(BuildContext context) async {
    try {
      documentTextField.clear();
      documentUploadStatus = false;
      pdfFiles = [];
      videoFile = null;
      final File? document = await filePickerService.pickFile(context: context);
      if (document != null) {
        pdfFiles.add(document);
        images.clear();
        notifyListeners();
      } else {
        MyLoggerServices.to.print('No Document picked');
      }
      return document;
    } catch (e) {
      debugPrint('error during document picking!: ${e.toString()}');
      return null;
    }
  }

  Uint8List? pdfThumbnail;

  //
  Future<Uint8List?> generateThumbnail({required String url}) async {
    CacheServices cacheService = CacheServices();
    pdfThumbnail = await cacheService.generateThumbnail(url: url);
    notifyListeners();
    return null;
  }

  Future<File?> generateThumbnailFile({required String url}) async {
    CacheServices cacheService = CacheServices();
    return await cacheService.generateThumbnailFile(url: url);
  }

  Future<void> generateLocalPdfThumbnail({required String url}) async {
    CacheServices cacheService = CacheServices();
    pdfThumbnail = await cacheService.generatelocalPdfThumbnail(url: url);
    notifyListeners();
  }

  //LOAD THE VIDEO PLAYER IN THE UI
  loadVideoPlayer(File file) {
    if (videoPlayerController != null) {
      videoPlayerController!.dispose();
    }
    videoPlayerController = VideoPlayerController.file(file);
    videoPlayerController!.setLooping(true);
    videoPlayerController!.setVolume(2.0);
    videoPlayerController!.initialize().then((value) {
      notifyListeners();
    });
  }

  final CacheServices cacheService = CacheServices();

  Future<String> downloadAndCachePdf({required String url}) async {
    return await cacheService.downloadAndCachePdf(url: url);
  }

// PLAY AND PAUSE THE VIDEO ON THE CLICK
  isPlaying() {
    isVideoPlaying = !isVideoPlaying;
    notifyListeners();
  }

//UPLOAD THE VIDEO TO FIREBASESTORAGE
  uploadVideoToFirebase(BuildContext context, File? file) async {
    try {
      if (file == null) {
        // log("There is no video to upload");
      } else {
        UploadTask uploadTask = FirebaseStorage.instance.ref().child('post videos').child(uuid.v1()).putFile(file);
        StreamSubscription listenEvent = uploadTask.snapshotEvents.listen((data) {
          videoUploadingPercentage = (data.bytesTransferred / data.totalBytes);
          notifyListeners();
          if (data.state == TaskState.success) {
            videoUploadingPercentage = null;
            // log('Our video uploading done');
          }
          // log('This is our uploading video task : ${videoUploadingPercentage.toString()}');
        });
        TaskSnapshot taskSnapshot = await uploadTask;
        videoDownloadLink = await taskSnapshot.ref.getDownloadURL();
        listenEvent.cancel();
        // log(downloadUrl!);
      }
    } catch (e) {
      // log(e.toString());
      snackBar(context, GayaStrings.upload_video_failed.tr, kRedColor);
    }
  }

//UPLOAD THE Document TO FIREBASESTORAGE
  uploadDocumentToFirebase(BuildContext context, File? file) async {
    try {
      if (file == null) {
        // log("There is no video to upload");
      } else {
        UploadTask uploadTask = FirebaseStorage.instance.ref().child('post documents').child(uuid.v1()).putFile(file);
        StreamSubscription listenEvent = uploadTask.snapshotEvents.listen((data) {
          videoUploadingPercentage = (data.bytesTransferred / data.totalBytes);
          notifyListeners();
          if (data.state == TaskState.success) {
            videoUploadingPercentage = null;
            // log('Our video uploading done');
          }
          // log('This is our uploading video task : ${videoUploadingPercentage.toString()}');
        });
        TaskSnapshot taskSnapshot = await uploadTask;
        pdfDocumentDownloadLink = await taskSnapshot.ref.getDownloadURL();
        listenEvent.cancel();
        // log(downloadUrl!);
      }
    } catch (e) {
      // log(e.toString());
      snackBar(context, GayaStrings.upload_video_failed.tr, kRedColor);
    }
  }

//UPLOAD THE Document thumbnail TO FIREBASESTORAGE
  uploadDocumentThumbnailToFirebase(BuildContext context, File? file) async {
    try {
      if (file == null) {
        // log("There is no video to upload");
      } else {
        // File file = File.fromRawPath(path);
        UploadTask uploadTask = FirebaseStorage.instance.ref().child('post documents thumbnails').child(uuid.v1()).putFile(file);
        StreamSubscription listenEvent = uploadTask.snapshotEvents.listen((data) {
          videoUploadingPercentage = (data.bytesTransferred / data.totalBytes);
          // notifyListeners();
          if (data.state == TaskState.success) {
            videoUploadingPercentage = null;
            // log('Our video uploading done');
          }
          // log('This is our uploading video task : ${videoUploadingPercentage.toString()}');
        });
        TaskSnapshot taskSnapshot = await uploadTask;
        pdfDocumentThumbnailDownloadLink = await taskSnapshot.ref.getDownloadURL();
        listenEvent.cancel();
        // log(downloadUrl!);
      }
    } catch (e) {
      // log(e.toString());
      snackBar(context, GayaStrings.upload_video_failed.tr, kRedColor);
    }
  }

//SHOW THE VIDEO IN THE POST
  showVideoInThePost(String videoUrl, index) {
    List<VideoPlayerController> allVideosController = [];
    allVideosController.clear();
    // MyLoggerServices.to.print(onlyVideos.first.toString());
    // MyLoggerServices.to.print(onlyVideos.length.toString() + "this is the length of the videos");
    allVideosController.add(VideoPlayerController.network(videoUrl));
    homePostvideoPlayerController = allVideosController;
    homePostvideoPlayerController[index].setLooping(true);
    homePostvideoPlayerController[index].setVolume(2.0);
    homePostvideoPlayerController[index].addListener(() {});
    homePostvideoPlayerController[index].initialize().then((value) {
      // controller.play();
      // log(allVideosController.toString());
      notifyListeners();
    });
    // for (List<Map<String, dynamic>> i in onlyVideos) {
    //   allVideosController.add(VideoPlayerController.network(i[currentVideoIndex]['video']));
    //
    //   homePostvideoPlayerController = allVideosController;
    //   homePostvideoPlayerController[currentVideoIndex].setLooping(true);
    //   homePostvideoPlayerController[currentVideoIndex].setVolume(2.0);
    //   homePostvideoPlayerController[currentVideoIndex].addListener(() {});
    //
    //   homePostvideoPlayerController[currentVideoIndex].initialize().then((value) {
    //     // controller.play();
    //     log(allVideosController.toString());
    //
    //     notifyListeners();
    //   });
    // }
  }

  //STORE ONLY VIDEOS IN THIS LIST
  storeOnlyVideos(BuildContext context) {
    onlyVideos.clear();
    // onlyVideos.add(
    //     context.read<HomePageController>().postsList.where((element) => (element['video'] != null || element['video'] != '')).toList());
    // log("Here in this list is only videos ${onlyVideos}");
  }

  removeNewPostmediaItem(int index) {
    if (images.isEmpty) return;
    images.removeAt(index);
    notifyListeners();
  }

  removeVideoFromNewPost() {
    if (videoPlayerController != null || videoFile != null) {
      videoFile = null;
      videoPlayerController?.dispose();
      notifyListeners();
    }
  }

  // image cropping section (done by mak)
  Future<void> cropPhoto() async {
    try {
      if (images.isNotEmpty) {
        List<File> croppedImage = await Routes.cropPhotoView(imageFile: images);
        images = [];
        images.addAll(croppedImage);
        notifyListeners();
      }
    } catch (e) {
      debugPrint('error throw during image cropping!');
    }
  }

//update poll count when user click on each of poll tile
  Future<void> updatePollDataInFirestore({required String docId, required PostWithPoll poll, required int pollOptionId}) async {
    try {
      await _firestore.runTransaction((transaction) async {
        DocumentReference postRef = _firestore.collection(CreatePostStrings.collectionName).doc(docId);
        DocumentSnapshot snapshot = await transaction.get(postRef);
        if (snapshot.exists) {
          Map<String, dynamic>? data = snapshot.data() as Map<String, dynamic>?;
          if (data != null) {
            final updatedPoll = poll.toJson();
            transaction.update(postRef, {
              CreatePostStrings.postTypeData: updatedPoll,
            });

            // Add a new collection within the document
            transaction.set(snapshot.reference.collection(CreatePostStrings.subCollectionName).doc(UserModel.to.uId),
                {CreatePostStrings.userId: UserModel.to.uId, CreatePostStrings.pollOptionId: pollOptionId}, SetOptions(merge: true));
          }
        }
      });
    } catch (e) {
      // Handle the error here
      debugPrint('Error updating poll data: $e');
    }
  }
}

///for firestore fields only
class CreatePostStrings {
  static String collectionName = "communityposts";
  static String subCollectionName = "poll";
  static String pollOptionId = "pollOptionId";
  static String userId = "userId";
  static String postTypeData = "postTypeData";
}
