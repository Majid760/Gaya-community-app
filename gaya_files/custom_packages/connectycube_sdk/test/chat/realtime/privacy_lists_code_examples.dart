import 'package:connectycube_sdk/connectycube_chat.dart';

class PrivacyTests {
  void test() {
    CubeChatConnection.instance.privacyListsManager
        ?.getAllLists()
        .then((result) {
      log('active: ${result.activeList}');
      log('default: ${result.defaultList}');
      log('allPrivacyLists: ${result.allPrivacyLists}');
    }).catchError((exception) {
      log('Exception: $exception');
    });

    var listName = 'custom';

    CubeChatConnection.instance.privacyListsManager
        ?.getList(listName)
        .then((items) {
      log('items: $items}');
    }).catchError((exception) {
      log('Exception: $exception');
    });

    CubeChatConnection.instance.privacyListsManager
        ?.setActiveList('custom')
        .then((users) {
      log('[setActiveList] SUCCESS');
    }).catchError((exception) {
      log('[setActiveList] Exception: $exception');
    });

    CubeChatConnection.instance.privacyListsManager
        ?.declineActiveList()
        .then((users) {
      log('[declineActiveList] SUCCESS');
    }).catchError((exception) {
      log('[declineActiveList] Exception: $exception');
    });

    CubeChatConnection.instance.privacyListsManager
        ?.setDefaultList(listName)
        .then((users) {
      log('[setDefaultList] SUCCESS');
    }).catchError((exception) {
      log('[setDefaultList] Exception: $exception');
    });

    CubeChatConnection.instance.privacyListsManager
        ?.declineDefaultList()
        .then((users) {
      log('[declineDefaultList] SUCCESS');
    }).catchError((exception) {
      log('[declineDefaultList] Exception: $exception');
    });

    CubeChatConnection.instance.privacyListsManager
        ?.removeList(listName)
        .then((voidResult) {
      log('[declineDefaultList] SUCCESS');
    }).catchError((exception) {
      log('[declineDefaultList] Exception: $exception');
    });

    var items = [
      CubePrivacyListItem(22, CubePrivacyAction.deny, isMutual: false),
      CubePrivacyListItem(23, CubePrivacyAction.deny),
      CubePrivacyListItem(24, CubePrivacyAction.allow)
    ];

    CubeChatConnection.instance.privacyListsManager
        ?.createList(listName, items)
        .then((users) {
      log('[createPrivacyList] SUCCESS');
    }).catchError((exception) {
      log('[createPrivacyList] Exception: $exception');
    });

    CubeChatConnection.instance.privacyListsManager
        ?.declineDefaultList()
        .then((voidResult) => CubeChatConnection.instance.privacyListsManager
            ?.createList(listName, items))
        .then((list) => CubeChatConnection.instance.privacyListsManager
            ?.setDefaultList(listName))
        .then((updatedList) {});
  }
}
