import 'package:collection/src/iterable_extensions.dart';
import 'package:flutter_test/flutter_test.dart';

import 'package:connectycube_sdk/connectycube_core.dart';

import 'core_test_utils.dart';

Future<void> main() async {
  setUpAll(initCubeFramework);
  setUp(createTestSession);

  group("Tests GET USERS", () {
    test("testGetUserByID", () async {
      await getUserById(config['user_2_id']).then((cubeUser) async {
        assert(cubeUser != null);
        assert(cubeUser!.login == config['user_2_login']);
        assert(cubeUser!.id == config['user_2_id']);
      }).catchError((onError) {
        logTime(onError.toString());
        assert(onError == null);
      });
    });

    test("testGetUsersByIDs", () async {
      Set<int> ids = {
        config['user_1_id'],
        config['user_2_id'],
        config['user_3_id'],
      };

      await getAllUsersByIds(ids).then((users) async {
        assert(users?.items
                .firstWhereOrNull((user) => user.id == config['user_1_id']) !=
            null);
        assert(users?.items
                .firstWhereOrNull((user) => user.id == config['user_2_id']) !=
            null);
        assert(users?.items
                .firstWhereOrNull((user) => user.id == config['user_3_id']) !=
            null);
      }).catchError((onError) {
        logTime(onError.toString());
        assert(onError == null);
      });
    });

    test("testGetUserByLOGIN", () async {
      await getUserByLogin(config['user_2_login']).then((cubeUser) async {
        assert(cubeUser != null);
        assert(cubeUser!.login == config['user_2_login']);
        assert(cubeUser!.id == config['user_2_id']);
      }).catchError((onError) {
        logTime(onError.toString());
        assert(onError == null);
      });
    });

    test("testGetAllUsers", () async {
      var itemsPerPage = 3;

      await GetUsersQuery.byFilter(
              null, null, {'page': 1, 'per_page': itemsPerPage})
          .perform()
          .then((pagedResult) {
        assert(pagedResult.items.length <= itemsPerPage);
      }).catchError((onError) {
        logTime(onError.toString());
        assert(onError == null);
      });
    });
  });

  tearDown(deleteSession);
}
