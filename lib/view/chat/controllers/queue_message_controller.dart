import 'package:gaya/utils/local.storage.dart';
import 'package:get/get.dart';

import '../models/queue_messages.dart';

class QueueMessageController extends GetxController {
  static QueueMessageController get to => Get.find();

  /// Add Message to Queue
  void addQueueMessage(QueueCubeMessage queueCubeMessage) {
    ///fetch
    List<QueueCubeMessage> messages = getQueuedMessages();

    /// add
    messages.add(queueCubeMessage);

    /// store
    GetStorageController.to.storeQueueMessages(queueMessages: messages);
  }

  /// Get All Queued Messages
  List<QueueCubeMessage> getQueuedMessages() {
    return GetStorageController.to.getQueueMessages();
  }

  /// Clears All Queued Messages
  void removeQueuedMessages(String dialogId) {
    GetStorageController.to.clearQueuedMessageByDialogId(dialogId: dialogId);
  }

  /// Clears All Queued Messages
  void removeQueuedMessage() {
    GetStorageController.to.clearQueuedMessages();
  }
}
