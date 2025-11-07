import 'package:flutter_test/flutter_test.dart';

import 'package:connectycube_sdk/connectycube_core.dart' as core;
import 'package:connectycube_sdk/connectycube_meetings.dart';

import 'meetings_test_utils.dart';

Future<void> main() async {
  await beforeTestPreparations();

  group("Tests UPDATE meeting", () {
    test("testUpdateName", () async {
      String updatedName = 'Updated name';
      int now = DateTime.now().millisecondsSinceEpoch;
      CubeMeeting meeting = CubeMeeting()
        ..attendees = [
          CubeMeetingAttendee(userId: config['user_1_id']),
          CubeMeetingAttendee(userId: config['user_2_id'])
        ]
        ..startDate = now
        ..endDate = now + 1 * 24 * 60 * 60
        ..withChat = true
        ..record = false
        ..name = 'Test meeting';

      String? createdMeetingId;
      await createMeeting(meeting).then((createdMeeting) async {
        logTime("Created meeting $createdMeeting");
        createdMeetingId = createdMeeting.meetingId;

        meeting.meetingId = createdMeetingId;
        meeting.name = updatedName;

        await updateMeeting(meeting).then((updatedMeeting) {
          assert(updatedMeeting.name == updatedName);
        });
      }).catchError((onError) {
        logTime("Error when create meeting $onError");
        assert(onError == null);
      }).whenComplete(() async {
        if (!core.isEmpty(createdMeetingId)) {
          await deleteMeeting(createdMeetingId!);
        }
      });
    });

    test("testUpdateById", () async {
      int now = DateTime.now().millisecondsSinceEpoch;
      CubeMeeting meeting = CubeMeeting()
        ..attendees = [
          CubeMeetingAttendee(userId: config['user_1_id']),
          CubeMeetingAttendee(userId: config['user_2_id'])
        ]
        ..startDate = now
        ..endDate = now + 1 * 24 * 60 * 60
        ..record = false
        ..name = 'Test meeting';

      String? createdMeetingId;
      await createMeeting(meeting).then((createdMeeting) async {
        logTime("Created meeting $createdMeeting");
        createdMeetingId = createdMeeting.meetingId;

        await updateMeetingById(createdMeeting.meetingId!, {'record': true}).then((updatedMeeting) async {
          assert(updatedMeeting.record == true);

          await updateMeetingById(createdMeeting.meetingId!, {'record': false}).then((updatedMeeting) {
            assert(updatedMeeting.record == false);
          });
        });
      }).catchError((onError) {
        logTime("Error when update meeting $onError");
        assert(onError == null);
      }).whenComplete(() async {
        if (!core.isEmpty(createdMeetingId)) {
          await deleteMeeting(createdMeetingId!);
        }
      });
    });

    test("testUpdateDates", () async {
      int startDate = DateTime.now().millisecondsSinceEpoch;
      int endDate = startDate + 1 * 24 * 60 * 60;

      int updatedStartDate = startDate + 2 * 24 * 60 * 60;
      int updatedEndDate = startDate + 3 * 24 * 60 * 60;

      CubeMeeting meeting = CubeMeeting()
        ..attendees = [
          CubeMeetingAttendee(userId: config['user_1_id']),
          CubeMeetingAttendee(userId: config['user_2_id'])
        ]
        ..startDate = startDate
        ..endDate = endDate
        ..withChat = true
        ..record = false
        ..name = 'Test meeting';

      String? createdMeetingId;
      await createMeeting(meeting).then((createdMeeting) async {
        logTime("Created meeting $createdMeeting");
        createdMeetingId = createdMeeting.meetingId;

        meeting.meetingId = createdMeetingId;
        meeting.startDate = updatedStartDate;
        meeting.endDate = updatedEndDate;

        await updateMeeting(meeting).then((updatedMeeting) {
          assert(updatedMeeting.startDate == updatedStartDate);
          assert(updatedMeeting.endDate == updatedEndDate);
        });
      }).catchError((onError) {
        logTime("Error when create meeting $onError");
        assert(onError == null);
      }).whenComplete(() async {
        if (!core.isEmpty(createdMeetingId)) {
          await deleteMeeting(createdMeetingId!);
        }
      });
    });

    test("testUpdateAttendees", () async {
      int startDate = DateTime.now().millisecondsSinceEpoch;
      int endDate = startDate + 1 * 24 * 60 * 60;

      var attendees = [
        CubeMeetingAttendee(userId: config['user_1_id']),
        CubeMeetingAttendee(userId: config['user_2_id'])
      ];

      CubeMeeting meeting = CubeMeeting()
        ..attendees = attendees
        ..startDate = startDate
        ..endDate = endDate
        ..name = 'Test meeting';

      String? createdMeetingId;
      await createMeeting(meeting).then((createdMeeting) async {
        logTime("Created meeting $createdMeeting");
        createdMeetingId = createdMeeting.meetingId;

        var updatedAttendees = [
          CubeMeetingAttendee(
              userId: config['user_3_id'], email: 'test@email.com'),
        ];
        meeting.meetingId = createdMeetingId;
        meeting.attendees = updatedAttendees;

        await updateMeeting(meeting).then((updatedMeeting) {
          assert(updatedMeeting.attendees?.length == updatedAttendees.length);
          assert(updatedMeeting.attendees?.first.userId ==
              updatedAttendees.first.userId);
          assert(updatedMeeting.attendees?.first.email ==
              updatedAttendees.first.email);
        });
      }).catchError((onError) {
        logTime("Error when create meeting $onError");
        assert(onError == null);
      }).whenComplete(() async {
        if (!core.isEmpty(createdMeetingId)) {
          await deleteMeeting(createdMeetingId!);
        }
      });
    });
  });
}
