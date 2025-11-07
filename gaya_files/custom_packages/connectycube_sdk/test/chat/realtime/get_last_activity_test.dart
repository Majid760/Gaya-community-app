import 'package:connectycube_sdk/connectycube_chat.dart';
import 'package:flutter_test/flutter_test.dart';

import '../chat_test_utils.dart';

Future<void> main() async {
  setUpAll(beforeTestPreparations);

  group("Tests GET_LAST_ACTIVITY", () {
    test("testGetLastActivity", () async {
      await CubeChatConnection.instance
          .login(CubeUser(
              id: config["user_1_id"], password: config["user_1_pass"]))
          .then((loggedUser) async {
        logTime("Success login to the chat $loggedUser");
        await CubeChatConnection.instance
            .getLasUserActivity(config["user_2_id"])
            .then((seconds) {
          logTime("Success get user last activity $seconds");
        }).catchError((onError) {
          logTime("Error get user last activity $onError");
        });
      }).catchError((error) {
        logTime("Error login to the chat $error");
      });
    });
  });

  tearDownAll(deleteSession);
}
