import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/foundation.dart';
import 'package:gaya/utils/logger.dart';

///
/// This class is all related to super admin
/// All the super admin related services will be here
///
abstract class SuperAdminServicesInterface {
  Future<bool> checkIfSuperAdmin();

  /// Ban, Unban()

  /// removeFromFeed()
}

class SuperAdminServices extends SuperAdminServicesInterface {
  /// Check if the current user is a super admin
  /// It will return [false] if the user is not logged in || the user is not a super admin
  @override
  Future<bool> checkIfSuperAdmin() async {
    bool isSuperAdmin = false;
    try {
      final appUser = FirebaseAuth.instance.currentUser;

      if (appUser?.uid == null) {
        throw Exception("User is not logged in");
      }
      isSuperAdmin = (await reference.doc(appUser!.uid).get()).exists;

      if (isSuperAdmin) {
        _logger.print("‼️‼️‼️‼️‼️\n😄😄😄😄User is a super admin😄😄😄😄\n‼️‼️‼️‼️");
      }
    } catch (e) {
      _logger.print("Error in checkIfSuperAdmin: $e");
    }

    return isSuperAdmin;
  }

  SuperAdminServices._();

  static SuperAdminServices? _superAdminServices;

  static SuperAdminServices get instance => _superAdminServices ??= SuperAdminServices._();

  final reference = FirebaseFirestore.instance.collection('admins');
  final userReference = FirebaseFirestore.instance.collection('users');
  final postReference = FirebaseFirestore.instance.collection('communityposts');
  final _logger = MyLoggerServices.to;
}

///
/// Extension for User related Super Services.
///
extension superUser on SuperAdminServices {
  /// Ban a user completely from app.
  Future<void> banUser({required String userId}) async {
    debugPrint("🔥🔥\nBan user with id: $userId\n🔥🔥");
    await userReference.doc(userId).update({'isActive': false});
    debugPrint("Successfully banned user with id: $userId");
  }

  /// UnBan a user completely from app.
  Future<void> unBanUser({required String userId}) async {
    debugPrint("🔥🔥\nUnBan user with id: $userId\n🔥🔥");

    await userReference.doc(userId).update({'isActive': true});
    debugPrint("Successfully unbanned user with id: $userId");
  }
}

///
/// Extension for Post related SuperServices.
///
extension SuperPost on SuperAdminServices {
  /// Toggle `showInFeed` to hide post from feed.
  Future<void> removeFromFeed({required String postId}) async {
    await postReference.doc(postId).update({"showInFeed": false});
  }
}
