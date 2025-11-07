import 'package:connectycube_sdk/connectycube_chat.dart';
import 'package:flutter_test/flutter_test.dart';

import '../../core/core_test_utils.dart';

Future<void> main() async {
  setUpAll(beforeTestPreparations);

  group("Tests UPDATE messages", () {
    test("testAddReaction", () async {
      String groupName = 'New GROUP chat';
      String groupDescription = 'Test dialog';
      List<int> occupantsIds = [
        config['user_1_id'],
        config['user_2_id'],
        config['user_3_id']
      ];

      CubeDialog newDialog = CubeDialog(CubeDialogType.GROUP);
      newDialog.name = groupName;
      newDialog.description = groupDescription;
      newDialog.occupantsIds = occupantsIds;

      CubeDialog createdDialog = await createDialog(newDialog);

      CubeMessage cubeMessage = CubeMessage()
        ..dialogId = createdDialog.dialogId
        ..body = 'Test message';

      var newReaction = '😍';

      CubeMessage createdMsg = await createMessage(cubeMessage);

      await addMessageReaction(createdMsg.messageId!, newReaction);

      await getMessages(createdDialog.dialogId!, {'_id': createdMsg.messageId})
          .then((result) async {
        assert(result?.items.first != null);
        assert(result?.items.first.reactions != null);
        assert(
            result?.items.first.reactions?.own.contains(newReaction) ?? false);
      }).catchError((onError) async {
        assert(onError == null);
      }).whenComplete(() => deleteDialog(createdDialog.dialogId!, true));
    });
  });

  tearDownAll(deleteSession);
}
