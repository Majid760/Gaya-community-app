import 'package:connectycube_sdk/connectycube_custom_objects.dart';
import 'package:flutter_test/flutter_test.dart';

import '../custom_objects/custom_object_test_class.dart';
import 'core_test_utils.dart';

Future<void> main() async {
  await initCubeFramework();

  group("Tests SESSION AUTO MANAGEMENT", () {
    test("testAutoCreateEmptySession", () async {
      await signIn(CubeUser(
              login: "flutter_sdk_tests_user",
              password: "flutter_sdk_tests_user"))
          .then((cubeUser) async {

        await deleteSession();
      }).catchError((onError) {
        logTime(onError.toString());
        assert(onError == null);
      });
    });

    test("testUseUsersSession", () async {
      CubeSettings.instance.onSessionRestore = () => createTestSession();

      await getCustomObjectsByClassName(testClassName).then((result) async {
        await deleteSession();
      }).catchError((onError) {
        logTime(onError.toString());
        assert(onError == null);
      });
    });

    test("testUseCustomSession", () async {
      await createTestSession();

      int? sessionId = CubeSessionManager.instance.activeSession!.id;
      String token = CubeSessionManager.instance.getToken();
      String expirationDate = CubeSessionManager.instance
          .getTokenExpirationDate()!
          .toIso8601String();

      CubeSessionManager.instance.deleteActiveSession();

      CubeSessionManager.instance.activeSession = CubeSession.fromJson({
        // 'id': sessionId,
        'token': token,
        // 'token_expiration_date': expirationDate
      });

      await getCustomObjectsByClassName(testClassName).then((result) async {
        await deleteSession();
      }).catchError((onError) {
        logTime(onError.toString());
        assert(onError == null);
      });
    });
  });
}
