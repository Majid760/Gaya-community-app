import 'package:flutter/material.dart';
import 'package:gaya/model/create.post.model.dart';
import 'package:gaya/routing/getx_route_methods.dart';
import 'package:gaya/widgets/home_view_widgets/home.post.widget.dart';
import 'package:get/get_utils/get_utils.dart';
import 'package:jiffy/jiffy.dart';

import '../../../../utils/strings.dart';

class ApprovalPostTile extends StatelessWidget {
  final Post post;

  final VoidCallback onApprove;
  final VoidCallback onDecline;

  const ApprovalPostTile({Key? key, required this.post, required this.onApprove, required this.onDecline}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    final userModel = post.postedBy;
    return HomePostWidget(
      /// COMMENTED For INFLUENCE BAR
      // influence points widget based on Influence Points
      // influenceIcon: (userModel.isUserInfluencePointsValid) ? userModel.getUserInfluencePointsIndicator : null,
      approveRequest: onApprove,
      declineRequest: onDecline,
      approvalShow: true,
      gender: userModel.gender,
      pdfFiles: post.pdfFiles,
      createdAt: post.postCreatedOn,
      postModel: post,
      hasVideo: (post.video?.isBlank ?? true) ? false : true,
      videoLink: post.video,
      crossAxis: (post.multipleImages?.length ?? 0) < 2 ? 1 : 2,
      anonymousPost: post.isPostedAnonymously == true ? true : false,
      onUserTap: () {
        // if null or anonymous post then don't navigate to profile
        if (userModel.uId == null || post.isPostedAnonymously == true) return;

        Routes.viewProfile(uid: userModel.uId, model: userModel);
      },
      subtitle: Jiffy(post.postCreatedOn).fromNow(),
      doNotshowBottomrow: true,
      groupImage: userModel.profilePicture ?? "",
      title: post.isPostedAnonymously == true
          ? userModel.gender == null
              ? anonymousUser
              : userModel.gender == 'male'
                  ? anonymousBoy
                  : userModel.gender == 'female'
                      ? anonymousGirl
                      : anonymousUser
          : userModel.name!,
      isPostHasImage: post.multipleImages == null
          ? false
          : post.multipleImages!.isEmpty == true
              ? false
              : true,
      // isPostHasImage: post.postPicture == null || post.postPicture.toString().trim() == "" ,

      content: post.postDescription.toString(),
      postImage: post.multipleImages ?? [],
      totalCommentsCount: '',
      totalLikesCount: '',
      totalCrownsCount: '',
      posterCrownsCount: '',

      ///// by waqar /////
      postId: post.postid,
    );
  }
}
