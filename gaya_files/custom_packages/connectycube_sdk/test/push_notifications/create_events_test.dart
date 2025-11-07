import 'package:connectycube_sdk/connectycube_pushnotifications.dart';
import 'package:flutter_test/flutter_test.dart';

import 'push_notifications_test_utils.dart';

Future<void> main() async {
  setUpAll(initCubeFramework);

  group("Tests CREATE events", () {
    test("testCreateEvent", () async {
      await createTestSession();

      CreateEventParams params = CreateEventParams();
      params.parameters = {
        'ios_voip': 1,
        'message': "Test message", // Change this to a name
        'dialog_id': "erhfehfbjbjwvjnw-vdws",
        'isVideo': true,
        'callerId': config['user_1_id'],
        'uuid': '5ad9e5e7-5ee0-4582-acf6-3161b50cd394',
      };

      params.notificationType = NotificationType.PUSH;
      params.environment = CubeEnvironment.DEVELOPMENT;
      params.usersIds = [317688, 893225, 1898894, config['user_3_id']];

      await createEvent(params.getEventForRequest()).then((cubeEvents) {
        log("Event sent successfully.", "CCM:createEvent:success: $cubeEvents");
      }).catchError((error) {
        log("Error sending event.", "CCM:createEvent:error: $error");
      });
    });
  });
}
