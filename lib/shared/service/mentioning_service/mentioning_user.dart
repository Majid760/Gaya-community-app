import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_phone_auth_handler/firebase_phone_auth_handler.dart';
import 'package:flutter/foundation.dart';
import 'package:gaya/model/user.model.dart';
import 'package:gaya/services/services.dart';
import 'package:gaya/utils/logger.dart';
import 'package:get/get.dart';

class UserMentionedService extends GetxService{
  static UserMentionedService get to => Get.find();

  UserModel userModel ()=> UserModel.to;
  FirebaseFirestore db = FirebaseFirestore.instance;
  final Services _commonServices = Services();
  List<Map<String, dynamic>> searchedFriends = [];
  List<Map<String, dynamic>> allUsers = [];

  // get user friend list
  List<Map<String, dynamic>> get searchedFriendsList => searchedFriends;

/*  //get the current user friends count
  Future<List<Map<String, dynamic>>> getUserFriends() async {
    User? user = FirebaseAuth.instance.currentUser;
    try {
      // clear friends on start to avoid duplication
      searchedFriends = [];

      //return empty array if user is not logged in
      if (user == null) return searchedFriends;
      MyLoggerServices.to.print('this is user:=>' + user!.uid);
      QuerySnapshot? friends =
          await db.collection('friendship').where('Recieveruid', isEqualTo: user!.uid).where('isaccepted', isEqualTo: true).get();



      if (friends.docs.isNotEmpty) {
        for (var snapshot in friends.docs) {
          final sender = await _commonServices.getUserById((snapshot.data() as Map<String, dynamic>)['senderUid']);
          if (sender == null) {
            debugPrint("Sender is null ${snapshot.data()}");
            continue;
          }
          try {
            searchedFriends.add({
              "id": sender.uId,
              "display": sender.name.toString(),
              "senderUid": (snapshot.data() as Map<String, dynamic>)['senderUid'].toString(),
              "senderProfile": (snapshot.data() as Map<String, dynamic>)['senderProfile'].toString()
            });
          } catch (_) {
            debugPrint("Error in adding friends ${_}");
          }
        }
      }
      QuerySnapshot? friends2 =
      await db.collection('friendship').where('senderUid', isEqualTo: user!.uid).where('isaccepted', isEqualTo: true).get();
      if (friends2.docs.isNotEmpty) {
        for (var rawUser in friends2.docs) {
          final receiver = await _commonServices.getUserById((rawUser.data() as Map<String, dynamic>)['Recieveruid']);
          if (receiver == null) {
            debugPrint("rec is null ${rawUser.data()}");
            continue;
          }
          try {
            searchedFriends.add({
              "id": receiver.uId,
              "display": receiver.name.toString(),
              "senderUid": (rawUser.data() as Map<String, dynamic>)['Recieveruid'].toString(),
              "senderProfile": receiver.profilePicture.toString()
            });
          } catch (_) {
            debugPrint("Error in adding friends ${_}");
          }
        }

        // searchedFriends.addAll(friends2.docs.map((snapshot)  {
        //  final receiver =  await _commonServices.getUserById((snapshot.data() as Map<String, dynamic>)['Recieveruid']);
        //   MyLoggerServices.to.print('this is senderUid:=>${(snapshot.data() as Map<String, dynamic>)['Recieveruid']}');
        //   return {
        //     "id": receiver.uId,
        //     "display": (snapshot.data() as Map<String, dynamic>)['RecieverName'].toString(),
        //     "senderUid": (snapshot.data() as Map<String, dynamic>)['Recieveruid'].toString(),
        //     "senderProfile":""
        //   };
        // }).toList());
      }
      friends2.docs.forEach((element) {debugPrint("Total Freinds1: ${element.data()}");});
      debugPrint("Total Freinds1: ${friends2.docs.length}");
      searchedFriends
          .removeWhere((element) => element['id'] == user!.uid || element['id'] == null || element['id']?.toString().trim() == "");
      // searchedFriends.removeWhere((element) => (element['senderUid'] == user!.uid || element['Recieveruid']==user!.uid));
      debugPrint("Total Freinds: ${searchedFriends.length}");
      return searchedFriends;
    } catch (e) {
      MyLoggerServices.to.print(e);
      return <Map<String, dynamic>>[];
    }
  }*/
  //get the current user friends count
  Future<List<Map<String, dynamic>>> getUserFriends() async {
    User? user = FirebaseAuth.instance.currentUser;
    try {
      // clear friends on start to avoid duplication
      searchedFriends = [];

      //return empty array if user is not logged in
      if (user == null) return searchedFriends;
      final friendss = await _commonServices.getMyAllFriends();
      MyLoggerServices.to.print('this is user:=>' + user!.uid);
      // QuerySnapshot? friends =
      //     await db.collection('friendship').where('Recieveruid', isEqualTo: user!.uid).where('isaccepted', isEqualTo: true).get();

      // debugPrint("Total Freinds1: ${friends.docs.length}");
      for (var user in friendss) {
        try {
          searchedFriends
              .add({"id": user.uId, "display": user.name.toString(), "senderUid": user.uId, "senderProfile": user.profilePicture});
        } catch (_) {
          debugPrint("Error in adding friends ${_}");
        }
      }

      searchedFriends.removeWhere((element) => element['id'] == user.uid);
      return searchedFriends;

      /* if (friends.docs.isNotEmpty) {
        for (var snapshot in friends.docs) {
          final sender = await _commonServices.getUserById((snapshot.data() as Map<String, dynamic>)['senderUid']);
          if (sender == null) {
            debugPrint("Sender is null ${snapshot.data()}");
            continue;
          }
          try {
            searchedFriends.add({
              "id": sender.uId,
              "display": sender.name.toString(),
              "senderUid": (snapshot.data() as Map<String, dynamic>)['senderUid'].toString(),
              "senderProfile": (snapshot.data() as Map<String, dynamic>)['senderProfile'].toString()
            });
          } catch (_) {
            debugPrint("Error in adding friends ${_}");
          }
        }
      }
      QuerySnapshot? friends2 =
      await db.collection('friendship').where('senderUid', isEqualTo: user!.uid).where('isaccepted', isEqualTo: true).get();
      if (friends2.docs.isNotEmpty) {
        for (var rawUser in friends2.docs) {
          final receiver = await _commonServices.getUserById((rawUser.data() as Map<String, dynamic>)['Recieveruid']);
          if (receiver == null) {
            debugPrint("rec is null ${rawUser.data()}");
            continue;
          }
          try {
            searchedFriends.add({
              "id": receiver.uId,
              "display": receiver.name.toString(),
              "senderUid": (rawUser.data() as Map<String, dynamic>)['Recieveruid'].toString(),
              "senderProfile": receiver.profilePicture.toString()
            });
          } catch (_) {
            debugPrint("Error in adding friends ${_}");
          }
        }

        // searchedFriends.addAll(friends2.docs.map((snapshot)  {
        //  final receiver =  await _commonServices.getUserById((snapshot.data() as Map<String, dynamic>)['Recieveruid']);
        //   MyLoggerServices.to.print('this is senderUid:=>${(snapshot.data() as Map<String, dynamic>)['Recieveruid']}');
        //   return {
        //     "id": receiver.uId,
        //     "display": (snapshot.data() as Map<String, dynamic>)['RecieverName'].toString(),
        //     "senderUid": (snapshot.data() as Map<String, dynamic>)['Recieveruid'].toString(),
        //     "senderProfile":""
        //   };
        // }).toList());
      }
      friends2.docs.forEach((element) {debugPrint("Total Freinds1: ${element.data()}");});
      debugPrint("Total Freinds1: ${friends2.docs.length}");
      // searchedFriends
      //     .removeWhere((element) => element['id'] == user!.uid || element['id'] == null || element['id']?.toString().trim() == "");
      // searchedFriends.removeWhere((element) => (element['senderUid'] == user!.uid || element['Recieveruid']==user!.uid));
      debugPrint("Total Freinds: ${searchedFriends.length}");
      return searchedFriends;*/
    } catch (e) {
      MyLoggerServices.to.print(e);
      return <Map<String, dynamic>>[];
    }
  }

  // get the app all users

  //get the current user friends count
  Future<List<Map<String, dynamic>>> getAllUsers() async {
    User? user = FirebaseAuth.instance.currentUser;
    MyLoggerServices.to.print("fetching users! as user is not null #${allUsers.length}");
    try {
      if (user == null) return allUsers;
      if (allUsers.isNotEmpty) return allUsers;
      QuerySnapshot? users = await db.collection('users').get();

      if (users.docs.isNotEmpty) {
        for (var snapshot in users.docs) {
          if (snapshot.data() != null) {
            try {
              allUsers.add({
                "id": (snapshot.data() as Map<String, dynamic>)['uid']!,
                "display": (snapshot.data() as Map<String, dynamic>)['name'],
                "senderUid": (snapshot.data() as Map<String, dynamic>)['uid']!,
                "senderProfile": (snapshot.data() as Map<String, dynamic>)['profilePic']!
              });
            }catch(_){}
          }
        }
      }
      MyLoggerServices.to.print('this is all users:=>${allUsers.length}');
      return allUsers;
    } catch (e) {
      MyLoggerServices.to.print(e);
      return <Map<String, dynamic>>[];
    }
  }
}