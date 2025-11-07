import 'dart:io';

import 'package:firebase_analytics/firebase_analytics.dart';
import 'package:flutter/foundation.dart';

import 'service/version_platform_services.dart';

class FirebaseAnalyticsService {
  FirebaseAnalyticsService();

  /* ----------------------------- STATE VARIABLES ---------------------------- */
  final FirebaseAnalytics _analytics = FirebaseAnalytics.instance;
  final FirebaseAnalyticsObserver observer = FirebaseAnalyticsObserver(
    analytics: FirebaseAnalytics.instance,
  );

  /* -------------------------------------------------------------------------- */
  /*                                 MAIN API'S                                 */
  /* -------------------------------------------------------------------------- */
  /* ------------------------------ USER PROFILE ------------------------------ */

  /// Invoke to log create user event
  Future<void> logCreateUser({
    String? userId,
    String? userName,
    String? userEmail,
  }) async {
    try {
      await _logEvent(
        'create_user',
        {
          'userId': userId,
          'userName': userName,
          'userEmail': userEmail,
          'userCreatedOn': DateTime.now().toIso8601String(),
        },
      );
    } catch (e) {
      debugPrint(e.toString());
    }
  }

  /// Invoke to log compliment
  Future<void> logCompliment({
    required String compliment,
    required String complimentGiverId,
    required String complimentReceiverId,
  }) async {
    try {
      await _logEvent(
        'user_compliment',
        {
          'compliment_giver_id': complimentGiverId,
          'compliment_receiver_id': complimentReceiverId,
          'compliment': compliment,
          'compliment_at': DateTime.now().toIso8601String(),
        },
      );
    } catch (e) {
      debugPrint(e.toString());
    }
  }

  /// Invoke to log user update profile event
  /// [updationType] -> profileImage, profileCover, bio or profile
  Future<void> logUpdateProfile({
    String? updationType,
    String? userId,
    String? userName,
    String? userEmail,
  }) async {
    try {
      await _logEvent(
        'update_profile',
        {
          'updationType': updationType,
          'userId': userId,
          'userName': userName,
          'userEmail': userEmail,
          'profileUpdatedOn': DateTime.now().toIso8601String(),
        },
      );
    } catch (e) {
      debugPrint(e.toString());
    }
  }

  /// Invoke to log create user event
  Future<void> logUserOpenedApp({
    String? userId,
    String? userName,
  }) async {
    try {
      await _logEvent(
        'user_opened_app',
        {
          'userId': userId,
          'userName': userName,
          'userOpenAppAt': DateTime.now().toIso8601String(),
        },
      );
    } catch (e) {
      debugPrint(e.toString());
    }
  }

  /* ------------------------------- FRIENDSHIP ------------------------------- */

  /// Invoke to log friend request send event
  Future<void> logFriendRequestSend({
    String? senderId,
    String? receiverId,
  }) async {
    try {
      await _logEvent(
        'friend_request_send',
        {
          'senderId': senderId,
          'receiverId': receiverId,
          'friend_request_send_at': DateTime.now().toIso8601String(),
        },
      );
    } catch (e) {
      debugPrint(e.toString());
    }
  }

  /// Invoke to log friend request receive event
  Future<void> logFriendRequestReceive({
    String? senderId,
    String? receiverId,
  }) async {
    try {
      await _logEvent(
        'friend_request_receive',
        {
          'senderId': senderId,
          'receiverId': receiverId,
          'friend_request_receive_at': DateTime.now().toIso8601String(),
        },
      );
    } catch (e) {
      debugPrint(e.toString());
    }
  }

  /// Invoke to log accept friend request event
  Future<void> logAcceptFriendRequest({
    String? userId,
    String? friendUserId,
  }) async {
    try {
      await _logEvent(
        'accept_friend_request',
        {
          'userId': userId,
          'friend_user_id': friendUserId,
          'friend_request_accept_at': DateTime.now().toIso8601String(),
        },
      );
    } catch (e) {
      debugPrint(e.toString());
    }
  }

  /// Invoke to log accept friend reject event
  Future<void> logRejectFriendRequest({
    String? userId,
    String? friendUserId,
  }) async {
    try {
      await _logEvent(
        'reject_friend_request',
        {
          'userId': userId,
          'friend_user_id': friendUserId,
          'friend_request_reject_at': DateTime.now().toIso8601String(),
        },
      );
    } catch (e) {
      debugPrint(e.toString());
    }
  }

  /// Invoke to log un-friend event
  Future<void> logUnFriend({
    String? userId,
    String? friendUserId,
  }) async {
    try {
      await _logEvent(
        'un_friend',
        {
          'userId': userId,
          'friend_user_id': friendUserId,
          'un_friend_at': DateTime.now().toIso8601String(),
        },
      );
    } catch (e) {
      debugPrint(e.toString());
    }
  }

  /// Invoke to log un-friend event
  Future<void> logUserBlock({
    String? userId,
    String? blockedUserId,
  }) async {
    try {
      await _logEvent(
        'user_block',
        {
          'userId': userId,
          'blocked_user_id': blockedUserId,
          'user_blocked_at': DateTime.now().toIso8601String(),
        },
      );
    } catch (e) {
      debugPrint(e.toString());
    }
  }

  /* --------------------------- COMMUNITIES / GROUP -------------------------- */

  /// Invoke to log create community event
  Future<void> logCreateCommunity({
    String? userId,
    String? communityId,
  }) async {
    try {
      await _logEvent(
        'create_community',
        {
          'userId': userId,
          'community_id': communityId,
          'community_created_at': DateTime.now().toIso8601String(),
        },
      );
    } catch (e) {
      debugPrint(e.toString());
    }
  }

  /// invoke to log event if a user joins a new community
  Future<void> logUserAddedToCommunity({
    required String communityId,
    required String userId,
  }) async {
    try {
      await _logEvent(
        'user_joined_community',
        {
          'community_id': communityId,
          'user_id': userId,
          'user_added_on': DateTime.now().toIso8601String(),
        },
      );
    } catch (e) {
      debugPrint(e.toString());
    }
  }

  /// Invoke to log leave community event
  Future<void> logLeaveCommunity({
    String? userId,
    String? communityId,
  }) async {
    try {
      await _logEvent(
        'leave_community',
        {
          'userId': userId,
          'community_id': communityId,
          'community_left_at': DateTime.now().toIso8601String(),
        },
      );
    } catch (e) {
      debugPrint(e.toString());
    }
  }

  /// Invoke to log create a post event
  Future<void> logCreatePost({
    required String communityId,
    required String postId,
    required String userId,
    required bool withMedia,
  }) async {
    try {
      return _logEvent(
        'create_post',
        {
          'community_id': communityId,
          'post_id': postId,
          'user_id': userId,
          'posted_with_media': withMedia,
          'post_created_at': DateTime.now().toIso8601String(),
        },
      );
    } catch (e) {
      debugPrint(e.toString());
    }
  }

  /// Invoke to log like or unlike post event
  /// [eventType] -> like or unlike
  Future<void> logLikeUnlikePost({
    required String eventType,
    required String userId,
    required String? communityId,
    required String? postId,
  }) async {
    try {
      await _logEvent(
        'like_unlike_post',
        {
          'event_type': eventType,
          'post_id': postId,
          'community_id': communityId,
          'user_id': userId,
          'post_liked_disliked_at': DateTime.now().toIso8601String(),
        },
      );
    } catch (e) {
      debugPrint(e.toString());
    }
  }

  /// Invoke to log pin or unpin post event
  /// [eventType] -> pin or unpin
  Future<void> logPinUnpinPost({
    required String eventType,
    required String userId,
    required String? communityId,
    required String? postId,
  }) async {
    try {
      await _logEvent(
        'pin_unpin_post',
        {
          'event_type': eventType,
          'post_id': postId,
          'community_id': communityId,
          'user_id': userId,
          'post_pin_unpin_at': DateTime.now().toIso8601String(),
        },
      );
    } catch (e) {
      debugPrint(e.toString());
    }
  }

  /// Invoke to log save or un-save post event
  /// [eventType] -> save or un_save
  Future<void> logSaveOrUnSavePost({
    required String eventType,
    required String userId,
    required String? communityId,
    required String? postId,
  }) async {
    try {
      await _logEvent(
        'save_un_save_post',
        {
          'event_type': eventType,
          'post_id': postId,
          'community_id': communityId,
          'user_id': userId,
          'post_save_un_save_at': DateTime.now().toIso8601String(),
        },
      );
    } catch (e) {
      debugPrint(e.toString());
    }
  }

  /// Invoke to log like or unlike post comment event
  /// [eventType] -> like or unlike
  Future<void> logLikeUnlikePostComment({
    required String eventType,
    required String userId,
    required String? communityId,
    required String? postId,
    required String? commentId,
  }) async {
    try {
      await _logEvent(
        'like_unlike_post_comment',
        {
          'event_type': eventType,
          'post_id': postId,
          'comment_id': commentId,
          'community_id': communityId,
          'user_id': userId,
          'post_comment_liked_disliked_at': DateTime.now().toIso8601String(),
        },
      );
    } catch (e) {
      debugPrint(e.toString());
    }
  }

  /// Invoke to log like or unlike post comment event
  /// [eventType] -> like or unlike
  Future<void> logLikeUnlikePostCommentReply({
    required String eventType,
    required String userId,
    required String? communityId,
    required String? postId,
    required String? commentId,
    required String? repliedCommentId,
  }) async {
    try {
      await _logEvent(
        'like_unlike_post_comment_reply',
        {
          'event_type': eventType,
          'post_id': postId,
          'comment_id': commentId,
          'replied_comment_id': repliedCommentId,
          'community_id': communityId,
          'user_id': userId,
          'post_replied_comment_liked_disliked_at': DateTime.now().toIso8601String(),
        },
      );
    } catch (e) {
      debugPrint(e.toString());
    }
  }

  /// Invoke to log new comment event
  Future<void> logNewComment({
    required String commentId,
    String? communityId,
    String? postId,
    String? userId,
  }) async {
    try {
      await _logEvent(
        'new_comment',
        {
          'community_id': communityId,
          'comment_id': commentId,
          'commenter_id': userId,
          'post_id': postId,
          'commented_on': DateTime.now().toIso8601String(),
        },
      );
    } catch (e) {
      debugPrint(e.toString());
    }
  }

  /// Invoke to log new comment reply event
  Future<void> logNewCommentReply({
    required String commentId,
    required String commentReplyId,
    String? communityId,
    String? postId,
    String? userId,
  }) async {
    try {
      await _logEvent(
        'new_comment_reply',
        {
          'community_id': communityId,
          'comment_id': commentId,
          'comment_reply_id': commentReplyId,
          'commenter_id': userId,
          'comment_replied_on': DateTime.now().toIso8601String(),
        },
      );
    } catch (e) {
      debugPrint(e.toString());
    }
  }

  /// Invoke to log crown post event
  Future<void> logCrownPost({
    required String communityId,
    required String postId,
    required String userId,
  }) async {
    try {
      await _logEvent(
        'crown_post',
        {
          'crown_giver_id': userId,
          'community_id': communityId,
          'post_id': postId,
          'post_crowned_on': DateTime.now().toIso8601String(),
        },
      );
    } catch (e) {
      debugPrint(e.toString());
    }
  }

  /// Invoke to log crown post comment event
  Future<void> logCrownPostComment({
    required String communityId,
    required String postId,
    required String commentId,
    required String userId,
  }) async {
    try {
      await _logEvent(
        'crown_post_comment',
        {
          'crown_giver_id': userId,
          'community_id': communityId,
          'post_id': postId,
          'comment_id': commentId,
          'post_comment_crowned_on': DateTime.now().toIso8601String(),
        },
      );
    } catch (e) {
      debugPrint(e.toString());
    }
  }

  /// Invoke to log crown post comment event
  Future<void> logCrownPostCommentReply({
    required String communityId,
    required String postId,
    required String commentId,
    required String commentReplyId,
    required String userId,
  }) async {
    try {
      await _logEvent(
        'crown_post_comment_reply',
        {
          'crown_giver_id': userId,
          'community_id': communityId,
          'post_id': postId,
          'comment_id': commentId,
          'comment_reply_id': commentReplyId,
          'post_comment_reply_crowned_on': DateTime.now().toIso8601String(),
        },
      );
    } catch (e) {
      debugPrint(e.toString());
    }
  }

  /// Invoke to share event
  Future<void> logShare({
    required String contentType,
    required String itemId,
    required String userId,
    String? platform,
  }) async {
    try {
      await _logEvent(
        'share',
        {
          'content_type': contentType,
          'item_id': itemId,
          'user_id': userId,
          'platform': platform,
          'share_at': DateTime.now().toIso8601String(),
        },
      );
    } on Exception catch (e) {
      debugPrint(e.toString());
    }
  }

  /// Invoke to community/group invite event
  Future<void> logCommunityInvite({
    required String communityId,
    required String userId,
    String? invitationSentUserId,
  }) async {
    try {
      await _logEvent(
        'community_invite',
        {
          'community_id': communityId,
          'user_id': userId,
          'invitation_sent_user_id': invitationSentUserId,
          'invite_sent_at': DateTime.now().toIso8601String(),
        },
      );
    } on Exception catch (e) {
      debugPrint(e.toString());
    }
  }

  /* ----------------------------- CONTENT SHARING ---------------------------- */

  /// Invoke to log delete post event
  Future<void> logDeletePost({
    required String communityId,
    required String postId,
    required String userId,
  }) async {
    try {
      return _logEvent(
        'delete_post',
        {
          'community_id': communityId,
          'post_id': postId,
          'user_id': userId,
          'post_deleted_at': DateTime.now().toIso8601String(),
        },
      );
    } catch (e) {
      debugPrint(e.toString());
    }
  }

  /* ---------------------------- DIRECT MESSAGING ---------------------------- */

  /// Invoke to log open messages event
  Future<void> logOpenMessages({
    required String userId,
  }) async {
    try {
      return _logEvent(
        'open_messages',
        {
          'user_id': userId,
          'opened_messages_at': DateTime.now().toIso8601String(),
        },
      );
    } catch (e) {
      debugPrint(e.toString());
    }
  }

  /// Invoke to log direct message event
  Future<void> logDirectMessage({
    required String senderId,
    required String receiverId,
    required String message,
  }) async {
    try {
      return _logEvent(
        'direct_message',
        {
          'sender_id': senderId,
          'receiver_id': receiverId,
          'message': message,
          'message_send_at': DateTime.now().toIso8601String(),
        },
      );
    } catch (e) {
      debugPrint(e.toString());
    }
  }

  /// Invoke to log direct message event
  Future<void> logSendMessageWithAttachments({
    required String senderId,
    required String receiverId,
    required String attachments,
  }) async {
    try {
      return _logEvent(
        'send_message_with_attachments',
        {
          'sender_id': senderId,
          'receiver_id': receiverId,
          'attachments': attachments,
          'message_send_at': DateTime.now().toIso8601String(),
        },
      );
    } catch (e) {
      debugPrint(e.toString());
    }
  }

  /// Invoke to log delete message event
  Future<void> logDeleteMessage({
    required String senderId,
    required String receiverId,
    required String message,
  }) async {
    try {
      return _logEvent(
        'delete_message',
        {
          'sender_id': senderId,
          'receiver_id': receiverId,
          'message': message,
          'message_deleted_at': DateTime.now().toIso8601String(),
        },
      );
    } catch (e) {
      debugPrint(e.toString());
    }
  }

  /* ------------------------------- SEARCH BAR ------------------------------- */

  /// Invoke to log user search event
  Future<void> logUserSearch({
    required String searchedText,
    required String userId,
  }) async {
    try {
      return _logEvent(
        'user_search',
        {
          'searched_text': searchedText,
          'user_id': userId,
          'user_searched_at': DateTime.now().toIso8601String(),
        },
      );
    } catch (e) {
      debugPrint(e.toString());
    }
  }

  /// Invoke to log user clicked search result event
  /// [itemType] -> user, community or post
  Future<void> logUserClickedSearchResult({
    required String searchedText,
    required String clickedResultText,
    required String itemType,
    required String clickedResultIndex,
    required String userId,
  }) async {
    try {
      return _logEvent(
        'user_clicked_search_result',
        {
          'searched_text': searchedText,
          'item_type': itemType,
          'clicked_result_text': clickedResultText,
          'clicked_result_index': clickedResultIndex,
          'user_id': userId,
          'user_clicked_search_result_at': DateTime.now().toIso8601String(),
        },
      );
    } catch (e) {
      debugPrint(e.toString());
    }
  }

  /// Invoke to log auto complete search text selected item event
  Future<void> logAutocompleteUsage({
    required String autoCompleteSelectedItemText,
    required String itemType,
    required String userId,
  }) async {
    try {
      return _logEvent(
        'auto_complete_usage',
        {
          'auto_complete_selected_item_text': autoCompleteSelectedItemText,
          'item_type': itemType,
          'user_id': userId,
          'auto_complete_item_selected_at': DateTime.now().toIso8601String(),
        },
      );
    } catch (e) {
      debugPrint(e.toString());
    }
  }

  /* ------------------------------ NOTIFICATION ------------------------------ */

  /// Invoke to log user clicked notification event
  Future<void> logUserClickNotification({
    required String payload,
    required String userId,
  }) async {
    try {
      return _logEvent(
        'user_click_notification',
        {
          'payload': payload,
          'user_id': userId,
          'user_clicked_notification_at': DateTime.now().toIso8601String(),
        },
      );
    } catch (e) {
      debugPrint(e.toString());
    }
  }

  /// Invoke to log user changed notifications settings event
  Future<void> logNotificationsSettingsChanged({
    required bool areNotificationsEnabled,
    required String userId,
  }) async {
    try {
      return _logEvent(
        'notification_settings',
        {
          'user_id': userId,
          'are_notifications_enabled': areNotificationsEnabled,
          'settings_changed_on': DateTime.now().toIso8601String(),
        },
      );
    } catch (e) {
      debugPrint(e.toString());
    }
  }

  /* ----------------------------- OTHER FEATURES ----------------------------- */

  /// Invoke to log special feature usage event
  /// [featureName] -> instagram_story_share, secret_community, community_theme,
  /// community_calendar, community_analytics, user_matches, post_reactions, user_compliment
  /// personal_message_privacy, community_post_approval
  Future<void> logSpecialFeatureUsage({
    required String userId,
    required String featureName,
  }) async {
    try {
      return _logEvent(
        'special_feature_usage',
        {
          'user_id': userId,
          'feature_name': featureName,
          'special_feature_used_at': DateTime.now().toIso8601String(),
        },
      );
    } catch (e) {
      debugPrint(e.toString());
    }
  }

  /// Invoke to log report community event
  Future<void> logReportCommunity({
    required String userId,
    required String communityId,
    required String reportMessage,
  }) async {
    try {
      return _logEvent(
        'report_community',
        {
          'user_id': userId,
          'community_id': communityId,
          'reportMessage': reportMessage,
          'community_reported_on': DateTime.now().toIso8601String(),
        },
      );
    } catch (e) {
      debugPrint(e.toString());
    }
  }

  /// Invoke to log report post event
  Future<void> logReportPost({
    required String userId,
    required String communityId,
    required String postId,
    required String reportMessage,
  }) async {
    try {
      return _logEvent(
        'report_post',
        {
          'user_id': userId,
          'community_id': communityId,
          'post_id': postId,
          'reportMessage': reportMessage,
          'post_reported_on': DateTime.now().toIso8601String(),
        },
      );
    } catch (e) {
      debugPrint(e.toString());
    }
  }

  /// Invoke to log report comment event
  Future<void> logReportComment({
    required String userId,
    required String communityId,
    required String postId,
    required String commentId,
    required String reportMessage,
  }) async {
    try {
      return _logEvent(
        'report_comment',
        {
          'user_id': userId,
          'community_id': communityId,
          'post_id': postId,
          'comment_id': commentId,
          'reportMessage': reportMessage,
          'comment_reported_on': DateTime.now().toIso8601String(),
        },
      );
    } catch (e) {
      debugPrint(e.toString());
    }
  }

  /// Invoke to log report comment reply event
  Future<void> logReportCommentReply({
    required String userId,
    required String communityId,
    required String postId,
    required String commentId,
    required String replyId,
    required String reportMessage,
  }) async {
    try {
      return _logEvent(
        'report_comment_reply',
        {
          'user_id': userId,
          'community_id': communityId,
          'post_id': postId,
          'comment_id': commentId,
          'reply_id': replyId,
          'reportMessage': reportMessage,
          'comment_reply_reported_on': DateTime.now().toIso8601String(),
        },
      );
    } catch (e) {
      debugPrint(e.toString());
    }
  }

  /* -------------------------------- APP USAGE ------------------------------- */

  /// Invoke to log special feature usage event
  Future<void> logUserSession({
    required String sessionStartTime,
    required String sessionEndTime,
    required String userSpentTime,
    required String userId,
  }) async {
    try {
      return _logEvent(
        'user_session_time',
        {
          'user_id': userId,
          'session_start_time': sessionStartTime,
          'session_end_time': sessionEndTime,
          'user_spent_time': userSpentTime,
        },
      );
    } catch (e) {
      debugPrint(e.toString());
    }
  }

  /* ------------------------------ OTHER EVENTS ------------------------------ */

  /// Invoke to log view post event
  Future<void> logViewPost({
    required String communityId,
    required String postId,
    required String userId,
  }) async {
    try {
      await _logEvent(
        'view_post',
        {
          'community_id': communityId,
          'post_id': postId,
          'user_id': userId,
          'post_viewed_at': DateTime.now().toIso8601String(),
        },
      );
    } catch (e) {
      debugPrint(e.toString());
    }
  }

  /// Invoke to log view community event
  Future<void> logViewCommunity({
    required String communityId,
    required String userId,
  }) async {
    try {
      await _logEvent(
        'view_community',
        {
          'community_id': communityId,
          'user_id': userId,
          'community_viewed_at': DateTime.now().toIso8601String(),
        },
      );
    } catch (e) {
      debugPrint(e.toString());
    }
  }

  /// Invoke to log view notification event
  /// [type] -> postCommented, postLiked, postCrowned, crownAirdrop, communityJoiningApproved, communityJoiningRejected,
  /// friendRequest, communityPostRequest, postReported, communityJoiningrequest
  Future<void> logViewNotification({
    required String userId,
    required String notificationId,
    required String type,
  }) async {
    try {
      await _logEvent(
        'view_notification',
        {
          'user_id': userId,
          'notification_id': notificationId,
          'type': type,
          'notification_viewed_at': DateTime.now().toIso8601String(),
        },
      );
    } catch (e) {
      debugPrint(e.toString());
    }
  }

  /// Invoke to log view chat event
  Future<void> logViewChat({
    required String userId,
    required String otherUserId,
  }) async {
    try {
      await _logEvent(
        'view_chat',
        {
          'user_id': userId,
          'other_user_id': otherUserId,
          'chat_viewed_at': DateTime.now().toIso8601String(),
        },
      );
    } catch (e) {
      debugPrint(e.toString());
    }
  }

  /// Invoke to log view user event
  Future<void> logViewUser({
    required String viewingUserId,
    required String viewedUserId,
  }) async {
    try {
      await _logEvent(
        'view_user',
        {
          'viewing_user_id': viewedUserId,
          'viewed_user_id': viewedUserId,
          'user_viewed_at': DateTime.now().toIso8601String(),
        },
      );
    } catch (e) {
      debugPrint(e.toString());
    }
  }

  /// Invoke to log community notifications status event
  Future<void> logCommunityNotificationsStatus({
    required String userId,
    required String communityId,
    required bool areNotificationsEnabled,
  }) async {
    try {
      return _logEvent(
        'community_notifications_status',
        {
          'notifications_enabled': areNotificationsEnabled,
          'community_id': communityId,
          'user_id': userId,
          'community_notifications_status_changed_at': DateTime.now().toIso8601String(),
        },
      );
    } catch (e) {
      debugPrint(e.toString());
    }
  }

  /// Invoke to set current screen (current running screen) event
  Future<void> setScreen(String screenName) async {
    try {
      await _analytics.setCurrentScreen(screenName: screenName);
    } catch (e) {
      debugPrint(e.toString());
    }
  }

  /// Invoke to set current user id to analytics event
  Future<void> setUserId(String userId) async {
    try {
      await _analytics.setUserId(id: userId);
    } catch (e) {
      debugPrint(e.toString());
    }
  }

  // Invoke to log user login event
  Future<void> logLogin({
    required String userId,
  }) async {
    try {
      await _logEvent(
        'login',
        {
          'user_id': userId,
          'user_login_time': DateTime.now().toIso8601String(),
        },
      );
    } catch (e) {
      debugPrint(e.toString());
    }
  }

  // Invoke to log user logout event
  Future<void> logLogout({
    required String userId,
  }) async {
    try {
      await _logEvent(
        'logout',
        {
          'user_id': userId,
          'user_logout_at': DateTime.now().toIso8601String(),
        },
      );
    } catch (e) {
      debugPrint(e.toString());
    }
  }

  /// Invoke to log delete account event
  Future<void> logDeleteAccount({
    required String userId,
    required Map? metadata,
  }) {
    return _logEvent(
      'delete_account',
      {
        'user_id': userId,
        'metadata': metadata,
        'user_account_deleted_at': DateTime.now().toIso8601String(),
      },
    );
  }

  /// Invoke to log change name event
  /// [type] -> user or community
  Future<void> logChangeName({
    required String oldName,
    required String newName,
    required String type,
  }) async {
    await _logEvent(
      'change_name',
      {
        'type': type,
        'old_name': oldName,
        'new_name': newName,
      },
    );
  }

  /// Invoke to log user with old app version event
  Future<void> logUserWithOldVersion({
    required String userId,
    required String currentVersion,
    required String newVersion,
  }) async {
    await _logEvent(
      'old_version',
      {
        'user_id': userId,
        'current_version': currentVersion,
        'new_version': newVersion,
      },
    );
  }

  /// Invoke to log view picture analytics event
  Future<void> logViewPicture({
    required List<String> urls,
    required String userId,
  }) async {
    try {
      await _logEvent(
        'view_picture',
        {
          'url': urls.toString(),
          'user_id': userId,
          'user_view_pic_at': DateTime.now().toIso8601String(),
        },
      );
    } catch (e) {
      debugPrint(e.toString());
    }
  }

  /// Invoke to log home logo tapped event
  Future<void> logHomeLogoTapped({
    required String userId,
  }) async {
    try {
      await _logEvent(
        'home_logo_tapped',
        {
          'user_id': userId,
          'home_logo_tapped_at': DateTime.now().toIso8601String(),
        },
      );
    } catch (e) {
      debugPrint(e.toString());
    }
  }

  /// Invoke to log invite home button event
  /// [isTappedOnly] -> whether user only tapped on home invite home button
  Future<void> logInviteHomeButton({
    bool isTappedOnly = true,
    required String userId,
  }) async {
    try {
      await _logEvent(
        'invite_home_button',
        {
          'is_tapped_only': isTappedOnly.toString(),
          'user_id': userId,
          'press_home_button_at': DateTime.now().toIso8601String(),
        },
      );
    } catch (e) {
      debugPrint(e.toString());
    }
  }

  /// Logging delete comment event
  Future<void> deleteComment({
    required String commentId,
    required String postId,
    required String communityId,
    required String userId,
  }) async {
    try {
      try {
        await _logEvent(
          'delete_comment',
          {
            'comment_id': commentId,
            'post_id': postId,
            'community_id': commentId,
            'user_id': userId,
            'comment_deleted_at': DateTime.now().toIso8601String(),
          },
        );
      } catch (e) {
        debugPrint(e.toString());
      }
    } catch (_) {}
  }

  /// Logging delete comment reply event
  Future<void> deleteCommentReply({
    required String replyCommentId,
    required String commentId,
    required String postId,
    required String communityId,
    required String userId,
  }) async {
    try {
      try {
        await _logEvent(
          'delete_comment_reply',
          {
            'reply_comment_id': replyCommentId,
            'comment_id': commentId,
            'post_id': postId,
            'community_id': commentId,
            'user_id': userId,
            'comment_deleted_at': DateTime.now().toIso8601String(),
          },
        );
      } catch (e) {
        debugPrint(e.toString());
      }
    } catch (_) {}
  }

  /// Invoke to log current tab of user event
  Future<void> logCurrentTab({
    required int index,
    required String userId,
  }) async {
    try {
      await _logEvent(
        'current_tab',
        {
          'index': index,
          'user_id': userId,
          'tab_changed_at': DateTime.now().toIso8601String(),
          'name': index == 0
              ? 'home'
              : index == 1
                  ? 'communities'
                  : index == 2
                      ? 'topics'
                      : index == 3
                          ? 'notifications'
                          : 'profile'
        },
      );
    } catch (e) {
      debugPrint(e.toString());
    }
  }

  /// Invoke to log pick image/video event
  /// pickType -> image or video
  Future<void> logPickImageVideo({
    required String pickType,
    required String userId,
  }) async {
    try {
      await _logEvent(
        'pick_image_or_video',
        {
          'pickType': pickType,
          'user_id': userId,
          'picked_at': DateTime.now().toIso8601String(),
        },
      );
    } catch (e) {
      debugPrint(e.toString());
    }
  }

  /// Invoke to log crop image event
  Future<void> cropImage({
    required String userId,
  }) async {
    try {
      await _logEvent(
        'crop_image',
        {
          'user_id': userId,
          'image_cropped_at': DateTime.now().toIso8601String(),
        },
      );
    } catch (e) {
      debugPrint(e.toString());
    }
  }

  /// Invoke to log crop video event
  Future<void> cropVideo({
    required String userId,
  }) async {
    try {
      await _logEvent(
        'crop_video',
        {
          'user_id': userId,
          'video_cropped_at': DateTime.now().toIso8601String(),
        },
      );
    } catch (e) {
      debugPrint(e.toString());
    }
  }

  /// Invoke to log view community modal event
  Future<void> logViewCommunityModal({
    required String communityId,
    required String userId,
  }) async {
    try {
      await _logEvent(
        'view_community_modal',
        {
          'community_id': communityId,
          'user_id': userId,
          'community_modal_viewed_at': DateTime.now().toIso8601String(),
        },
      );
    } catch (error) {
      debugPrint(error.toString());
    }
  }

  /// Invoke to log change language event
  Future<void> logChangeLanguage({
    required String oldLanguage,
    required String newLanguage,
    required String userId,
  }) async {
    try {
      await _logEvent(
        'change_language',
        {
          'user_id': userId,
          'old_language': oldLanguage,
          'new_language': newLanguage,
          'language_changed_at': DateTime.now().toIso8601String(),
        },
      );
    } catch (error) {
      debugPrint(error.toString());
    }
  }

  /// Invoke to log edit community event
  Future<void> logEditCommunity({
    required String communityId,
    required String userId,
    bool isNameChanged = false,
    bool isBioChanged = false,
    bool isThemeChanged = false,
    bool isTypeChanged = false,
    bool isCoverPictureChanged = false,
    bool isProfilePictureChanged = false,
  }) async {
    try {
      await _logEvent(
        'edit_community',
        {
          'user_id': userId,
          'community_id': communityId,
          'is_name_changed': isNameChanged,
          'is_bio_changed': isBioChanged,
          'is_theme_changed': isThemeChanged,
          'is_type_changed': isTypeChanged,
          'is_cover_picture_changed': isCoverPictureChanged,
          'is_profile_picture_changed': isProfilePictureChanged,
          'community_changed_at': DateTime.now().toIso8601String(),
        },
      );
    } catch (error) {
      debugPrint(error.toString());
    }
  }

  /// Invoke to log view all hidden communities event
  Future<void> logViewAllHiddenCommunities({
    required String userId,
  }) async {
    try {
      return _logEvent(
        'view_all_hidden_communities',
        {
          'user_id': userId,
          'hidden_communities_viewed_at': DateTime.now().toIso8601String(),
        },
      );
    } catch (e) {
      debugPrint(e.toString());
    }
  }

  /// Invoke to log report a problem event
  Future<void> logReportAProblem({
    required String userId,
    required String reportMessage,
  }) async {
    try {
      return _logEvent(
        'report_a_problem',
        {
          'user_id': userId,
          'report_message': reportMessage,
          'problem_reported_at': DateTime.now().toIso8601String(),
        },
      );
    } catch (e) {
      debugPrint(e.toString());
    }
  }

  /// Invoke to log open privacy policy event
  Future<void> logOpenPrivacyPolicy({
    required String userId,
  }) async {
    try {
      return _logEvent(
        'open_privacy_policy',
        {
          'user_id': userId,
          'privacy_policy_opened_at': DateTime.now().toIso8601String(),
        },
      );
    } catch (e) {
      debugPrint(e.toString());
    }
  }

  /// Invoke to log open terms of use event
  Future<void> logOpenTermsOfUse({
    required String userId,
  }) async {
    try {
      return _logEvent(
        'open_terms_of_use',
        {
          'user_id': userId,
          'terms_of_use_opened_at': DateTime.now().toIso8601String(),
        },
      );
    } catch (e) {
      debugPrint(e.toString());
    }
  }

  /// Invoke to log view about community event
  Future<void> logViewAboutCommunity({
    required String userId,
    required String communityId,
  }) async {
    try {
      return _logEvent(
        'view_about_community',
        {
          'user_id': userId,
          'community_id': communityId,
          'community_about_viewed_at': DateTime.now().toIso8601String(),
        },
      );
    } catch (e) {
      debugPrint(e.toString());
    }
  }

  /// Invoke to log community access lock use event
  Future<void> logCommunityAccessLockUse({
    required String userId,
    required String communityId,
    required bool isAccessLockEnabled,
  }) async {
    try {
      return _logEvent(
        'community_access_lock_use',
        {
          'access_lock_enabled': isAccessLockEnabled,
          'community_id': communityId,
          'user_id': userId,
          'access_lock_enabled_disabled_at': DateTime.now().toIso8601String(),
        },
      );
    } catch (e) {
      debugPrint(e.toString());
    }
  }

  /// Invoke to log community moderator tag event
  Future<void> logCommunityModeratorTag({
    required String adminId,
    required String communityId,
    required String tag,
  }) async {
    try {
      return _logEvent(
        'community_moderator_tag',
        {
          'admin_id': adminId,
          'community_id': communityId,
          'moderator_tag': tag,
          'moderator_tagged_at': DateTime.now().toIso8601String(),
        },
      );
    } catch (e) {
      debugPrint(e.toString());
    }
  }

  /// Invoke to log report comment reply event
  Future<void> logNotificationReport({
    required String notificationId,
    required String content,
    required String reportMsg,
    required String userId,
  }) async {
    try {
      return _logEvent(
        'report_notification',
        {
          'user_id': userId,
          'notification_id': notificationId,
          'content': content,
          'report_message': reportMsg,
          'notification_reported_at': DateTime.now().toIso8601String(),
        },
      );
    } catch (e) {
      debugPrint(e.toString());
    }
  }

  Future<void> logNotificationDelete({
    required String notificationId,
    required String userId,
  }) async {
    try {
      return _logEvent(
        'delete_notification',
        {
          'user_id': userId,
          'notification_id': notificationId,
          'notification_deleted_at': DateTime.now().toIso8601String(),
        },
      );
    } catch (e) {
      debugPrint(e.toString());
    }
  }

  /* ------------------------------------ . ----------------------------------- */

  Future<void> _logEvent(String name, Map<String, dynamic> parameters) async {
    if (kDebugMode) return;
    try {
      parameters['timestamp'] = DateTime.now().millisecondsSinceEpoch;
      parameters['platform'] = Platform.operatingSystem;
      parameters['version'] = (await VersionPlatformServices.to.getPlatformInfo())?.version ?? 'unknown';

      await _analytics.logEvent(name: name, parameters: parameters);
      debugPrint('log event $name $parameters');
    } catch (_) {
      debugPrint('log event error $_ $name $parameters');
    }
  }
}
