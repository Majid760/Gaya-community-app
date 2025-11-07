import 'package:connectycube_sdk/connectycube_chat.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:objectid/objectid.dart';

import '../../core/core_test_utils.dart';

Future<void> main() async {
  setUpAll(beforeTestPreparations);

  group("Tests GET messages", () {
    test("testGetReactions", () async {
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

      await getMessageReactions(createdMsg.messageId!).then((reactions) async {
        assert(reactions.isNotEmpty);
        assert(reactions.keys.contains(newReaction));
      }).catchError((onError) async {
        assert(onError == null);
      }).whenComplete(() => deleteDialog(createdDialog.dialogId!, true));
    });

    test("testCreateMessageWithAttachment", () async {
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

      var uid = ObjectId().hexString;
      var id = ObjectId().hexString;
      var url =
          'https://medium.com/flutter-community/parsing-complex-json-in-flutter-747c46655f51';
      var contentType = 'img/png';
      var data = {'date': 123456789, 'name': 'John Smith'}.toString();
      var size = 12.345;
      var width = 340;
      var height = 680;
      var type = 'photo';
      var duration = 120000;

      CubeMessage cubeMessage = CubeMessage()
        ..dialogId = createdDialog.dialogId
        ..body = 'Test message'
        ..attachments = [
          CubeAttachment()
            ..uid = uid
            ..id = id
            ..url = url
            ..contentType = contentType
            ..data = data
            ..size = size
            ..width = width
            ..height = height
            ..type = type
            ..duration = duration
        ];

      await createMessage(cubeMessage).then((message) async {
        assert(message.attachments != null);
        assert(message.attachments?.isNotEmpty ?? false);

        assert(message.attachments?.first != null);
        assert(message.attachments?.first.id == id);
        assert(message.attachments?.first.uid == uid);
        assert(message.attachments?.first.url == url);
        assert(message.attachments?.first.contentType == contentType);
        assert(message.attachments?.first.data == data);
        assert(message.attachments?.first.size == size);
        assert(message.attachments?.first.width == width);
        assert(message.attachments?.first.height == height);
        assert(message.attachments?.first.type == type);
        assert(message.attachments?.first.duration == duration);
      }).catchError((onError) async {
        assert(onError == null);
      }).whenComplete(() => deleteDialog(createdDialog.dialogId!, true));
    });
  });

  tearDownAll(deleteSession);
}
