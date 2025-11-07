import 'package:universal_io/io.dart';

import 'package:connectycube_sdk/connectycube_sdk.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:collection/collection.dart' show IterableExtension;

import '../chat_test_utils.dart';

Future<void> main() async {
  setUpAll(beforeTestPreparations);

  group("Tests EDIT_DELETE_MSG realtime", () {
    test("testEditMessage", () async {
      List<int> occupantsIds = [
        config['user_1_id'],
        config['user_2_id'],
        // 563546,
      ];

      CubeDialog newDialog = CubeDialog(CubeDialogType.GROUP, name: "Name");
      newDialog.occupantsIds = occupantsIds;

      CubeDialog createdDialog = await createDialog(newDialog);

      await CubeChatConnection.instance
          .login(CubeUser(
              id: config["user_1_id"], password: config["user_1_pass"]))
          .then((loggedUser) {
        logTime("Success login to the chat $loggedUser");
      }).catchError((error) {
        logTime("Error login to the chat $error");
      });

      CubeMessage message = CubeMessage()
        ..body = 'Body'
        ..saveToHistory = true
        ..markable = true
        ..dialogId = createdDialog.dialogId;

      await createdDialog.sendMessage(message).then((sentMessage) async {
        logTime("Success SENT MESSAGE: ${sentMessage.messageId}");
      }).catchError((onError) async {
        logTime("Error SENT MESSAGE $onError");
        assert(onError == null);
      });

      var updatedBody = 'Body updated';

      message.body = updatedBody;
      await createdDialog.editMessage(message, false).then((voidRes) async {
        logTime("Success EDIT MESSAGE");
      }).catchError((onError) async {
        logTime("Error EDIT MESSAGE $onError");
        assert(onError == null);
      });

      sleep(Duration(seconds: 2));

      await getMessages(createdDialog.dialogId!, {"_id": message.messageId})
          .then((pagerResult) async {
        logTime("Success GET MESSAGES: ${pagerResult!.items}");
        assert(pagerResult.items.isNotEmpty);

        var msg = pagerResult.items.firstWhereOrNull((msg) =>
            msg.messageId == message.messageId && msg.body == updatedBody);
        assert(msg != null);
      }).catchError((onError) async {
        logTime("Error GET MESSAGES $onError");
        assert(onError == null);
      }).whenComplete(() {
        CubeChatConnection.instance.destroy();
        deleteDialog(createdDialog.dialogId!, true);
      });
    });

    test("testDeleteMessage", () async {
      List<int> occupantsIds = [
        config['user_1_id'],
        config['user_2_id'],
        // 563546,
      ];

      CubeDialog newDialog = CubeDialog(CubeDialogType.GROUP, name: "Name");
      newDialog.occupantsIds = occupantsIds;

      CubeDialog createdDialog = await createDialog(newDialog);

      await CubeChatConnection.instance
          .login(CubeUser(
              id: config["user_1_id"], password: config["user_1_pass"]))
          .then((loggedUser) {
        logTime("Success login to the chat $loggedUser");
      }).catchError((error) {
        logTime("Error login to the chat $error");
      });

      CubeMessage message = CubeMessage()
        ..body = 'Body'
        ..saveToHistory = true
        ..markable = true
        ..dialogId = createdDialog.dialogId;

      await createdDialog.sendMessage(message).then((sentMessage) async {
        logTime("Success SENT MESSAGE: ${sentMessage.messageId}");
      }).catchError((onError) async {
        logTime("Error SENT MESSAGE $onError");
        assert(onError == null);
      });

      await createdDialog.deleteMessage(message).then((voidRes) async {
        logTime("Success DELETE MESSAGE");
      }).catchError((onError) async {
        logTime("Error DELETE MESSAGE $onError");
        assert(onError == null);
      });

      sleep(Duration(seconds: 2));

      await getMessages(createdDialog.dialogId!, {"_id": message.messageId})
          .then((pagerResult) async {
        logTime("Success GET MESSAGES: ${pagerResult!.items}");

        var msg = pagerResult.items
            .firstWhereOrNull((msg) => msg.messageId == message.messageId);
        assert(msg == null);
      }).catchError((onError) async {
        logTime("Error GET MESSAGES $onError");
        assert(onError == null);
      }).whenComplete(() {
        CubeChatConnection.instance.destroy();
        deleteDialog(createdDialog.dialogId!, true);
      });
    });
  });

  tearDownAll(deleteSession);
}
