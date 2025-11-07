import 'dart:developer';

import 'package:firebase_phone_auth_handler/firebase_phone_auth_handler.dart';
import 'package:flutter/material.dart';
import 'package:gaya/components/snackbar.component.dart';
import 'package:gaya/utils/const.dart';
import 'package:gaya/utils/language/translation.dart';
import 'package:get/get.dart';

import '../model/topic.model.dart';
import '../services/topic_services.dart/topicService.dart';

class TopicsController extends ChangeNotifier {
  List interestList = [];
  List addTopicsList = [];
  int? totalSelection = 0;
  int? topicsSelected;
  List usersInterest = [];
  final TopicServices _topicServices = TopicServices();

  Map<String, dynamic>? topic;

  bool isSelection(int index) {
    topicsList[index].isSeleted = !topicsList[index].isSeleted;
    notifyListeners();
    return topicsList[index].isSeleted;
  }

  bool topicSelection(int index) {
    topicsList[index].isSeleted = !topicsList[index].isSeleted;
    notifyListeners();
    return topicsList[index].isSeleted;
  }

  addToInterestList() {
    interestList.add(topicsList.length);
  }

  addTopicsToList(int index) {
    if (topicsList[index].isSeleted == true) interestList.add(topicsList);

    notifyListeners();
  }

//Select the interest of the user
  bool userInterests(int index) {
    topicsList[index].isSeleted = !topicsList[index].isSeleted;

    notifyListeners();
    return topicsList[index].isSeleted;
  }

  //add the interest to the user  profile
  addUserInterests() {
    for (var item in topicsList) {
      if (item.isSeleted == true) {
        if (!usersInterest.contains(item.title)) {
          usersInterest.add(
            item.title,
          );
        }

        notifyListeners();
      }
    }

    log(usersInterest.toString());
    return usersInterest;
  }

  //------------->//
  //topic view controller
  List<TopicsModel> allTopics = topicsList;
  List<TopicsModel> get topics => allTopics;

  List<TopicsModel> selectedList = [];
  List<TopicsModel> get selectedItems => selectedList;

  List<String> selectTitles = [];
  List<String> get getSelectedTitles => selectTitles;

  List<String> titleSelected = [];
  List<String> get getTitlesSelected => titleSelected;

  List<String> randomTitles = [];
  List<String> get getRandomTitles => randomTitles;

  //add topics to the list
  void addTopics(TopicsModel topics) {
    selectedList.add(topics);
    notifyListeners();
  }

  //add topics to the list
  void addTitles(TopicsModel topics) {
    getTitlesSelected.add(topics.title);
    notifyListeners();
  }

  //add topics to the list
  void removeTitles(TopicsModel topics) {
    getTitlesSelected.remove(topics.title);
    notifyListeners();
  }

  //remove topics from the list
  void removeTopics(TopicsModel topics) {
    selectedList.remove(topics);
    notifyListeners();
  }

  //----------->//

  Future<void> sendNewInterestSuggestion(BuildContext context, {String interest = ''}) async {
    try {
      await _topicServices.sendNewInterestSuggestion(interest: interest);
    } catch (e) {
      log('error caught during sending Suggestion user=>${e.toString()}');
      snackBar(context, GayaStrings.unable_send_interest_suggestion.tr, kRedColor);
    }
  }

  // update the user intrests
  Future<void> updateIntrest({required BuildContext context, required List<Map<String, dynamic>> intrests}) async {
    try {
      final user = FirebaseAuth.instance.currentUser;
      if (user == null) return;
      await _topicServices.saveUserIntrests(intrests: intrests, userId: user.uid);
      selectedList.clear();
      notifyListeners();
    } catch (e) {
      log('error caught during updation of  intrest =>${e.toString()}');
      snackBar(context, GayaStrings.unable_update_user_interest.tr, kRedColor);
    }
  }
}
