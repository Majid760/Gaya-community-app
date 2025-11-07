import 'dart:async';
import 'dart:math' as math;
import 'dart:math';

import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:gaya/components/snackbar.component.dart';
import 'package:gaya/model/friendship.model.dart';
import 'package:gaya/model/save.post.model.dart';
import 'package:gaya/model/user.model.dart';
import 'package:gaya/model/user.saved.post.model.dart';
import 'package:gaya/services/services.dart';
import 'package:gaya/shared/service/search_service/search_service.dart';
import 'package:gaya/shared/view/widget/gaya_snackbar.dart';
import 'package:gaya/utils/const.dart';
import 'package:gaya/utils/enum.dart';
import 'package:gaya/utils/helper/helper.functions.dart';
import 'package:gaya/utils/language/translation.dart';
import 'package:gaya/utils/logger.dart';
import 'package:gaya/utils/methods.dart';
import 'package:get/get.dart';
import 'package:intl/intl.dart' as intl;

class HomePageController extends ChangeNotifier {
  HelperFunc helperFunc = HelperFunc();

// Firestore things

  FirebaseAuth firebaseAuth = FirebaseAuth.instance;
  late QuerySnapshot<Map<String, dynamic>> querySnapshot;
  DocumentSnapshot? lastDocument;
  DocumentSnapshot? lastPostNoCommunity;

  QuerySnapshot? postQueryDocs;

  TextEditingController searchFriendsController = TextEditingController();

  Services services = Services();
  UserSavedPostsModel? userSavedPostsModel;

  //All bools
  bool loadMoreData = false;
  bool isMoreDataAvailable = true;
  bool isMoreDataAvailableForNoJoinedCommunities = true;
  bool loadMoreDataNoCommunities = false;
  bool isSend = false;
  bool isSearchModeOn = false;

  List allUsername = [];
  List<String> userCommuniteisWithIdsOnly = [];
  List savePostsIds = [];
  List savePostsCommunityIds = [];
  List<String> savePostsUserIds = [];
  List<String> sentMessageUserIds = [];

  List<String> senderFriendsUid = [];
  List<String> recieverFriendsUid = [];
  List<String> allFriendsList = [];

  List<UserModel> allFriends = [];
  List<UserModel> searchFriends = [];

  addUserInAllFriends(UserModel user) {
    if (!allFriends.contains(user)) {
      allFriends.add(user);
    }
  }

  void addUsersInAllFriends(List<UserModel> users) {
    allFriends.addAll(users);
    debugPrint("All friends : ${allFriends.length}");
  }

  int totalCommunitiesMembers = 0;
  int flowerSize = 0;

  //switch between the screens
  HomepageSwitch index = HomepageSwitch.home;

  get getView => index;

  bool isRTL(String text) {
    return intl.Bidi.detectRtlDirectionality(text);
  }

  //set the save posts in the user collections
  Future setSavePostInUSerCollection(Map<String, dynamic> setMap, BuildContext context) async {
    User? user = FirebaseAuth.instance.currentUser;
    SavePostModel savePostModel = SavePostModel(saveDocID: setMap["postId"]);

    try {
      await FirebaseFirestore.instance
          .collection('users')
          .doc(user!.uid)
          .collection('saveposts')
          .doc(savePostModel.saveDocID)
          .set(setMap)
          .then((value) {
        GayaSnackBar.show(context: context, type: GayaSnackBarType.save, text: GayaStrings.post_saved.tr);

        return value;
      });
    } catch (e) {
      // log(e.toString());
      snackBar(context, GayaStrings.failed_to_save.tr, kprimaryColor);
    } finally {}
  }

  //delete the user unsave doc from community post save collection
  Future<QuerySnapshot?> deleteUserSaveDocFromPostCollection(String postId, BuildContext context) async {
    User? user = firebaseAuth.currentUser;
    QuerySnapshot? unsavePostQuery;

    try {
      unsavePostQuery = await FirebaseFirestore.instance
          .collection('communityposts')
          .doc(postId)
          .collection('savepost')
          .where('userUid', isEqualTo: user!.uid)
          .get()
          .then((value) {
        value.docs.first.reference.delete();
        return value;
      });
    } catch (e) {
      // log("failed to unsave the post");
      snackBar(context, GayaStrings.failed_to_unsaved.tr, kRedColor);
    } finally {}
    return unsavePostQuery;
  }

  //delete the save post from the user collection
  Future deletePostFromUserCollection(String postId) async {
    User? user = firebaseAuth.currentUser;
    try {
      await FirebaseFirestore.instance.collection('users').doc(user!.uid).collection('saveposts').doc(postId).delete();
    } catch (_) {}
  }

  //getting all users
  List<UserModel> searchedUser = [];
  AlgoliaService algoliaService = AlgoliaService();
  bool isLoading = false;
  Future<void> fetchUsers(String query) async {
    try {
      notifyListeners();
      if (query.trim().isEmpty) return;
      searchedUser = await algoliaService.getsAllUsers(query);
      isLoading = false;
      notifyListeners();
    } catch (e) {
      MyLoggerServices.to.print('errorororo${e.toString()}');
    }
  }

  //

  Future<List<UserModel>> getMyFriends() async {
    User? user = firebaseAuth.currentUser;

    if (user == null) return [];
    final freindsSnaps = await Future.wait([
      FirebaseFirestore.instance
          .collection("friendship")
          .where("Recieveruid", isEqualTo: user.uid)
          .where("isaccepted", isEqualTo: true)
          .get(),
      FirebaseFirestore.instance.collection("friendship").where("senderUid", isEqualTo: user.uid).where("isaccepted", isEqualTo: true).get()
    ]);

    //senders
    for (var index in freindsSnaps[0].docs) {
      FriendShipModel friendShipModel = FriendShipModel.fromMap(index.data());

      senderFriendsUid.add(friendShipModel.senderUid!);
    }

    // recievers
    for (var index in freindsSnaps[1].docs) {
      FriendShipModel friendShipModel = FriendShipModel.fromMap(index.data());

      recieverFriendsUid.add(friendShipModel.recieverUid!);
    }

    List<String> allFriendsIds = [...senderFriendsUid, ...recieverFriendsUid];

    List<UserModel> allFriendsData = [];
    try {
      /// split the list into chunks of 10
      /// then get the users by ids
      /// then add the users to the list
      /// then return the list
      Methods.generateListOfChunks(allFriendsIds).forEach((element) async {
        await services.getUsersByIds(element).then((userChunk) {
          allFriendsData.addAll(userChunk);
        });
      });
    } catch (e) {
      print(e);
    }
    return allFriendsData;
  }

  //get all the your friends
  Future<QuerySnapshot?> yourFriends() async {
    User? user = firebaseAuth.currentUser;
    if (user == null) return null;
    return await FirebaseFirestore.instance
        .collection("friendship")
        .where("Recieveruid", isEqualTo: user.uid)
        .where("isaccepted", isEqualTo: true)
        .get()
        .then((value) {
      for (var index in value.docs) {
        FriendShipModel friendShipModel = FriendShipModel.fromMap(index.data());

        senderFriendsUid.add(friendShipModel.senderUid!);
      }

      return value;
    }).whenComplete(() async {
      await FirebaseFirestore.instance
          .collection("friendship")
          .where("senderUid", isEqualTo: user.uid)
          .where("isaccepted", isEqualTo: true)
          .get()
          .then((value) {
        for (var index in value.docs) {
          FriendShipModel friendShipModel = FriendShipModel.fromMap(index.data());
          recieverFriendsUid.add(friendShipModel.recieverUid!);
        }
        return value;
      });
    }).whenComplete(() async {
      allFriendsList = [...recieverFriendsUid, ...senderFriendsUid];
      // to remove the current user from the list

      // log("This is our complete list ${allFriendsList}");
      // log("This is reciver list ${recieverFriendsUid}");
      // log("This is sender list ${senderFriendsUid}");
      // log("This is getfirends list list ${_getFriendsList(allFriendsList)}");
    }).then((value) async {
      if (allFriendsList.isEmpty) return null;
      return await FirebaseFirestore.instance
          .collection("users")
          .where("uid", whereIn: _getFriendsList(allFriendsList))
          .get()
          .then((value) {
        return value;
      });
    }).whenComplete(() {
      allFriendsList.clear();
      senderFriendsUid.clear();
      recieverFriendsUid.clear();
    });
  }

  final Random random = Random();

  int generateRand({int? max}) {
    int rand = (random.nextInt(max ?? 10000));
    return rand;
  }

  DateTime generateRandomDateTime() {
    DateTime now = DateTime.now();
    int day = generateRand(max: 30);
    DateTime randomDay = now.subtract(Duration(days: day));
    return randomDay;
  }

  Future<QuerySnapshot?> getUsersOfMyInterest({int? limit}) async {
    if (UserModel.to.interests?.isEmpty ?? true) return null;
    debugPrint("My itnerests :  ${UserModel.to.interests}");
    final myInterest = await FirebaseFirestore.instance
        .collection("users")
        .where("interests", arrayContainsAny: UserModel.to.interests?.map((element) => element.toMap()).toList())
        .limit(limit ?? 10)
        .get();
    return myInterest;
  }

  Future<QuerySnapshot?> randomUsers({int? limit}) async {
    final randomUsers = await FirebaseFirestore.instance
        .collection("users")
        .where('userCreatedOn', isGreaterThanOrEqualTo: generateRandomDateTime())
        .limit(limit ?? 10)
        .get();
    return randomUsers;
  }

  Future<QuerySnapshot?> myFriendsOrInterestBaseOrRandomUsers() async {
    QuerySnapshot? users;

    try {
      /// fetch my friends
      await yourFriends().then((friends) {
        if (friends?.docs.isNotEmpty ?? false) {
          users = friends;
        } else {
          /// if no friends then fetch ppl from my interests
          return getUsersOfMyInterest().then((interests) {
            if (interests?.docs.isNotEmpty ?? false) {
              users = interests;
            } else {
              /// if no interests then fetch random users
              return randomUsers().then((random) {
                if (random?.docs.isNotEmpty ?? false) {
                  users = random;
                }
              });
            }
          });
        }
      });
    } catch (_) {
      debugPrint("Error in getting myFriendsOrInterestBaseOrRandomUsers $_");
    }

    return users;
  }

  List<String?> _getFriendsList(List<String?> allFriendsList) {
    List<String?> allfriendsIds = [];
    if (allFriendsList.length < 10) {
      allfriendsIds = allFriendsList;
    } else {
      allfriendsIds = allFriendsList.cutList(allFriendsList, 10);
    }
    return allfriendsIds;
  }

//search the communities
  searchFriendsFunc(String query) {
    if (isSearchModeOn != true) {
      isSearchModeOn = true;
    }
    if (query.trim().isEmpty) {
      isSearchModeOn = false;
    }
    debugPrint('all friends length : ${allFriends.length}');
    final suggestion = allFriends.where((element) {
      final friendName = element.name!.toLowerCase();
      final input = query.toLowerCase();
      return friendName.contains(input);
    }).toList();
    searchFriends = suggestion;
    debugPrint('search friends length : ${searchFriends.length}');
    notifyListeners();
  }
}

extension CutList<T> on List<T?> {
  List<T?> cutList(List<T?> oldList, int newLength) {
    return List<T?>.filled(newLength, null)..setRange(0, math.min(newLength, oldList.length), oldList);
  }
}
