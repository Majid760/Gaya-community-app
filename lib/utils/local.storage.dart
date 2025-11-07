import 'dart:developer';

import 'package:get/get.dart';
import 'package:get_storage/get_storage.dart';
import "package:shared_preferences/shared_preferences.dart";

import '../model/topic.model.dart';
import '../view/chat/models/queue_messages.dart';

class LocalStorage {
  String interestUiKey = "IUK";

  //write the data
  Future writeBool(String key, bool value) async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.setBool(key, value);
  }

  //read the data
  readData(String key) async {
    final prefs = await SharedPreferences.getInstance();
    prefs.getBool(key);
  }
}

//ignore_for_file_prefer_const_constructors, prefer_const_literals_to_create_immutables

class GetStorageController extends GetxController implements GetxService {
  static GetStorageController get to => Get.find();
  final box = GetStorage();

  static const firstTimeKey = "isFirstTime";
  static const recentSearchesKey = "recentSearches";
  static const queueMessagesKey = "queueMessages";

  Future<void> initStorage() async {
    await box.initStorage;
  }

  @override
  void onInit() {
    super.onInit();
    initStorage();
  }

  bool isHavingData = false;

  toggleIsHavingData(bool value) {
    isHavingData = value;
    update();
  }

  ///returns true if its the first time the app is opened
  bool get isFirstTime {
    if (box.read(firstTimeKey) == null) {
      box.write(firstTimeKey, true);
      return true;
    } else {
      return false;
    }
  }

  String? writeString({required String key, required String value}) {
    log("Saving key in Get Storage: Key is: $key and value is: $value");
    box.write(key, value);
    toggleIsHavingData(true);
    return null;
  }

  String? readKey(String key) {
    return box.read(key);
  }

  Future<void> clearAll() async {
    await box.erase().then((value) async {
      toggleIsHavingData(false);
      log("Remove Storage: ");
      update();
    });
  }

  void storeRecentSearchedList({required List<dynamic>? recentSearches}) {
    log("Recent Search List: ${recentSearches.toString()}");
    box.write(recentSearchesKey, recentSearches);
    update();
    log("Recent Searches Stored Successfully:");
  }

  List<QueueCubeMessage> getQueueMessages() {
    List<QueueCubeMessage> queueMessages = [];
    List<dynamic>? data = box.read(queueMessagesKey) ?? [];
    if (data.isNotEmpty) {
      for (var element in data) {
        try {
          final queued = QueueCubeMessage.fromJson(element);
          print("Element is: $element");
          queueMessages.add(queued);
        } catch (_) {
          print("Error in parsing QueueCubeMessage $_");
        }
      }
    }
    return queueMessages;
  }

  void storeQueueMessages({required List<QueueCubeMessage> queueMessages}) {
    List<dynamic> data = [];
    for (var element in queueMessages) {
      data.add(element.toJson());
    }
    box.write(queueMessagesKey, data);
  }

  void clearQueuedMessages() {
    box.remove(queueMessagesKey);
  }

  void clearQueuedMessageByDialogId({required String dialogId}) {
    List<QueueCubeMessage> queueMessages = getQueueMessages();
    queueMessages.removeWhere((element) => element.chatroom.dialogId == dialogId);
    storeQueueMessages(queueMessages: queueMessages);
  }

  List<dynamic>? getRecentSearchedList() {
    List<dynamic>? data = box.read(recentSearchesKey);
    update();
    if (data != null) {
      return data;
    } else {
      return null;
    }
  }

  dynamic write({required String key, required dynamic value}) {
    box.write(key, value);
    log("Key is: $key and value is: $value");
  }

  read(String key) {
    return box.read(key);
  }
}

// save the community recent search

class GetCommunityStorageController extends GetxController implements GetxService {
  late GetStorageController _storage;

  @override
  void onInit() {
    super.onInit();
    _storage = GetStorageController.to;
    log("Get Storage Controller Initialized:");
  }

  bool isHavingData = false;

  toggleIsHavingData(bool value) {
    isHavingData = value;
    update();
  }

  String? writeStorage({required String key, required String value}) {
    log("Saving key in Get Storage: Key is: $key and value is: $value");
    _storage.box.write(key, value);
    log("Token is saved in GetStorage: ${_storage.box.read(key)}");
    toggleIsHavingData(true);
    return null;
  }

  String? readStorage(String key) {
    return _storage.box.read(key);
  }

  storeRecentCommunitySearchedList({required List<dynamic>? recentSearches}) {
    log("Recent Search List: ${recentSearches.toString()}");
    _storage.box.write("recentCommunitySearches", recentSearches);
    update();
    log("Recent Searches Stored Successfully:");
  }

  List<dynamic>? getRecentSearchedList() {
    List<dynamic>? data = _storage.box.read("recentCommunitySearches");
    update();
    if (data != null) {
      return data;
    } else {
      return null;
    }
  }
}

// save the community user  recent search

class GetCommunityUsersStorageController extends GetxController implements GetxService {
  final communityUserBox = GetStorage();

  Future<void> initStorage() async {
    await GetStorage().initStorage;
  }

  @override
  void onInit() {
    super.onInit();
    log("Get Storage Controller Initialized:");
  }

  bool isHavingData = false;

  toggleIsHavingData(bool value) {
    isHavingData = value;
    update();
  }

  String? writeStorage({required String key, required String value}) {
    log("Saving key in Get Storage: Key is: $key and value is: $value");
    communityUserBox.write(key, value);
    log("Token is saved in GetStorage: ${communityUserBox.read(key)}");
    toggleIsHavingData(true);
    return null;
  }

  String? readStorage(String key) {
    return communityUserBox.read(key);
  }

  storeRecentCommunitySearchedList({required List<dynamic>? recentSearches}) {
    log("Recent Search List: ${recentSearches.toString()}");
    communityUserBox.write("recentCommunityUsersSearches", recentSearches);
    update();
    log("Recent Searches Stored Successfully:");
  }

  List<dynamic>? getRecentSearchedList() {
    List<dynamic>? data = communityUserBox.read("recentCommunityUsersSearches");
    update();
    if (data != null) {
      return data;
    } else {
      return null;
    }
  }
}

// save   user  recent interests
class GetInterestStorageController extends GetxController implements GetxService {
  static GetInterestStorageController get to => Get.find();
  final userInterestBox = GetStorage();

  Future<void> initStorage() async {
    await GetStorage().initStorage;
  }

  @override
  void onInit() {
    super.onInit();
    log("Get Storage Controller Initialized:");
  }

  bool isHavingData = false;

  toggleIsHavingData(bool value) {
    isHavingData = value;
    update();
  }

  String? writeStorage({required String key, required String value}) {
    log("Saving key in Get Storage: Key is: $key and value is: $value");
    userInterestBox.write(key, value);
    log("Token is saved in GetStorage: ${userInterestBox.read(key)}");
    toggleIsHavingData(true);
    return null;
  }

  String? readStorage(String key) {
    return userInterestBox.read(key);
  }

  Future<void> removeGetStorage() async {
    await userInterestBox.remove('recentInterest');
    log("Get Storage Emptied for recentInterest: ");
  }

  storeInterestList({required List<dynamic>? recentInterests}) {
    userInterestBox.write("recentInterest", recentInterests);
    update();
    log("Recent Searches Stored Successfully:");
  }

  List<TopicsModel> getSavedInterestList() {
    List data = userInterestBox.read("recentInterest") ?? [];
    List<TopicsModel> resp = data.map((e) => TopicsModel.fromMap(e)).toList();
    update();
    if (data != null) {
      return resp;
    } else {
      return [];
    }
  }

  List<dynamic>? getInterestList() {
    List<dynamic>? data = userInterestBox.read("recentInterest");
    update();
    if (data != null) {
      return data;
    } else {
      return null;
    }
  }

  List<TopicsModel> getInterestModelList() {
    try {
      List data = userInterestBox.read("recentInterest");
      List<TopicsModel> resp = data.map((e) => TopicsModel.fromMap(e)).toList();
      update();
      if (data != null) {
        return resp;
      } else {
        return [];
      }
    } catch (e) {
      log("Error in getInterestList1: $e");
    }
    return [];
  }
}
