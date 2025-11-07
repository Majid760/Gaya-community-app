import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:connectycube_sdk/connectycube_sdk.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:gaya/app.dart';
import 'package:gaya/model/chatroom.model.dart';
import 'package:gaya/model/community.model.dart';
import 'package:gaya/model/create.post.model.dart';
import 'package:gaya/model/messaging.model/messages.model.dart';
import 'package:gaya/model/user.model.dart';
import 'package:gaya/routing/getx_route_methods.dart';
import 'package:gaya/services/services.dart';
import 'package:gaya/shared/service/message_service/message_service.dart';
import 'package:gaya/shared/view/widget/gaya_snackbar.dart';
import 'package:gaya/utils/language/translation.dart';
import 'package:gaya/utils/logger.dart';
import 'package:gaya/view/ai_daily_user_matches/controller/ai_matches_controller.dart';
import 'package:gaya/view/ai_daily_user_matches/utils/strings.dart';
import 'package:gaya/view/chat/controllers/chat_controller.dart';
import 'package:gaya/view/comments/models/comment_custom_model.dart';
import 'package:get/get.dart';

import '../../controller/firebase_analytics_controller.dart';
import '../../services/notification/notification_api/notification_api.dart';

enum MessageType { text, image, post, community }

class HelperFunc {
  final services = Services();
  final NotificationApiHitting _notificationApiHitting = NotificationApiHitting();

  ///this is always used as post.id
  Future<ChatRoomModel?> sendMessageAsPostOrCommunity(String uid, String postId, BuildContext context, String lastMessage,
      {MessageType messageType = MessageType.post}) async {
    if (FirebaseAuth.instance.currentUser?.uid == null) {
      return null;
    }

    // final users = [uid, FirebaseAuth.instance.currentUser!.uid]..sort();
    ChatRoomModel chatRoom = ChatRoomModel();
    User? user = FirebaseAuth.instance.currentUser;
    final participants = [uid, user!.uid]..sort();
    DocumentSnapshot snapshotData = await FirebaseFirestore.instance.collection('chatrooms').doc(participants.join()).get();

    /// Score
    EngagementScoreController.to.instance.onDirectMessage(toUserId: uid);
    if (messageType == MessageType.post) {
      EngagementScoreController.to.instance.onShare(postId: postId);
    } else {
      EngagementScoreController.to.instance.onShare(communityId: postId);
    }

    if (snapshotData.exists) {
      var chatRoomData = snapshotData.data();
      ChatRoomModel exisitingChatRoom = ChatRoomModel.fromMap(chatRoomData as Map<String, dynamic>);

      chatRoom = exisitingChatRoom;

      sendMessage(context, chatRoom, postId, lastMessage, messageType: messageType);

      log('you have already a chatroom');
    } else {
      ChatRoomModel newChatRoom = ChatRoomModel(
          typing: [],
          chatRoomId: participants.join(),
          participants: participants,
          isReadSender: true,
          isReadReceiver: false,
          lastMessage: 'Send message to start chatting!',
          lastMesgUserId: FirebaseAuth.instance.currentUser!.uid.toString());
      final UserModel? participant1 = await services.getUserById(FirebaseAuth.instance.currentUser!.uid);
      final UserModel? participant2 = await services.getUserById(uid);
      await FirebaseFirestore.instance
          .collection('chatrooms')
          .doc(participants.join())
          .set(newChatRoom.toMapForCreateRoom(participant1: participant1!, participant2: participant2!));
      chatRoom = newChatRoom;

      log('Hurrah!new chat room created!');

      await sendMessage(context, chatRoom, postId, lastMessage, messageType: messageType);
    }

    return chatRoom;
  }

  sendMessage(BuildContext context, ChatRoomModel chatRoomModel, String postId, String lastMessage,
      {MessageType messageType = MessageType.text}) async {
    FirebaseAuth firebaseAuth = FirebaseAuth.instance;
    User? user = firebaseAuth.currentUser;
    if (user == null) return;
    MessageModel messagesModel = MessageModel(
      sender: user.uid,
      message: postId,
      createTime: DateTime.now(),
      messageId: uuid.v1(),
      messageType: messageType,
    );

    await FirebaseFirestore.instance
        .collection('chatrooms')
        .doc(chatRoomModel.chatRoomId)
        .collection('messages')
        .doc(messagesModel.messageId)
        .set(messagesModel.toMap());
// "Shared a post";
    chatRoomModel.lastMessage = lastMessage;
    chatRoomModel.lastMessageTime = DateTime.now();
    chatRoomModel.isReadSender = true;
    chatRoomModel.isReadReceiver = false;
    chatRoomModel.lastMesgUserId = user.uid.toString();

    String otherChatParticipantFcmToken = '';
    await FirebaseFirestore.instance
        .collection('chatrooms')
        .doc(chatRoomModel.chatRoomId)
        .set(chatRoomModel.toUpdateRoomOnSentMap(), SetOptions(merge: true));

    int? receiverIndex = chatRoomModel.participants?.indexWhere((element) => element != messagesModel.sender);
    final userModel = UserModel.to;
    if (receiverIndex != null && receiverIndex != -1) {
      otherChatParticipantFcmToken =
          (await FirebaseFirestore.instance.collection('users').doc(chatRoomModel.participants?[receiverIndex]).get()).data()?['fm_token'];
      if (messagesModel.message.toString().isBlank == false) {
        final fcmMessageModel = FcmMessageModel(
            chatroomId: chatRoomModel.chatRoomId ?? '',
            messageContent: messagesModel.message ?? '',
            messageTitle: userModel.name ?? '',
            receiverFcm: otherChatParticipantFcmToken);
        _notificationApiHitting.callOnFcmApiChat(fcmMessageModel);
      }
    }
  }

  ////////////////////////////// Connectycube New Message Methods //////////////////////////////

  Future<void> openOrCreateCubeConversation(BuildContext context, String userId) async {
    try {
      /// Score
      EngagementScoreController.to.instance.onDirectMessage(toUserId: userId);

      CubeUser? user = await getUserByLogin(userId).catchError((error) {});

      if (user?.id == null) return;

      Set<int> users = {user!.id!};

      CubeDialog newDialog = CubeDialog(CubeDialogType.PRIVATE, occupantsIds: users.toList());
      createDialog(newDialog).then((createdDialog) {
        if (createdDialog.dialogId == null) return;
        Routes.openConversationAndRemovePreviousConversationRouteIfOpen(createdDialog, shouldReplace: true);
        // Get.toNamed(
        //   RouteHelper.conversation,
        //   arguments: {"dialog": createdDialog},
        //   preventDuplicates: false,
        // )?.then((value) => ChatController.to().refreshChatsList());
      }).catchError((error) {
        log("catch error on create new chat dialogs= $error");
      });
    } catch (_) {}
  }

  Future<void> createNewChatAndSendMessage(
    BuildContext context,
    String userId,
    String attachmentId,
    String type, {
    String attachmentData = '',
    Post? post,
    Community? community,
    String? simplePostTextMessage,
    String? customData,
  }) async {
    debugPrint("createNewChatAndSendMessage");
    try {
      final canSendMessage = await MessageUtils.canSendAMessage(user: UserModel(uId: userId));

      /// Cannot send message to this user
      if (canSendMessage != null) {
        return GayaSnackBar.show(context: context, type: GayaSnackBarType.problem, text: canSendMessage);
      }

      /// Score
      EngagementScoreController.to.instance.onDirectMessage(toUserId: userId);
      if (type == 'post') {
        EngagementScoreController.to.instance.onShare(postId: attachmentId);
      } else if (type == 'community') {
        EngagementScoreController.to.instance.onShare(communityId: attachmentId);
      }

      CubeUser? user = await getUserByLogin(userId).catchError((error) {});

      if (user?.id == null) return;

      Set<int> users = {user!.id!};

      CubeDialogCustomData customDataModel = CubeDialogCustomData("AIMatch");
      customDataModel.className = "AIMatch";
      customDataModel.fields['flag'] = 'AIMatch';

      CubeDialog newDialog =
          CubeDialog(CubeDialogType.PRIVATE, occupantsIds: users.toList(), customData: (customData == null) ? null : customDataModel);
      await createDialog(newDialog).then((createdDialog) {
        sendMessageFromOutsideOfChatModule(
          context,
          createdDialog,
          type,
          attachmentData: attachmentData,
          post: post,
          community: community,
          simplePostTextMessage: simplePostTextMessage,
          userId: userId,
        );
      }).catchError((error) {
        log("catch error on create new chat dialogs= $error");
      });
    } catch (_) {
      log("catch error on create new chat dialogs= $_");
    }
  }

  sendMessageFromOutsideOfChatModule(
    context,
    CubeDialog newChat,
    String type, {
    String attachmentData = '',
    Post? post,
    Community? community,
    String? simplePostTextMessage,
    String? userId,
  }) async {
    try {
      final attachment = CubeAttachment();
      final message = createCubeMsg();
      if (type == 'community') {
        MyLoggerServices.to.print('===> type == "community"');
        attachment.type = null;
        attachment.url = null;
        attachment.name = 'community';
        attachment.data = attachmentData;
        message.properties = {
          'userId': UserModel.to.uId ?? '',
          'postId': '',
          'communityId': attachmentData,
          'postName': '',
          'communityName': community?.communityName ?? '',
          'postImage': '',
          'communityImage': community?.CommunityPic ?? '',
          'postDescription': '',
          'communityDescription': community?.communityDescription ?? '',
        };
        message.body = "Attachment";
        message.attachments = [attachment];
      } else if (type == 'post') {
        MyLoggerServices.to.print('===> type == "post"');
        attachment.type = null;
        attachment.url = null;
        attachment.name = 'post';
        attachment.data = attachmentData;
        message.properties = {
          'userId': UserModel.to.uId ?? '',
          'postId': attachmentData,
          'communityId': post?.communityId ?? '',
          'postName': post?.postDescription ?? '',
          'communityName': post?.community.communityName ?? '',
          'postImage': (post?.multipleImages?.isEmpty ?? true) ? '' : post?.multipleImages?[0],
          'communityImage': '',
          'postDescription': post?.postDescription ?? '',
          'communityDescription': '',
        };
        message.body = "Attachment";
        message.attachments = [attachment];
      } else if (type == 'link') {
        MyLoggerServices.to.print('===> type == "link"');
        attachment.type = null;
        attachment.url = null;
        attachment.name = 'link';
        attachment.data = attachmentData;
        message.body = "Attachment";
        message.attachments = [attachment];
      } else {
        MyLoggerServices.to.print('=====================================> No Type Matched');
      }

      if (type == 'AIMatch') {
        // check if initial messages are already sent from other users
        if (newChat.lastMessage != null || newChat.lastMessageDateSent != null) {
          if (ChatController.to().currentUser != null) {
            openOrCreateCubeConversation(context, userId ?? "");
            if (userId != null && UserModel.to.uId != null) {
              // Tod un comment this line to remove match doc for both users
              AIMatchesController.to.removeMatchedUserDocs();
            }
          }
          return;
        }

        newChat.lastMessage = 'Attachment';

        final textMesage1 = createCubeMsg();
        final textMesage2 = createCubeMsg();
        final textMesage3 = createCubeMsg();

        if (simplePostTextMessage != null && simplePostTextMessage.isNotEmpty) {
          // 1sd message
          textMesage1.properties = {
            'flag': 'AIMatch',
            'imageUrl': 'Images/assets/ai_match.png',
          };
          textMesage1.body = "Atachment";
          await newChat.sendMessage(textMesage1);

          // 2rd message
          textMesage2.properties = {
            'flag': 'AIMatch',
            'imageUrl': '',
          };
          textMesage2.body = simplePostTextMessage.trim();
          await newChat.sendMessage(textMesage2);

          // 3rd message
          textMesage3.properties = {
            'flag': 'AIMatch',
            'imageUrl': '',
          };
          textMesage3.body = 'Default message'; //GayaStrings.match_message_text2;
          await newChat.sendMessage(textMesage3).then((message) {
            if (ChatController.to().currentUser != null) {
              openOrCreateCubeConversation(context, userId ?? "");
              if (userId != null && UserModel.to.uId != null) {
                // Tod un comment this line to remove match doc for both users
                AIMatchesController.to.removeMatchedUserDocs();
              }
            }
          });
        }
      } else {
        newChat.lastMessage = 'Attachment';
        newChat.sendMessage(message).then((value) async {
          if (simplePostTextMessage != null && simplePostTextMessage.isNotEmpty) {
            final textMesage = createCubeMsg();
            textMesage.body = simplePostTextMessage.trim();
            await newChat.sendMessage(textMesage).then((message) {
              if (ChatController.to().currentUser != null) {
                // delete match user doc for both users
                openOrCreateCubeConversation(context, userId ?? "");
              }
            });
          }
        });
      }
    } catch (_) {
      print(_);
    }
  }

  CubeMessage createCubeMsg() {
    var message = CubeMessage();
    message.dateSent = DateTime.now().millisecondsSinceEpoch ~/ 1000;
    message.markable = true;
    message.saveToHistory = true;
    return message;
  }

  //////////////////////////////    Connectycube Methods Ended    //////////////////////////////

  // update new reaction status on post
  Post? getPostModelOnReactionChange(String reaction, Post? post) {
    if (reaction == 'Like') {
      post?.postReactionData?.like = (post.postReactionData?.like ?? 0) + 1;
      if (post?.reactionModel != null) {
        if (post?.reactionModel?.reaction == 'Like') {
          post?.postReactionData?.like =
              ((post.postReactionData?.like == null || post.postReactionData?.like == 0) ? 1 : post.postReactionData!.like) - 1;
        } else if (post?.reactionModel?.reaction == 'Love') {
          post?.postReactionData?.inLove =
              ((post.postReactionData?.inLove == null || post.postReactionData?.inLove == 0) ? 1 : post.postReactionData!.inLove) - 1;
        } else if (post?.reactionModel?.reaction == 'Sad') {
          post?.postReactionData?.sad =
              ((post.postReactionData?.sad == null || post.postReactionData?.sad == 0) ? 1 : post.postReactionData!.sad) - 1;
        } else if (post?.reactionModel?.reaction == 'Angry') {
          post?.postReactionData?.angry =
              ((post.postReactionData?.angry == null || post.postReactionData?.angry == 0) ? 1 : post.postReactionData!.angry) - 1;
        } else if (post?.reactionModel?.reaction == 'Surprised') {
          post?.postReactionData?.surprized =
              ((post.postReactionData?.surprized == null || post.postReactionData?.surprized == 0) ? 1 : post.postReactionData!.surprized) -
                  1;
        } else if (post?.reactionModel?.reaction == 'Funny') {
          post?.postReactionData?.funny =
              ((post.postReactionData?.funny == null || post.postReactionData?.funny == 0) ? 1 : post.postReactionData!.funny) - 1;
        }
      }
    } else if (reaction == 'Love') {
      post?.postReactionData?.inLove = (post.postReactionData?.inLove ?? 0) + 1;
      if (post?.reactionModel != null) {
        if (post?.reactionModel?.reaction == 'Like') {
          post?.postReactionData?.like =
              ((post.postReactionData?.like == null || post.postReactionData?.like == 0) ? 1 : post.postReactionData!.like) - 1;
        } else if (post?.reactionModel?.reaction == 'Love') {
          post?.postReactionData?.inLove =
              ((post.postReactionData?.inLove == null || post.postReactionData?.inLove == 0) ? 1 : post.postReactionData!.inLove) - 1;
        } else if (post?.reactionModel?.reaction == 'Sad') {
          post?.postReactionData?.sad =
              ((post.postReactionData?.sad == null || post.postReactionData?.sad == 0) ? 1 : post.postReactionData!.sad) - 1;
        } else if (post?.reactionModel?.reaction == 'Angry') {
          post?.postReactionData?.angry =
              ((post.postReactionData?.angry == null || post.postReactionData?.angry == 0) ? 1 : post.postReactionData!.angry) - 1;
        } else if (post?.reactionModel?.reaction == 'Surprised') {
          post?.postReactionData?.surprized =
              ((post.postReactionData?.surprized == null || post.postReactionData?.surprized == 0) ? 1 : post.postReactionData!.surprized) -
                  1;
        } else if (post?.reactionModel?.reaction == 'Funny') {
          post?.postReactionData?.funny =
              ((post.postReactionData?.funny == null || post.postReactionData?.funny == 0) ? 1 : post.postReactionData!.funny) - 1;
        }
      }
    } else if (reaction == 'Sad') {
      post?.postReactionData?.sad = (post.postReactionData?.sad ?? 0) + 1;
      if (post?.reactionModel != null) {
        if (post?.reactionModel?.reaction == 'Like') {
          post?.postReactionData?.like =
              ((post.postReactionData?.like == null || post.postReactionData?.like == 0) ? 1 : post.postReactionData!.like) - 1;
        } else if (post?.reactionModel?.reaction == 'Love') {
          post?.postReactionData?.inLove =
              ((post.postReactionData?.inLove == null || post.postReactionData?.inLove == 0) ? 1 : post.postReactionData!.inLove) - 1;
        } else if (post?.reactionModel?.reaction == 'Sad') {
          post?.postReactionData?.sad =
              ((post.postReactionData?.sad == null || post.postReactionData?.sad == 0) ? 1 : post.postReactionData!.sad) - 1;
        } else if (post?.reactionModel?.reaction == 'Angry') {
          post?.postReactionData?.angry =
              ((post.postReactionData?.angry == null || post.postReactionData?.angry == 0) ? 1 : post.postReactionData!.angry) - 1;
        } else if (post?.reactionModel?.reaction == 'Surprised') {
          post?.postReactionData?.surprized =
              ((post.postReactionData?.surprized == null || post.postReactionData?.surprized == 0) ? 1 : post.postReactionData!.surprized) -
                  1;
        } else if (post?.reactionModel?.reaction == 'Funny') {
          post?.postReactionData?.funny =
              ((post.postReactionData?.funny == null || post.postReactionData?.funny == 0) ? 1 : post.postReactionData!.funny) - 1;
        }
      }
    } else if (reaction == 'Angry') {
      post?.postReactionData?.angry = (post.postReactionData?.angry ?? 0) + 1;
      if (post?.reactionModel != null) {
        if (post?.reactionModel?.reaction == 'Like') {
          post?.postReactionData?.like =
              ((post.postReactionData?.like == null || post.postReactionData?.like == 0) ? 1 : post.postReactionData!.like) - 1;
        } else if (post?.reactionModel?.reaction == 'Love') {
          post?.postReactionData?.inLove =
              ((post.postReactionData?.inLove == null || post.postReactionData?.inLove == 0) ? 1 : post.postReactionData!.inLove) - 1;
        } else if (post?.reactionModel?.reaction == 'Sad') {
          post?.postReactionData?.sad =
              ((post.postReactionData?.sad == null || post.postReactionData?.sad == 0) ? 1 : post.postReactionData!.sad) - 1;
        } else if (post?.reactionModel?.reaction == 'Angry') {
          post?.postReactionData?.angry =
              ((post.postReactionData?.angry == null || post.postReactionData?.angry == 0) ? 1 : post.postReactionData!.angry) - 1;
        } else if (post?.reactionModel?.reaction == 'Surprised') {
          post?.postReactionData?.surprized =
              ((post.postReactionData?.surprized == null || post.postReactionData?.surprized == 0) ? 1 : post.postReactionData!.surprized) -
                  1;
        } else if (post?.reactionModel?.reaction == 'Funny') {
          post?.postReactionData?.funny =
              ((post.postReactionData?.funny == null || post.postReactionData?.funny == 0) ? 1 : post.postReactionData!.funny) - 1;
        }
      }
    } else if (reaction == 'Surprised') {
      post?.postReactionData?.surprized = (post.postReactionData?.surprized ?? 0) + 1;
      if (post?.reactionModel != null) {
        if (post?.reactionModel?.reaction == 'Like') {
          post?.postReactionData?.like =
              ((post.postReactionData?.like == null || post.postReactionData?.like == 0) ? 1 : post.postReactionData!.like) - 1;
        } else if (post?.reactionModel?.reaction == 'Love') {
          post?.postReactionData?.inLove =
              ((post.postReactionData?.inLove == null || post.postReactionData?.inLove == 0) ? 1 : post.postReactionData!.inLove) - 1;
        } else if (post?.reactionModel?.reaction == 'Sad') {
          post?.postReactionData?.sad =
              ((post.postReactionData?.sad == null || post.postReactionData?.sad == 0) ? 1 : post.postReactionData!.sad) - 1;
        } else if (post?.reactionModel?.reaction == 'Angry') {
          post?.postReactionData?.angry =
              ((post.postReactionData?.angry == null || post.postReactionData?.angry == 0) ? 1 : post.postReactionData!.angry) - 1;
        } else if (post?.reactionModel?.reaction == 'Surprised') {
          post?.postReactionData?.surprized =
              ((post.postReactionData?.surprized == null || post.postReactionData?.surprized == 0) ? 1 : post.postReactionData!.surprized) -
                  1;
        } else if (post?.reactionModel?.reaction == 'Funny') {
          post?.postReactionData?.funny =
              ((post.postReactionData?.funny == null || post.postReactionData?.funny == 0) ? 1 : post.postReactionData!.funny) - 1;
        }
      }
    } else if (reaction == 'Funny') {
      post?.postReactionData?.funny = (post.postReactionData?.funny ?? 0) + 1;
      if (post?.reactionModel != null) {
        if (post?.reactionModel?.reaction == 'Like') {
          post?.postReactionData?.like =
              ((post.postReactionData?.like == null || post.postReactionData?.like == 0) ? 1 : post.postReactionData!.like) - 1;
        } else if (post?.reactionModel?.reaction == 'Love') {
          post?.postReactionData?.inLove =
              ((post.postReactionData?.inLove == null || post.postReactionData?.inLove == 0) ? 1 : post.postReactionData!.inLove) - 1;
        } else if (post?.reactionModel?.reaction == 'Sad') {
          post?.postReactionData?.sad =
              ((post.postReactionData?.sad == null || post.postReactionData?.sad == 0) ? 1 : post.postReactionData!.sad) - 1;
        } else if (post?.reactionModel?.reaction == 'Angry') {
          post?.postReactionData?.angry =
              ((post.postReactionData?.angry == null || post.postReactionData?.angry == 0) ? 1 : post.postReactionData!.angry) - 1;
        } else if (post?.reactionModel?.reaction == 'Surprised') {
          post?.postReactionData?.surprized =
              ((post.postReactionData?.surprized == null || post.postReactionData?.surprized == 0) ? 1 : post.postReactionData!.surprized) -
                  1;
        } else if (post?.reactionModel?.reaction == 'Funny') {
          post?.postReactionData?.funny =
              ((post.postReactionData?.funny == null || post.postReactionData?.funny == 0) ? 1 : post.postReactionData!.funny) - 1;
        }
      }
    }

    return post;
  }

  // update new reaction status on parent comment
  CommentCustomModel? getCommentModelOnReactionChange(String reaction, CommentCustomModel? parentComment) {
    if (reaction == 'Like') {
      parentComment?.commentReactionData?.like = (parentComment.commentReactionData?.like ?? 0) + 1;
      if (parentComment?.reactionModel != null) {
        if (parentComment?.reactionModel?.reaction == 'Like') {
          parentComment?.commentReactionData?.like = (parentComment.commentReactionData?.like ?? 1) - 1;
        } else if (parentComment?.reactionModel?.reaction == 'Love') {
          parentComment?.commentReactionData?.inLove = (parentComment.commentReactionData?.inLove ?? 1) - 1;
        } else if (parentComment?.reactionModel?.reaction == 'Sad') {
          parentComment?.commentReactionData?.sad = (parentComment.commentReactionData?.sad ?? 1) - 1;
        } else if (parentComment?.reactionModel?.reaction == 'Angry') {
          parentComment?.commentReactionData?.angry = (parentComment.commentReactionData?.angry ?? 1) - 1;
        } else if (parentComment?.reactionModel?.reaction == 'Surprised') {
          parentComment?.commentReactionData?.surprized = (parentComment.commentReactionData?.surprized ?? 1) - 1;
        } else if (parentComment?.reactionModel?.reaction == 'Funny') {
          parentComment?.commentReactionData?.funny = (parentComment.commentReactionData?.funny ?? 1) - 1;
        }
      }
    } else if (reaction == 'Love') {
      parentComment?.commentReactionData?.inLove = (parentComment.commentReactionData?.inLove ?? 0) + 1;
      if (parentComment?.reactionModel != null) {
        if (parentComment?.reactionModel?.reaction == 'Like') {
          parentComment?.commentReactionData?.like = (parentComment.commentReactionData?.like ?? 1) - 1;
        } else if (parentComment?.reactionModel?.reaction == 'Love') {
          parentComment?.commentReactionData?.inLove = (parentComment.commentReactionData?.inLove ?? 1) - 1;
        } else if (parentComment?.reactionModel?.reaction == 'Sad') {
          parentComment?.commentReactionData?.sad = (parentComment.commentReactionData?.sad ?? 1) - 1;
        } else if (parentComment?.reactionModel?.reaction == 'Angry') {
          parentComment?.commentReactionData?.angry = (parentComment.commentReactionData?.angry ?? 1) - 1;
        } else if (parentComment?.reactionModel?.reaction == 'Surprised') {
          parentComment?.commentReactionData?.surprized = (parentComment.commentReactionData?.surprized ?? 1) - 1;
        } else if (parentComment?.reactionModel?.reaction == 'Funny') {
          parentComment?.commentReactionData?.funny = (parentComment.commentReactionData?.funny ?? 1) - 1;
        }
      }
    } else if (reaction == 'Sad') {
      parentComment?.commentReactionData?.sad = (parentComment.commentReactionData?.sad ?? 0) + 1;
      if (parentComment?.reactionModel != null) {
        if (parentComment?.reactionModel?.reaction == 'Like') {
          parentComment?.commentReactionData?.like = (parentComment.commentReactionData?.like ?? 1) - 1;
        } else if (parentComment?.reactionModel?.reaction == 'Love') {
          parentComment?.commentReactionData?.inLove =
              ((parentComment.commentReactionData?.inLove == null || parentComment.commentReactionData?.inLove == 0)
                      ? 1
                      : parentComment.commentReactionData!.inLove) -
                  1;
        } else if (parentComment?.reactionModel?.reaction == 'Sad') {
          parentComment?.commentReactionData?.sad =
              ((parentComment.commentReactionData?.sad == null || parentComment.commentReactionData?.sad == 0)
                      ? 1
                      : parentComment.commentReactionData!.sad) -
                  1;
        } else if (parentComment?.reactionModel?.reaction == 'Angry') {
          parentComment?.commentReactionData?.angry =
              ((parentComment.commentReactionData?.angry == null || parentComment.commentReactionData?.angry == 0)
                      ? 1
                      : parentComment.commentReactionData!.angry) -
                  1;
        } else if (parentComment?.reactionModel?.reaction == 'Surprised') {
          parentComment?.commentReactionData?.surprized =
              ((parentComment.commentReactionData?.surprized == null || parentComment.commentReactionData?.surprized == 0)
                      ? 1
                      : parentComment.commentReactionData!.surprized) -
                  1;
        } else if (parentComment?.reactionModel?.reaction == 'Funny') {
          parentComment?.commentReactionData?.funny =
              ((parentComment.commentReactionData?.funny == null || parentComment.commentReactionData?.funny == 0)
                      ? 1
                      : parentComment.commentReactionData!.funny) -
                  1;
        }
      }
    } else if (reaction == 'Angry') {
      parentComment?.commentReactionData?.angry = (parentComment.commentReactionData?.angry ?? 0) + 1;
      if (parentComment?.reactionModel != null) {
        if (parentComment?.reactionModel?.reaction == 'Like') {
          parentComment?.commentReactionData?.like = (parentComment.commentReactionData?.like ?? 1) - 1;
        } else if (parentComment?.reactionModel?.reaction == 'Love') {
          parentComment?.commentReactionData?.inLove =
              ((parentComment.commentReactionData?.inLove == null || parentComment.commentReactionData?.inLove == 0)
                      ? 1
                      : parentComment.commentReactionData!.inLove) -
                  1;
        } else if (parentComment?.reactionModel?.reaction == 'Sad') {
          parentComment?.commentReactionData?.sad =
              ((parentComment.commentReactionData?.sad == null || parentComment.commentReactionData?.sad == 0)
                      ? 1
                      : parentComment.commentReactionData!.sad) -
                  1;
        } else if (parentComment?.reactionModel?.reaction == 'Angry') {
          parentComment?.commentReactionData?.angry =
              ((parentComment.commentReactionData?.angry == null || parentComment.commentReactionData?.angry == 0)
                      ? 1
                      : parentComment.commentReactionData!.angry) -
                  1;
        } else if (parentComment?.reactionModel?.reaction == 'Surprised') {
          parentComment?.commentReactionData?.surprized =
              ((parentComment.commentReactionData?.surprized == null || parentComment.commentReactionData?.surprized == 0)
                      ? 1
                      : parentComment.commentReactionData!.surprized) -
                  1;
        } else if (parentComment?.reactionModel?.reaction == 'Funny') {
          parentComment?.commentReactionData?.funny =
              ((parentComment.commentReactionData?.funny == null || parentComment.commentReactionData?.funny == 0)
                      ? 1
                      : parentComment.commentReactionData!.funny) -
                  1;
        }
      }
    } else if (reaction == 'Surprised') {
      parentComment?.commentReactionData?.surprized = (parentComment.commentReactionData?.surprized ?? 0) + 1;
      if (parentComment?.reactionModel != null) {
        if (parentComment?.reactionModel?.reaction == 'Like') {
          parentComment?.commentReactionData?.like = (parentComment.commentReactionData?.like ?? 1) - 1;
        } else if (parentComment?.reactionModel?.reaction == 'Love') {
          parentComment?.commentReactionData?.inLove =
              ((parentComment.commentReactionData?.inLove == null || parentComment.commentReactionData?.inLove == 0)
                      ? 1
                      : parentComment.commentReactionData!.inLove) -
                  1;
        } else if (parentComment?.reactionModel?.reaction == 'Sad') {
          parentComment?.commentReactionData?.sad =
              ((parentComment.commentReactionData?.sad == null || parentComment.commentReactionData?.sad == 0)
                      ? 1
                      : parentComment.commentReactionData!.sad) -
                  1;
        } else if (parentComment?.reactionModel?.reaction == 'Angry') {
          parentComment?.commentReactionData?.angry =
              ((parentComment.commentReactionData?.angry == null || parentComment.commentReactionData?.angry == 0)
                      ? 1
                      : parentComment.commentReactionData!.angry) -
                  1;
        } else if (parentComment?.reactionModel?.reaction == 'Surprised') {
          parentComment?.commentReactionData?.surprized =
              ((parentComment.commentReactionData?.surprized == null || parentComment.commentReactionData?.surprized == 0)
                      ? 1
                      : parentComment.commentReactionData!.surprized) -
                  1;
        } else if (parentComment?.reactionModel?.reaction == 'Funny') {
          parentComment?.commentReactionData?.funny =
              ((parentComment.commentReactionData?.funny == null || parentComment.commentReactionData?.funny == 0)
                      ? 1
                      : parentComment.commentReactionData!.funny) -
                  1;
        }
      }
    } else if (reaction == 'Funny') {
      parentComment?.commentReactionData?.funny = (parentComment.commentReactionData?.funny ?? 0) + 1;
      if (parentComment?.reactionModel != null) {
        if (parentComment?.reactionModel?.reaction == 'Like') {
          parentComment?.commentReactionData?.like = (parentComment.commentReactionData?.like ?? 1) - 1;
        } else if (parentComment?.reactionModel?.reaction == 'Love') {
          parentComment?.commentReactionData?.inLove =
              ((parentComment.commentReactionData?.inLove == null || parentComment.commentReactionData?.inLove == 0)
                      ? 1
                      : parentComment.commentReactionData!.inLove) -
                  1;
        } else if (parentComment?.reactionModel?.reaction == 'Sad') {
          parentComment?.commentReactionData?.sad =
              ((parentComment.commentReactionData?.sad == null || parentComment.commentReactionData?.sad == 0)
                      ? 1
                      : parentComment.commentReactionData!.sad) -
                  1;
        } else if (parentComment?.reactionModel?.reaction == 'Angry') {
          parentComment?.commentReactionData?.angry =
              ((parentComment.commentReactionData?.angry == null || parentComment.commentReactionData?.angry == 0)
                      ? 1
                      : parentComment.commentReactionData!.angry) -
                  1;
        } else if (parentComment?.reactionModel?.reaction == 'Surprised') {
          parentComment?.commentReactionData?.surprized =
              ((parentComment.commentReactionData?.surprized == null || parentComment.commentReactionData?.surprized == 0)
                      ? 1
                      : parentComment.commentReactionData!.surprized) -
                  1;
        } else if (parentComment?.reactionModel?.reaction == 'Funny') {
          parentComment?.commentReactionData?.funny =
              ((parentComment.commentReactionData?.funny == null || parentComment.commentReactionData?.funny == 0)
                      ? 1
                      : parentComment.commentReactionData!.funny) -
                  1;
        }
      }
    }

    print("parentComment?.commentReactionData?.inLove ${parentComment?.commentReactionData?.toMap()}");
    return parentComment;
  }
}
