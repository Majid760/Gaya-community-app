import 'package:collection/collection.dart' show IterableExtension;
import 'package:connectycube_sdk/connectycube_chat.dart';
import 'package:connectycube_sdk/connectycube_whiteboard.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:http/http.dart';

import 'whiteboards_test_utils.dart';

Future<void> main() async {
  var createdDialogId;

  setUpAll(() async {
    await beforeTestPreparations();

    CubeDialog newDialog = CubeDialog(CubeDialogType.PRIVATE);
    newDialog.occupantsIds = [config['user_2_id']];

    createdDialogId = (await createDialog(newDialog)).dialogId;
  });

  group("Tests WHITEBOARDS", () {
    test("testCreateWhiteboard", () async {
      CubeWhiteboard whiteboard = CubeWhiteboard()
        ..name = "Test whiteboard"
        ..chatDialogId = createdDialogId;

      var createdWhiteboardId;
      await createWhiteboard(whiteboard).then((createdWhiteboard) {
        logTime("Success CREATE_WHITEBOARD: $createdWhiteboard");
        createdWhiteboardId = createdWhiteboard.whiteboardId;
        assert(createdWhiteboard.whiteboardId != null);
        assert(createdWhiteboard.name == whiteboard.name);
        assert(createdWhiteboard.chatDialogId == whiteboard.chatDialogId);
        assert(createdWhiteboard.userId == config['user_1_id']);
      }).catchError((onError) {
        logTime("Error CREATE_WHITEBOARD");
        assert(onError == null);
      }).whenComplete(() async {
        logTime("Completed CREATE_WHITEBOARD");
        if (createdWhiteboardId != null) {
          await deleteWhiteboard(createdWhiteboardId);
        }
      });
    });

    test("testGetWhiteboard", () async {
      CubeWhiteboard whiteboard = CubeWhiteboard()
        ..name = "Test whiteboard"
        ..chatDialogId = createdDialogId;

      var createdWhiteboardId =
          (await createWhiteboard(whiteboard)).whiteboardId;

      await getWhiteboards(createdDialogId).then((whiteboards) {
        logTime("Success GET_WHITEBOARDS: $whiteboards");
        var createdWhiteboard = whiteboards.firstWhereOrNull(
            (element) => element.whiteboardId == createdWhiteboardId);
        assert(createdWhiteboard != null);
      }).catchError((onError) {
        logTime("Error GET_WHITEBOARDS");
        assert(onError == null);
      }).whenComplete(() async {
        logTime("Completed GET_WHITEBOARDS");
        if (createdWhiteboardId != null) {
          await deleteWhiteboard(createdWhiteboardId);
        }
      });
    });

    test("testWhiteboardUrl", () async {
      CubeWhiteboard whiteboard = CubeWhiteboard()
        ..name = "Test whiteboard"
        ..chatDialogId = createdDialogId;

      var createdWhiteboard = await createWhiteboard(whiteboard);
      var url = createdWhiteboard.getUrlForUser('Test user');

      logTime("WHITEBOARD URL = $url");

      final response = await get(Uri.parse(url));

      logTime("statusCode = ${response.statusCode}");
      assert(response.statusCode == 200);

      await deleteWhiteboard(createdWhiteboard.whiteboardId!);
    });

    test("testUpdateWhiteboard", () async {
      CubeWhiteboard whiteboard = CubeWhiteboard()
        ..name = "Test whiteboard"
        ..chatDialogId = createdDialogId;

      String updatedName = 'Updated Name';

      var createdWhiteboardId =
          (await createWhiteboard(whiteboard)).whiteboardId;

      await updateWhiteboard(createdWhiteboardId!, updatedName)
          .then((updatedWhiteboard) {
        assert(updatedWhiteboard.name == updatedName);
      }).catchError((onError) {
        logTime("Error UPDATE_WHITEBOARD");
        assert(onError == null);
      }).whenComplete(() async {
        logTime("Completed UPDATE_WHITEBOARD");
        await deleteWhiteboard(createdWhiteboardId);
      });
    });

    test("testDeleteWhiteboard", () async {
      CubeWhiteboard whiteboard = CubeWhiteboard()
        ..name = "Test whiteboard"
        ..chatDialogId = createdDialogId;

      var createdWhiteboardId =
          (await createWhiteboard(whiteboard)).whiteboardId;

      await deleteWhiteboard(createdWhiteboardId!).then((voidResult) {
        logTime("Success DELETE_WHITEBOARD");
      }).catchError((onError) {
        logTime("Error DELETE_WHITEBOARD");
        assert(onError == null);
      });
    });
  });

  tearDownAll(() async {
    await deleteDialog(createdDialogId, true);
    await deleteSession();
  });
}
