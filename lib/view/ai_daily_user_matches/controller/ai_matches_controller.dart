import 'package:flutter/material.dart';
import 'package:gaya/controller/app_config_controller.dart';
import 'package:gaya/model/user.model.dart';
import 'package:gaya/utils/local.storage.dart';
import 'package:gaya/utils/logger.dart';
import 'package:gaya/view/ai_daily_user_matches/model/ai_user_matched_model.dart';
import 'package:gaya/view/ai_daily_user_matches/model/goal_Interest_model.dart';
import 'package:gaya/view/ai_daily_user_matches/services/ai_matches_services.dart';
import 'package:gaya/view/ai_daily_user_matches/utils/goal_interest_utils.dart';
import 'package:get/get.dart';

class AIMatchesController extends GetxController {
  static AIMatchesController get to => Get.find();
  final _aiMatchServices = AIMatchServices();
  final goalInterestUtil = GoalInterestUtil();
  final GetStorageController getStorage = Get.find();

  UserModel get userModel => UserModel.to;
  List<GoalInterestModel> goals = [];
  List<GoalInterestModel> genders = [];

  List<String> selectedGoals = [];
  List<String> selectedGenders = [];

  ///this bool is used to expand and collapse the ai widget on home feed view.
  bool isExpanded = false;

  ///this bool is used to  show and hide the ai bottom sheet contents.
  bool isAIMatch = true;

  bool isLoading = false;

  AiUserMatchedModel? myAIMatchModel;

  @override
  void onInit() {
    // TODO: implement onInit
    super.onInit();
    goals = goalInterestUtil.goals;
    genders = goalInterestUtil.genders;
    selectedGenders = [];
    selectedGoals = [];
    selectedGoals.add('friends');
    selectedGenders.add('everyone');
    genders[0].isSelected = true;
    goals[0].isSelected = true;
    getBoolFromStorage();

    fetchMyMatches();
  }

  ///check that user send match request or not
  bool isSendMatchRequest() {
    if (myAIMatchModel == null) return false;
    return true;
  }

  // check that when user send request and  got a match
  bool isGotMatch() {
    if (myAIMatchModel != null && myAIMatchModel?.matchedUserProfile != null) return true;
    return false;
  }

  // fetch my match doc if available
  void fetchMyMatches({bool shouldRemoveMyMatchDoc = false}) async {
    try {
      if (userModel.uId == null) return;
      myAIMatchModel = await _aiMatchServices.getMyAIMatchedUser(userId: userModel.uId ?? "");

      // if the user has not matched with anyone then remove the match request doc
      if (shouldRemoveMyMatchDoc && myAIMatchModel?.matchedUserProfile == null) {
        await removeMatchRequestDoc();
        myAIMatchModel = null;
      }

      // check if match is valid or expired
      if (myAIMatchModel != null) {
        await checkMatchModelValidity();
      }

      update();
    } catch (e) {
      debugPrint(e.toString());
    }
    setIsLoading(status: false);
  }

  // check if the match is valid or not
  Future<void> checkMatchModelValidity() async {
    // myAIMatchModel

    if (myAIMatchModel?.matchedUserProfile != null || myAIMatchModel?.createdAt == null) return;

    // Get the current UTC time
    // DateTime createdAt = DateTime.now().add(Duration(hours: -8)).toUtc();
    DateTime createdAt = myAIMatchModel!.createdAt;

    // Get the current UTC time
    DateTime currentUtcTime = DateTime.now().toUtc();

    // Calculate the next 17:00 UTC time for the same day
    DateTime next17UtcTime = DateTime.utc(currentUtcTime.year, currentUtcTime.month, currentUtcTime.day, 17, 0, 0);
    if (currentUtcTime.isAfter(next17UtcTime)) {
      next17UtcTime = next17UtcTime.add(const Duration(days: 1));
    }
    // Calculate the time difference between createdAt and the next 17:00 UTC time
    Duration timeDifference = next17UtcTime.difference(createdAt);
    // Check if the time difference is within 24 hours
    if (timeDifference.inHours > 24) {
      await removeMatchRequestDoc();
      myAIMatchModel = null;
    }
  }

  // get the state of ai match widget
  getBoolFromStorage() {
    isExpanded = getStorage.box.read("isExpanded") ?? false;
    update();
  }

  // get mutual communities of matched user and current user
  int getMutualCommunities() {
    List<String> mutualCommunities = [];
    if (myAIMatchModel?.matchedUserProfile?.joinedCommunities == null) return 0;
    List<String> myCommunities = myAIMatchModel?.createdBy.joinedCommunities ?? [];
    List<String> matchedUserCommunities = myAIMatchModel?.matchedUserProfile?.joinedCommunities ?? [];
    for (int i = 0; i < myCommunities.length; i++) {
      if (matchedUserCommunities.contains(myCommunities[i])) {
        mutualCommunities.add(myCommunities[i]);
      }
    }
    return mutualCommunities.length;
  }

  // get mutual topics of matched user and current user
  String getMutualTopics() {
    List<String> mutualTopics = [];
    if (myAIMatchModel?.matchedUserProfile?.interests == null) return '';
    List<String> myTopics = myAIMatchModel?.createdBy.interests ?? [];
    List<String> matchedUserTopics = myAIMatchModel?.matchedUserProfile?.interests ?? [];
    for (int i = 0; i < myTopics.length; i++) {
      if (matchedUserTopics.contains(myTopics[i])) {
        mutualTopics.add(myTopics[i]);
      }
    }
    if (mutualTopics.isNotEmpty && mutualTopics.length < 2) {
      return mutualTopics[0];
    } else if (mutualTopics.isNotEmpty && mutualTopics.length > 1) {
      return '${mutualTopics[0]} and ${mutualTopics[1]}';
    } else {
      return '';
    }
  }

  // find that the current user and matched user age is same or not
  String isSameAge() {
    if (myAIMatchModel?.matchedUserProfile?.age == null) return '';
    if (myAIMatchModel?.createdBy.age == null) return '';
    if (calculateAge(myAIMatchModel!.matchedUserProfile!.age) == calculateAge(myAIMatchModel!.createdBy.age)) {
      return '${calculateAge(myAIMatchModel!.matchedUserProfile!.age)}';
    }
    return '${calculateAge(myAIMatchModel!.createdBy!.age)},${calculateAge(myAIMatchModel!.matchedUserProfile!.age)}';
  }

  int calculateAge(DateTime birthdate) {
    final now = DateTime.now();
    final age = now.year - birthdate.year;

    if (now.month < birthdate.month || (now.month == birthdate.month && now.day < birthdate.day)) {
      return age - 1;
    }

    return age;
  }

  // collapse & expand ai match tile
  void collapseExpandTile({required bool expand}) {
    isExpanded = expand;
    getStorage.box.write("isExpanded", isExpanded);
    update();
  }

  // set loading bool
  void setIsLoading({required bool status}) {
    isLoading = status;
    update();
  }

  // show and hide the ai bottom sheet contents.
  setAIMatchStatus(bool status) {
    isAIMatch = status;
    update();
  }

  Duration getTotalDurationForTweenAnimation() {
    // Get the current UTC time
    DateTime currentUtcTime = DateTime.now().toUtc();

    // Calculate the next 17:00 UTC time
    DateTime next17UtcTime = DateTime.utc(currentUtcTime.year, currentUtcTime.month, currentUtcTime.day, 17, 0, 0);
    if (currentUtcTime.isAfter(next17UtcTime)) {
      next17UtcTime = next17UtcTime.add(const Duration(days: 1));
    }
    next17UtcTime = next17UtcTime.add(const Duration(minutes: 10));
    // Calculate the time difference
    Duration timeDifference = next17UtcTime.difference(currentUtcTime);

    return timeDifference;
  }

  // add selected goals to list
  void addGoals(String goal, int index) {
    try {
      if (selectedGoals.contains(goal)) {
        selectedGoals.remove(goal);
        goals[index].isSelected = false;
      } else {
        goals[index].isSelected = true;
        selectedGoals.add(goal);
      }
      update();
      MyLoggerServices.to.print('length is :$selectedGoals');
    } catch (_) {
      MyLoggerServices.to.print('error caught during adding goals');
    }
  }

  // add selected genders to list
  void addGenders(String gender, int index) {
    try {
      if (selectedGenders.contains(gender)) {
        genders[index].isSelected = false;
        selectedGenders.remove(gender);
      } else {
        genders[index].isSelected = true;
        selectedGenders.add(gender);
      }
      update();
      MyLoggerServices.to.print('length is :${selectedGenders.length}');
    } catch (_) {
      MyLoggerServices.to.print('error caught during adding gender');
    }
  }

  //Add user matches to firestore
  Future<void> sendMatchRequest() async {
    setIsLoading(status: true);
    try {
      List<String> interests = [];
      userModel.interests?.forEach((element) {
        interests.add(element.title);
      });
      CreatedBy createdBy = CreatedBy(
          id: userModel.uId ?? "",
          name: userModel.name ?? "",
          age: userModel.dob ?? DateTime.now(),
          joinedCommunities: AppConfigurationController.to.joinedCommunities.map((e) => e.communityId ?? "").toList(),
          interests: interests,
          gender: userModel.gender ?? "",
          imageUrl: userModel.profilePicture ?? "");
      myAIMatchModel = AiUserMatchedModel(
        goals: selectedGoals,
        genders: selectedGenders,
        createdBy: createdBy,
        createdAt: DateTime.now(),
      );
      if (myAIMatchModel == null) return;
      bool isSent = await _aiMatchServices.sendUserAIMatchRequest(documentId: userModel.uId ?? "", aiUserMatchedModels: myAIMatchModel!);
      if (!isSent) myAIMatchModel = null;
    } catch (e) {
      debugPrint(e.toString());
    }
    setIsLoading(status: false);
  }

  // Remove users matches in firestore
  Future<void> removeMatchedUserDocs() async {
    if (myAIMatchModel?.createdBy.id == null || myAIMatchModel?.matchedUserProfile?.id == null) return;
    try {
      bool isRemoved = await _aiMatchServices.removeMatchedUserDocs(
          matchCreatorId: myAIMatchModel?.createdBy.id ?? "", matchUserId: myAIMatchModel?.matchedUserProfile?.id ?? "");
      if (isRemoved) {
        myAIMatchModel = null;
        update();
      }
    } catch (e) {
      debugPrint(e.toString());
    }
    setIsLoading(status: false);
  }

  // Remove single match in firestore
  Future<void> removeMatchRequestDoc() async {
    if (myAIMatchModel?.createdBy.id == null) return;
    try {
      await _aiMatchServices.removeMatchRequestDoc(matchCreatorId: myAIMatchModel?.createdBy.id ?? "");
    } catch (e) {
      debugPrint(e.toString());
    }
  }

  // get get Local Time Fo Utc 17:00 time
  String getLocalTimeFoUtc1700() {
    final now = DateTime.now();
    DateTime utcDateTime = DateTime.utc(now.year, now.month, now.day, 17, 0);
    final local = utcDateTime.toLocal();
    return "${local.hour.toString().padLeft(2, "0")}:${local.minute.toString().padLeft(2, "0")}";
  }
}
