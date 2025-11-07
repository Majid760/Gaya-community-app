import 'package:connectycube_sdk/connectycube_meetings.dart';
import 'package:connectycube_sdk/connectycube_core.dart' as connectyCube;
import 'package:flutter_test/flutter_test.dart';

import 'meetings_test_utils.dart';

Future<void> main() async {
  await beforeTestPreparations();

  group("Tests CREATE meetings", () {
    test("testCreateNormal", () async {
      int now = DateTime.now().millisecondsSinceEpoch ~/ 1000;
      CubeMeeting meeting = CubeMeeting()
        ..attendees = [
          CubeMeetingAttendee(userId: config['user_1_id']),
          CubeMeetingAttendee(userId: config['user_2_id'])
        ]
        ..startDate = now
        ..endDate = now + 60 * 60
        ..withChat = true
        ..record = false
        ..name = 'Test meeting';

      String? createdMeetingId;
      await createMeeting(meeting).then((createdMeeting) {
        logTime("Created meeting $createdMeeting");
        createdMeetingId = createdMeeting.meetingId;

        assert(createdMeeting.meetingId != null);
        assert(createdMeeting.name == meeting.name);
        assert(createdMeeting.startDate == meeting.startDate);
        assert(createdMeeting.endDate == meeting.endDate);
        assert(createdMeeting.chatDialogId != null);
        assert(createdMeeting.hostId == config['user_1_id']);
      }).catchError((onError) {
        logTime("Error when create meeting $onError");
        assert(onError == null);
      }).whenComplete(() async {
        if (!connectyCube.isEmpty(createdMeetingId)) {
          await deleteMeeting(createdMeetingId!);
        }
      });
    });

    test("testCreateNormalV2", () async {
      int now = DateTime.now().millisecondsSinceEpoch ~/ 1000;
      CubeMeeting meeting = CubeMeeting()
        ..attendees = [
          CubeMeetingAttendee(userId: config['user_1_id']),
          CubeMeetingAttendee(userId: config['user_2_id'])
        ]
        ..startDate = now
        ..endDate = now + 60 * 60
        ..withChat = true
        ..record = false
        ..name = 'Test meeting'
        ..notifyBefore = CubeMeetingNotifyBefore(TimeMetric.HOURS, 1)
        ..notify = true
        ..scheduled = true
        ..public = true;

      String? createdMeetingId;
      await createMeeting(meeting).then((createdMeeting) {
        logTime("Created meeting $createdMeeting");
        createdMeetingId = createdMeeting.meetingId;

        assert(createdMeeting.meetingId != null);
        assert(createdMeeting.name == meeting.name);
        assert(createdMeeting.startDate == meeting.startDate);
        assert(createdMeeting.endDate == meeting.endDate);
        assert(createdMeeting.chatDialogId != null);
        assert(createdMeeting.hostId == config['user_1_id']);
        assert(createdMeeting.record == false);
        assert(createdMeeting.notify == true);
        assert(createdMeeting.scheduled == true);
        assert(createdMeeting.public == true);
        assert(createdMeeting.notifyBefore != null);
        assert(createdMeeting.notifyBefore!.metric == TimeMetric.HOURS);
        assert(createdMeeting.notifyBefore!.value == 1);
      }).catchError((onError) {
        logTime("Error when create meeting $onError");
        assert(onError == null);
      }).whenComplete(() async {
        if (!connectyCube.isEmpty(createdMeetingId)) {
          await deleteMeeting(createdMeetingId!);
        }
      });
    });

    // test("testCreateWithEmptyName", () async {
    //   int now = DateTime.now().millisecondsSinceEpoch;
    //   CubeMeeting meeting = CubeMeeting()
    //     ..attendees = [
    //       CubeMeetingAttendee(userId: config['user_1_id']),
    //       CubeMeetingAttendee(userId: config['user_1_id'])
    //     ]
    //     ..startDate = now
    //     ..endDate = now + 1 * 24 * 60 * 60
    //     ..withChat = true
    //     ..record = false;
    //
    //   await createMeeting(meeting).catchError((onError) {
    //     logTime("Error when create meeting $onError");
    //     assert(onError != null);
    //   });
    // });
  });
}
