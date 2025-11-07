import 'package:flutter/cupertino.dart';
import 'package:gaya/shared/helper/async_helper.dart';
import 'package:gaya/shared/service/mentioning_service/mentioning_user.dart';
import 'package:gaya/shared/service/search_service/search_service.dart';
import 'package:gaya/utils/extension.dart';
import 'package:gaya/utils/logger.dart';
import 'package:gaya/view/community/controllers/base_controller.dart';
import 'package:get/get.dart';
import 'package:get/get_rx/src/rx_workers/utils/debouncer.dart';

class MentionedUserController extends BaseController {
  List<Map<String, dynamic>> userFriends = [];
  List<Map<String, dynamic>> allUsers = [];
  List<Map<String, dynamic>> userCommunities = [];
  List<Map<String, dynamic>> userCommunitiesAndFriends = [];
  List<Map<String, dynamic>> mentionedUsers = [];
  List<String> taggedUsers = [];
  String commentData = '';

  // searched list for search user
  List<Map<String, dynamic>> searchedUsers = [];
  UserMentionedService userMentionedService = UserMentionedService.to;

  List<String> extractMentions(String commentText) {
    List<String> ids = [];
    RegExp pattern = RegExp(r'@([A-Za-z0-9]+(?:-[A-Za-z0-9]+)*)');
    for (RegExpMatch match in pattern.allMatches(commentText)) {
      ids.add(match.group(1).toString()); // Add only the matched part without the "@" symbol
    }
    return ids;
  }

  /// to get the Mentioned(Friends and Communities) from the comments;
  Future getMentionedUserAndCommunity() async {
    taggedUsers = extractMentions(commentData);
    // print("////////////////////taggedUsers");
    // print(taggedUsers);
    // print("/////////////////////////taggedUsers");
    mentionedUsers = [];
    for (var data in taggedUsers) {
      for (Map<String, dynamic> user in userCommunitiesAndFriends) {
        if (user['id'] == data) {
          mentionedUsers.add(user);
        }
      }
    }
    // print("mentionedUsers///////////////////////////////////");
    // print(mentionedUsers.length);
    // print(mentionedUsers);
    // print("//////////// kkkkkkkkkkkkk 222222222222222222222222");
  }

  @override
  Future<void> onInit() async {
    super.onInit();
    try {
      getUserFriends();
      // allUsers = await userMentionedService.getAllUsers();
      //
      // userCommunitiesAndFriends.addAll(allUsers);
      // userCommunities = AppConfigurationController.to.allCommunitiesExceptSecret
      //     .map<Map<String, dynamic>>((community) => {
      //           "id": community.communityId,
      //           "display": community.communityName,
      //           "senderUid": community.communityId,
      //           "senderProfile": community.CommunityPic,
      //           "isCommunity": true
      //         })
      //     .toList();
      // userCommunitiesAndFriends.addAll(userCommunities);
      // update();
    } catch (e) {
      MyLoggerServices.to.print('error caught during getting user friends');
    }
  }

  // getUser
  Future<void> getUserFriends() async {
    if (userFriends.isNotEmpty) {
      return;
    }
    try {
      setLoading(true);
      userFriends = await userMentionedService.getUserFriends();
      setLoading(false);
    } catch (e) {
      MyLoggerServices.to.print('error caught during getting mentioned user');
    }
  }

  // add the item to mentioned User
  void addItem(String item) {
    try {
      //  mentionedUsers.add(item);
      commentData = item;
      update();
    } catch (e) {
      MyLoggerServices.to.print('error caught during getting mentioned user');
    }
  }

  // add the item to mentioned User
  void resetMentionedUser() {
    try {
      mentionedUsers = [];
      update();
    } catch (e) {
      MyLoggerServices.to.print('error caught during getting mentioned user');
    }
  }

  /// resert searched User
  void resetSearchedUser() {
    try {
      searchedUsers = [];
      update();
    } catch (e) {
      MyLoggerServices.to.print('error caught during getting mentioned user');
    }
  }

  // search the users
  final Debouncer _debouncer = Debouncer(delay: 500.milliseconds);

  void searchFriend(String query) {
    try {
      _debouncer.call(() {
        searchedUsers = [];
        if (userFriends.isEmpty) return;
        final suggestion = userFriends.where((element) {
          final userName = element['display']?.toLowerCase();
          return userName?.contains(query.toLowerCase()) ?? false;
        }).toList();
        searchedUsers = suggestion;
        update();
      });
    } catch (_) {
      MyLoggerServices.to.print('error caught during getting mentioned user');
    }
  }

  // search the users from algolia
  AlgoliaService algoliaService = AlgoliaService();

  // this class is used to manage the async calls
  CancelableFuture<List<Map<String, dynamic>>>? asyncTask;

  String getAfterTaggedText(String query) {
    try {
      if (query.isEmpty) return 'a';
      final index = commentData.lastIndexOf('@');
      if (index == -1) return 'a';
      return query.substring(index);
    } catch (_) {
      return query;
    }
  }

  Future<void> getMentionedData(String query) async {
    try {
      debugPrint('Before query:=> $query');
      query = getAfterTaggedText(query);
      debugPrint('After query:=> $query');
      asyncTask?.cancel();
      asyncTask = CancelableFuture<List<Map<String, dynamic>>>(algoliaService.getUserAndCommunitiesForMentions(query.isEmpty ? 'a' : query),
          onSuccessCallback: (_) {
        userCommunitiesAndFriends.addAll(_);
        userCommunitiesAndFriends = userCommunitiesAndFriends.distinctBy((e) => e['id']).toList();
        update();
      }, onErrorCallback: (_) {});
    } catch (e) {
      MyLoggerServices.to.print('error thrown here:=>${e.toString()}');
    }
  }
}

class UserFriendsController extends BaseController {
  UserMentionedService userMentionedService = UserMentionedService.to;

  @override
  onInit() {
    super.onInit();
    getUserFriends();
  }

  List<Map<String, dynamic>> userFriends = [];

  // searched list for search user
  List<Map<String, dynamic>> searchedUsers = [];

// search the users
  final Debouncer _debouncer = Debouncer(delay: 500.milliseconds);

  void searchFriend(String query) {
    try {
      _debouncer.call(() {
        searchedUsers = [];
        if (userFriends.isEmpty) return;
        final suggestion = userFriends.where((element) {
          final userName = element['display']?.toLowerCase();
          return userName?.contains(query.toLowerCase()) ?? false;
        }).toList();
        searchedUsers = suggestion;
        update();
      });
    } catch (_) {
      MyLoggerServices.to.print('error caught during getting mentioned user');
    }
  }

  // getUser
  Future<void> getUserFriends() async {
    if (userFriends.isNotEmpty) {
      return;
    }
    try {
      setLoading(true);
      userFriends = await userMentionedService.getUserFriends();
      setLoading(false);
    } catch (e) {
      MyLoggerServices.to.print('error caught during getting mentioned user');
    }
  }

  /// resert searched User
  void resetSearchedUser() {
    try {
      searchedUsers = [];
      update();
    } catch (e) {
      MyLoggerServices.to.print('error caught during getting mentioned user');
    }
  }
}
