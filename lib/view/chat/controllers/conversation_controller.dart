// ignore_for_file: unused_import

import 'dart:async';
import 'dart:convert';
import 'dart:io';

import 'package:collection/collection.dart' show IterableExtension;
import 'package:connectivity_plus/connectivity_plus.dart';
import 'package:connectycube_sdk/connectycube_sdk.dart' as ConnectyCubeSdk;
import 'package:connectycube_sdk/connectycube_sdk.dart';
import 'package:connectycube_sdk/src/chat/realtime/managers/chat_managers.dart';
import 'package:easy_refresh/easy_refresh.dart';
import 'package:file_picker/file_picker.dart';
import 'package:firebase_messaging/firebase_messaging.dart';
import 'package:firebase_phone_auth_handler/firebase_phone_auth_handler.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:fluttertoast/fluttertoast.dart';
import 'package:gaya/components/custom_snackbars.dart';
import 'package:gaya/components/snackbar.component.dart';
import 'package:gaya/controller/firebase_analytics_controller.dart';
import 'package:gaya/controller/gaya_shared_controller.dart';
import 'package:gaya/model/user.model.dart';
import 'package:gaya/routing/getx_route_methods.dart';
import 'package:gaya/services/encryption/password_encryption.dart';
import 'package:gaya/shared/service/cache_service/cache_services.dart';
import 'package:gaya/shared/service/dynamic_link_service/enums/dynamic_link_type.dart';
import 'package:gaya/shared/service/dynamic_link_service/model/gaya_social_tag.dart';
import 'package:gaya/shared/service/dynamic_link_service/utils/dynamic_link_utils.dart';
import 'package:gaya/shared/service/dynamic_link_service/utils/query_param_consts.dart';
import 'package:gaya/shared/service/media_service/file_picking_service.dart';
import 'package:gaya/shared/service/permission_service/device_permission.dart';
import 'package:gaya/shared/view/widget/gaya_snackbar.dart';
import 'package:gaya/utils/extension.dart';
import 'package:gaya/utils/helper/helper.functions.dart';
import 'package:gaya/utils/language/translation.dart';
import 'package:gaya/utils/logger.dart';
import 'package:gaya/utils/theme/app_colors.dart';
import 'package:gaya/view/chat/components/message_placeholder.dart';
import 'package:gaya/view/chat/controllers/base_controller.dart';
import 'package:gaya/view/chat/controllers/chat_controller.dart';
import 'package:gaya/view/chat/controllers/queue_message_controller.dart';
import 'package:gaya/view/chat/helper/helper_functions.dart' as helper;
import 'package:gaya/view/chat/services/connectycube_members_services.dart';
import 'package:gaya/view/chat/utils/api_utils.dart';
import 'package:gaya/view/chat/utils/consts.dart';
import 'package:gaya/view/chat/views/conversation/chat_global_variables.dart';
import 'package:gaya/view/chat/views/group_detail/add_new_members_to_group_screen.dart';
import 'package:gaya/view/comments/services/comment_services.dart';
import 'package:get/get.dart';
import 'package:get/get_rx/src/rx_workers/utils/debouncer.dart';
import 'package:helpers/helpers.dart';
import 'package:image_picker/image_picker.dart';
import 'package:permission_handler/permission_handler.dart';
import 'package:share/share.dart';
import 'package:universal_io/io.dart';

import '../models/queue_messages.dart';

class ConversationBindings extends Bindings {
  @override
  void dependencies() {
    final params = Get.arguments;
    final dialog = params["dialog"] as CubeDialog;
    Get.lazyPut(() => ConversationController(currentChatDialog: dialog), tag: dialog.dialogId);
  }
}

class ConversationController extends BaseController {
  static ConversationController to(String tag) => Get.find<ConversationController>(tag: tag);

  static bool isRegistered(String tag) => Get.isRegistered<ConversationController>(tag: tag);

  CubeUser? currentUser;
  CubeDialog currentChatDialog;

  ConversationController({required this.currentChatDialog});

  UserModel? otherUser;

  Future<UserModel?> getOtherUserProfile() async {
    return otherUser ??= await _getCurrentUserExternalId();
  }

  ScrollController? listScrollController;

  @override
  onInit() {
    super.onInit();

    /// Register scroll controller for pagination inside chat.
    listScrollController = ScrollController();
    listScrollController!.addListener(() => onScrollChanged(listScrollController!));

    currentUser = ChatController.to().currentUser;
    conversationScreenInit();
    getOtherUserProfile();

    WidgetsBinding.instance.addPostFrameCallback((_) {
      getMessagesList();
      _getCurrentUserExternalId();
      update();
    });
    print("CurrentChatDialog: ${currentChatDialog.toJson()}");
  }

  bool isMessagesGetting = false;

  setMessagingLoading(bool value, {bool notify = true}) {
    isMessagesGetting = value;
    if (notify) update();
  }

  // CHECK IF THE MESSAGE IS AIMatch initial message
  bool checkIfAIMatchInitialMessage(CubeMessage message) {
    if (currentChatDialog.customData?.className == 'AIMatch' && message.properties['flag'] == 'AIMatch') return true;
    return false;
  }

  Future<List<CubeMessage>> getMessagesList() async {
    setMessagingLoading(true, notify: false);
    if (chatMessagesList.isNotEmpty) return Future.value(chatMessagesList);
    setMessagingLoading(true);
    Completer<List<CubeMessage>> completer = Completer();
    List<CubeMessage>? messages;
    try {
      await Future.wait<void>([
        getMessagesByDate(0, false).then((loadedMessages) {
          isLoading = false;
          messages = loadedMessages;
        }),
        getOccupantsOfTheChatDialog()
      ]);
      debugPrint("getMessagesList");

      /// add these messages at the end of the list
      addAddMessages(messages);
    } catch (error) {
      completer.completeError(error);
    }
    setMessagingLoading(false);
    return completer.future;
  }

  getOccupantsOfTheChatDialog() async {
    if (currentChatDialog.type == CubeDialogType.PUBLIC) {
      await getDialogOccupants(currentChatDialog.dialogId ?? '').then((pagedResult) {
        if (pagedResult != null && pagedResult.items.isNotEmpty) {
          occupants.clear();
          Map<int, CubeUser> map = {for (var item in pagedResult.items) item.id ?? 1: item};
          occupants.addAll(map);
          occupants.remove(currentUser?.id);
        }
      }).catchError((error) {});
    } else {
      getAllUsersByIds(currentChatDialog.occupantsIds!.toSet()).then((result) {
        occupants.addAll({for (var item in result!.items) item.id: item});
      });
    }
  }

  final _distinctDebouncer = Debouncer(delay: 500.milliseconds);

  void distinctMessages() {
    _distinctDebouncer.call(() {
      chatMessagesList.distinctBy((element) => element.messageId ?? "-1").toList();
      update();
    });
  }

  void addAddMessages(List<CubeMessage>? messages) {
    if (messages == null) return;
    chatMessagesList.addAll(messages);
    distinctMessages();
  }

  Future<UserModel?> _getCurrentUserExternalId() async {
    Map<int, CubeUser> chatDetailScreenOccupants = {};
    CubeUser? otherContactParticipiant;

    var result = await getUsersByIds(currentChatDialog.occupantsIds!.toSet());
    chatDetailScreenOccupants.clear();
    chatDetailScreenOccupants.addAll(result);
    // if (currentChatDialog.dialogId != null) {
    //   groupCreatedBy =
    //       chatDetailScreenOccupants.entries.firstWhere((groupCreatedUser) => groupCreatedUser.value.id == currentChatDialog.userId!).value;
    // }
    // // get group creator name
    // if (currentChatDialog.dialogId != null) {
    //   final cubeUser = await getUserById(currentChatDialog.userId!);
    //   groupCreatedBy = cubeUser;
    // }
    chatDetailScreenOccupants.remove(currentUser?.id);
    otherContactParticipiant =
        chatDetailScreenOccupants.values.isNotEmpty ? chatDetailScreenOccupants.values.first : CubeUser(fullName: "Absent");

    return UserModel(
      uId: otherContactParticipiant.login,
      name: otherContactParticipiant.fullName,
      profilePicture: otherContactParticipiant.avatar,
    );
  }

  @override
  dispose() {
    // conversationScreenDispose();
    listScrollController?.dispose();
    super.dispose();
  }

  final Map<int?, CubeUser?> occupants = {};
  @override
  bool isLoading = false;
  late StreamSubscription<ConnectivityResult> connectivityStateSubscription;
  String? imageUrl;
  List<CubeMessage> chatMessagesList = [];
  Timer? typingTimer;
  bool isTyping = false;
  String userStatus = '';

  // ignore: constant_identifier_names
  static const int TYPING_TIMEOUT = 700;

  // ignore: constant_identifier_names
  static const int STOP_TYPING_TIMEOUT = 2000;

  int sendIsTypingTime = DateTime.now().millisecondsSinceEpoch;
  Timer? sendStopTypingTimer;

  final TextEditingController messageTextField = TextEditingController();
  final FocusNode messageTextFieldFocusNode = FocusNode();
  final _connectivity = Connectivity();
  final crashlytics = CrashlyticsController.to;
  final Debouncer _debouncer = Debouncer(delay: 1000.milliseconds);
  final _imagePicker = ImagePicker();
  final MediaService _mediaService = MediaService();

  // late ScrollController listScrollController;

  StreamSubscription<CubeMessage>? messageSubscription;
  StreamSubscription<MessageStatus>? deliveredSubscription;
  StreamSubscription<MessageStatus>? readSubscription;
  StreamSubscription<TypingStatus>? typingSubscription;
  StreamSubscription<MessageStatus>? deleteSubscription;

  List<CubeMessage> unreadMessages = [];

  static const int messagesPerPage = 30;
  int lastPartSize = 0;

  List<CubeMessage> oldMessages = [];
  bool isAttachmentLoading = false;

  // uploading message type
  late helper.MessageType uploadingMessageType;
  Map<String, MessagePlaceholder> uploadingMessagesMap = {};

  // List<MessagePlaceholder> uploadingMessagesList = [];
  ChatGlobalVariables chatGlobalVariables = ChatGlobalVariables();

  /// Send Message to the chat
  void onSendMessage(CubeMessage message) async {
    final isInternetAvailable = await _isInternetConnected;
    // print("${isInternetAvailable} Message sending! \n \n${message.toJson()}\n \nChatroom: ${currentChatDialog.toJson()}\n \n");

    if (isInternetAvailable) {
      message.body = EncryptData.encryption(data: message.body!);

      await currentChatDialog.sendMessage(message);

      message.senderId = currentUser?.id;
      addMessageToListView(message);
      sendCustomNotification(message);
    } else {
      /// INTERNET IS NOT CONNECTED SO QUEUE THE MESSAGE
      message.senderId = currentUser?.id;

      /// add message to queue
      QueueMessageController.to.addQueueMessage(QueueCubeMessage(message: message, chatroom: currentChatDialog));

      /// add message to list view
      addMessageToListView(message);
    }

    ChatController.to().setChatroomLastMessage(message, notify: true);
  }

  /// send custom push notification to only group members
  sendCustomNotification(CubeMessage message) {
    if (currentChatDialog.type != CubeDialogType.PUBLIC) return;
    String title = currentUser?.fullName ?? 'New Message';
    String body = (message.body == null || message.body?.isEmpty == true) ? 'Attachment' : message.body!;
    CreateEventParams params = CreateEventParams();

    /// get all members of the group
    List<int?> memberIds = occupants.keys.toList();

    /// if theres no member in group that means
    /// its a private chat so add the other user
    if (memberIds.isEmpty) {
      return;
    } else {
      title = "${currentChatDialog.name}";
      body = "${currentUser?.fullName ?? 'New Message'}: $body";
    }

    params.parameters = {
      'message': body,
      'dialog_id': currentChatDialog.dialogId,
      'message_id': message.messageId,
      "user_id": currentChatDialog.userId,
      "dialog_type": currentChatDialog.type ?? 'Message',
      "messageType": "chatMessage",
      "android_fcm_notification": {
        "title": title,
        "body": body,
      },
      "is_group_notification": "true",
    };
    params.notificationType = NotificationType.PUSH;
    params.environment = "production";

    /// group members ids
    params.usersIds = memberIds;

    createEvent(params.getEventForRequest()).then((events) {
      events.forEach((event) {
        print("Event created: ${event.toJson()}\n");
      });
    }).catchError((error) {
      print("Error creating event: $error");
    });
  }

  void conversationScreenInit() {
    // reLoginChatUser();
    initCubeChat();
    isLoading = false;
    imageUrl = '';
    // listScrollController.addListener(onScrollChanged);
    connectivityStateSubscription = Connectivity().onConnectivityChanged.handleError(handleStreamError).listen(onConnectivityChanged);
  }

  void handleStreamError(Object error) {
    if (error is SocketException) {
      CustomSnackBar.showCustomErrorSnackBar(
        title: "No Internet Connection",
        message: "Please check your internet connection and try again",
      );
    }
  }

  void conversationScreenDispose() {
    messageSubscription?.cancel();
    deliveredSubscription?.cancel();
    readSubscription?.cancel();
    typingSubscription?.cancel();
    deleteSubscription?.cancel();
    try {
      messageTextField.clear();
    } catch (_) {}
    connectivityStateSubscription.cancel();
    // currentChatDialog= null;
    chatMessagesList.clear();

    /// Mark Inactive only if there is no stack of conversation screen
    ChatController.to().decideToCallInactive(currentChatDialog.dialogId ?? '');
  }

  initChatListeners() {
    messageSubscription = CubeChatConnection.instance.chatMessagesManager!.chatMessagesStream.listen(onReceiveMessage);
    deliveredSubscription = CubeChatConnection.instance.messagesStatusesManager!.deliveredStream.listen(onDeliveredMessage);
    readSubscription = CubeChatConnection.instance.messagesStatusesManager!.readStream.listen(onReadMessage);
    typingSubscription = CubeChatConnection.instance.typingStatusesManager!.isTypingStream.listen(onTypingMessage);
    deleteSubscription = CubeChatConnection.instance.messagesStatusesManager!.deletedStream.listen(onDeleteMessage);
  }

  /// Call when internet is backed!
  /// Read unread messages
  Future<void> onReconnected() async {
    if (!await _isInternetConnected) return;
    if (unreadMessages.isNotEmpty) {
      for (var cubeMessage in unreadMessages) {
        currentChatDialog.readMessage(cubeMessage);
      }
      unreadMessages.clear();
    }
  }

  void initCubeChat() {
    bool isValid = CubeChatConnection.instance.isAuthenticated();
    if (isValid) {
      initChatListeners();
    } else {
      CubeChatConnection.instance.connectionStateStream.listen((state) {
        if (CubeChatConnectionState.Ready == state) {
          initChatListeners();
          onReconnected();
        } else {}
      });
    }
  }

  Future<bool> get _isInternetConnected async => (await _connectivity.checkConnectivity()) != ConnectivityResult.none;

  void openGallery() async {
    FilePickerResult? result = await FilePicker.platform.pickFiles(
      type: FileType.image,
    );
    if (result == null) return;
    isLoading = true;
    update();
    var uploadImageFuture = getUploadingImageFuture(result);
    Uint8List imageData;
    if (kIsWeb) {
      imageData = result.files.single.bytes!;
    } else {
      imageData = File(result.files.single.path!).readAsBytesSync();
    }
    var decodedImage = await decodeImageFromList(imageData);
    uploadImageFile(uploadImageFuture, decodedImage);
  }

  Future uploadImageFile(Future<CubeFile> uploadAction, imageData) async {
    uploadAction.then((cubeFile) {
      onSendChatAttachment(cubeFile, imageData);
    }).catchError((ex) {
      isLoading = false;
      update();

      Fluttertoast.showToast(msg: GayaStrings.file_not_image.tr);
    });
  }

  void onReceiveMessage(CubeMessage message) {
    if (message.dialogId != currentChatDialog.dialogId || message.senderId == currentUser?.id) return;

    addMessageToListView(message);

    /// Setting last message on `[chat_screen.dart]`
    ChatController.to().setChatroomLastMessage(message);
  }

  void onDeliveredMessage(MessageStatus status) {
    updateReadDeliveredStatusMessage(status, false);
  }

  void onDeleteMessage(MessageStatus status) {
    updateDeletedMessagesList(status);
  }

  void onReadMessage(MessageStatus status) {
    updateReadDeliveredStatusMessage(status, true);
  }

  void onTypingMessage(TypingStatus status) {
    if (status.userId == currentUser?.id || (status.dialogId != null && status.dialogId != currentChatDialog.dialogId)) return;
    userStatus = occupants[status.userId]?.fullName ?? occupants[status.userId]?.login ?? '';
    if (userStatus.isEmpty) return;
    userStatus = "$userStatus is typing ...";
    if (isTyping != true) {
      isTyping = true;
      update();
    }
    startTypingTimer();
  }

  startTypingTimer() {
    typingTimer?.cancel();
    typingTimer = Timer(const Duration(milliseconds: 900), () {
      isTyping = false;
      update();
    });
  }

  void onSendChatAttachment(CubeFile cubeFile, imageData) async {
    final attachment = CubeAttachment();
    attachment.id = cubeFile.uid;
    attachment.type = CubeAttachmentType.IMAGE_TYPE;
    attachment.url = cubeFile.getPublicUrl();
    attachment.height = imageData.height;
    attachment.width = imageData.width;
    final message = createCubeMsg();
    message.body = "Attachment";
    message.attachments = [attachment];
    onSendMessage(message);
  }

  CubeMessage createCubeMsg() {
    var message = CubeMessage();
    message.dateSent = DateTime.now().millisecondsSinceEpoch ~/ 1000;
    message.markable = true;
    message.saveToHistory = true;
    return message;
  }

  updateReadDeliveredStatusMessage(MessageStatus status, bool isRead) {
    CubeMessage? msg = chatMessagesList.firstWhereOrNull((msg) => msg.messageId == status.messageId);
    if (msg == null) return;
    if (isRead) {
      msg.readIds == null ? msg.readIds = [status.userId] : msg.readIds?.add(status.userId);
    } else {
      msg.deliveredIds == null ? msg.deliveredIds = [status.userId] : msg.deliveredIds?.add(status.userId);
    }
    update();
  }

  updateDeletedMessagesList(MessageStatus status) {
    CubeMessage? msg = chatMessagesList.firstWhereOrNull((msg) => msg.messageId == status.messageId);
    if (msg == null) return;
    removeMessageFromListView(msg);
  }

  void addMessageToListView(CubeMessage message) {
    try {
      /// no need to add message while messages are fetching because
      /// it will be added in the list when fetching will be completed
      /// so to avoid duplicate messages we are not adding message here if fetching is in progress [for Other User]
      if (isMessagesGetting) return;

      message.body = EncryptData.decryptionOfLastMessage(data: message.body);
      isAttachmentLoading = false;

      int existMessageIndex = chatMessagesList.indexWhere((cubeMessage) {
        return cubeMessage.messageId == message.messageId;
      });
      if (existMessageIndex != -1) {
        chatMessagesList[existMessageIndex] = message;
      } else {
        print("berfor addMessageToListView length: ${chatMessagesList.length}");
        chatMessagesList.insert(0, message);
        print("addMessageToListView length: ${chatMessagesList.length}");
      }
    } catch (_) {
      print("addMessageToListView Error at : ${_}");
    } finally {
      update();
    }
  }

  removeMessageFromListView(CubeMessage message) {
    isLoading = false;
    int existMessageIndex = chatMessagesList.indexWhere((cubeMessage) {
      return cubeMessage.messageId == message.messageId;
    });

    if (existMessageIndex != -1) {
      // chatMessagesList[existMessageIndex] = message;
      chatMessagesList.removeAt(existMessageIndex);
    } else {
      // chatMessagesList.insert(0, message);
    }
    update();
  }

  bool isLoadingMore = false;
  bool isLoadingMoreFinished = false;

  void onScrollChanged(ScrollController listScrollController) {
    if (isLoadingMoreFinished) return;
    if ((listScrollController.position.pixels == listScrollController.position.maxScrollExtent) && messagesPerPage >= lastPartSize) {
      isLoadingMore = true;
      if (oldMessages.isNotEmpty) {
        getMessagesBetweenDates(
                oldMessages.first.dateSent ?? 0, chatMessagesList.last.dateSent ?? DateTime.now().millisecondsSinceEpoch ~/ 1000)
            .then((newMessages) {
          isLoadingMore = false;

          /// decrypt messages
          newMessages = EncryptData.decryptListOfMessages(messages: newMessages);

          print(
              "newMessages.length < messagesPerPage ${newMessages.length < messagesPerPage}, $messagesPerPage perPage,  ${newMessages.length} fetched ");
          chatMessagesList.addAll(newMessages);
          if (newMessages.length < messagesPerPage) {
            oldMessages.insertAll(0, chatMessagesList);
            chatMessagesList = List.from(oldMessages);
            oldMessages.clear();
          }

          distinctMessages();
        });
      } else {
        print("Else CASE FOR ScrollChanged ${messagesPerPage >= lastPartSize}, $messagesPerPage perPage,  ${lastPartSize} fetched");
        getMessagesByDate(chatMessagesList.last.dateSent ?? 0, false).then((messages) {
          isLoadingMore = false;
          addAddMessages(messages);
        });
      }

      if (messagesPerPage > lastPartSize) {
        isLoadingMoreFinished = true;
      }
      update();
    }
  }

  Future<void> onConnectivityChanged(ConnectivityResult connectivityType) async {
    if (connectivityType == ConnectivityResult.wifi ||
        connectivityType == ConnectivityResult.mobile ||
        connectivityType == ConnectivityResult.vpn ||
        connectivityType == ConnectivityResult.ethernet ||
        connectivityType == ConnectivityResult.other) {
      _onConnectivityDebouncer.call(() {
        isLoading = true;
        update();
        getMessagesBetweenDates(chatMessagesList.firstOrNull?.dateSent ?? 0, DateTime.now().millisecondsSinceEpoch ~/ 1000)
            .then((newMessages) {
          if (newMessages.length == messagesPerPage) {
            oldMessages = List.from(chatMessagesList);
            chatMessagesList = newMessages;
          } else {
            chatMessagesList.insertAll(0, newMessages);
          }
          distinctMessages();
        }).whenComplete(() {
          isLoading = false;
          update();
        });
      });
    }
  }

  Future<List<CubeMessage>> getMessagesByDate(int date, bool isLoadNew) async {
    var params = GetMessagesParameters();
    params.sorter = RequestSorter(SORT_DESC, '', 'date_sent');
    params.limit = messagesPerPage;
    params.filters = [RequestFilter('', 'date_sent', isLoadNew || date == 0 ? 'gt' : 'lt', date)];

    return getMessages(currentChatDialog.dialogId ?? '', params.getRequestParameters())
        .then((result) {
          lastPartSize = result!.items.length;

          /// decrypt messages
          result.items = EncryptData.decryptListOfMessages(messages: result.items);

          return result.items;
        })
        .whenComplete(() {})
        .catchError((onError) {});
  }

  Future<List<CubeMessage>> getMessagesBetweenDates(int startDate, int endDate) async {
    var params = GetMessagesParameters();
    params.sorter = RequestSorter(SORT_DESC, '', 'date_sent');
    params.limit = messagesPerPage;
    params.filters = [RequestFilter('', 'date_sent', 'gt', startDate), RequestFilter('', 'date_sent', 'lt', endDate)];

    return getMessages(currentChatDialog.dialogId ?? '', params.getRequestParameters()).then((result) {
      /// decrypt messages
      return EncryptData.decryptListOfMessages(messages: result!.items);
    });
  }

  void sendIsTypingStatus() {
    var currentTime = DateTime.now().millisecondsSinceEpoch;
    var isTypingTimeout = currentTime - sendIsTypingTime;
    if (isTypingTimeout >= TYPING_TIMEOUT) {
      sendIsTypingTime = currentTime;
      currentChatDialog.sendIsTypingStatus();
      _startStopTypingStatus();
    }
  }

  void _startStopTypingStatus() {
    sendStopTypingTimer?.cancel();
    sendStopTypingTimer = Timer(const Duration(milliseconds: STOP_TYPING_TIMEOUT), () {
      currentChatDialog.sendStopTypingStatus();
    });
  }

  deleteMessage(CubeMessage message, bool force) {
    List<String> ids = [message.messageId ?? ''];
    deleteMessages(ids, force).then((deleteItemsResult) async {
      removeMessageFromListView(message);

      // Logging delete message event to analytics
      AnalyticsController.to.instance.logDeleteMessage(
        senderId: UserModel.to.uId ?? '',
        receiverId: await getOtherUserId() ?? '',
        message: message.body ?? '',
      );
    }).catchError((error) {});
  }

  ////////////////////////////////////////////  Ubaid new chat UI methods below  //////////////////////////////////
  TextEditingController documentTextField = TextEditingController();
  List<File> pdfFiles = [];
  Uint8List? pdfThumbnail;
  bool isPdf = false;
  bool isVideo = false;
  File? messageImage;
  bool documentUploadStatus = false;
  String writtenMessage = '';
  String? message;

  bool isCameraPermissionAllowed = false;
  bool isStoragePermissionAllowed = false;

  Future<bool> cameraPermissionCheck({required BuildContext context}) async {
    final cameraPermissionStatus = await Permission.camera.request();

    if (cameraPermissionStatus.isPermanentlyDenied || cameraPermissionStatus.isRestricted || cameraPermissionStatus.isDenied) {
      WidgetsBinding.instance.addPostFrameCallback((_) {
        _showCameraPermissionSnackBar(context: context);
      });
    }

    return cameraPermissionStatus.isGranted;
  }

  Future<bool> storagePermissionCheck({required BuildContext context}) async {
    final storagePermissionCheck = await Permission.storage.request();

    if (storagePermissionCheck.isPermanentlyDenied || storagePermissionCheck.isRestricted || storagePermissionCheck.isDenied) {
      WidgetsBinding.instance.addPostFrameCallback((_) {
        _showStoragePermissionSnackBar(context: context);
      });
    }

    return storagePermissionCheck.isGranted;
  }

  void _showStoragePermissionSnackBar({required BuildContext context}) {
    Navigator.of(context).pop();
    GayaSnackBar.show(type: GayaSnackBarType.problem, text: GayaStrings.storage_permission_allow.tr, context: context);
    Future.delayed(const Duration(seconds: 2), () {
      openAppSettings();
    });
  }

  void _showCameraPermissionSnackBar({required BuildContext context}) {
    GayaSnackBar.show(type: GayaSnackBarType.problem, text: GayaStrings.camera_permission_allow.tr, context: context);
    Future.delayed(const Duration(seconds: 2), () {
      openAppSettings();
    });
  }

  Future cameraImage({required BuildContext context}) async {
    try {
      clearNewMessagefields();

      XFile? imagePick = await _imagePicker.pickImage(source: ImageSource.camera, imageQuality: 50);

      if (imagePick != null) {
        // Logging pick image or video analytics event
        AnalyticsController.to.instance.logPickImageVideo(
          pickType: 'image',
          userId: UserModel.to.uId ?? '',
        );

        File convertedFile = File(imagePick.path);
        messageImage = convertedFile;

        update();
        return messageImage;
        // uploadMessageImage(chatroom);
      } else {
        return;
      }
    } on PlatformException catch (e) {
      if (DevicePermissionUtils.isDenied(e.message ?? e.code)) {
        openAppSettings();
      }
    }
  }

  Future pickGalleryImage({required BuildContext context, int imageQuality = 50}) async {
    try {
      clearNewMessagefields();
      XFile? galleryImage = await _imagePicker.pickImage(source: ImageSource.gallery, imageQuality: 50);

      if (galleryImage != null) {
        // Logging pick image or video analytics event
        AnalyticsController.to.instance.logPickImageVideo(pickType: 'image', userId: UserModel.to.uId ?? '');

        File convertedFile = File(galleryImage.path);
        messageImage = convertedFile;

        update();
        return messageImage;
      } else {
        return;
      }
    } on PlatformException catch (e) {
      if (DevicePermissionUtils.isDenied(e.message ?? e.code)) {
        openAppSettings();
      }
    }
  }

  updatetextField() {
    update(['textfield']);
  }

  // by mak => picking video from gallerey with proper permission handling etc
  Future pickVideo({required BuildContext context, int imageQuality = 50}) async {
    try {
      isVideo = true;
      XFile? file = await _mediaService.pickVideoFromGallery(context: context);
      if (file != null) {
        messageImage = File(file.path);
        messageImage = await Routes.cropVideoView(video: messageImage!);
      }
      update();
      return messageImage;
    } on PlatformException catch (e) {
      if (DevicePermissionUtils.isDenied(e.message ?? e.code)) {
        openAppSettings();
      }
    } catch (e) {}
  }

  //GET THE Document FROM STORAGE
  Future<File?> getPdfDocument({required BuildContext context}) async {
    try {
      clearNewMessagefields();

      messageTextField.clear();
      pdfFiles = [];
      messageImage = null;

      final File? document = await _mediaService.pickFile(context: context);
      if (document != null) {
        pdfFiles.add(document);
        isPdf = true;
      } else {}
      update();
      return document;
    } on PlatformException catch (e) {
      if (DevicePermissionUtils.isDenied(e.message ?? e.code)) {
        openAppSettings();
      }
    } catch (e) {}
  }

  final helper.CubeUtils _cubeUtils = helper.CubeUtils();

  Future<void> generatePdfThumbnail({required String url}) async {
    pdfThumbnail = await _cubeUtils.generateLocalPdfThumbnail(url: url);
    update(['textfield']);
  }

  Future<File?> generateThumbnailFile({required String url}) async {
    return await _cubeUtils.generateThumbnailFile(url: url);
  }

  Future<String> downloadAndCachePdf({required String url}) async {
    return await _cubeUtils.downloadAndCachePdf(url: url);
  }

  updateDocumentUploadStatus() {
    documentUploadStatus = true;
    update();
  }

  void removeSelectedPdf() {
    try {
      documentTextField.clear();
      messageImage = null;
      pdfFiles = [];
      pdfThumbnail = null;
      isPdf = false;

      update();
    } catch (e) {}
  }

  onChanged(value) {
    writtenMessage = value;
    update();
  }

  final CommentsServices service = CommentsServices();

  sendMessage(BuildContext context, helper.MessageType messagetype, {File? audioFile, String? duration}) async {
    // assign variables to object
    // chatGlobalVariables = ChatGlobalVariables();
    chatGlobalVariables.globalMessageImage = messageImage;
    chatGlobalVariables.globalPdfFiles = pdfFiles;
    chatGlobalVariables.globalAudioFile = audioFile;
    chatGlobalVariables.globalIsVideo = isVideo;
    chatGlobalVariables.globalIsPdf = isPdf;
    chatGlobalVariables.globalMessageTextField.text = messageTextField.text;
    chatGlobalVariables.globalDocumentTextField = documentTextField;
    chatGlobalVariables.globalDocumentTextField = documentTextField;

    // uploading message
    uploadingMessageType = messagetype;

    // Generate a unique key for the message
    String key = UniqueKey().toString();
    // Add the message type to the map with the unique key
    uploadingMessagesMap[key] = MessagePlaceholder(messagetype: messagetype);
    // uploadingMessagesMap.add(MessagePlaceholder(messagetype: messagetype));

    // assign values to empty
    messageImage = null;
    pdfFiles = [];
    audioFile = null;
    isVideo = false;
    isPdf = false;
    messageTextField.clear();
    documentTextField.clear();

    try {
      if (chatGlobalVariables.globalMessageImage != null ||
          chatGlobalVariables.globalPdfFiles.isNotEmpty ||
          chatGlobalVariables.globalAudioFile != null) {
        chatGlobalVariables.globalIsAttachmentLoading = true;
        update();
        if (chatGlobalVariables.globalAudioFile != null) {
          var cubeFile = getUploadingImageFutureAsCubeFile(chatGlobalVariables.globalAudioFile!);
          cubeFile.then((cubeFile) {
            sendAttachmentMessage(
              cubeFile,
              null,
              'audio',
              duration: duration,
            ).then((value) {
              uploadingMessagesMap.remove(key);
            });
            // Logging send message with attachment event
            logMessageSendEventToAnalytics(attachment: 'audio');
          }).catchError((ex) {
            Fluttertoast.showToast(msg: 'This file is not an image');
            chatGlobalVariables.globalIsAttachmentLoading = false;
            uploadingMessagesMap.remove(key);
          });
        } else if (chatGlobalVariables.globalMessageImage != null && !chatGlobalVariables.globalIsVideo) {
          var cubeFile = getUploadingImageFutureAsCubeFile(chatGlobalVariables.globalMessageImage!);
          var decodedImage = await decodeImageFromList(chatGlobalVariables.globalMessageImage!.readAsBytesSync());
          cubeFile.then((cubeFile) {
            sendAttachmentMessage(
              cubeFile,
              decodedImage,
              'image',
            ).then((value) {
              uploadingMessagesMap.remove(key);
            });
            // Logging send message with attachment event
            logMessageSendEventToAnalytics(attachment: 'image');
          }).catchError((ex) {
            Fluttertoast.showToast(msg: 'This file is not an image');
            chatGlobalVariables.globalIsAttachmentLoading = false;
            uploadingMessagesMap.remove(key);
          });
        } else if (chatGlobalVariables.globalMessageImage != null && chatGlobalVariables.globalIsVideo) {
          var cubeFile = getUploadingImageFutureAsCubeFile(chatGlobalVariables.globalMessageImage!);

          cubeFile.then((cubeFile) {
            sendAttachmentMessage(
              cubeFile,
              null,
              'video',
            ).then((value) {
              uploadingMessagesMap.remove(key);
            });
            // Logging send message with attachment event
            logMessageSendEventToAnalytics(attachment: 'video');
          }).catchError((ex) {
            Fluttertoast.showToast(msg: 'This file is not an image');
            chatGlobalVariables.globalIsAttachmentLoading = false;
            uploadingMessagesMap.remove(key);
          });
        } else if (chatGlobalVariables.globalIsPdf && chatGlobalVariables.globalPdfFiles.isNotEmpty) {
          File pdfFile = chatGlobalVariables.globalPdfFiles.first;
          var cubeFile = getUploadingImageFutureAsCubeFile(pdfFile);
          // var urrrl = await cubeFile.getPublicUrl();
          File? thumbnailFile = await generateThumbnailFile(url: pdfFile.path);

          cubeFile.then((cubeFile) {
            sendAttachmentMessage(cubeFile, null, 'document',
                    attachmentData: chatGlobalVariables.globalDocumentTextField.text.isNotEmpty
                        ? chatGlobalVariables.globalDocumentTextField.text.trim()
                        : pdfFile.path.split("/").last.split('-').last,
                    documentThumbnail: thumbnailFile)
                .then((value) {
              uploadingMessagesMap.remove(key);
            });
            // Logging send message with attachment event
            logMessageSendEventToAnalytics(attachment: 'document');
          }).catchError((ex) {
            Fluttertoast.showToast(msg: 'This file is not an image');
            chatGlobalVariables.globalIsAttachmentLoading = false;
            uploadingMessagesMap.remove(key);
            update();
          });
        }
      } else if (chatGlobalVariables.globalMessageTextField.text.isNotEmpty) {
        onSendChatMessage(chatGlobalVariables.globalMessageTextField.text.trim()).then((value) {
          uploadingMessagesMap.remove(key);
        });
        chatGlobalVariables.globalMessageTextField.clear();
      }
      update();
    } catch (_) {
      chatGlobalVariables.globalIsAttachmentLoading = false;
      uploadingMessagesMap.remove(key);
      update();
    }
  }

  bool isMessageUploading = false;

  Future<void> sendAttachmentMessage(CubeFile cubeFile, imageData, String type,
      {String attachmentData = '', File? documentThumbnail, String? duration}) async {
    try {
      // clearNewMessagefields();
      // update();
      final attachment = CubeAttachment();
      attachment.id = cubeFile.uid;
      final message = createCubeMsg();

      if (type == 'image') {
        MyLoggerServices.to.print('===> type == "image"');
        attachment.type = CubeAttachmentType.IMAGE_TYPE;
        attachment.url = cubeFile.getPublicUrl();
        attachment.height = imageData.height;
        attachment.width = imageData.width;
        message.body = "Attachment";
        message.attachments = [attachment];
      } else if (type == 'video') {
        MyLoggerServices.to.print('===> type == "video"');

        attachment.type = CubeAttachmentType.VIDEO_TYPE;
        String? url = cubeFile.getPublicUrl();
        attachment.url = url;

        /// once media is uploaded, update the comment with real url
        var thumbnailFile = await service.getThumbnailFromVideoUrl(videoUrl: url ?? '');
        if (thumbnailFile != null) {
          var thumbnail = await getUploadingImageFutureAsCubeFile(thumbnailFile);
          String? thumbnailUrl = thumbnail.getPublicUrl();
          attachment.data = thumbnailUrl;
        }

        message.body = "Attachment";
        message.attachments = [attachment];
      } else if (type == 'audio') {
        MyLoggerServices.to.print('===> type == "audio"');
        attachment.type = CubeAttachmentType.AUDIO_TYPE;
        attachment.url = cubeFile.getPublicUrl();
        message.body = "Attachment";
        message.properties['duration'] = duration ?? '';

        message.attachments = [attachment];
      } else if (type == 'document') {
        MyLoggerServices.to.print('===> type == "document"');
        attachment.type = null;
        attachment.url = cubeFile.getPublicUrl();
        attachment.name = 'document';
        if (documentThumbnail != null) {
          var thumbnail = await getUploadingImageFutureAsCubeFile(documentThumbnail);
          String? thumbnailUrl = thumbnail.getPublicUrl();
          attachment.data = thumbnailUrl;
        }
        message.body = "Attachment";
        message.attachments = [attachment];
      } else if (type == 'community') {
        MyLoggerServices.to.print('===> type == "community"');
        attachment.type = null;
        attachment.url = null;
        attachment.name = 'community';
        attachment.data = attachmentData;
        message.body = "Attachment";
        message.attachments = [attachment];
      } else if (type == 'post') {
        MyLoggerServices.to.print('===> type == "post"');
        attachment.type = null;
        attachment.url = null;
        attachment.name = 'post';
        attachment.data = attachmentData;
        message.body = "Attachment";
        message.attachments = [attachment];
      } else {
        MyLoggerServices.to.print('=====================================> No Type Matched');
      }

      onSendMessage(message);
    } catch (_) {
      MyLoggerServices.to.print('===> $_');
    }
  }

  void sendAttchmentMessageWithoutCubeFile(String type, {String attachmentData = ''}) {
    try {
      final attachment = CubeAttachment();
      final message = createCubeMsg();
      if (type == 'community') {
        MyLoggerServices.to.print('===> type == "community"');
        attachment.type = null;
        attachment.url = null;
        attachment.name = 'community';
        attachment.data = attachmentData;
        message.body = "Attachment";
        message.attachments = [attachment];
      } else if (type == 'post') {
        MyLoggerServices.to.print('===> type == "post"');
        attachment.type = null;
        attachment.url = null;
        attachment.name = 'post';
        attachment.data = attachmentData;
        message.body = "Attachment";
        message.attachments = [attachment];
      } else {
        MyLoggerServices.to.print('=====================================> No Type Matched');
      }
      onSendMessage(message);
    } catch (_) {}
  }

  Future<void> onSendChatMessage(String content) async {
    if (content.trim() != '') {
      final message = createCubeMsg();
      message.body = content.trim();
      onSendMessage(message);
    } else {
      Fluttertoast.showToast(msg: 'Nothing to send');
    }
  }

  removeNewImage() {
    if (messageImage == null) return;
    messageImage = null;
    update();
  }

  clearNewMessagefields() {
    messageImage = null;
    try {
      // messageTextField.clear();
      documentTextField.clear();
    } catch (_) {}

    isVideo = false;
    pdfFiles = [];
    pdfThumbnail = null;
    isPdf = false;
    isAttachmentLoading = false;
  }

  /// Invoke to log send message with [attachment] event to analytics
  Future<void> logMessageSendEventToAnalytics({
    String? attachment,
    String? message,
  }) async {
    if (attachment != null) {
      // Logging send message with attachment event
      AnalyticsController.to.instance.logSendMessageWithAttachments(
        senderId: UserModel.to.uId ?? '',
        receiverId: await getOtherUserId() ?? '',
        attachments: attachment,
      );
    } else {
      // Logging direct message event
      AnalyticsController.to.instance.logDirectMessage(
        receiverId: await getOtherUserId() ?? '',
        senderId: UserModel.to.uId ?? '',
        message: message!,
      );
    }
  }

  /// Invoke to get other user id (user with we are chatting one to one)
  Future<String?> getOtherUserId() async {
    // checking whether the chat is one to one chat
    if (currentChatDialog.type == CubeDialogType.PRIVATE) {
      // getting all chatting user (me and other)
      List<int>? allUsers = currentChatDialog.occupantsIds;
      if (allUsers != null && allUsers.length == 2 && currentUser != null) {
        // removing me form all users list
        bool currentUserRemoved = allUsers.remove(currentUser!.id!);
        // if my user id removed successfully form all users we only have other user id
        if (currentUserRemoved) {
          final user = await getUserById(allUsers.first);
          return user?.login;
        }
      }
    }
    return null;
  }

  // Invoke to log view chat analytics event
  Future<void> logViewChat() async {
    // Logging view chat analytics event
    AnalyticsController.to.instance.logViewChat(
      otherUserId: await getOtherUserId() ?? '',
      userId: UserModel.to.uId ?? '',
    );
  }

////////////////////////////////////////////  Ubaid new chat UI methods ended  //////////////////////////////////

  //////////////////////////////// Single contact and group detail or setting screen methods below ///////////////////////

  Map<int, CubeUser> chatDetailScreenOccupants = {};
  var isChatDetailScreenLoading = false;
  CubeUser? otherContactParticipiant;
  String? groupPhotoUrl = "";
  Set<int?> userstoRemoveFromGroup = {};
  List<int>? usersToAddInGroup;
  String userLastActivityTime = GayaStrings.not_available.tr;
  TextEditingController groupNameTextField = TextEditingController();
  CubeUser? groupCreatedBy;

  bool get groupCreatedByUser => groupCreatedBy?.fullName == null ? false : true;

  void initOfChatDetailInfoScreen() {
    getGroupOccupants();
  }

  void disposeOfChatDetailInfoScreen() {
    chatDetailScreenOccupants = {};
    isChatDetailScreenLoading = false;
    otherContactParticipiant = null;
    groupNameTextField.clear();
    groupPhotoUrl = '';
    usersToAddInGroup = null;
    userstoRemoveFromGroup.clear();
  }

  clearGroupChatDetailFieldsOnly() {
    groupNameTextField.clear();
    groupPhotoUrl = '';
    usersToAddInGroup = null;
    userstoRemoveFromGroup.clear();
  }

  initializeOtherContactOfContactChat() async {
    isChatDetailScreenLoading = true;
    WidgetsBinding.instance.addPostFrameCallback((_) {
      update();
    });
    var result = await getUsersByIds(currentChatDialog.occupantsIds!.toSet());
    chatDetailScreenOccupants.clear();
    chatDetailScreenOccupants.addAll(result);
    chatDetailScreenOccupants.remove(currentUser?.id);
    otherContactParticipiant =
        chatDetailScreenOccupants.values.isNotEmpty ? chatDetailScreenOccupants.values.first : CubeUser(fullName: "Absent");
    isChatDetailScreenLoading = false;
    WidgetsBinding.instance.addPostFrameCallback((_) {
      update();
    });
  }

  void groupCreatedUser() {
    if (currentChatDialog.dialogId != null) {
      groupCreatedBy =
          chatDetailScreenOccupants.entries.firstWhere((groupCreatedUser) => groupCreatedUser.value.id == currentChatDialog.userId!).value;
    }
  }

  Future<void> getGroupOccupants() async {
    isChatDetailScreenLoading = true;
    try {
      if (currentChatDialog.type == CubeDialogType.GROUP) {
        if (currentChatDialog.occupantsIds == null || currentChatDialog.occupantsIds!.isEmpty) {
          isChatDetailScreenLoading = false;
          WidgetsBinding.instance.addPostFrameCallback((_) {
            update();
          });
          return;
        }

        var result = await getUsersByIds(currentChatDialog.occupantsIds!.toSet());
        chatDetailScreenOccupants.clear();
        chatDetailScreenOccupants.addAll(result);
        groupCreatedUser();
        chatDetailScreenOccupants.remove(currentUser?.id);
        isChatDetailScreenLoading = false;
        WidgetsBinding.instance.addPostFrameCallback((_) {
          update();
        });
      } else if (currentChatDialog.type == CubeDialogType.PUBLIC) {
        if (currentChatDialog == null) {
          isChatDetailScreenLoading = false;
          WidgetsBinding.instance.addPostFrameCallback((_) {
            update();
          });
          return;
        }
        await getDialogOccupants(currentChatDialog.dialogId ?? '').then((pagedResult) async {
          if (pagedResult != null && pagedResult.items.isNotEmpty) {
            chatDetailScreenOccupants.clear();
            Map<int, CubeUser> map = {for (var item in pagedResult.items) item.id ?? 1: item};
            MyLoggerServices.to.print('pagedResult users map is: $map');
            chatDetailScreenOccupants.addAll(map);
            groupCreatedUser();
            chatDetailScreenOccupants.remove(currentUser?.id);
            isChatDetailScreenLoading = false;
            update();
          }
        }).catchError((error) {
          isChatDetailScreenLoading = false;
          WidgetsBinding.instance.addPostFrameCallback((_) {
            update();
          });
        });
      }
    } catch (_) {
      isChatDetailScreenLoading = false;
      WidgetsBinding.instance.addPostFrameCallback((_) {
        update();
      });
    } finally {
      isChatDetailScreenLoading = false;
    }
  }

  changeGroupProfile() async {
    FilePickerResult? result = await FilePicker.platform.pickFiles(
      type: FileType.image,
    );

    if (result == null) return;
    isChatDetailScreenLoading = true;
    update();
    var uploadImageFuture = getUploadingImageFuture(result);
    uploadImageFuture.then((cubeFile) {
      groupPhotoUrl = cubeFile.getPublicUrl();
      currentChatDialog.photo = groupPhotoUrl;
      isChatDetailScreenLoading = false;
      updateGroupDetails();
      update();
    }).catchError((error) {
      isChatDetailScreenLoading = false;
      update();
    });
  }

  navigateToaddOpponentsToGroupScreen(context) async {
    if (currentUser != null) {
      Get.toNamed(RouteHelper.addOponentsToGroup, arguments: {'dialogId': currentChatDialog.dialogId ?? ''})?.then((users) {
        if (users != null && users!.isNotEmpty) {
          usersToAddInGroup = users;
          updateGroupOpponentsOnly();
        }
      });
    } else {}
  }

  navigateToSearchGroupMembersScreen(context) async {
    if (currentUser != null) {
      // Routes.openSearchGroupChatMembers(dialogId: currentChatDialog.dialogId ?? '');
      Get.toNamed(RouteHelper.searchGroupMembers, arguments: {'dialogId': currentChatDialog.dialogId ?? ''})?.then((users) {
        if (users != null && users!.isNotEmpty) {
          usersToAddInGroup = users;
          updateGroupOpponentsOnly();
        }
      });
    } else {}
  }

  removeOpponentFromGroup() async {
    if (userstoRemoveFromGroup.isNotEmpty) updateGroupDetails();
  }

  void updateGroupDetails() {
    if (currentChatDialog == null) {
      return;
    }
    if (groupNameTextField.text.isEmpty &&
        groupPhotoUrl!.isEmpty &&
        (usersToAddInGroup?.isEmpty ?? true) &&
        (userstoRemoveFromGroup.isEmpty)) {
      Fluttertoast.showToast(msg: GayaStrings.nothing_save.tr);
      return;
    }
    Map<String, dynamic> params = {};
    if (groupNameTextField.text.isNotEmpty) params['name'] = groupNameTextField.text;
    if (groupPhotoUrl!.isNotEmpty) params['photo'] = groupPhotoUrl;
    if (usersToAddInGroup?.isNotEmpty ?? false) {
      params['push_all'] = {'occupants_ids': List.of(usersToAddInGroup!)};
    }
    if (userstoRemoveFromGroup.isNotEmpty) {
      params['pull_all'] = {'occupants_ids': List.of(userstoRemoveFromGroup)};
    }
    isChatDetailScreenLoading = true;
    update();
    ConnectyCubeSdk.updateDialog(currentChatDialog.dialogId!, params).then((dialog) {
      currentChatDialog = dialog;

      Fluttertoast.showToast(msg: GayaStrings.success_txt.tr);

      if ((usersToAddInGroup?.isNotEmpty ?? false) || (userstoRemoveFromGroup.isNotEmpty)) {
        getGroupOccupants();
      }
      isChatDetailScreenLoading = false;
      clearGroupChatDetailFieldsOnly();
      update();
    }).catchError((error) {});
  }

  // update group opponents
  void updateGroupOpponentsOnly() {
    try {
      if (currentChatDialog == null) {
        return;
      }
      if ((usersToAddInGroup?.isEmpty ?? true) && (userstoRemoveFromGroup.isEmpty)) {
        Fluttertoast.showToast(msg: GayaStrings.nothing_save.tr);
        return;
      }
      Map<String, dynamic> params = {};
      if (usersToAddInGroup?.isNotEmpty ?? false) {
        List<int> userIds = [];

        if (usersToAddInGroup!.length < 9 || usersToAddInGroup!.length == 9) {
          for (int i = 0; i < usersToAddInGroup!.length; i++) {
            userIds.add(usersToAddInGroup![i]);
          }
        } else {
          for (int i = 0; i < 9; i++) {
            userIds.add(usersToAddInGroup![i]);
          }
        }
        params['push_all'] = {'occupants_ids': List.of(usersToAddInGroup!)};
      }

      isChatDetailScreenLoading = true;
      WidgetsBinding.instance.addPostFrameCallback((_) {
        update();
      });
      ConnectyCubeSdk.updateDialog(currentChatDialog.dialogId!, params).then((dialog) {
        currentChatDialog = dialog;
        Fluttertoast.showToast(msg: GayaStrings.success_txt.tr);
        if ((usersToAddInGroup?.isNotEmpty ?? false) || (userstoRemoveFromGroup.isNotEmpty)) {
          getGroupOccupants();
        }
        isChatDetailScreenLoading = false;
        clearGroupChatDetailFieldsOnly();
        usersToAddInGroup?.clear();
        WidgetsBinding.instance.addPostFrameCallback((_) {
          update();
        });
      }).catchError((error) {
        isChatDetailScreenLoading = false;
        clearGroupChatDetailFieldsOnly();
        usersToAddInGroup?.clear();
        WidgetsBinding.instance.addPostFrameCallback((_) {
          update();
        });
        Fluttertoast.showToast(msg: GayaStrings.only_admin_allowed.tr);
      });
    } catch (_) {
      isChatDetailScreenLoading = false;
      clearGroupChatDetailFieldsOnly();
      usersToAddInGroup?.clear();
      WidgetsBinding.instance.addPostFrameCallback((_) {
        update();
      });
    }
  }

  exitGroup(context) {
    if (currentChatDialog != null) {
      deleteDialog(currentChatDialog.dialogId!).then((onValue) {
        Fluttertoast.showToast(msg: GayaStrings.exit_success.tr);
        Routes.openAllChatsScreenAndRemoveGroupsviewAfterExit();
        ChatController.to().getAllChatsList(notify: true);
      }).catchError((error) {
        log("exitGroup(): error $error");
        disposeOfChatDetailInfoScreen();
        isChatDetailScreenLoading = false;
        update();
      });
    }
  }

  toggleGroupOpponents(int index, bool toggle) {
    if (toggle) {
      userstoRemoveFromGroup.add(chatDetailScreenOccupants.values.elementAt(index).id);
    } else {
      userstoRemoveFromGroup.remove(chatDetailScreenOccupants.values.elementAt(index).id);
    }
    update();
  }

  bool isImageUploading = false;

  Future<void> pickImageFromGallery({required BuildContext context, int imageQuality = 50}) async {
    try {
      isImageUploading = true;
      update();
      XFile? files = await _mediaService.pickImageFromPhotos(context: context, imageQuality: imageQuality);
      if (files != null) {
        // Logging pick image or video analytics event
        AnalyticsController.to.instance.logPickImageVideo(
          pickType: 'image',
          userId: UserModel.to.uId ?? '',
        );

        File convertedFile = File(files.path);
        var uploadImageFuture = getUploadingImageFutureAsCubeFile(convertedFile);
        uploadImageFuture.then((cubeFile) {
          var url = cubeFile.getPublicUrl();
          currentChatDialog.photo = url;
          isImageUploading = false;
          update();
        }).catchError((exception) {
          GayaSnackBar(type: GayaSnackBarType.error, text: GayaStrings.failed_upload_group_profile.tr);
          isImageUploading = false;
          update();
        });
      } else {
        isImageUploading = false;
        update();
      }
    } on PlatformException {
      isImageUploading = false;
      update();
    } catch (e) {
      isImageUploading = false;
      update();
    }
  }

  // by mak => picking image from camera with proper permission handling etc
  Future<void> pickImageFromCamera({required BuildContext context, int imageQuality = 50}) async {
    try {
      isImageUploading = true;
      update();
      XFile? file = await _mediaService.pickImageFromCamera(context: context, imageQuality: imageQuality);
      if (file != null && file.path.isNotEmpty) {
        // Logging pick image or video analytics event
        AnalyticsController.to.instance.logPickImageVideo(
          pickType: 'image',
          userId: UserModel.to.uId ?? '',
        );

        File convertedFile = File(file.path);
        var uploadImageFuture = getUploadingImageFutureAsCubeFile(convertedFile);
        uploadImageFuture.then((cubeFile) {
          var url = cubeFile.getPublicUrl();
          currentChatDialog.photo = url;
          isImageUploading = false;
          update();
        }).catchError((exception) {
          GayaSnackBar(type: GayaSnackBarType.error, text: GayaStrings.failed_upload_group_profile.tr);
          isImageUploading = false;
          update();
        });
      } else {
        isImageUploading = false;
        update();
      }
    } on PlatformException {
      isImageUploading = false;
      update();
    } catch (e) {
      isImageUploading = false;
      update();
    }
  }

  //// Sharing group chat methods ///
  Future<void> generateGroupChatSharableLink(context) async {
    try {
      if (currentChatDialog == null) {
        Fluttertoast.showToast(msg: GayaStrings.faled_generate_link.tr);
        return;
      }
      String queryParam = "";
      GayaSocialTag? tag;
      late DynamicLinkType type;
      queryParam = queryParams;
      tag = DynamicLinkUtils.generateTagGroupChat(userName: currentUser?.fullName, groupChatModel: currentChatDialog);
      type = DynamicLinkType.groupChat;
      final shareAbleLink = await GayaSharedController.to.createAShareableLink(queryParam: queryParam, tag: tag, type: type);
      if (shareAbleLink != null) await Share.share(shareAbleLink);

      // logging share event
      AnalyticsController.to.instance.logShare(
        contentType: 'shareable_link',
        itemId: shareAbleLink ?? '',
        userId: UserModel.to.uId ?? '',
        platform: 'internal_group_shareable_link',
      );
    } catch (_) {
      Fluttertoast.showToast(msg: GayaStrings.faled_generate_link.tr);
    }
  }

  String get queryParams =>
      "?${QueryParamConst.id}=${currentChatDialog.dialogId}&${QueryParamConst.type}=$type&${QueryParamConst.isPrivate}=$isChatPrivate";

  String get type => DynamicLinkType.groupChat.name;

  bool get isChatPrivate => currentChatDialog.type == CubeDialogType.PRIVATE;

//////////////////////////////////////////// Paginated users and dialogs methods //////////////////////////////////
  TextEditingController searchUsersTextField = TextEditingController();
  ConnectyCubeMembersServices? _connectyCubeMembersServices;
  EasyRefreshController refreshController = EasyRefreshController();
  bool isFirstTimeGetAllUsers = false;

  /// Debouncer for connectivity state changed
  final Debouncer _onConnectivityDebouncer = Debouncer(delay: 2000.milliseconds);

  EasyRefreshController searchRefreshController = EasyRefreshController();
  EasyRefreshController groupChatMembersRefreshController = EasyRefreshController();
  bool isFirstTimeGetSearchedUsers = false;

  bool isNewGroupChat = false;
  bool isCreateGroupEditFieldsScreenSelected = false;

  final allCubeUsers = [];
  bool isConnectyCubeUsersLoading = true;
  List<CubeUser> groupAllMembers = [];
  List<CubeUser> searchedUsersList = [];
  List<CubeUser> selectedCubeUsersList = [];
  Set<int> selectedUsers = {};
  var isUserSearching = false;
  var isPrivateChat = true;
  String? userSearchQuery;
  String userSearchMessage = " ";

  initializeCommunityMembersServices() {
    _connectyCubeMembersServices = ConnectyCubeMembersServices(currentUser: currentUser);
  }

  Future<void> requestMoreAllUsers({bool fromInit = false}) async {
    if (currentUser == null) return;
    // _communityMembersServices = CommunityMembersServices(communityId: createCommunityModel?.communityId ?? '');
    // to avoid double loading at top andbottom on screen
    if (fromInit == false) refreshController.callLoad();
    if (fromInit) {
      isConnectyCubeUsersLoading = true;
    }
    isFirstTimeGetAllUsers = true;
    final newUsers = await _connectyCubeMembersServices!.requestAllUsersMoreData();
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
    if (fromInit == false) searchRefreshController.callLoad();
    if (fromInit) {
      isConnectyCubeUsersLoading = true;
    }
    isFirstTimeGetSearchedUsers = true;
    final newUsers = await _connectyCubeMembersServices!.requestSearchedUsersMoreData(query: userSearchQuery);
    final usersList = newUsers.map<CubeUser>((user) {
      return user as CubeUser;
    }).toList();
    searchedUsersList.addAll(usersList);
    isConnectyCubeUsersLoading = false;
    update();
  }

  // A dispose method for searched users.
  void resetSearchedUsersController({bool isDisposing = false}) async {
    searchedUsersList.clear();
    isFirstTimeGetSearchedUsers = false;
    isConnectyCubeUsersLoading = false;
    if (_connectyCubeMembersServices != null) {
      _connectyCubeMembersServices?.resetSearchedUsers();
    } else {
      initializeCommunityMembersServices();
    }
    if (isDisposing) {
    } else {
      await requestMoreSearchedUsers(
        fromInit: true,
      );
    }
    _debouncer.cancel();
  }

  Future<void> requestMoreGroupAllUsers({bool fromInit = false}) async {
    if (currentUser == null) return;
    if (fromInit == false) groupChatMembersRefreshController.callLoad();
    MyLoggerServices.to.print(" requestMoreData called");
    if (fromInit) {
      isConnectyCubeUsersLoading = true;
    }
    isFirstTimeGetAllUsers = true;
    final newUsers = await _connectyCubeMembersServices!.requestGroupAllUsersMoreData();
    groupAllMembers.addAll(newUsers);
    isConnectyCubeUsersLoading = false;
    update();
  }

  // A dispose method.
  void resetGroupAllUsersController({bool isDisposing = false}) async {
    groupAllMembers.clear();
    isFirstTimeGetAllUsers = false;
    isConnectyCubeUsersLoading = false;
    clearSearchValues();
    if (_connectyCubeMembersServices != null) {
      _connectyCubeMembersServices?.resetGroupAllUsers();
    }
    if (isDisposing) {
    } else {
      await requestMoreGroupAllUsers(
        fromInit: true,
      );
    }
    _debouncer.cancel();
  }

  searchUsers(value) async {
    if (value != null) {
      userSearchQuery = value;
      isUserSearching = true;
      await getSearchedUsersList();
      update();
    }
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

  Future<void> getSearchedUsersList() async {
    if (userSearchQuery != null && userSearchMessage.isNotEmpty) {
      resetSearchedUsersController();
    }
  }

  bool isUserSelected(CubeUser user) {
    bool isAvailable = selectedCubeUsersList.containsWhere((e) => e.id == user.id);
    return isAvailable;
  }

  addRemoveUsersInNewGroupChat(int index) {
    if (selectedUsers.contains(searchedUsersList[index].id)) {
      selectedUsers.remove(searchedUsersList[index].id);
    } else {
      selectedUsers.add(searchedUsersList[index].id!);
    }
    update();
  }

  updateCubeCurrentChat(CubeDialog chat) {
    currentChatDialog = chat;
    update();
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

////////////////////////////////////////////  Paginated users and dialogs ended  //////////////////////////////////
  List<CubeUser?>? selectedGroupUsers;
  Uint8List? selectedGroupImage;

  void disposeOfCreateNewGroupScreen() {
    groupNameTextField.clear();
    selectedGroupImage = null;
    selectedGroupUsers = [];
  }

  toggleIsNewGroupChat({bool shouldNotify = true, bool? customValue}) {
    isNewGroupChat = (customValue != null) ? customValue : !isNewGroupChat;
    if (shouldNotify) update();
  }

  void createNewConversation(BuildContext context, Set<int> users, bool isGroup) async {
    if (isGroup) {
      if (users.isEmpty) return;
      CubeDialog newDialog = CubeDialog(CubeDialogType.PUBLIC, occupantsIds: users.toList());
      List<CubeUser> usersToAdd = users.map((id) => selectedCubeUsersList.firstWhere((user) => user.id == id)).toList();
      if (currentUser != null) {
        selectedGroupUsers = [];
        selectedGroupUsers = usersToAdd;
        isCreateGroupEditFieldsScreenSelected = true;

        /// newly created group chat so by default add current user as admin
        /// reason: because we are making cubeDialog manually [newDialog]
        newDialog.adminsIds = [currentUser!.id!];
        updateCubeCurrentChat(newDialog);
      }
    } else {
      CubeDialog newDialog = CubeDialog(CubeDialogType.PRIVATE, occupantsIds: users.toList());
      createDialog(newDialog).then((createdDialog) {
        if (currentUser != null) {
          updateCubeCurrentChat(createdDialog);
          clearSearchValues();
          String previousRoute = Get.previousRoute;
          if (previousRoute == '/switch') {
            Get.toNamed(
              RouteHelper.conversation,
            )?.then((value) => ChatController.to().refreshChatsList());
          } else {
            Get.offAndToNamed(
              RouteHelper.conversation,
            )?.then((value) => ChatController.to().refreshChatsList());
          }
        }
      }).catchError((error) {});
    }
  }

  bool isGroupAdmin(int userId) {
    return (currentChatDialog.userId == userId) || (currentChatDialog.adminsIds?.contains(userId) ?? false);
  }

  bool get amIGroupAdmin => isGroupAdmin(currentUser?.id ?? 0);
}
