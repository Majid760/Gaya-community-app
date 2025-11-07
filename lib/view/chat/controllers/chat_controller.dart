import 'dart:async';
import 'dart:io';

import 'package:connectivity_plus/connectivity_plus.dart';
import 'package:connectycube_sdk/connectycube_sdk.dart';
import 'package:easy_refresh/easy_refresh.dart';
import 'package:file_picker/file_picker.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:gaya/services/encryption/password_encryption.dart';
import 'package:gaya/utils/extension.dart';
import 'package:gaya/view/chat/controllers/queue_message_controller.dart';
import 'package:get/get.dart';
import 'package:get/get_rx/src/rx_workers/utils/debouncer.dart';
import 'package:helpers/helpers.dart';
import 'package:image_picker/image_picker.dart';
import 'package:provider/provider.dart';
import 'package:universal_io/io.dart';

import '../../../components/show.friends.sheet.dart';
import '../../../controller/firebase_analytics_controller.dart';
import '../../../model/user.model.dart';
import '../../../routing/getx_route_methods.dart';
import '../../../services/notification/fcm_service.dart';
import '../../../shared/service/media_service/file_picking_service.dart';
import '../../../shared/view/widget/gaya_snackbar.dart';
import '../../../utils/helper/helper.functions.dart';
import '../../../utils/language/translation.dart';
import '../../../utils/logger.dart';
import '../../../utils/theme/app_colors.dart';
import '../../Auth/controller/login.controller.dart';
import '../../switch_view/controllers/switch_view_controller.dart';
import '../models/queue_messages.dart';
import '../services/connectycube_members_services.dart';
import '../utils/api_utils.dart';
import '../utils/configs.dart' as config;
import '../utils/pref_util.dart';
import 'base_controller.dart';
import 'conversation_controller.dart';

class ChatController extends BaseController {
  ChatController();

  static ChatController to() => Get.find();

  static bool get isRegistered => Get.isRegistered<ChatController>();

  static void deleteInstance() => Get.delete<ChatController>();
  CubeUser? _currentUser;

  CubeUser? get currentUser {
    if (_currentUser == null) {
      reLoginUser();
    }
    return _currentUser;
  }

  set currentUser(CubeUser? value) {
    if (value != null) {
      _currentUser = value;
    }
  }

  CubeDialog? currentChat;
  List<ListItem<CubeDialog>> chatsList = [];
  var isChatsLoading = true;

  StreamSubscription<CubeMessage>? msgSubscription;
  ChatMessagesManager? chatMessagesManager = CubeChatConnection.instance.chatMessagesManager;
  List<CubeUser> groupAllMembers = [];

  List<CubeUser> searchedUsersList = [];
  List<CubeUser> selectedCubeUsersList = [];
  Set<int> selectedUsers = {};
  var isUserSearching = false;
  var isPrivateChat = true;
  String? userSearchQuery;
  String userSearchMessage = " ";

  /// Workaround for marking chat as Active/inactive
  ///
  /// Keep track of all opened screen and it will decide either to call inactive or not so
  /// notification can be received. @ [MarkActiveInactive]
  final List<String> _openedScreensDialogIds = [];

  @override
  void onInit() {
    super.onInit();
    registerOnConnectivityChange();
  }

  @override
  void onClose() {
    // resetState();
    // setLoading(true);

    msgSubscription?.cancel();
    super.onClose();
  }

  removeListeners() {
    msgSubscription?.cancel();
    chatMessagesManager = null;
  }

  /// Invokes when user clicks on a chat item
  /// [index] is the index of the chat item
  /// reason: on Opening chat, we need to update the unread message count at badge for realTime
  void onOpenChat({required int index}) {
    /// get Navbar count
    int totalUnread = SwitchViewController.to.unreadMessageCount;

    /// get current chat unread count
    int currentUnread = chatsList[index].data.unreadMessageCount ?? 0;

    /// Update Nav Bar Unread Message Count
    totalUnread = totalUnread - currentUnread;
    SwitchViewController.to.unreadMessageCount = totalUnread;

    chatsList[index].data.unreadMessageCount = 0;
    update();
  }

  /// Invokes when new message is received or sent
  /// reason: on new message, we need to update `chat list at messages tab` for realTime
  void setChatroomLastMessage(CubeMessage newMessage, {bool notify = false, bool clearCount = true}) {
    try {
      int index = chatsList.indexWhere((element) => element.data.dialogId == newMessage.dialogId);
      if (index == -1) return;
      final oldDialog = chatsList[index].data;

      /// Badge count

      if (clearCount) clearBadgeCount(oldDialog.unreadMessageCount ?? 0);
      oldDialog.lastMessage = EncryptData.decryptionOfLastMessage(data: newMessage.body);
      oldDialog.lastMessageDateSent = DateTime.now().millisecondsSinceEpoch ~/ 1000;
      if (clearCount) oldDialog.unreadMessageCount = 0;

      /// shift this dialog to top
      chatsList.removeAt(index);
      chatsList.insert(0, ListItem<CubeDialog>(oldDialog));

      if (notify) update();
    } catch (_) {}
  }

  void clearBadgeCount(int unreadMessagesCount) {
    SwitchViewController.to.unreadMessageCount = SwitchViewController.to.unreadMessageCount - unreadMessagesCount;
  }

  checkIfNotSubscribedToNewMsgsThenreSubscribe() {
    if (chatMessagesManager == null || msgSubscription == null) {
      subscribeToNewMsgs();
    }
  }

  final _connectivity = Connectivity();
  final _queueDebouncer = Debouncer(delay: const Duration(milliseconds: 2000));

  ///‼️️️️️️️️️️️️ ️️️️️️️️️️️️️️️️️️️️️️️️️️️️️️️️️️️️️️️️️️️️️️️️️️️️️️️️️️️️️️️️️️️️️️️️️️️️️️️️️️️️️️️️️️️️️️ Only this method should be used to update chat list ‼️‼️‼️‼️
  /// update chat list
  ///
  void addAllToChatList(List<CubeDialog> dialogs, {bool notify = true}) {
    /// reset unread message count and chats list
    chatsList = [];
    SwitchViewController.to.unreadMessageCount = 0;

    int _badgeCount = SwitchViewController.to.unreadMessageCount;

    /// add to chats list
    chatsList.addAll(dialogs.map((dialog) {
      _badgeCount = _badgeCount + (dialog.unreadMessageCount ?? 0);

      /// if have last message then decrypt it
      dialog.lastMessage = EncryptData.decryptionOfLastMessage(data: dialog.lastMessage);
      return ListItem(dialog);
    }).toList());

    /// update unread message count
    SwitchViewController.to.unreadMessageCount = _badgeCount;

    /// update UI
    if (notify) update();
  }

  void registerOnConnectivityChange() {
    _connectivity.onConnectivityChanged.listen((ConnectivityResult result) async {
      if (result != ConnectivityResult.none) {
        _queueDebouncer.call(() async {
          await onReconnected();
          getAllChatsList(notify: true);
        });
      }
    });
  }

  /// Invokes when user reconnects to internet
  /// reason: on reconnection, we need to send all queued messages and update the chat list for realTime
  Future<List<CubeMessage>> onReconnected() async {
    final queuedMessages = QueueMessageController.to.getQueuedMessages();
    if (queuedMessages.isNotEmpty) {
      for (QueueCubeMessage queued in queuedMessages) {
        queued.chatroom.sendMessage(queued.message);
      }
      QueueMessageController.to.removeQueuedMessage();

      /// add to current view if it is open [the sent messages]
      for (var element in queuedMessages) {
        try {
          if (element.chatroom.dialogId != null && ConversationController.isRegistered(element.chatroom.dialogId!)) {
            ConversationController.to(element.chatroom.dialogId!).addMessageToListView(element.message);
          }
        } catch (_) {}
      }
    }
    return [];
  }

  subscribeToNewMsgs() {
    try {
      msgSubscription?.cancel();
      if (chatMessagesManager == null) {
        ChatMessagesManager? manager = CubeChatConnection.instance.chatMessagesManager;
        chatMessagesManager = manager;
        msgSubscription = chatMessagesManager?.chatMessagesStream.listen(onReceiveChatMessage);
      } else {
        msgSubscription = chatMessagesManager?.chatMessagesStream.listen(onReceiveChatMessage);
      }
    } catch (_) {
      log("subscribeToNewMsgs error= $_");
    }
  }

  getAllChatListAndUpdateCurrentUser(CubeUser user) async {
    currentUser = user;
    await getAllChatsList(notify: false);
    update();
  }

  updateCubeUser(CubeUser user) {
    currentUser = user;
    // showAlertDialog(context, 'updateCubeUser(), user: ${user.login}', user);
    update();
  }

  updateCubeCurrentChat(CubeDialog chat, {bool notify = true}) {
    currentChat = chat;
    if (notify) {
      update();
    }
  }

  // login to connectycube
  Future<void> loginToCC(BuildContext context, CubeUser user, {bool saveUser = false, dynamic isFromDeepLink}) async {
    if (currentUser != null) return;
    init(config.APP_ID, config.AUTH_KEY, config.AUTH_SECRET);
    try {
      CubeChatConnection.instance.destroy();
    } catch (_) {}
    await createSession(user).then((cubeSession) async {
      var tempUser = user;
      user = cubeSession.user!..password = tempUser.login; //tempUser.password;
      if (saveUser) {
        SharedPrefs.instance.init().then((sharedPrefs) {
          sharedPrefs.saveNewUser(user);
        });
      }
      // showAlertDialog(context, 'createSession, link: $isFromDeepLink', user);
      _loginToCubeChat(context, user, isFromDeepLink);
    }).catchError((error) {});
    // }
  }

  _loginToCubeChat(BuildContext context, CubeUser user, dynamic isFromDeepLink) async {
    try {
      CubeChatConnectionSettings.instance.totalReconnections = 5;
      CubeChatConnection.instance.login(user).then((cubeUser) async {
        await getAllChatListAndUpdateCurrentUser(cubeUser);
      }).catchError((error) {});
    } catch (_) {}
  }

  void onReceiveChatMessage(CubeMessage message) {
    log("onReceiveChatMessage global message= $message");

    SwitchViewController.to.unreadMessageCount += 1;
    updateDialog(message);
  }

  getAllChatsList({required bool notify}) {
    getDialogs().then((dialogs) {
      isChatsLoading = false;
      if (dialogs?.items == null) return;

      /// add to chat list
      addAllToChatList(dialogs!.items, notify: notify);
    }).catchError((exception) {
      log("chatch error on get chat dialogs= $exception");
    });
  }

  clearAllChatList() {
    try {
      currentUser = null;
      currentChat = null;
      chatsList.clear();
    } catch (_) {}
    update();
  }

  updatetextField() {
    update(['textfield']);
  }

  // relogin user
  Future<void> reLoginUser() async {
    String? userId = FirebaseAuth.instance.currentUser?.uid;
    CubeUser user = CubeUser(login: userId, password: userId);
    Provider.of<LoginController>(Get.context!, listen: false).connectyCubeLogin(Get.context!, user, saveUser: true);
  }

  // dummy function to test new groups
  getAllUpdatedChatListIfNeeded() {
    if (currentUser == null) {
      reLoginUser();
    }

    getDialogs().then((dialogs) {
      isChatsLoading = false;
      int preGroups = chatsList.length;
      if (dialogs?.items == null) return;
      addAllToChatList(dialogs!.items, notify: false);
      int postGroups = chatsList.length;
      MyLoggerServices.to.print('Pre group: lenth is: $preGroups and post groups length is $postGroups');
      if (preGroups != postGroups) {
        update();
      }
      // print('$preGroups and $postGroups');
    }).catchError((exception) {
      log("chatch error on get chat dialogs= $exception");
    });
  }

  addNewChatroom(CubeDialog dialog, {bool notify = true}) {
    /// if already added then return
    if (chatsList.firstWhereOrNull((element) => element.data.dialogId == dialog.dialogId) != null) return;

    /// if have last message then decrypt it
    if (dialog.lastMessage != null) dialog.lastMessage = EncryptData.decryptionOfLastMessage(data: dialog.lastMessage);

    /// add to top
    chatsList.insert(0, ListItem<CubeDialog>(dialog));
    if (notify) update();
  }

  /// Invokes when New Chatroom is being created or the current chatroom
  /// is needed to be updated~
  updateDialog(CubeMessage msg) {
    // print("UpdateDialog");
    msg.body = EncryptData.decryptionOfLastMessage(data: msg.body);
    try {
      /// Check if dialog is already added or not
      ListItem<CubeDialog>? dialogItem = chatsList.firstWhereOrNull((dlg) => dlg.data.dialogId == msg.dialogId);

      /// if dialog is not added then fetch it from server
      if (dialogItem == null) {
        if (msg.dialogId != null) {
          /// At this stage, its cleared that dialog was not present, so fetching from server
          getDialogs({'_id': msg.dialogId}).then((dialogs) async {
            if (dialogs?.items != null && dialogs!.items.isNotEmpty) {
              CubeDialog dialog = dialogs.items.first;
              try {
                dialog.lastMessage = EncryptData.decryptionOfLastMessage(data: dialog.lastMessage);
              } catch (_) {}

              /// Again check if dialog is already added or not,
              /// reason: edge case where `[chatsList]` might have got the dialog before this call
              /// so it causes duplicate dialog in `[chatsList]` - so we need to remove it and add it to top
              int index = chatsList.indexWhere((dialog) => dialog.data.dialogId == msg.dialogId);

              /// if dialog is already added then remove it and add it to top
              if (index != -1) {
                chatsList.removeAt(index);
              }

              /// add to top
              chatsList.insert(0, ListItem<CubeDialog>(dialog));
            }
          });
        }
      } else {
        /// Dialog is already added, so update it
        dialogItem.data.lastMessage = msg.body;
        dialogItem.data.lastMessageDateSent = msg.dateSent;
        if (currentChat == null && msg.senderId != currentUser?.id) {
          dialogItem.data.unreadMessageCount = (dialogItem.data.unreadMessageCount == null || dialogItem.data.unreadMessageCount == 0)
              ? 1
              : dialogItem.data.unreadMessageCount! + 1;
        }
      }

      setChatroomLastMessage(msg, notify: false, clearCount: false);
      update();
      // /// sort messages on new message received!
      // chatsList.sort((a, b) {
      //   if (a.data.lastMessageDateSent == null || b.data.lastMessageDateSent == null) return 0;
      //   return b.data.lastMessageDateSent!.compareTo(a.data.lastMessageDateSent!);
      // });
    } catch (_) {
      print("Error at updateDialog: ${_.toString()}");
    }
  }

  void refreshChatsList() {
    try {
      isChatsLoading = true;
      update();
      getAllChatsList(notify: true);
    } catch (_) {
      isChatsLoading = false;
      update();
    }
  }

  searchUsers(value) async {
    if (value != null) {
      userSearchQuery = value;
      isUserSearching = true;
      await getSearchedUsersList();
      update();
    }
  }

  bool checkIsChatlistNotEmptyAndSerachIsOff() {
    return (!isChatsLoading && chatsList.isNotEmpty && searchUsersTextField.text.isEmpty) ? true : false;
  }

  bool checkIsChatlistIsEmptyAndChatIsLoading() {
    return (isChatsLoading && chatsList.isEmpty) ? true : false;
  }

  deleteSingleConversation(String conversationId, bool force, {required BuildContext ctx}) async {
    try {
      GayaSnackBar.show(context: ctx, text: GayaStrings.deleting_conversation.tr, type: GayaSnackBarType.waiting);
      await _deleteConversation(conversationId);
      GayaSnackBar.show(context: ctx, text: GayaStrings.conversation_deleted_success.tr, type: GayaSnackBarType.success);
      chatsList.removeWhere((element) => element.data.dialogId == conversationId);
      update();
    } catch (_) {
      print("deleteSingleConversation error= $_");
      if (_ is PlatformException || _ is SocketException) {
        GayaSnackBar.show(context: ctx, text: GayaStrings.conversation_deleted_failed.tr, type: GayaSnackBarType.error);
      }
    }
  }

  Future<void> _deleteConversation(String conversationId) async {
    await deleteAllMessagesByDialogId(conversationId);
    await deleteDialog(conversationId, false);
  }

  Future<void> getSearchedUsersList() async {
    if (userSearchQuery != null && userSearchMessage.isNotEmpty) {
      resetSearchedUsersController();
    }
  }

  final allCubeUsers = [];
  bool isConnectyCubeUsersLoading = true;

  getAllCubeUsersList({bool shouldClearFields = false}) async {
    try {
      if (shouldClearFields) {
        clearSearchValues();
        clearNewGroupSelectedUsersValues();
      }
      requestMoreAllUsers(fromInit: true);
    } catch (_) {
      isConnectyCubeUsersLoading = false;
      update();
    }
  }

  addRemoveUsersInNewGroupChatForSearchedUsers(int index) {
    if (isNewGroupChat == false) {
      selectedUsers.clear();
      selectedCubeUsersList.clear();
    }
    if (selectedUsers.contains(searchedUsersList[index].id)) {
      selectedUsers.remove(searchedUsersList[index].id);
      selectedCubeUsersList.removeWhere((element) => element.id == searchedUsersList[index].id);
    } else {
      selectedUsers.add(searchedUsersList[index].id!);
      selectedCubeUsersList.add(searchedUsersList[index]);
    }
    update();
  }

  addRemoveUsersInNewGroupChatForAllUsersList(int index) {
    if (isNewGroupChat == false) {
      selectedUsers.clear();
      selectedCubeUsersList.clear();
    }
    if (selectedUsers.contains(allCubeUsers[index].id)) {
      selectedUsers.remove(allCubeUsers[index].id);
      selectedCubeUsersList.removeWhere((element) => element.id == allCubeUsers[index].id);
    } else {
      selectedUsers.add(allCubeUsers[index].id!);
      selectedCubeUsersList.add(allCubeUsers[index]);
    }
    update();
  }

  bool isUserSelected(CubeUser user) {
    bool isAvailable = selectedCubeUsersList.containsWhere((e) => e.id == user.id);
    return isAvailable;
  }

  removeSelectedUsers(int index, CubeUser user) {
    if (selectedCubeUsersList.isEmpty) return;
    selectedUsers.remove(user.id);
    selectedCubeUsersList.remove(user);
    update();
  }

  clearSearchValues() {
    isUserSearching = false;
    userSearchQuery = null;
    userSearchMessage = " ";
    searchedUsersList.clear();
    groupNameTextField.clear();
    searchUsersTextField.clear();
  }

  clearNewGroupSelectedUsersValues() {
    selectedUsers.clear();
    selectedCubeUsersList.clear();
    isNewGroupChat = false;
    isCreateGroupEditFieldsScreenSelected = false;
  }

  changeNewChatStatus() {
    isPrivateChat = !isPrivateChat;
    selectedUsers.clear();
    update();
  }

  clearSearchChatUsersTextField() {
    searchUsersTextField.clear();
    update();
  }

  addRemoveUsersInNewGroupChat(int index) {
    if (selectedUsers.contains(searchedUsersList[index].id)) {
      selectedUsers.remove(searchedUsersList[index].id);
    } else {
      selectedUsers.add(searchedUsersList[index].id!);
    }
    update();
  }

  void createNewChat(BuildContext context, Set<int> users, bool isGroup) async {
    if (isGroup) {
      if (users.length < 2) return;
      CubeDialog newDialog = CubeDialog(CubeDialogType.GROUP, occupantsIds: users.toList());
      List<CubeUser> usersToAdd = users.map((id) => searchedUsersList.firstWhere((user) => user.id == id)).toList();
      if (currentUser != null) {
        selectedGroupUsers = usersToAdd;
        updateCubeCurrentChat(newDialog, notify: true);
        Get.toNamed(
          RouteHelper.newGroup,
        );
      }
    } else {
      CubeDialog newDialog = CubeDialog(CubeDialogType.PRIVATE, occupantsIds: users.toList());
      createDialog(newDialog).then((createdDialog) {
        if (currentUser != null) {
          updateCubeCurrentChat(createdDialog, notify: true);
          Get.offAndToNamed(
            RouteHelper.conversation,
          )?.then((value) => refreshChatsList());
        }
      }).catchError((error) {
        log("catch error on create new chat dialogs= $error");
      });
    }
  }

  /////////////////////////// Create and Edit Group Chat Methods below /////////////////////////

  List<CubeUser?>? selectedGroupUsers;
  TextEditingController groupNameTextField = TextEditingController();
  Uint8List? selectedGroupImage;
  bool isNewGroupChat = false;
  bool isCreateGroupEditFieldsScreenSelected = false;

  void disposeOfCreateNewGroupScreen() {
    groupNameTextField.clear();
    selectedGroupImage = null;
    selectedGroupUsers = [];
  }

  createNewGroupChat(BuildContext context) {
    if (isCreatingNewChat) return;
    isCreatingNewChat = true;
    update();
    if (groupNameTextField.text.isEmpty || groupNameTextField.text.length < 5) {
      // const GayaSnackBar(type: GayaSnackBarType.error, text: 'Enter more tha 4 characters group name');
      Get.showSnackbar(
        GetSnackBar(
          message: GayaStrings.for_char_group_name.tr,
          //'Enter more tha 4 characters group name.',
          duration: const Duration(seconds: 3),
          backgroundColor: AppColors.error,
          dismissDirection: DismissDirection.horizontal,
          margin: EdgeInsets.symmetric(horizontal: 20.w, vertical: 16.h),
        ),
      );

      isCreatingNewChat = false;
      update();
    } else {
      if (currentChat != null) {
        currentChat?.name = groupNameTextField.text.trim();
        createDialog(currentChat!).then((createdDialog) {
          createdDialog.occupantsIds?.removeWhere((element) => element == currentUser?.id);

          updateCubeCurrentChat(createdDialog);

          searchedUsersList.clear();
          selectedUsers.clear();
          selectedCubeUsersList.clear();
          searchUsersTextField.clear();
          Routes.openConversationAndRemoveCreateGroupChat(createdDialog);
          isCreatingNewChat = false;
          addNewChatroom(createdDialog);
          refreshChatsList();
        }).catchError((exception) {
          isCreatingNewChat = false;
          update();
          Get.showSnackbar(
            GetSnackBar(
              message: GayaStrings.upto_ten_user_group.tr,
              //'You can only add upto 10 users for a group chat.',
              duration: const Duration(seconds: 3),
              backgroundColor: AppColors.error,
              dismissDirection: DismissDirection.horizontal,
              margin: EdgeInsets.symmetric(horizontal: 20.w, vertical: 16.h),
            ),
          );
        });
      } else {
        isCreatingNewChat = false;
        update();
        Get.showSnackbar(
          GetSnackBar(
            message: GayaStrings.failed_create_group.tr,
            //'Failed to create new group.',
            duration: const Duration(seconds: 3),
            backgroundColor: AppColors.error,
            dismissDirection: DismissDirection.horizontal,
            margin: EdgeInsets.symmetric(horizontal: 20.w, vertical: 16.h),
          ),
        );
      }
    }
  }

  pickAndUploadNewGroupImage() async {
    FilePickerResult? result = await FilePicker.platform.pickFiles(
      type: FileType.image,
    );

    if (result == null) return;

    Uint8List? image;

    if (kIsWeb) {
      image = result.files.single.bytes;
    } else {
      image = File(result.files.single.path!).readAsBytesSync();
    }

    var uploadImageFuture = getUploadingImageFuture(result);

    uploadImageFuture.then((cubeFile) {
      selectedGroupImage = image;
      var url = cubeFile.getPublicUrl();
      log("_createDialogImage url= $url");
      currentChat?.photo = url;
      update();
    }).catchError((exception) {
      const GayaSnackBar(type: GayaSnackBarType.error, text: 'Failed to upload new group profile image.');
    });
  }

  toggleIsNewGroupChat({bool shouldNotify = true, bool? customValue}) {
    isNewGroupChat = (customValue != null) ? customValue : !isNewGroupChat;
    if (shouldNotify) update();
  }

  ///
  /// Create new group chat
  bool isCreatingNewChat = false;

  Future<void> createNewConversation(BuildContext context, Set<int> users, bool isGroup) async {
    isCreatingNewChat = true;
    update();
    try {
      if (isGroup) {
        if (users.isEmpty) return;
        CubeDialog newDialog = CubeDialog(CubeDialogType.PUBLIC, occupantsIds: users.toList());
        List<CubeUser> usersToAdd = users.map((id) => selectedCubeUsersList.firstWhere((user) => user.id == id)).toList();
        if (currentUser != null) {
          selectedGroupUsers = [];
          selectedGroupUsers = usersToAdd;
          isCreateGroupEditFieldsScreenSelected = true;
          updateCubeCurrentChat(newDialog);
        }
      } else {
        CubeDialog newDialog = CubeDialog(CubeDialogType.PRIVATE, occupantsIds: users.toList());
        createDialog(newDialog).then((createdDialog) {
          if (currentUser != null) {
            updateCubeCurrentChat(createdDialog);
            clearSearchValues();
            String previousRoute = Get.previousRoute;
            String currentRoute = Get.currentRoute;

            if (previousRoute == RouteHelper.switchView) {
              Get.toNamed(
                RouteHelper.conversation,
                preventDuplicates: false,
                arguments: {"dialog": createdDialog},
              )?.then((value) => ChatController.to().refreshChatsList());
            } else if (currentRoute == RouteHelper.switchView) {
              Get.toNamed(RouteHelper.conversation, arguments: {"dialog": createdDialog}, preventDuplicates: false)
                  ?.then((value) => ChatController.to().refreshChatsList());
            } else {
              Get.offAndToNamed(
                RouteHelper.conversation,
                arguments: {"dialog": createdDialog},
              )?.then((value) => refreshChatsList());
            }
          }
        }).catchError((error) {
          log("catch error on create new chat dialogs= $error");
          isCreatingNewChat = false;
          update();
        });
      }
    } catch (e) {
      log("catch error on create new chat dialogs= $e");
      isCreatingNewChat = false;
      update();
    } finally {
      isCreatingNewChat = false;
      update();
    }
  }

  goBackFromCreateGroupFieldsViewAndClearFields() {
    groupNameTextField.clear();
    searchUsersTextField.clear();
    selectedGroupImage = null;
    isCreateGroupEditFieldsScreenSelected = false;
    resetAllUsersController(isDisposing: false);
    update();
  }

// //////////////////////////////////////////// Paginated users and dialogs methods //////////////////////////////////
  TextEditingController searchUsersTextField = TextEditingController();
  ConnectyCubeMembersServices? _connectyCubeMembersServices;
  EasyRefreshController refreshController = EasyRefreshController();
  bool isFirstTimeGetAllUsers = false;
  final Debouncer _debouncer = Debouncer(delay: 1000.milliseconds);
  EasyRefreshController searchRefreshController = EasyRefreshController();
  EasyRefreshController groupChatMembersRefreshController = EasyRefreshController();
  bool isFirstTimeGetSearchedUsers = false;

  initializeCommunityMembersServices() {
    _connectyCubeMembersServices = ConnectyCubeMembersServices(currentUser: currentUser);
  }

  Future<void> requestMoreAllUsers({bool fromInit = false}) async {
    if (currentUser == null) return;
    // to avoid double loading at top andbottom on screen
    if (fromInit == false) refreshController.callLoad();
    MyLoggerServices.to.print(" requestMoreData called");
    if (fromInit) {
      isConnectyCubeUsersLoading = true;
      // update();
    }
    isFirstTimeGetAllUsers = true;
    final newUsers = await _connectyCubeMembersServices!.requestAllUsersMoreData();
    MyLoggerServices.to.print("newMembers.length ${newUsers.length}");
    allCubeUsers.addAll(newUsers);
    isConnectyCubeUsersLoading = false;
    update();
  }

  // A dispose method.
  void resetAllUsersController({bool isDisposing = false}) async {
    allCubeUsers.clear();
    isFirstTimeGetAllUsers = false;

    isConnectyCubeUsersLoading = false;
    clearSearchValues();
    if (_connectyCubeMembersServices != null) {
      _connectyCubeMembersServices?.resetAllUsers();
    }
    if (isDisposing) {
      // WidgetsBinding.instance.addPostFrameCallback((_) {
      //   update();
      // });
    } else {
      await requestMoreAllUsers(
        fromInit: true,
      );
    }
    _debouncer.cancel();
  }

  // search connectycube users.
  Future<void> requestMoreSearchedUsers({bool fromInit = false}) async {
    if (currentUser == null || userSearchQuery == null) return;
    // to avoid double loading at top andbottom on screen
    if (fromInit == false) searchRefreshController.callLoad();
    MyLoggerServices.to.print(" requestMoreData called");
    if (fromInit) {
      isConnectyCubeUsersLoading = true;
      // update();
    }
    isFirstTimeGetSearchedUsers = true;
    final newUsers = await _connectyCubeMembersServices!.requestSearchedUsersMoreData(query: userSearchQuery);
    MyLoggerServices.to.print("newMembers.length ${newUsers.length}");
    final usersList = newUsers.map<CubeUser>((user) {
      return user as CubeUser;
    }).toList();
    searchedUsersList.addAll(usersList);
    isConnectyCubeUsersLoading = false;
    update();
  }

//   // A dispose method for searched users.
  void resetSearchedUsersController({bool isDisposing = false}) async {
    searchedUsersList.clear();
    isFirstTimeGetSearchedUsers = false;
    log("searchedUsersList length is: ${searchedUsersList.length}");
    isConnectyCubeUsersLoading = false;
    if (_connectyCubeMembersServices != null) {
      _connectyCubeMembersServices?.resetSearchedUsers();
    } else {
      initializeCommunityMembersServices();
    }
    if (isDisposing) {
      // WidgetsBinding.instance.addPostFrameCallback((_) {
      //   update();
      // });
    } else {
      await requestMoreSearchedUsers(
        fromInit: true,
      );
    }
    _debouncer.cancel();
  }

  Future<void> requestMoreGroupAllUsers({bool fromInit = false}) async {
    if (currentUser == null) return;
    // to avoid double loading at top andbottom on screen
    if (fromInit == false) groupChatMembersRefreshController.callLoad();
    MyLoggerServices.to.print(" requestMoreData called");
    if (fromInit) {
      isConnectyCubeUsersLoading = true;
      // update();
    }
    isFirstTimeGetAllUsers = true;
    final newUsers = await _connectyCubeMembersServices!.requestGroupAllUsersMoreData();
    MyLoggerServices.to.print("newMembers.length ${newUsers.length}");
    groupAllMembers.addAll(newUsers);
    isConnectyCubeUsersLoading = false;
    update();
  }

  // A dispose method.
  void resetGroupAllUsersController({bool isDisposing = false}) async {
    groupAllMembers.clear();
    isFirstTimeGetAllUsers = false;
    log("allCubeUsers length is: ${groupAllMembers.length}");

    isConnectyCubeUsersLoading = false;
    clearSearchValues();
    if (_connectyCubeMembersServices != null) {
      _connectyCubeMembersServices?.resetGroupAllUsers();
    }
    if (isDisposing) {
      // WidgetsBinding.instance.addPostFrameCallback((_) {
      //   update();
      // });
    } else {
      await requestMoreGroupAllUsers(
        fromInit: true,
      );
    }
    _debouncer.cancel();
  }

// ////////////////////////////////////////////  Paginated users and dialogs ended  //////////////////////////////////
  HelperFunc helperFunc = HelperFunc();

  final MediaService _mediaService = MediaService();
  bool isImageUploading = false;

  Future<void> pickImageFromGallery({required BuildContext context, int imageQuality = 50}) async {
    try {
      XFile? files = await _mediaService.pickImageFromPhotos(context: context, imageQuality: imageQuality);

      if (files != null) {
        // Logging pick image or video analytics event
        AnalyticsController.to.instance.logPickImageVideo(pickType: 'image', userId: UserModel.to.uId ?? '');
        File convertedFile = File(files.path);
        isImageUploading = true;
        update();
        var uploadImageFuture = getUploadingImageFutureAsCubeFile(convertedFile);
        uploadImageFuture.then((cubeFile) {
          var url = cubeFile.getPublicUrl();
          log("_createDialogImage url= $url");
          currentChat?.photo = url;
          isImageUploading = false;
          update();
        }).catchError((exception) {
          GayaSnackBar(
            type: GayaSnackBarType.error,
            text: GayaStrings.failed_upload_group_profile.tr,
          );
          isImageUploading = false;
          update();
        });
      } else {
        isImageUploading = false;
        update();
      }
    } on PlatformException catch (e) {
      log(e.toString());
      isImageUploading = false;
      update();
    } catch (e) {
      log(e.toString());
      isImageUploading = false;
      update();
    }
  }

  // // by mak => picking image from camera with proper permission handling etc
  Future<void> pickImageFromCamera({required BuildContext context, int imageQuality = 50}) async {
    try {
      XFile? file = await _mediaService.pickImageFromCamera(context: context, imageQuality: imageQuality);
      if (file != null && file.path.isNotEmpty) {
        // Logging pick image or video analytics event
        AnalyticsController.to.instance.logPickImageVideo(pickType: 'image', userId: UserModel.to.uId ?? '');
        File convertedFile = File(file.path);
        isImageUploading = true;
        update();
        var uploadImageFuture = getUploadingImageFutureAsCubeFile(convertedFile);
        uploadImageFuture.then((cubeFile) {
          var url = cubeFile.getPublicUrl();
          log("_createDialogImage url= $url");
          currentChat?.photo = url;
          isImageUploading = false;
          update();
        }).catchError((exception) {
          GayaSnackBar(
            type: GayaSnackBarType.error,
            text: GayaStrings.failed_upload_group_profile.tr,
          );
          isImageUploading = false;
          update();
        });
      } else {
        isImageUploading = false;
        update();
      }
    } on PlatformException catch (e) {
      log(e.toString());
      isImageUploading = false;
      update();
    } catch (e) {
      log(e.toString());
      isImageUploading = false;
      update();
    }
  }

  List<UserModel> onlineFriendsList = [];
  bool isLoadingOnlineFriend = false;

  void getOnlineFriends(BuildContext context) async {
    // onlineFriendsList = [];
    // return;
    try {
      isLoadingOnlineFriend = true;
      WidgetsBinding.instance.addPostFrameCallback((_) {
        update(['onlineFriendsList']);
      });
      final snapshot = await getUserFriends(context: context);
      if (snapshot == null || snapshot.docs.isEmpty == true) {
        isLoadingOnlineFriend = false;
        onlineFriendsList = [];
        WidgetsBinding.instance.addPostFrameCallback((_) {
          update(['onlineFriendsList']);
        });
      } else {
        for (var user in snapshot.docs) {
          onlineFriendsList.add(UserModel.fromMap(user.data() as Map<String, dynamic>, userId: user.id));
        }
        isLoadingOnlineFriend = false;
        WidgetsBinding.instance.addPostFrameCallback((_) {
          /// avoid duplication.
          onlineFriendsList.distinctBy((e) => e.uId ?? "-1").toList();
          update(['onlineFriendsList']);
        });
      }
    } catch (_) {
      isLoadingOnlineFriend = false;
      onlineFriendsList = [];
      WidgetsBinding.instance.addPostFrameCallback((_) {
        update(['onlineFriendsList']);
      });
    }
  }
}

extension MarkActiveInactive on ChatController {
  /// Add dialog id to [_openedScreensDialogIds] list
  void addDialogIdToOpenedScreens(String dialogId) {
    if (!_openedScreensDialogIds.contains(dialogId)) {
      _openedScreensDialogIds.add(dialogId);
    }
  }

  /// Remove dialog id from [_openedScreensDialogIds] list
  void removeDialogIdFromOpenedScreens(String dialogId) {
    if (_openedScreensDialogIds.contains(dialogId)) {
      _openedScreensDialogIds.remove(dialogId);
    }
  }

  /// Decides on basis of [_openedScreensDialogIds] list
  /// whether to call inactive or to remove dialog id from [_openedScreensDialogIds] list
  void decideToCallInactive(String dialogId) {
    print("decideToCallInactive dialogId= $dialogId");
    _openedScreensDialogIds.isEmpty ? _startNotifications() : removeDialogIdFromOpenedScreens(dialogId);
  }

  /// API call to mark user as inactive
  Future<void> _startNotifications() async {
    try {
      await CubeChatConnection.instance.markInactive();
      await FirebaseMessagingService.instance.showIosAlerts();
    } catch (_) {
      MyLoggerServices.to.print("Error at _callInactive: $_");
    }
  }

  /// API call to stop receving notifications
  Future<void> stopNotifications() async {
    CubeChatConnection.instance.markActive();

    /// stop ios alerts because iOS directly trigger if it have notification item in it.
    /// so forcefully we have to stop it.
    FirebaseMessagingService.instance.stopIosAlerts();
  }
}
