import 'package:cloud_firestore/cloud_firestore.dart';

import '../constants/event_strings.dart';

class EventModel {
  late String createdByUserId;
  late String eventName;
  late String eventType;
  late DateTime eventStartTime;
  DateTime? eventEndTime;

  EventModel({
    required this.createdByUserId,
    required this.eventName,
    required this.eventType,
    required this.eventStartTime,
    this.eventEndTime,
  });

  EventModel.fromJson(dynamic json) {
    createdByUserId = json[EventFieldStrings.createdByUserId];
    eventName = json[EventFieldStrings.eventName];
    eventType = json[EventFieldStrings.eventType];
    eventStartTime = json[EventFieldStrings.eventSTime].toDate();
    eventEndTime = json[EventFieldStrings.eventETime]?.toDate();
  }

  /// By default [isUpdate] is false
  Map<String, dynamic> toJson({bool isUpdate = false}) {
    final map = <String, dynamic>{};
    map[EventFieldStrings.createdByUserId] = createdByUserId;
    map[EventFieldStrings.eventName] = eventName;
    map[EventFieldStrings.eventType] = eventType;
    map[EventFieldStrings.eventSTime] = eventStartTime;

    /// if toJson is for update, we dont want to over write value of
    /// createdAt, so for this reason added IF_ELSE
    if (isUpdate) {
      map['updatedAt'] = FieldValue.serverTimestamp();
    } else {
      map['createdAt'] = FieldValue.serverTimestamp();
    }

    return map;
  }
}
