// ignore_for_file: use_build_context_synchronously
import 'dart:developer';
import 'dart:io';

import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:easy_refresh/easy_refresh.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:gaya/components/snackbar.component.dart';
import 'package:gaya/controller/app_config_controller.dart';
import 'package:gaya/controller/firebase_analytics_controller.dart';
import 'package:gaya/model/community.model.dart';
import 'package:gaya/model/user.model.dart';
import 'package:gaya/routing/getx_route_methods.dart';
import 'package:gaya/services/media_cropping/service/image_cropping_service.dart';
import 'package:gaya/services/services.dart';
import 'package:gaya/shared/service/media_service/file_picking_service.dart';
import 'package:gaya/shared/service/search_service/search_service.dart';
import 'package:gaya/shared/view/widget/gaya_snackbar.dart';
import 'package:gaya/utils/const.dart';
import 'package:gaya/utils/helpers.functions.dart';
import 'package:gaya/utils/language/translation.dart';
import 'package:gaya/utils/logger.dart';
import 'package:gaya/view/community/controllers/base_controller.dart';
import 'package:gaya/view/community/controllers/community_feed_controller.dart';
import 'package:gaya/view/community/controllers/community_profile_controller.dart';
import 'package:gaya/view/community/services/community_members_services.dart';
import 'package:get/get.dart';
import 'package:get/get_rx/src/rx_workers/utils/debouncer.dart';
import 'package:image_picker/image_picker.dart';
import 'package:provider/provider.dart';

enum PhotoType { profile, cover }

class EditCommunityController extends BaseController {
  Community? community;

  EditCommunityController({this.community});

  static EditCommunityController to({required String? tag}) => Get.find(tag: tag);

  static bool isRegistered(String? tag) => Get.isRegistered<EditCommunityController>(tag: tag);
  late Services services;
  late MediaService _mediaService;

  UserModel userModel = UserModel.to;
  final FirebaseAuth _firebaseAuth = FirebaseAuth.instance;
  Community? createCommunityModel;
  List<String> topics = [];

  // Services services = Services();
  ImageServices imageService = ImageServices();
  List<UserModel> communityUsers = [];
  List<UserModel> dummyCommunityModerators = [];
  List<UserModel> communityModerators = [];
  TextEditingController searchFieldController = TextEditingController();
  XFile? coverPhoto;
  XFile? profilePhoto;
  @override
  bool isLoading = false;
  bool isUploadingModerator = false;
  bool isImageLoading = false;
  bool isSavedPressed = false;

  @override
  onInit() {
    super.onInit();
    services = Services();
    _mediaService = MediaService();

    if (community != null) {
      fetchCommunityProfile(community!, isFirstTime: true);
    }
  }

  @override
  void onClose() {
    resetState();
    super.onClose();
  }

  // void fetchCommunityProfile() async {
  //   setLoading(true);
  //   // final communityProfile = await _commonService.getCommunityDetailsModel(communityId);
  //   if (communityProfile != null) {
  //     communityModel = communityProfile;
  //   }
  //   setLoading(false);
  // setLoading(false, notify: false);
  // }

////////////////////////////////// Old Editing Provider Code ///////////////////////////////

  /// togle the isSavedPressed value
  void setIsSavedPressed(bool value) {
    isSavedPressed = value;
  }

  // Community members for paginated form community members
  bool isFirstTime = false;
  List<UserModel> _paginatedCommunityMembers = [];
  CommunityMembersServices? _communityMembersServices;
  EasyRefreshController refreshController = EasyRefreshController();

  bool get isMembersEmpty => _paginatedCommunityMembers.isEmpty;

  Community? get communityModel => createCommunityModel;

  List<UserModel> searchedUsers = [];
  final Debouncer _debouncer = Debouncer(delay: 1000.milliseconds);

  List<UserModel> getMembers() => _paginatedCommunityMembers;

  bool isModeratorExists(UserModel user) => dummyCommunityModerators.isEmpty || !dummyCommunityModerators.contains(user);

  bool isPosterModerator(UserModel user) =>
      dummyCommunityModerators.isNotEmpty && dummyCommunityModerators.contains(user) ||
      createCommunityModel?.moderators?.contains(user.uId ?? "") == true;

  Future<void> requestMoreData({bool fromInit = false}) async {
    if (createCommunityModel?.communityId == null) return;
    // _communityMembersServices = CommunityMembersServices(communityId: createCommunityModel?.communityId ?? '');
    // to avoid double loading at top andbottom on screen
    if (fromInit == false) refreshController.callLoad();

    MyLoggerServices.to.print(" requestMoreData called");
    if (fromInit) {
      isLoading = true;
      // update();
    }
    isFirstTime = true;
    final newPosts = await _communityMembersServices!.requestMoreData();
    MyLoggerServices.to.print("newMembers.length ${newPosts.length}");
    _paginatedCommunityMembers.addAll(newPosts);
    isLoading = false;
    update();
  }

  initializeCommunityMembersServices() {
    _communityMembersServices = CommunityMembersServices(communityId: createCommunityModel?.communityId ?? '');
  }

  // A dispose method.
  void resetController({bool isDisposing = false}) async {
    _paginatedCommunityMembers = [];
    isFirstTime = false;
    isLoading = false;
    searchFieldController.clear();
    if (_communityMembersServices != null) {
      _communityMembersServices?.reset();
    }
    if (isDisposing) {
      WidgetsBinding.instance.addPostFrameCallback((_) {
        update();
      });
    } else {
      await requestMoreData(
        fromInit: true,
      );
    }
    _debouncer.cancel();
  }

  void setCreateCommunityModel(Community communityModel, {bool isFirstTime = false}) async {
    try {
      createCommunityModel = communityModel;
      topics = [];
      topics.addAll(createCommunityModel?.communityTopicList?.map((e) => e).toList() ?? []);
      // update();
      if (isFirstTime) {
        await getCommunityMembersProfile();
      } else {
        isLoading = false;
        update();
      }
    } catch (_) {}
  }

  void fetchCommunityProfile(Community communityModel, {bool isFirstTime = false}) async {
    try {
      final communityDetail = await services.getCommunitiesDetails(communityModel.communityId);
      if (communityDetail?.data() != null) {
        isLoading = true;
        update();
        Community commModel = Community.fromMap(communityDetail?.data() as Map<String, dynamic>);
        topics = [];
        setCreateCommunityModel(commModel, isFirstTime: isFirstTime);
      }

      isLoading = false;
      update();
    } catch (_) {
      isLoading = false;
    }
  }

  // pick the photo from gallery
  Future<void> pickImageFromGallery({required BuildContext context, int imageQuality = 50, required PhotoType photoType}) async {
    try {
      isImageLoading = true;
      update();
      List<XFile>? files = await _mediaService.pickImageFromGallery(context: context, imageQuality: imageQuality);
      if (files != null && files.isNotEmpty) {
        // Logging pick image or video analytics event
        AnalyticsController.to.instance.logPickImageVideo(
          pickType: 'image',
          userId: UserModel.to.uId ?? '',
        );
        if (photoType == PhotoType.cover) {
          coverPhoto = files.last;
          if (coverPhoto != null) {
            List<File> files = await Routes.cropPhotoView(imageFile: <File>[File(coverPhoto!.path)]);
            if (files.isNotEmpty) {
              coverPhoto = XFile(files.first.path);
            }
          }
        } else if (photoType == PhotoType.profile) {
          profilePhoto = files.last;
          if (profilePhoto != null) {
            List<File> files = await Routes.cropPhotoView(imageFile: <File>[File(profilePhoto!.path)]);
            if (files.isNotEmpty) {
              profilePhoto = XFile(files.first.path);
            }
          }
        } else {}
      }
      MyLoggerServices.to.print(coverPhoto!.path);
      isImageLoading = false;
      update();
    } on PlatformException catch (e) {
      log(e.toString());
      isImageLoading = false;
      update();
    } catch (e) {
      log(e.toString());
      isImageLoading = false;
      update();
    }
  }

  // to check that user has changed the desc,profile, or cover phot
  bool isUserDataChanged({
    required String description,
    required String name,
    required String selectedThemeColor,
    required String communityType,
  }) {
    try {
      return (profilePhoto != null ||
          coverPhoto != null ||
          description != createCommunityModel?.communityDescription ||
          name != createCommunityModel?.communityName ||
          isCommunityThemeColorChanged(selectedThemeColor) ||
          communityType != createCommunityModel?.communityType);
    } catch (e) {
      return false;
    }
  }

  bool isCommunityThemeColorChanged(String color) => color != (createCommunityModel?.communityThemeModel?.color ?? 'FFD28AFF');

  // discard the changes
  void discardChanges() {
    try {
      profilePhoto = null;
      coverPhoto = null;
      update();
    } catch (e) {
      log('error during discard changes!${e.toString()}');
    }
  }

  // update the communities
  Future<void> updateCommunity(
    BuildContext context, {
    required Community community,
    required String description,
    required String name,
    required String selectedThemeColor,
    required String communityType,
  }) async {
    try {
      isSavedPressed = false;
      isLoading = true;
      update();

      final helperController = Provider.of<HelpersFunctions>(context, listen: false);
      User? user = _firebaseAuth.currentUser;
      if (user == null) return;
      String? communityPhoto;
      String? communityCoverPhoto;
      if (profilePhoto != null) {
        await helperController.uploadImage(
            context, helperController.imageUploadPercentage, File(profilePhoto!.path), helperController.communityImageFolderName);
        communityPhoto = helperController.communityPictureDownloadUrl;
      }
      if (coverPhoto != null) {
        await helperController.uploadCoverImage(
            context, helperController.imageUploadPercentageCover, File(coverPhoto!.path), helperController.communityImageFolderNameCover);
        communityCoverPhoto = helperController.communityPictureDownloadUrlCover;
      }
      if (createCommunityModel != null) {
        if (createCommunityModel?.communityName != name) {
          // Logging change name analytics event
          AnalyticsController.to.instance.logChangeName(
            oldName: createCommunityModel?.communityName ?? "",
            newName: name,
            type: 'community',
          );
        }

        final updatedCommunity = community.copyWith(
          communityDescription: description,
          communityName: name,
          CommunityPic: communityPhoto,
          coverPicture: communityCoverPhoto,
          communityThemeModel: community.communityThemeModel?.copyWith(color: selectedThemeColor),
          communityType: communityType,
        );
        // createCommunityModel!.CommunityPic = communityPhoto ?? createCommunityModel?.CommunityPic ?? '';
        // createCommunityModel!.coverPicture = communityCoverPhoto ?? createCommunityModel!.coverPicture ?? '';
        // createCommunityModel!.communityThemeModel = CommunityThemeModel(color: selectedThemeColor, isThemeSelected: true);
        // createCommunityModel!.communityDescription =
        //     description.isBlank == true ? createCommunityModel?.communityDescription ?? "" : description;
        // createCommunityModel!.communityName = name.isBlank == true ? createCommunityModel?.communityName ?? "" : name;
        // createCommunityModel!.communityType =
        //     communityType.isBlank == true ? createCommunityModel?.communityType ?? "Public" : communityType;

        debugPrint("New Fields: ${updatedCommunity.toUpdateFirestore()}");
        await FirebaseFirestore.instance
            .collection('communities')
            .doc(updatedCommunity.communityId)
            .set(updatedCommunity.toUpdateFirestore(), SetOptions(merge: true));
        coverPhoto = null;
        profilePhoto = null;
        createCommunityModel = updatedCommunity;
      }
      isLoading = false;
      isSavedPressed = true;
      update();

      updateGroupViewCommunity(community: createCommunityModel);
      snackBar(context, GayaStrings.community_updated_successfully.tr, kprimaryColor);
    } catch (e) {
      MyLoggerServices.to.print('something went woring during updating community error => ${e.toString()}');
    }
  }

  /// updates group.view object.
  void updateGroupViewCommunity({required Community? community}) {
    CommunityProfileController.to(tag: community?.communityId ?? "").updateGroupViewCommunity(community: community);
  }

  addNewCommunityTopic(context, {String topic = ''}) {
    if (createCommunityModel == null || createCommunityModel?.communityTopicList == null) return;
    if (topics.contains(topic) == false && topic.trim().isNotEmpty) {
      topics.add(topic);
    }
    update();
  }

  deleteCommunityTopic(int index) {
    if (createCommunityModel == null || createCommunityModel?.communityTopicList == null) return;
    topics.removeAt(index);
    update();
  }

  // update the community topics
  Future<void> updateCommunityTopics(BuildContext context) async {
    try {
      if (listEquals(createCommunityModel?.communityTopicList, topics)) return;
      createCommunityModel?.communityTopicList = [];
      createCommunityModel?.communityTopicList?.addAll(topics);
      isLoading = true;
      update();
      User? user = _firebaseAuth.currentUser;
      if (user == null) return;
      if (createCommunityModel != null) {
        await FirebaseFirestore.instance.collection('communities').doc(createCommunityModel!.communityId).update({
          'communityTopicList': createCommunityModel?.communityTopicList ?? [],
        });
      }
      isLoading = false;
      CommunityFeedController.to(tag: createCommunityModel?.communityId).setCommunityModel(createCommunityModel);
      update();

      snackBar(context, GayaStrings.community_topics_updated_successfully.tr, kprimaryColor);
    } catch (e) {
      isLoading = false;
      update();
      MyLoggerServices.to.print('something went woring during updating community topics error => ${e.toString()}');
    }
  }

  // reset tcommunity topics
  Future<void> resetCommunityTopics() async {
    topics = [];
    topics.addAll(createCommunityModel?.communityTopicList?.map((e) => e).toList() ?? []);
    update();
  }

  // check topics list equality incase of discard changes while creating new topics
  Future<bool> areTopicListsEquals() async {
    if (listEquals(createCommunityModel?.communityTopicList, topics)) return true;
    return false;
  }

  /// converts List<String?> to  List<String>
  List<String> convertNullableStringList({required List<String?> list}) {
    List<String> newList = [];
    for (var element in list) {
      if (element != null) {
        newList.add(element);
      }
    }
    return newList;
  }

  resetState() {
    createCommunityModel = null;
    topics = [];
    community = null;
    debugPrint('resetting the state of the community provider');
  }

  //get the count of the members in the  community
  Future getCommunityMembersProfile() async {
    try {
      if (createCommunityModel?.communityId == null) return;

      final allMembersAndModerators = await services.getCommunityModerators(createCommunityModel!);
      List<UserModel> allUsers = allMembersAndModerators["allMembers"] ?? [];
      List<UserModel> allModerators = [];
      for (var user in allUsers) {
        if (createCommunityModel?.moderators?.contains(user.uId) ?? false) {
          allModerators.add(user);
        }
      }

      if (allMembersAndModerators.isEmpty) {
        communityUsers = [];
        communityModerators = [];
        dummyCommunityModerators = [];
      } else {
        communityUsers = [];
        communityModerators = [];
        dummyCommunityModerators = [];
        communityUsers.addAll(allUsers);
        communityModerators.addAll(allModerators);
        dummyCommunityModerators.addAll(allModerators);
      }
      isLoading = false;

      update();
    } catch (_) {
      isLoading = false;
      update();
    }
  }

  //search the communities
  // searchFeed(String query) {
  //   _debouncer.call(() {
  //     searchedUsers = [];
  //     if (communityUsers.isEmpty) return;
  //     final suggestion = communityUsers.where((element) {
  //       final userName = element.name?.toLowerCase();
  //       return userName?.contains(query.toLowerCase()) ?? false;
  //     }).toList();
  //     searchedUsers = suggestion;
  //     update();
  //   });
  // }
  //search the communities

  // algolia searched users
  AlgoliaService algoliaService = AlgoliaService();

  searchFeed(String query) {
    try {
      _debouncer.call(() async {
        searchedUsers = [];
        if (query.trim().isEmpty) {
          isLoading = false;
          update();
          return;
        }
        isLoading = true;
        update();
        if (communityUsers.isEmpty) return;
        searchedUsers = await algoliaService.getsAllUsers(query);
        isLoading = false;
        update();
      });
    } catch (_) {}
    isLoading = false;
    update();
  }

  // add/remove moderator in the community
  addRemoveCommumityModerator(context, UserModel userModel, bool value) {
    if (createCommunityModel == null || communityUsers == []) return;
    if (value == true) {
      dummyCommunityModerators.add(userModel);
      // createCommunityModel?.moderators?.add(userModel.uId!);
    } else {
      dummyCommunityModerators.remove(userModel);
    }
    update();
  }

  // update the community moderators in db
  Future updateCommunityModerators(BuildContext context) async {
    if (listEquals(createCommunityModel?.moderators, dummyCommunityModerators)) return;
    try {
      if (createCommunityModel == null || dummyCommunityModerators.isEmpty) return;
      bool isExist = await checkIfSearchedUsersExistsInCommunityMembers();
      if (!isExist) {
        snackBar(context, GayaStrings.user_not_a_member_of_community.tr, kprimaryColor);
        return;
      }
      isUploadingModerator = true;
      update();
      // createCommunityModel?.moderators = [];
      for (var moderator in dummyCommunityModerators) {
        if (moderator.uId != null) {
          await FirebaseFirestore.instance.collection('communities').doc(createCommunityModel!.communityId).set({
            "moderators": FieldValue.arrayUnion([moderator.uId!])
          }, SetOptions(merge: true));
          if (createCommunityModel?.moderators != null && !createCommunityModel!.moderators!.contains(moderator.uId!)) {
            createCommunityModel?.moderators?.add(moderator.uId!);
          }

          ///Add locally to controller.
          AppConfigurationController.to.asModeratorCommunities.add(Community(communityId: createCommunityModel!.communityId!));
        }
      }
      isUploadingModerator = false;
      update();
      // to update community feeds with moderator tag
      final CommunityFeedController communityFeedController = CommunityFeedController.to(tag: createCommunityModel?.communityId);
      communityFeedController.update();

      // ignore: use_build_context_synchronously
      snackBar(context, GayaStrings.community_moderators_updated_successfully.tr, kprimaryColor);
    } on SocketException {
      isUploadingModerator = false;
      update();
      snackBar(context, GayaStrings.check_internet_connection.tr, Colors.red);
    } catch (e) {
      isUploadingModerator = false;
      update();
    }
  }

  //checkIfSearchedUsersExistsInCommunityMembers
  Future<bool> checkIfSearchedUsersExistsInCommunityMembers() async {
    try {
      List<String> userIds = [];
      for (var moderator in dummyCommunityModerators) {
        if (moderator.uId != null) {
          userIds.add(moderator.uId ?? '123');
        }
      }
      if (userIds.isEmpty) {
        return false;
      }
      if (userIds.length > 9) {
        userIds.removeRange(9, userIds.length);
      }
      final communityMembers = await FirebaseFirestore.instance
          .collection('communities')
          .doc(createCommunityModel!.communityId)
          .collection('communityMembers')
          .where("userUid", whereIn: userIds)
          .get();
      if (communityMembers.docs.length == userIds.length) {
        return true;
      } else {
        return false;
      }
    } catch (_) {}
    return false;
  }

  // delete the community moderators in db
  Future deleteCommunityModeratorsInDb(BuildContext context, UserModel userModel) async {
    try {
      if (createCommunityModel == null || userModel.uId == null) return;
      isUploadingModerator = true;
      update();
      await FirebaseFirestore.instance.collection('communities').doc(createCommunityModel!.communityId).set({
        "moderators": FieldValue.arrayRemove([userModel.uId!])
      }, SetOptions(merge: true));

      ///Remove locally to controller.
      AppConfigurationController.to.asModeratorCommunities
          .removeWhere((community) => community.communityId == createCommunityModel!.communityId);
      if (dummyCommunityModerators.contains(userModel)) {
        dummyCommunityModerators.remove(userModel);
        communityModerators.remove(userModel);
        createCommunityModel?.moderators?.remove(userModel.uId);
      }
      isUploadingModerator = false;
      update();
      // to update community feeds with moderator tag
      final CommunityFeedController communityFeedController = CommunityFeedController.to(tag: createCommunityModel?.communityId);
      communityFeedController.update();
      snackBar(context, GayaStrings.community_moderators_updated_successfully.tr, kprimaryColor);
    } on SocketException {
      isUploadingModerator = false;
      update();
      snackBar(context, GayaStrings.check_internet_connection.tr, Colors.red);
    } catch (e) {
      isUploadingModerator = false;
      update();
      MyLoggerServices.to.print('something went woring during updating community moderators error => ${e.toString()}');
    }
  }

  handleError() {
    isUploadingModerator = false;
    update();
  }

  Future<void> _updateCommunityFeedView() async {
    CommunityProfileController.to(tag: createCommunityModel?.communityId).reloadCommunityProfile();
  }

  // update the community moderators tag data
  Future<void> updateModeratorsTagData(context, String tagColor, {String moderatorTag = 'Moderator'}) async {
    if (createCommunityModel == null) return;
    try {
      isLoading = true;
      update();
      Map<String, dynamic>? moderatorTagData = {
        'moderatorTag': moderatorTag,
        'tagColor': tagColor,
      };
      createCommunityModel?.moderatorTagData = moderatorTagData;
      User? user = _firebaseAuth.currentUser;
      if (user == null) return;
      if (createCommunityModel != null) {
        await services.updateModeratorsTagData(createCommunityModel?.communityId ?? '', moderatorTagData);
        GayaSnackBar.show(context: context, type: GayaSnackBarType.success, text: GayaStrings.community_updated_successfully.tr);
      }
      isLoading = false;
      update();
    } catch (e) {
      isLoading = false;
      update();
      MyLoggerServices.to.print('something went woring during updating community topics error => ${e.toString()}');
    }
  }

  // clearing moderators data
  clearModeratorsData() {
    communityUsers = [];
    dummyCommunityModerators = [];
    communityModerators = [];
    isLoading = false;
  }

////////////////////////////////// End Editing Provider Code///////////////////////////////
}
