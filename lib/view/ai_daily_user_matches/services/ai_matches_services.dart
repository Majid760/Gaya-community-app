import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/cupertino.dart';
import 'package:gaya/view/ai_daily_user_matches/model/ai_user_matched_model.dart';

abstract class AIMatches {
  Future<bool> sendUserAIMatchRequest({required String documentId, required AiUserMatchedModel aiUserMatchedModels});
  Future<AiUserMatchedModel?> getMyAIMatchedUser({required String userId});
  Future<bool> removeMatchedUserDocs({required String matchCreatorId, required String matchUserId});
  Future<bool> removeMatchRequestDoc({required String matchCreatorId});
}

class AIMatchServices implements AIMatches {
  final ref = FirebaseFirestore.instance.collection("matches");

  @override
  Future<AiUserMatchedModel?> getMyAIMatchedUser({required String userId}) async {
    try {
      final result = await ref.doc(userId).get();
      if (result.exists) {
        return AiUserMatchedModel.fromJson(result.data()!);
      }
    } catch (e) {
      debugPrint(e.toString());
      return null;
    }
    return null;
  }

  @override
  Future<bool> sendUserAIMatchRequest({required String documentId, required AiUserMatchedModel aiUserMatchedModels}) async {
    try {
      await ref.doc(documentId).set(
          aiUserMatchedModels.toJson(),
          SetOptions(
            merge: true,
          ));
    } catch (e) {
      debugPrint(e.toString());
      return false;
    }
    return true;
  }

  @override
  Future<bool> removeMatchedUserDocs({required String matchCreatorId, required String matchUserId}) async {
    try {
      await ref.doc(matchCreatorId).delete();
      await ref.doc(matchUserId).delete();
    } catch (e) {
      debugPrint(e.toString());
      return false;
    }
    return true;
  }

  @override
  Future<bool> removeMatchRequestDoc({required String matchCreatorId}) async {
    try {
      await ref.doc(matchCreatorId).delete();
    } catch (e) {
      debugPrint(e.toString());
      return false;
    }
    return true;
  }
}
