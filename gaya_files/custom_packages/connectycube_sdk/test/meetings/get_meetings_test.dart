import 'package:collection/collection.dart' show IterableExtension;
import 'package:flutter_test/flutter_test.dart';

import 'package:connectycube_sdk/connectycube_core.dart' as core;
import 'package:connectycube_sdk/connectycube_meetings.dart';

import 'meetings_test_utils.dart';

Future<void> main() async {
  await beforeTestPreparations();

  group("Tests GET meetings", () {
    test("testGetAll", () async {
      int now = DateTime.now().millisecondsSinceEpoch;
      CubeMeeting meeting = CubeMeeting()
        ..attendees = [
          CubeMeetingAttendee(userId: config['user_1_id']),
          CubeMeetingAttendee(userId: config['user_2_id'])
        ]
        ..startDate = now
        ..endDate = now + 1 * 24 * 60 * 60
        ..name = 'Test meeting';

      String? createdMeetingId;
      await createMeeting(meeting).then((createdMeeting) async {
        logTime("Created meeting: $createdMeeting");
        createdMeetingId = createdMeeting.meetingId;

        assert(createdMeeting.meetingId != null);

        await getMeetings().then((meetings) async {
          logTime("Got meetings: $meetings");
          assert(meetings.length != 0);

          CubeMeeting? crestedMeeting = meetings.firstWhereOrNull(
              (element) => element.meetingId == createdMeetingId);
          assert(crestedMeeting != null);
        });
      }).catchError((onError) {
        logTime("Error when delete meeting $onError");
        assert(onError == null);
      }).whenComplete(() async {
        if (!core.isEmpty(createdMeetingId)) {
          await deleteMeeting(createdMeetingId!);
        }
      });
    });

    test("testGetPaged", () async {
      int now = DateTime.now().millisecondsSinceEpoch;
      CubeMeeting meeting = CubeMeeting()
        ..attendees = [
          CubeMeetingAttendee(userId: config['user_1_id']),
          CubeMeetingAttendee(userId: config['user_2_id'])
        ]
        ..startDate = now
        ..endDate = now + 1 * 24 * 60 * 60
        ..name = 'Test meeting'
        ..notifyBefore = CubeMeetingNotifyBefore(TimeMetric.HOURS, 1)
        ..notify = true
        ..scheduled = true
        ..public = true;

      String? createdMeetingId;
      await createMeeting(meeting).then((createdMeeting) async {
        logTime("Created meeting: $createdMeeting");
        createdMeetingId = createdMeeting.meetingId;

        assert(createdMeeting.meetingId != null);

        await getMeetingsPaged().then((result) async {
          logTime("Got meetings: $result");
          assert(result.items.length != 0);

          CubeMeeting? crestedMeeting = result.items.firstWhereOrNull(
              (element) => element.meetingId == createdMeetingId);
          assert(crestedMeeting != null);
        });
      }).catchError((onError) {
        logTime("Error when delete meeting $onError");
        // assert(onError == null);
      }).whenComplete(() async {
        if (!core.isEmpty(createdMeetingId)) {
          await deleteMeeting(createdMeetingId!);
        }
      });
    });

    test("testGetById", () async {
      int now = DateTime.now().millisecondsSinceEpoch;
      CubeMeeting meeting = CubeMeeting()
        ..attendees = [
          CubeMeetingAttendee(userId: config['user_1_id']),
          CubeMeetingAttendee(userId: config['user_2_id'])
        ]
        ..startDate = now
        ..endDate = now + 1 * 24 * 60 * 60
        ..name = 'Test meeting';

      String? createdMeetingId;
      await createMeeting(meeting).then((createdMeeting) async {
        logTime("Created meeting: $createdMeeting");
        createdMeetingId = createdMeeting.meetingId;

        assert(createdMeeting.meetingId != null);

        return getMeetings({'_id': createdMeetingId}).then((meetings) {
          logTime("Got meetings: $createdMeeting");
          assert(meetings.length == 1);
          assert(meetings.first.meetingId == createdMeetingId);
        });
      }).catchError((onError) {
        logTime("Error when delete meeting $onError");
        assert(onError == null);
      }).whenComplete(() async {
        if (!core.isEmpty(createdMeetingId)) {
          await deleteMeeting(createdMeetingId!);
        }
      });
    });
  });
}
