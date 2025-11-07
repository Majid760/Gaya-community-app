import 'package:firebase_phone_auth_handler/firebase_phone_auth_handler.dart';
import 'package:flutter/material.dart';
import 'package:gaya/app.dart';
import 'package:gaya/components/snackbar.component.dart';
import 'package:gaya/controller/topics.controller.dart';
import 'package:gaya/model/communities.memebers.model.dart';
import 'package:gaya/model/community.model.dart';
import 'package:gaya/services/services.dart';
import 'package:gaya/utils/const.dart';
import 'package:gaya/utils/enum.dart';
import 'package:gaya/utils/helpers.functions.dart';
import 'package:gaya/utils/language/translation.dart';
import 'package:gaya/utils/strings.dart';
import 'package:gaya/view/community/create_community/controllers/community_questionnaire_controller.dart';
import 'package:gaya/view/community/create_community/models/community_theme_model.dart';
import 'package:gaya/view/community/create_community/services/create_community_services.dart';
import 'package:get/get.dart';
import 'package:provider/provider.dart';

import '../../../../controller/firebase_analytics_controller.dart';
import '../../../../model/user.model.dart';

class CreateCommunityController extends GetxController {
  static CreateCommunityController get to => Get.find();

  String? communityId;
  communityType type = communityType.Public;

  get getType => type;

  communityType setType(communityType setType) {
    type = setType;
    update();
    return type;
  }

  @override
  void onInit() {
    super.onInit();

    communityThemeModel = CommunityThemeModel(isThemeSelected: true, color: moderatortagColors[13]);
  }

  bool isCustomThemeSelected = true;
  CommunityThemeModel? communityThemeModel;

  CreateCommunityViewEnum communityViewPage = CreateCommunityViewEnum.CommunityView1;
  final TextEditingController communityName = TextEditingController();
  final TextEditingController description = TextEditingController();
  final FirebaseAuth _firebaseAuth = FirebaseAuth.instance;
  Services services = Services();
  bool skip = false;
  bool createPostLoader = false;

  bool isPostApprovalNeeded = false;
  bool isQuestionnaire = false;
  final CreateCommunityServices _createCommunityServices = CreateCommunityServices();

  get getCommunityViewPage => communityViewPage;

  // change theme boolean while creating new community
  toggleCommunityTheme() {
    isCustomThemeSelected = !isCustomThemeSelected;
    update();
  }

  // setPostApprovalStatus
  setPostApprovalStatus(bool status) {
    isPostApprovalNeeded = status;
    update();
  }

  ///setQuestionnaireStatus
  setQuestionnaireStatus(bool status) {
    isQuestionnaire = status;
    if (!isQuestionnaire) {
      QuestionnaireController.to.clear();
    }
    update();
  }

  // setCommunityThemeModel
  setCommunityThemeModel(String themecolor) {
    communityThemeModel = CommunityThemeModel(isThemeSelected: true, color: themecolor);

    // Logging special feature usage analytics event
    AnalyticsController.to.instance.logSpecialFeatureUsage(
      userId: UserModel.to.uId ?? '',
      featureName: 'community_theme',
    );

    update();
  }

  // set setCommunityViewPage
  CreateCommunityViewEnum setCommunityViewPage(CreateCommunityViewEnum setPage) {
    communityViewPage = setPage;
    update();
    return setPage;
  }

  //create a community
  Future<Community?> createACommunity(BuildContext context, HelpersFunctions imageUpload, bool loading) async {
    loading = true;
    update();

    /// by default [isQuestionnaire] it should be false, if user added questionnaire below we are
    /// already checking if there is any item in [questionnaire] then consider it as comQNeed true
    isQuestionnaire = false;
    communityId = uuid.v1();
    final controller = Provider.of<HelpersFunctions>(context, listen: false);
    final topicsController = Provider.of<TopicsController>(context, listen: false);
    User? user = _firebaseAuth.currentUser;
    if (user == null) return null;
    CommunityThemeModel? themeModel;
    if (isCustomThemeSelected) {
      themeModel = communityThemeModel;
    } else {
      themeModel = CommunityThemeModel(isThemeSelected: false);
    }

    /// making true if there is any questionnaire added otherwise by defualt its false.
    if (QuestionnaireController.isRegistered) {
      final questionnaires = QuestionnaireController.to.getQuestionnaireList;
      isQuestionnaire = questionnaires.isNotEmpty;
    }

    try {
      await imageUpload.uploadImage(
          context, imageUpload.imageUploadPercentage, imageUpload.communityImage, imageUpload.communityImageFolderName);
      // ignore: use_build_context_synchronously
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
        adminUid: FirebaseAuth.instance.currentUser!.uid,
        communityThemeModel: themeModel,
        isCommQNeeded: isQuestionnaire,
        isPostApprovalNeeded: isPostApprovalNeeded,
      );

      CommunityMembership communitiesMembers = CommunityMembership(
        isMember: true,
        userUid: user.uid,
        isAdmin: true,
        createdOn: DateTime.now(),
      );
      if (communityName.text.isEmpty ||
          description.text.isEmpty ||
          controller.communityImage == null ||
          controller.communityCoverImage == null ||
          topicsController.selectedList.isEmpty) {
        // ignore: use_build_context_synchronously
        snackBar(context, GayaStrings.fill_all_details.tr, kRedColor);
      } else {
        // ignore: use_build_context_synchronously
        await _createCommunityServices.createNewCommunity(
          createNewCommunity: communityModel,
          context: context,
        );
        // ignore: use_build_context_synchronously
        await _createCommunityServices.addNewMemberInCommunity(
          communityId: communityModel.communityId ?? '',
          communitiesMembers: communitiesMembers,
          context: context,
        );
        await services.setUserCommunity(
          {
            'communityName': communityModel.communityName,
            'communityId': communityModel.communityId,
          },
        );

        ///Add Community Questionnaire to database.
        if (QuestionnaireController.isRegistered) {
          await QuestionnaireController.to.addQuestionnaire(communityId: communityModel.communityId);

          // Logging create community event to analytics
          AnalyticsController.to.instance.logCreateCommunity(
            userId: user.uid,
            communityId: communityId,
          );

          // Logging special feature usage event to analytics
          AnalyticsController.to.instance.logSpecialFeatureUsage(
            userId: user.uid,
            featureName: 'secret_community',
          );
        }

        description.clear();
        communityName.clear();
        communityViewPage = CreateCommunityViewEnum.CommunityView1;
        controller.communityImage = null;
        topicsController.selectedList.clear();
        imageUpload.communityPictureDownloadUrl = null;
        imageUpload.communityCoverImage = null;
        controller.communityPictureDownloadUrl = null;
        communityThemeModel = null;
        isCustomThemeSelected = false;
        return communityModel;
      }
    } catch (error) {
      snackBar(context, somethingWrong, kprimaryColor);
    } finally {
      loading = false;
      update();
    }
    return null;
  }

  String getCommunityTypeString(communityType type) {
    switch (type) {
      case communityType.Secret:
        return "Secret";
      case communityType.Private:
        return "Private";
      default:
        return "Public";
    }
  }

  // OnWillPop function to check is pop enable or not
  Future<bool> shouldPop(context) async {
    bool isPop = false;
    if (communityName.text.isEmpty &&
        communityViewPage == CreateCommunityViewEnum.CommunityView1 &&
        Provider.of<TopicsController>(context, listen: false).selectedList.isEmpty) {
      isPop = true;
    }

    return isPop;
  }

  resetState(context) {
    communityId = null;
    type = communityType.Public;
    communityViewPage = CreateCommunityViewEnum.CommunityView1;
    communityName.clear();
    description.clear;
    communityThemeModel = null;
    final helperController = Provider.of<HelpersFunctions>(context, listen: false);
    final topicController = Provider.of<TopicsController>(context, listen: false);
    helperController.communityImage = null;
    topicController.selectedList.clear();
    helperController.communityPictureDownloadUrl = null;
    helperController.communityCoverImage = null;
    isPostApprovalNeeded = false;
  }
}
