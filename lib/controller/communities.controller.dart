import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:gaya/app.dart';
import 'package:gaya/controller/app_config_controller.dart';
import 'package:gaya/controller/firebase_analytics_controller.dart';
import 'package:gaya/controller/topics.controller.dart';
import 'package:gaya/model/community.model.dart';
import 'package:gaya/model/user.model.dart';
import 'package:gaya/utils/const.dart';
import 'package:gaya/utils/extension.dart';
import 'package:gaya/utils/helpers.functions.dart';
import 'package:gaya/utils/language/translation.dart';
import 'package:get/get.dart';
import 'package:provider/provider.dart';

import '../components/snackbar.component.dart';
import '../model/communities.memebers.model.dart';
import '../services/services.dart';
import '../utils/enum.dart';

class CommunitiesController extends ChangeNotifier {
  //TextEditing controllers
  // final TextEditingController searchController = TextEditingController();
  final TextEditingController communityName = TextEditingController();
  final TextEditingController description = TextEditingController();
  User? user = FirebaseAuth.instance.currentUser;
  List<int> userCommunityPostCount = [];

  bool joinCommunityIsloading = false;
  bool skip = false;
  bool createPostLoader = false;

  bool isReadMore = false;

  bool alreadyRequested = false;

  @override
  void dispose() {
    communityName.dispose();
    description.dispose();
    allUsers = [];
    super.dispose();
  }

  isAlreadyClicked() {
    alreadyRequested = true;
    notifyListeners();
  }

  isNotClicked() {
    alreadyRequested = false;
    notifyListeners();
  }

  // store the topic in the variable the
  String topic = '';

  //current user
  final FirebaseAuth _firebaseAuth = FirebaseAuth.instance;
  Services services = Services();

  //public or private selection
  communityType type = communityType.Public;

  get getType => type;

  communityType setType(communityType setType) {
    type = setType;
    notifyListeners();
    return type;
  }

  List<Community> allCommunties = [];
  List<Community> searchCommunities = [];
  List listOfCommunitiesNames = [];

  List<UserModel> allUsers = [];
  List<UserModel> searchUsers = [];
  String? communityId;

  //create communities page views
  CreateCommunityViewEnum communityViewPage = CreateCommunityViewEnum.CommunityView1;
  get getCommunityViewPage => communityViewPage;
  late ScrollController communitiesScrollController;

  void scrollToTop() {
    try {
      if (communitiesScrollController.hasClients == false) return;
      WidgetsBinding.instance.addPostFrameCallback((_) {
        communitiesScrollController.animateTo(
          communitiesScrollController.position.minScrollExtent,
          duration: const Duration(milliseconds: 350),
          curve: Curves.bounceIn,
        );
      });
    } catch (_) {}
  }

  CreateCommunityViewEnum setCommunityViewPage(CreateCommunityViewEnum setPage) {
    communityViewPage = setPage;
    notifyListeners();
    return setPage;
  }

  String getCommunityTypeString(communityType type) {
    return type.name.toUpperCamelCase();
  }

  //create a community
  Future<Community?> createACommunity(BuildContext context, HelpersFunctions imageUpload, bool loading) async {
    loading = true;
    notifyListeners();
    communityId = uuid.v1();
    final controller = Provider.of<HelpersFunctions>(context, listen: false);
    final topicsController = Provider.of<TopicsController>(context, listen: false);
    User? user = _firebaseAuth.currentUser;
    if (user == null) return null;
    services.getUserDetailsServices();
    try {
      await imageUpload.uploadImage(
          context, imageUpload.imageUploadPercentage, imageUpload.communityImage, imageUpload.communityImageFolderName);
      await imageUpload.uploadCoverImage(
          context, imageUpload.imageUploadPercentageCover, imageUpload.communityCoverImage, imageUpload.communityImageFolderNameCover);
      Community communityModel = Community(
          coverPicture: imageUpload.communityPictureDownloadUrlCover,
          communityId: communityId,
          createdon: DateTime.now(),
          CommunityPic: imageUpload.communityPictureDownloadUrl,
          communityDescription: description.text.trim(),
          communityName: communityName.text.trim(),
          communityMembers: 0,
          communityType: getCommunityTypeString(type),
          communityTopics: {'icon': topicsController.selectedList[0].image, 'topicName': topicsController.selectedList[0].title},
          adminUid: FirebaseAuth.instance.currentUser!.uid);
      CommunityMembership communitiesMembers =
          CommunityMembership(isMember: true, userUid: user.uid, isAdmin: true, createdOn: DateTime.now());

      if (communityName.text.isEmpty ||
          description.text.isEmpty ||
          controller.communityImage == null ||
          controller.communityCoverImage == null ||
          topicsController.selectedList.isEmpty) {
        // ignore: use_build_context_synchronously
        snackBar(context, GayaStrings.fill_all_details.tr, kRedColor);
      } else {
        await FirebaseFirestore.instance.collection('communities').doc(communityModel.communityId).set(
              communityModel.toMap(),
            );

        await FirebaseFirestore.instance
            .collection('communities')
            .doc(communityModel.communityId)
            .collection('communityMembers')
            .doc(communitiesMembers.userUid)
            .set(communitiesMembers.toMap());

        await services.setUserCommunity({
          'communityName': communityModel.communityName,
          'communityId': communityModel.communityId,
        });

        /// add locally to the list
        AppConfigurationController.to.asAdminCommunities.add(communityModel);
        description.clear();
        communityName.clear();
        communityViewPage = CreateCommunityViewEnum.CommunityView1;
        controller.communityImage = null;
        topicsController.selectedList.clear();
        imageUpload.communityPictureDownloadUrl = null;
        imageUpload.communityCoverImage = null;
        return communityModel;
      }
    } catch (error, s) {
      CrashlyticsController.to.instance.recordError(error, stackTrace: s);
      snackBar(context, GayaStrings.something_wrong.tr, kprimaryColor);
    } finally {
      loading = false;
      notifyListeners();
    }
    return null;
  }

  //get the communities of the user
  Stream<QuerySnapshot<Map<String, dynamic>>> getCurrentUserCommunities() async* {
    yield* services.getUserCommunites();
  }

  /// update my communities list to get updated stream
  /// in My Communities Horizontal list view
  void updateMyCommunities() {
    if (AppConfigurationController.to.joinedCommunities.isNotEmpty == true) {
      services.updateMyCommunities(AppConfigurationController.to.joinedCommunities.first.communityId);
    }
  }

  //get quersnapshot communities of user
  Future<QuerySnapshot?> getUserCommunities() async {
    QuerySnapshot? userAllCommunities;
    try {
      userAllCommunities = await FirebaseFirestore.instance.collection('users').doc(UserModel.to.uId).collection('communities').get();
      userAllCommunities.docs.removeWhere((element) {
        final data = element.data() as Map<String, dynamic>;
        return data['isPending'] == true;
      });
    } catch (_) {}
    return userAllCommunities;
  }

  //search all the communities which are public
  Future<QuerySnapshot?> searchAllTheCommunities() async {
    return services.serchTheCommunities();
  }

  //search all the communities which are public
  Future<List<Community>> getJoinedCommunities() async {
    if (user == null) return [];
    return services.getJoinedCommunitiesFromUserCollection();
  }

  //Get all the users
  Future<QuerySnapshot?> allUsersFunc() async {
    QuerySnapshot data = await FirebaseFirestore.instance.collection('users').get();
    return data;
  }

  //Get community members profile the users
  Future getCommunityMembersProfile(String communityId) async {
    try {
      List<UserModel> data = await services.getCommunityMemeberIds(communityId);
      allUsers = [];
      allUsers = data;
      notifyListeners();
    } catch (_) {
      print('error caught during getCommunityMembers=>>> ${_.toString()}}');
    }
    // return data;20
  }

  void resetAllUsersOfCommunity() {
    allUsers = [];
  }

  // OnWillPop function to check is pop enable or not
  bool shouldPop(context) {
    bool isPop = false;
    if (communityName.text.isEmpty &&
        communityViewPage == CreateCommunityViewEnum.CommunityView1 &&
        Provider.of<TopicsController>(context, listen: false).selectedList.isEmpty) {
      isPop = true;
    }
    return isPop;
  }

  // reset all create community variables when discard action performs
  resetState(context) {
    description.clear();
    communityName.clear();
    communityViewPage = CreateCommunityViewEnum.CommunityView1;
    final helperController = Provider.of<HelpersFunctions>(context, listen: false);
    final topicController = Provider.of<TopicsController>(context, listen: false);

    helperController.communityImage = null;
    topicController.selectedList.clear();
    helperController.communityPictureDownloadUrl = null;
    helperController.communityCoverImage = null;
  }

//search the communities
  void searchFeed(String query) {
    // print("query is this $query ${allCommunties.length}");
    if (allCommunties.isEmpty) return;
    final suggestion = allCommunties.where((element) => element.communityType != 'Secret').where((element) {
      final communitiesMemebers = element.communityName?.toLowerCase();
      return communitiesMemebers?.contains(query.toLowerCase()) ?? false;
    }).toList();

    final nameSuggestion = allUsers.where((element) {
      final usersNames = element.name?.toLowerCase();
      return usersNames?.contains(query.toLowerCase()) ?? false;
    }).toList();

    // print("suggestion is this $suggestion");
    // print("nameSuggestion is this $nameSuggestion");
    searchCommunities = suggestion;
    allCommunties.clear();

    searchUsers = nameSuggestion;
    // searchUsers.clear();
    notifyListeners();
  }

  //search user specific  communities
  // user specific communities
  List<Community> userSpecificCommunties = [];
  List<Community> userSpecificSearchedCommunities = [];

  void userSpecificCommunitiesSearch(String query) {
    if (userSpecificCommunties.isEmpty) return;
    final suggestion = userSpecificCommunties.where((element) => element.communityType != 'Secret').where((element) {
      final communities = element.communityName?.toLowerCase();
      return communities?.contains(query.toLowerCase()) ?? false;
    }).toList();

    userSpecificSearchedCommunities = suggestion;
    userSpecificCommunties.clear();
    notifyListeners();
  }

//search community members
  searchMembers(String query) {
    final nameSuggestion = allUsers.where((user) {
      final usersName = user.name?.toLowerCase();
      return usersName?.contains(query.toLowerCase()) ?? false;
    }).toList();
    searchUsers = nameSuggestion;
    notifyListeners();
  }

  //get user details
  Future<DocumentSnapshot?> userDetailsfunc() async {
    return services.getUserDetailsServices();
  }

  //get the communnities details
  Future<DocumentSnapshot?> communityDetails(String? communityId) async {
    return services.getCommunitiesDetails(communityId);
  }

  //to show all the interest communities in the see all
  Future<QuerySnapshot?> getInterestSeeAll(String categoryName) async {
    QuerySnapshot data = await FirebaseFirestore.instance
        .collection('communities')
        .where('topics.${'topicName'}', isEqualTo: categoryName)
        // .where('type', isEqualTo: 'Public')
        .get();
    return data;
  }

  // CHECK THE IF ONE THE COMMUNITY HAS MORE POST IN WHICH THE CURRENT USER JOINED
  // List notiifcationList = [];
//[Depricated for expensive reads]
/*  Future<void> checkForCommunityBatch() async {
    if (_firebaseAuth.currentUser == null) return null;
    AppConfigurationController.to.joinedCommunities.forEach((community) async {
      final totalMorePosts = await FirebaseFirestore.instance
          .collection("communities")
          .doc(community.communityId)
          .collection('communityMembers')
          .where('userUid', isEqualTo: _firebaseAuth.currentUser!.uid)
          .where('morePosts', isEqualTo: true)
          .count()
          .get();
      if (totalMorePosts.count > 0) {
        notiifcationList.add(totalMorePosts.count);
      }
    });
    notiifcationList.clear();

    // return FirebaseFirestore.instance.collection("communities").get().then((event) {
    //   event.docs.forEach((snapshot) {
    //     if (_firebaseAuth.currentUser != null) {
    //       FirebaseFirestore.instance
    //           .collection("communities")
    //           .doc(snapshot.id)
    //           .collection('communityMembers')
    //           .where('userUid', isEqualTo: _firebaseAuth.currentUser!.uid)
    //           .where('morePosts', isEqualTo: true)
    //           .get()
    //           .then((event) {
    //         print(event.docs.length.toString() + "length");
    //         notiifcationList.add(event.docs.length);
    //         return event;
    //       });
    //
    //       // log(notiifcationList.toString());
    //     }
    //   });
    //   notiifcationList.clear();
    //   return event;
    // });
  }*/

  //GET ALL THE COMMUNITIES CATEGORIES AND SHOW ALL COMMUNITIES IN THE CATEGORIES
  Future<QuerySnapshot?> allCommunitiesCategories(String interestName) async {
    return await FirebaseFirestore.instance.collection('communities').where('topics.${'topicName'}', isEqualTo: interestName).get();
  }
}
