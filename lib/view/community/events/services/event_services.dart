import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/cupertino.dart';
import 'package:gaya/view/community/events/constants/event_strings.dart';
import 'package:get/get.dart';

abstract class CEventServices {
  Future addEvents(String documentId, createdByUserId, eventName, eventType,
      {required DateTime eventStartTime, required DateTime eventEndTime});

  Future<Query<Map<String, dynamic>?>?> getEvents(String documentId, DateTime selectedDate);
  Future<Query<Map<String, dynamic>?>?> getAllEvents(String documentId);
}

class EventServices implements CEventServices {
  final ref = FirebaseFirestore.instance.collection("communities");

  @override
  Future addEvents(String documentId, createdByUserId, eventName, eventType,
      {required DateTime eventStartTime, required DateTime eventEndTime}) async {
    try {
      await ref.doc(documentId).collection(EventFieldStrings.collectionName).add({
        EventFieldStrings.createdByUserId: createdByUserId,
        EventFieldStrings.eventName: eventName,
        EventFieldStrings.eventType: eventType,
        EventFieldStrings.eventSTime: eventStartTime,
        EventFieldStrings.eventETime: eventEndTime,
      });
    } catch (e) {
      debugPrint(e.toString());
    }
  }

  @override
  Future<Query<Map<String, dynamic>?>?> getEvents(
      String documentId, DateTime selectedDate) async {
    final d1 = DateTime(
        selectedDate.year, selectedDate.month, selectedDate.day, 0, 0, 0, 0, 0);
    final d2 = DateTime(selectedDate.year, selectedDate.month, selectedDate.day,
        23, 0, 0, 0, 0);
    try {
      final query = ref
          .doc(documentId)
          .collection(EventFieldStrings.collectionName)
          .where(
            EventFieldStrings.eventSTime,
            isLessThanOrEqualTo: d2,
          )
          .where(
            EventFieldStrings.eventSTime,
            isGreaterThanOrEqualTo: d1,
          )
          .orderBy(EventFieldStrings.eventSTime, descending: true);
      if (query.isBlank == true) return null;
      return query;
    } catch (_) {}
    return null;
  }

  @override
  Future<Query<Map<String, dynamic>?>?> getAllEvents(String documentId) async {
    try {
      final allData =
          ref.doc(documentId).collection(EventFieldStrings.collectionName).orderBy(EventFieldStrings.eventSTime, descending: true);
      if (allData.isBlank == true) return null;
      return allData;
    } catch (_) {}
    return null;
  }
}
