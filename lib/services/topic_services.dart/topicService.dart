import 'package:cloud_firestore/cloud_firestore.dart';

abstract class TopicServiceImpl {
  Future<void> sendNewInterestSuggestion({String interest});
  Future<void> saveUserIntrests({required List<Map<String, dynamic>> intrests, required String userId});
}

class TopicServices implements TopicServiceImpl {
  @override
  Future<void> sendNewInterestSuggestion({String interest = ''}) async {
    try {
      await FirebaseFirestore.instance
          .collection('userInterestSuggestions')
          .add({'interest': interest, 'status': 'pending', 'createdOn': FieldValue.serverTimestamp()});
    } catch (e) {
      rethrow;
    }
  }

  @override
  Future<void> saveUserIntrests({required List<Map<String, dynamic>> intrests, required String userId}) async {
    try {
      await FirebaseFirestore.instance.collection('users').doc(userId).update({'interests': intrests});
    } catch (e) {
      rethrow;
    }
  }
}
