import 'package:flutter_test/flutter_test.dart';

import 'package:connectycube_sdk/connectycube_meetings.dart';

import 'meetings_test_utils.dart';

Future<void> main() async {
  await beforeTestPreparations();

  group("Tests DELETE meetings", () {
    test("testDeleteById", () async {
      int now = DateTime.now().millisecondsSinceEpoch;
      CubeMeeting meeting = CubeMeeting()
        ..attendees = [
          CubeMeetingAttendee(userId: config['user_1_id']),
          CubeMeetingAttendee(userId: config['user_2_id'])
        ]
        ..startDate = now
        ..endDate = now + 1 * 24 * 60 * 60
        ..name = 'Test meeting';

      await createMeeting(meeting).then((createdMeeting) async {
        logTime("Created meeting $createdMeeting");

        assert(createdMeeting.meetingId != null);

        return deleteMeeting(createdMeeting.meetingId!);
      }).catchError((onError) {
        logTime("Error when delete meeting $onError");
        assert(onError == null);
      });
    });
  });
}
