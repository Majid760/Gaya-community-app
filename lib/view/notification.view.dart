import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:firebase_ui_firestore/firebase_ui_firestore.dart';
import 'package:flutter/material.dart';
import 'package:flutter/scheduler.dart';
import 'package:flutter/services.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:gaya/model/community.model.dart';
import 'package:gaya/model/create.post.model.dart';
import 'package:gaya/model/notifications.model.dart';
import 'package:gaya/model/user.model.dart';
import 'package:gaya/routing/getx_route_methods.dart';
import 'package:gaya/shared/view/widget/gaya_back_button.dart';
import 'package:gaya/utils/assets_icons.dart';
import 'package:gaya/utils/language/translation.dart';
import 'package:gaya/utils/methods.dart';
import 'package:gaya/utils/theme/app_colors.dart';
import 'package:get/get.dart';
import 'package:get/get_rx/src/rx_workers/utils/debouncer.dart';
import 'package:jiffy/jiffy.dart';
import 'package:provider/provider.dart';

import '../components/profile_image_widget.dart';
import '../controller/firebase_analytics_controller.dart';
import '../controller/notification.controller.dart';
import '../controller/report_controller.dart';
import '../services/services.dart';
import '../shared/view/widget/gaya_report_dialog.dart';
import '../utils/asset_images.dart';
import '../utils/const.dart';
import '../utils/textstyles.dart';
import '../widgets/notification_widgets/nonotification.widget.dart';
import '../widgets/notification_widgets/notification.whole.widget.dart';

class NotificationView extends StatefulWidget {
  const NotificationView({Key? key}) : super(key: key);

  @override
  State<NotificationView> createState() => _NotificationViewState();
}

class _NotificationViewState extends State<NotificationView> {
  Stream<QuerySnapshot>? snapShotData;
  List docId = [];
  var getFriendRequests;

  _onCommunityNotificationTap(QueryDocumentSnapshot<Map<String, dynamic>> snap, {required NotificationModel notification}) {
    onTapDebounce.call(() {
      debugPrint("_onCommunityNotificationTap() Notification tapped");

      if (notification.communityId != null && notification.communityId != '') {
        Methods.showModalSheetToJoinCommunity(
          communityId: notification.communityId,
          ctx: context,
          communityModel: Community(communityId: notification.communityId),
        );
        // Methods.routeToGroup(community: createCommunityModel);
      }
      if (snap["isRead"] == true) {
        //already read. no need to run below.
        return;
      }
      Services.to.readNotification(
        receiverUserID: NotificationItemUtils.isCrownAirdrppNotification(snap) ? "" : snap["receiverUserID"],
        notificationId: snap.id,
        type: snap["type"],
      );
    });
  }

  Debouncer onTapDebounce = Debouncer(delay: const Duration(milliseconds: 800));

  @override
  Widget build(BuildContext context) {
    User? user = FirebaseAuth.instance.currentUser;
    final notificationController = Provider.of<NotificationController>(context, listen: false);

    return Scaffold(
      resizeToAvoidBottomInset: false,
      appBar: AppBar(
        systemOverlayStyle: SystemUiOverlayStyle.dark,
        shape: Border(bottom: BorderSide(color: kBaseGrey.withOpacity(0.5))),
        automaticallyImplyLeading: false,
        title: Text(GayaStrings.notifications_txt.tr, style: CustomTypography.bodyStyle),
        leading: GayaBackButton(onPop: () => Navigator.pop(context)),
        centerTitle: true,
        backgroundColor: kTransparentColor,
        elevation: 0,
        actions: [
          Padding(
            padding: const EdgeInsets.only(right: 12.0),
            child: StreamProvider<QuerySnapshot?>(
              initialData: null,
              create: (context) => FirebaseAuth.instance.currentUser?.uid == null
                  ? const Stream.empty()
                  : FirebaseFirestore.instance
                      .collection('users')
                      .doc(FirebaseAuth.instance.currentUser!.uid)
                      .collection('notifications')
                      .where("isRead", isEqualTo: true)
                      .snapshots(),
              child: Consumer<QuerySnapshot?>(
                builder: (context, isReadAll, child) {
                  return isReadAll == null
                      ? const SizedBox.shrink()
                      : TextButton(
                          onPressed: isReadAll.docs.isNotEmpty ? () => Services.to.markAllNotificationsAsRead() : null,
                          child: Text(
                            GayaStrings.mark_as_read.tr,
                            style: TextStyle(
                              color: (docId.isEmpty && isReadAll.docs.isEmpty) ? kSecondaryColor : kprimaryColor,
                              fontWeight: FontWeight.w600,
                              fontFamily: GayaFontTheme.primaryFont,
                              fontSize: 14.sp,
                            ),
                          ),
                        );
                },
              ),
            ),
          ),
        ],
      ),
      body: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          if (user != null)

            /// Friend Request Notification
            StreamBuilder<QuerySnapshot>(
                stream: notificationController.friendRequestNotificationsStream(),
                builder: (context, dataSnapshot) {
                  if (dataSnapshot.connectionState == ConnectionState.waiting &&
                      Provider.of<NotificationController>(context, listen: true).isNotificationsLoaded == false) {
                    return const SizedBox.shrink();
                  }
                  if (dataSnapshot.connectionState == ConnectionState.active || dataSnapshot.connectionState == ConnectionState.done) {
                    if (dataSnapshot.hasData) {
                      if (docId.isEmpty) {
                      } else if (docId.isNotEmpty) {
                        docId.clear();
                      }
                      for (var i = 0; i < dataSnapshot.data!.docs.length; i++) {
                        docId.add(dataSnapshot.data!.docs[i].id);
                        // log(docId[i].toString());
                      }
                      if (docId.isEmpty || docId.length == 1) {}
                      return SizedBox(
                        // height: MediaQuery.sizeOf(context).height * 0.79,
                        width: MediaQuery.sizeOf(context).width,
                        child: Column(
                          mainAxisSize: MainAxisSize.min,
                          children: [
                            docId.isNotEmpty
                                ? ListView.builder(
                                    // controller: notificationController.notificationsScrollController,
                                    physics: const NeverScrollableScrollPhysics(),
                                    shrinkWrap: true,
                                    itemCount: (dataSnapshot.data!.docs.isNotEmpty && dataSnapshot.data!.docs.length > 2)
                                        ? 2
                                        : dataSnapshot.data!.docs.length,
                                    itemBuilder: (context, index) {
                                      Timestamp timestamp = dataSnapshot.data?.docs[index]['createdOn'];
                                      DateTime dateTime = timestamp.toDate();
                                      return Column(
                                        children: [
                                          RequestNotificationWidget(
                                              senderId: dataSnapshot.data?.docs[index]['senderUid'],
                                              profileImg: dataSnapshot.data?.docs[index]['senderProfile'],
                                              color: Colors.blue,
                                              text: dataSnapshot.data?.docs[index]['senderName'],
                                              postedTime: Jiffy(dateTime).fromNow(),
                                              pic: SvgIconWidget.userFilled(color: AppColors.white, height: 16.h, width: 16.w),
                                              widget1: GestureDetector(
                                                onTap: () async {
                                                  notificationController.aproveFriendRequest(docId[index]);
                                                },
                                                child: Container(
                                                  alignment: Alignment.center,
                                                  // height: 32,
                                                  padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
                                                  decoration: BoxDecoration(
                                                    color: kprimaryColor,
                                                    borderRadius: BorderRadius.circular(borderRadius_4),
                                                  ),
                                                  child: Center(
                                                    child: Text(GayaStrings.add_friend.tr, style: CustomTypography.titleStyleWhite),
                                                  ),
                                                ),
                                              ),
                                              widget2: GestureDetector(
                                                onTap: () async {
                                                  notificationController.rejectFriendrequest(docId[index]);

                                                  // Logging reject/ignore friend request to analytics events
                                                  AnalyticsController.to.instance.logRejectFriendRequest(
                                                    userId: UserModel.to.uId ?? '',
                                                    friendUserId: dataSnapshot.data?.docs[index]['senderUid'],
                                                  );
                                                },
                                                child: Container(
                                                  alignment: Alignment.center,
                                                  // height: distance_40,
                                                  padding: const EdgeInsets.symmetric(horizontal: 18, vertical: 8),
                                                  decoration: BoxDecoration(
                                                    color: kBaseGrey,
                                                    borderRadius: BorderRadius.circular(borderRadius_4),
                                                  ),
                                                  child: Text(
                                                    GayaStrings.remove_txt.tr,
                                                    style: CustomTypography.dark12,
                                                  ),
                                                ),
                                              )),
                                        ],
                                      );
                                    })
                                : const SizedBox.shrink(),
                            if (dataSnapshot.data!.docs.isNotEmpty && dataSnapshot.data!.docs.length > 2)
                              Padding(
                                padding: const EdgeInsets.symmetric(vertical: 10, horizontal: 20),
                                child: Row(
                                  mainAxisAlignment: MainAxisAlignment.end,
                                  children: [
                                    GestureDetector(
                                      onTap: () {
                                        Routes.openSeeAllFriendRequests();
                                      },
                                      child: Text(GayaStrings.see_all.tr, style: CustomTypography.secondaryFontStyle),
                                    ),
                                  ],
                                ),
                              )
                          ],
                        ),
                      );
                    }
                  }
                  return const SizedBox.shrink();
                }),
          if (user != null)
            Expanded(
              child: FirestoreListView(
                pageSize: 25,
                emptyBuilder: (_) => const Center(child: NoNotificationWidget()),
                loadingBuilder: (_) => const Center(child: CircularProgressIndicator.adaptive()),
                query: FirebaseFirestore.instance
                    .collection('users')
                    .doc(user.uid)
                    .collection("notifications")
                    .orderBy("time", descending: true),
                itemBuilder: (BuildContext context, QueryDocumentSnapshot<Map<String, dynamic>> documentSnapshots) {
                  NotificationModel notificationModel = NotificationModel.fromMap(documentSnapshots.data());
                  return (notificationModel.postId != null)
                      ? PostNotificationItem(
                          onTapMore: () => _onTapMore(documentSnapshots), notificationModel: notificationModel, snap: documentSnapshots)
                      : (notificationModel.communityId != null)
                          ?
                          ////// community related notifications ///////
                          CommunityNotificationItem(
                              onTapMore: () => _onTapMore(documentSnapshots),
                              notificationModel: notificationModel,
                              snap: documentSnapshots,
                              onTap: () => _onCommunityNotificationTap(documentSnapshots, notification: notificationModel),
                            )
                          : OtherNotificationWidget(
                              onTapMore: () => _onTapMore(documentSnapshots),
                              unreadMessageColor: notificationModel.isRead == false ? kprimaryColorLight : kTransparentColor,
                              notificationId: documentSnapshots.id,
                              receiverUserId: isCrownAirdrppNotification(documentSnapshots) ? "" : documentSnapshots["receiverUserID"],
                              profileImg: isCrownAirdrppNotification(documentSnapshots) ? null : documentSnapshots['userImage'],
                              color: _getColor(documentSnapshots),
                              typeOfComment: documentSnapshots['type'],
                              text: documentSnapshots['sender_name'],
                              postedTime: getJiffyDateTimeFromString(documentSnapshots),
                              shouldShowImageWidget: _shouldShowImageWidget(documentSnapshots),
                              pic: _getPicture(documentSnapshots),
                              message: documentSnapshots['message'],
                              onTapNotification: () => _onTapNotification(documentSnapshots),
                            );
                },
              ),
            )
        ],
      ),
    );
  }

  void _onTapMore(QueryDocumentSnapshot<Map<String, dynamic>> snap) {
    final iconSize = 24.0.r;
    Methods.showCircularModalSheet(
        context,
        SafeArea(
          child: Column(
            children: [
              ListTile(
                onTap: () {
                  Navigator.pop(context);
                  _onDeleteNotification(snap);
                },
                leading: SvgIconWidget.xCloseOutline(height: iconSize, width: iconSize),
                title: Text(GayaStrings.remove_notification.tr),
              ),
              ListTile(
                onTap: () {
                  _onReportNotification(snap);
                },
                leading: SvgIcons.problem(height: iconSize, width: iconSize),
                title: Text(GayaStrings.report_notification.tr),
              ),
            ],
          ),
        ));
  }

  Future<void> _onDeleteNotification(QueryDocumentSnapshot<Map<String, dynamic>> snap) async {
    await snap.reference.delete();
    AnalyticsController.to.instance.logNotificationDelete(
      userId: UserModel.to.uId ?? '',
      notificationId: snap.id,
    );
  }

  /// Reports notification with a bottom modal sheet
  Future<void> _onReportNotification(QueryDocumentSnapshot<Map<String, dynamic>> ref) async {
    return reportTextFieldBottomModal(
      context,
      onSubmit: (String reportMsg) async {
        Navigator.pop(context);
        await ReportController.to.reportANotification(
          notificationId: ref.id,
          reportMsg: reportMsg,
          content: ref['message'] ?? ref['sender_name'] ?? "No Content",
          context: context,
        );

        //  Logging report notification to analytics events
        AnalyticsController.to.instance.logNotificationReport(
          userId: UserModel.to.uId ?? '',
          notificationId: ref.id,
          reportMsg: reportMsg,
          content: ref['message'] ?? ref['sender_name'] ?? "No Content",
        );
      },
    );
  }

  _onTapNotification(QueryDocumentSnapshot<Map<String, dynamic>> documentSnapshots) {
    if (documentSnapshots["type"] == "friendRequest") {
      final user = UserModel(uId: documentSnapshots["sender_user_id"]);
      Routes.viewProfile(uid: user.uId, model: user);
    }

    if (documentSnapshots["isRead"] == true) {
      //already read. no need to run below.
      return;
    }
    Services.to.readNotification(
      receiverUserID: (isCrownAirdrppNotification(documentSnapshots)) ? UserModel.to.uId : documentSnapshots["receiverUserID"],
      notificationId: documentSnapshots.id,
      type: documentSnapshots["type"],
    );
  }

  _getColor(QueryDocumentSnapshot<Map<String, dynamic>> documentSnapshots) {
    return (documentSnapshots['type'] == 'postCommented')
        ? Colors.green
        : (documentSnapshots['type'] == 'postLiked')
            ? Colors.red
            : (documentSnapshots['type'] == 'postCrowned' || documentSnapshots['type'] == 'crownAirdrop')
                ? kYellowColor
                : (documentSnapshots['type'] == 'communityJoiningApproved' ||
                        documentSnapshots['type'] == 'communityJoiningRejected' ||
                        documentSnapshots['type'] == 'communityPostApproved' ||
                        documentSnapshots['type'] == 'communityPostRejected'
                    // ||
                    // documentSnapshots[index]['type'] == 'communityJoiningrequest'
                    )
                    ? kPrimaryBackgroundBtnColor //Colors.blue
                    : (documentSnapshots['type'] == 'friendRequest')
                        ? Colors.blue
                        : (documentSnapshots['type'] == 'communityPostRequest' ||
                                documentSnapshots['type'] == 'postReported' ||
                                documentSnapshots['type'] == 'communityJoiningrequest')
                            ? kTransparentColor
                            : (documentSnapshots['type'] == 'compliment')
                                ? kTransparentColor
                                : Colors.pinkAccent;
  }

  _getPicture(QueryDocumentSnapshot<Map<String, dynamic>> documentSnapshots) {
    return (documentSnapshots['type'] == 'postCommented')
        ? SvgIconWidget.commentOutline(color: AppColors.white)
        : (documentSnapshots['type'] == 'postLiked')
            ? SvgIconWidget.like()
            : (documentSnapshots['type'] == 'postCrowned')
                ? SvgIconWidget.flower()
                : (documentSnapshots['type'] == 'crownAirdrop')
                    ? SvgIconWidget.flower()
                    : (documentSnapshots['type'] == 'communityJoiningApproved' ||
                            documentSnapshots['type'] == 'communityJoiningRejected' ||
                            documentSnapshots['type'] == 'communityPostApproved' ||
                            documentSnapshots['type'] == 'communityPostRejected')
                        ? SvgIconWidget.community()
                        // Image.asset('Assets/images/community_logo.png',
                        //                         color: Colors.white, height: 15, width: 15)
                        : (documentSnapshots['type'] == 'friendRequest')
                            ? SvgIconWidget.userFilled(color: AppColors.white, height: 16.h, width: 16.w)
                            : (documentSnapshots['type'] == 'communityPostRequest' ||
                                    documentSnapshots['type'] == 'postReported' ||
                                    documentSnapshots['type'] == 'communityJoiningrequest')
                                ? const SizedBox.shrink()
                                : (documentSnapshots['type'] == 'compliment')
                                    ? const SizedBox.shrink()
                                    : (documentSnapshots['type'] == 'community' || documentSnapshots['type'] == 'allUsers')
                                        ? documentSnapshots['subImage'] != null
                                            ? ClipOval(
                                                child: ExtendedImageWidget(
                                                  url: documentSnapshots['subImage'],
                                                  width: 32.0,
                                                  height: 32.0,
                                                  fit: BoxFit.cover,
                                                  shape: null,
                                                  size: const Size(64.0, 64.0),
                                                ),
                                              )
                                            : const SizedBox()
                                        : SvgIconWidget.like();
  }

  bool _shouldShowImageWidget(QueryDocumentSnapshot<Map<String, dynamic>> documentSnapshots) {
    return (documentSnapshots['type'] == 'community' || documentSnapshots['type'] == 'allUsers') && documentSnapshots['subImage'] != null;
  }

  /// data is snapshot of notification
  String getJiffyDateTimeFromString(DocumentSnapshot<Object?> data) {
    try {
      final String dateTime = data['time'].toString();
      if (isCrownAirdrppNotification(data) && isInt(dateTime)) {
        int time = int.parse(dateTime);
        return Jiffy(DateTime.fromMillisecondsSinceEpoch(time).toLocal()).fromNow();
      }

      return Jiffy(dateTime).fromNow();
    } catch (e) {}
    return "";
  }

  bool isInt(String s) {
    return int.tryParse(s) != null;
  }

  bool isCrownAirdrppNotification(DocumentSnapshot<Object?> data) {
    return data['type'] == 'crownAirdrop';
  }
}

class PostNotificationItem extends StatelessWidget {
  final NotificationModel notificationModel;
  final DocumentSnapshot snap;
  final VoidCallback onTapMore;

  const PostNotificationItem({Key? key, required this.notificationModel, required this.snap, required this.onTapMore}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return OtherNotificationWidget(
      onTapMore: onTapMore,
      unreadMessageColor: notificationModel.isRead == false ? kprimaryColorLight : kTransparentColor,
      notificationId: snap.id,
      receiverUserId: NotificationItemUtils.isCrownAirdrppNotification(snap) ? "" : snap["receiverUserID"],
      profileImg: NotificationItemUtils.isCrownAirdrppNotification(snap) ? null : snap['userImage'],
      color: (snap['type'] == 'postCommented')
          ? Colors.green
          : (snap['type'] == 'postLiked')
              ? Colors.red
              : (snap['type'] == 'postCrowned' || snap['type'] == 'crownAirdrop')
                  ? kYellowColor
                  : (snap['type'] == 'communityJoiningApproved' ||
          snap['type'] == 'communityJoiningRejected' ||
          snap['type'] == 'communityPostApproved' ||
          snap['type'] == 'communityPostRejected')
          ? kPrimaryBackgroundBtnColor
          : (snap['type'] == 'friendRequest')
          ? Colors.blue
          : (snap['type'] == 'communityPostRequest' ||
          snap['type'] == 'postReported' ||
          snap['type'] == 'communityJoiningrequest')
          ? kTransparentColor
          : (snap['type'] == 'Love') ||
          (snap['type'] == 'Sad') ||
          (snap['type'] == 'Funny') ||
          (snap['type'] == 'Angry') ||
          (snap['type'] == 'Surprised')
          ? AppColors.white
          : Colors.pinkAccent,
      typeOfComment: snap['type'],
      text: snap['sender_name'],
      postedTime: NotificationItemUtils.getJiffyDateTimeFromString(snap),
      pic: (snap['type'] == 'postCommented')
          ? SvgIconWidget.comment()
      // SvgPicture.asset("Assets/icons/comments.svg", color: Colors.white)
      // : (notificationSnapshot['type'] == 'postLiked')
      //     ? SvgIconWidget.like()
      // SvgPicture.asset('Assets/images/like_notification.svg')
          : (snap['type'] == 'postCrowned')
          ? SvgIconWidget.flower()
      // SvgPicture.asset('Assets/images/filled_crown.svg', color: kWhiteColor, height: 10, width: 12)
          : (snap['type'] == 'crownAirdrop')
          ? Container(color: kprimaryColor)
          : (snap['type'] == 'communityJoiningApproved' ||
          snap['type'] == 'communityJoiningRejected' ||
          snap['type'] == 'communityPostApproved' ||
          snap['type'] == 'communityPostRejected')
          ? SvgIconWidget.community()
      // Image.asset('Assets/images/community_logo.png', color: Colors.white, height: 16, width: 16)
          : (snap['type'] == 'friendRequest')
          ? SvgIconWidget.userFilled(color: AppColors.white, height: 16.h, width: 16.w)
      // const Icon(Icons.person, color: kWhiteColor, size: 16)
          : (snap['type'] == 'communityPostRequest' ||
          snap['type'] == 'postReported' ||
          snap['type'] == 'communityJoiningrequest')
          ? const SizedBox.shrink()
          : (snap['type'] == 'postLiked')
          ? SvgIconWidget.like()
          : (snap['type'] == 'Love')
          ? SvgIconWidget.love()
          : (snap['type'] == 'Sad')
          ? SvgIconWidget.sad()
          : (snap['type'] == 'Funny')
          ? SvgIconWidget.funny()
          : (snap['type'] == 'Angry')
          ? SvgIconWidget.angry()
          : (snap['type'] == 'Surprised')
          ? SvgIconWidget.surprised()
          : SvgIconWidget.like(),
      // SvgPicture.asset('Assets/images/like_notification.svg'),
      message: snap['message'],
      onTapNotification: () async {
        Routes.postDetailsScreen(
            post: Post(
                postid: notificationModel.postId, postedBy: UserModel(), community: Community(communityId: notificationModel.communityId)),
            community: Community(communityId: notificationModel.communityId));
        /*// Get.to(() => CommentWithPostScreen(postModel: createPostModel, userModel: userModel));
        if (createPostModel.communityId != null) {
          // Get.lazyPut<EditCommunityController>(() => EditCommunityController());
          // EditCommunityController.to
          //     .fetchCommunityProfile(CreateCommunityModel(communityId: createPostModel.communityId));
        }
        final reactionModel = await _commonServices.getUserReactionOnPost(createPostModel.postid ?? '');
        createPostModel.reactionModel = reactionModel;

        List<CommentCustomModel> comments = await _commonServices.loadPostRecentCommentsFromPostMap(createPostModel.postedBy,
            map: postQuery?.data() as Map<String, dynamic>);
        createPostModel.recentComments = comments;

        // List<MultiCommentModel> comments = await _commonServices.loadPostsComments(createPostModel.postid ?? "");
        // createPostModel.recentComments = comments;

        Routes.postDetailsScreen(
          post: createPostModel,
          community: Community(communityId: createPostModel.communityId),
        );*/

        if (snap["isRead"] == true) {
          //already read. no need to run below.
          return;
        }
        Services().readNotification(
          receiverUserID: NotificationItemUtils.isCrownAirdrppNotification(snap) ? "" : snap["receiverUserID"],
          notificationId: snap.id,
          type: snap['type'],
        );
      },
    );
  }
}

class CommunityNotificationItem extends StatelessWidget {
  final NotificationModel notificationModel;
  final DocumentSnapshot snap;
  final VoidCallback onTap, onTapMore;

  const CommunityNotificationItem(
      {Key? key, required this.notificationModel, required this.snap, required this.onTap, required this.onTapMore})
      : super(key: key);

  @override
  Widget build(BuildContext context) {
    Community createCommunityModel = Community(communityId: notificationModel.communityId);
    return OtherNotificationWidget(
      onTapMore: onTapMore,
      unreadMessageColor: notificationModel.isRead == false ? kprimaryColorLight : kTransparentColor,
      notificationId: snap.id,
      receiverUserId: NotificationItemUtils.isCrownAirdrppNotification(snap) ? "" : snap["receiverUserID"],
      profileImg: NotificationItemUtils.isCrownAirdrppNotification(snap) ? null : snap['userImage'],
      color: (snap['type'] == 'postCommented')
          ? Colors.green
          : (snap['type'] == 'postLiked')
              ? Colors.red
              : (snap['type'] == 'postCrowned' || snap['type'] == 'crownAirdrop')
                  ? kYellowColor
                  : (snap['type'] == 'communityJoiningApproved' ||
          snap['type'] == 'communityJoiningRejected' ||
          snap['type'] == 'communityPostApproved' ||
          snap['type'] == 'communityPostRejected')
          ? kPrimaryBackgroundBtnColor
          : (snap['type'] == 'friendRequest')
          ? Colors.blue
          : (snap['type'] == 'communityPostRequest' ||
          snap['type'] == 'postReported' ||
          snap['type'] == 'communityJoiningrequest')
          ? kTransparentColor
          : Colors.pinkAccent,
      typeOfComment: snap['type'],

      text: snap['sender_name'],
      postedTime: NotificationItemUtils.getJiffyDateTimeFromString(snap),
      // '${dateTime.isAfter(DateTime.now().subtract(Duration(days: 1))) ? 'today' : DateFormat.yMd().format(dateTime)} at $time',
      pic: (snap['type'] == 'postCommented')
          ? SvgIconWidget.comment()
      // SvgPicture.asset("Assets/icons/comments.svg", color: Colors.white)
          : (snap['type'] == 'postLiked')
          ? SvgIconWidget.like()
      // ? SvgPicture.asset('Assets/images/like_notification.svg')
          : (snap['type'] == 'postCrowned')
          ? SvgIconWidget.flower()
      // ? SvgPicture.asset('Assets/images/filled_crown.svg', height: 10, width: 12, color: kWhiteColor)
          : (snap['type'] == 'crownAirdrop')
          ? Container(color: kprimaryColor)
          : (snap['type'] == 'communityJoiningApproved' ||
          snap['type'] == 'communityJoiningRejected' ||
          snap['type'] == 'communityPostApproved' ||
          snap['type'] == 'communityPostRejected')
          ? SvgIconWidget.community(height: 16, width: 16)
      // Image.asset('Assets/images/community_logo.png', color: Colors.white, height: 16, width: 16)
          : (snap['type'] == 'communityPostRequest')
          ? const SizedBox.shrink()
          : (snap['type'] == 'friendRequest')
          ? SvgIconWidget.userFilled(color: AppColors.white, height: 16.h, width: 16.w)
      // const Icon(Icons.person, color: kWhiteColor, size: 16)
          : (snap['type'] == 'postReported' || snap['type'] == 'communityJoiningrequest')
          ? const SizedBox.shrink()
          : SvgIconWidget.like(),
      // SvgPicture.asset('Assets/images/like_notification.svg'),
      message: snap['message'],
      onTapNotification: true
          ? onTap
          : () {
        if (createCommunityModel.communityId != null && createCommunityModel.communityId != '') {
          // Methods.showModalSheetToJoinCommunity(
          //     communityId: createCommunityModel.communityId, ctx: context, communityModel: createCommunityModel);
          SchedulerBinding.instance.addPostFrameCallback((_) {
            Methods.showModalSheetToJoinCommunity(
                communityId: createCommunityModel.communityId, ctx: context, communityModel: createCommunityModel);
            // Methods.routeToGroup(community: createCommunityModel);
          });
        }
        if (snap["isRead"] == true) {
          //already read. no need to run below.
          return;
        }
        Services().readNotification(
          receiverUserID: NotificationItemUtils.isCrownAirdrppNotification(snap) ? "" : snap["receiverUserID"],
          notificationId: snap.id,
          type: snap["type"],
        );
      },
    );
  }
}

class NotificationItemUtils {
  static bool isInt(String s) {
    return int.tryParse(s) != null;
  }

  static bool isCrownAirdrppNotification(DocumentSnapshot<Object?> data) {
    return data['type'] == 'crownAirdrop';
  }

  /// data is snapshot of notification
  static String getJiffyDateTimeFromString(DocumentSnapshot<Object?> data) {
    try {
      final String dateTime = data['time'].toString();
      if (isCrownAirdrppNotification(data) && isInt(dateTime)) {
        int time = int.parse(dateTime);
        return Jiffy(DateTime.fromMillisecondsSinceEpoch(time).toLocal()).fromNow();
      }

      return Jiffy(dateTime).fromNow();
    } catch (e) {}
    return "";
  }
}
