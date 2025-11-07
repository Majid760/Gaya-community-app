import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';
import 'package:get/utils.dart';

import '../../../../model/community.model.dart';

abstract class QuestionnaireMethods {
  Future<Query<Map<String, dynamic>?>?> getQuestionnaires({required String communityId});

  Future<void> addQuestionnaire({required List<Questionnaire> questionnaires, required String communityId});

  Future<void> removeQuestionnaire({required String communityId});

  Future<void> addAnswers({required String communityId, required String userId, required Map<dynamic, dynamic> answer});
}

class QuestionnaireServices implements QuestionnaireMethods {
  final ref = FirebaseFirestore.instance.collection(QuestionnaireString.commColl);

  @override
  Future<Query<Map<String, dynamic>?>?> getQuestionnaires({required String communityId}) async {
    final rawQuestionnaires = ref.doc(communityId).collection(QuestionnaireString.quesCollNa);
    if (rawQuestionnaires.isBlank == true) return null;
    return rawQuestionnaires;
  }

  @override
  Future<void> addQuestionnaire({required List<Questionnaire> questionnaires, required String communityId}) async {
    // make it order by
    questionnaires = questionnaires.reversed.toList();
    List<Map<String, dynamic>> questionnairesMap = questionnaires.map((questionnaire) => questionnaire.toMap()).toList();
    try {
      WriteBatch batch = FirebaseFirestore.instance.batch();

      int i = 0;
      for (Map<String, dynamic> questionnaireMap in questionnairesMap) {
        i = i + 1;

        /// storing by micro to have unique id as sorted
        var docRef = ref.doc(communityId).collection(QuestionnaireString.quesCollNa).doc('${DateTime.now().microsecondsSinceEpoch + i}');
        batch.set(docRef, questionnaireMap);
      }
      await batch.commit();
    } catch (e) {
      debugPrint(e.toString());
    }
  }

  @override
  Future<void> removeQuestionnaire({required String communityId}) async {}

  @override
  Future<void> addAnswers({required String communityId, required String userId, required Map<dynamic, dynamic> answer}) async {
    await ref
        .doc(communityId)
        .collection(QuestionnaireString.commMembersColl)
        .doc(userId)
        .update({QuestionnaireString.quesFieldNa: answer});
  }
}

class QuestionnaireString {
  static String commColl = "communities";
  static String quesCollNa = "questionnaires";
  static String quesFieldNa = "questionnaires";
  static String commMembersColl = "communityMembers";
}
