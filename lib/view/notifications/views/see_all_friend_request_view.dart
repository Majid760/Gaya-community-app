import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';
import 'package:gaya/controller/notification.controller.dart';
import 'package:gaya/utils/const.dart';
import 'package:gaya/utils/language/translation.dart';
import 'package:gaya/utils/textstyles.dart';
import 'package:gaya/widgets/notification_widgets/notification.whole.widget.dart';
import 'package:get/get.dart';
import 'package:jiffy/jiffy.dart';
import 'package:provider/provider.dart';

class SeeAllFriendRequest extends StatefulWidget {
  const SeeAllFriendRequest({Key? key}) : super(key: key);

  @override
  State<SeeAllFriendRequest> createState() => _SeeAllFriendRequestState();
}

class _SeeAllFriendRequestState extends State<SeeAllFriendRequest> {
  @override
  void initState() {
    // final controller = context.read<GroupController>();
    // controller.adminofCommunity(widget.communityId);

    super.initState();
  }

  List docId = [];

  @override
  Widget build(BuildContext context) {
    final notificationController = Provider.of<NotificationController>(context, listen: false);
    return Scaffold(
      backgroundColor: kDimWhiteColor,
      appBar: AppBar(
        iconTheme: const IconThemeData(color: kBlackColor),
        elevation: 0.1,
        backgroundColor: kDimWhiteColor,
        centerTitle: true,
        title: Text(
          "All Request",
          style: CustomTypography.bodyStyle,
        ),
      ),
      body: SingleChildScrollView(
        child: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            StreamBuilder<QuerySnapshot>(
                stream: notificationController.friendRequestNotificationsStream(),
                builder: (context, dataSnapshot) {
                  if (dataSnapshot.connectionState == ConnectionState.active || dataSnapshot.connectionState == ConnectionState.done) {
                    if (dataSnapshot.hasError) {
                      return Column(
                        mainAxisAlignment: MainAxisAlignment.center,
                        children: [
                          Center(child: Text(GayaStrings.error_occurred.tr)),
                        ],
                      );
                    } else if (dataSnapshot.hasData) {
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
                                ? SizedBox(
                                    height: MediaQuery.sizeOf(context).height - (kToolbarHeight + 24),
                                    child: ListView.builder(
                                        // controller: notificationController.notificationsScrollController,
                                        physics: const NeverScrollableScrollPhysics(),
                                        // shrinkWrap: true,
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
                                                  pic: const Icon(Icons.person, color: kWhiteColor, size: 16),
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
                                        }),
                                  )
                                : const SizedBox.shrink(),
                          ],
                        ),
                      );
                    }
                  }
                  return const SizedBox.shrink();
                }),
          ],
        ),
      ),
    );
  }
}
