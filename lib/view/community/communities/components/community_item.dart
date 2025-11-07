import 'package:flutter/material.dart';
import 'package:gaya/utils/extension.dart';
import 'package:provider/provider.dart';

import '../../../../controller/app_config_controller.dart';
import '../../../../controller/communities.controller.dart';
import '../../../../model/community.model.dart';
import '../../../../utils/methods.dart';
import '../../../../widgets/community_view_widgets/community.widget.dart';

class CommunityItem extends StatelessWidget {
  final Community community;
  final VoidCallback onHideCommunity;
  const CommunityItem({Key? key, required this.community, required this.onHideCommunity}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    final totalMembersCount = community.communityMembers ?? 0;
    return CommunityWidget(
      onLongTap: () {
        final isJoinedCommunity = AppConfigurationController.to.getJoinedCommunitiesIds().contains(community.communityId);
        /// If the user is already a member of the community, show the full modal sheet
        if (isJoinedCommunity) {
          Methods.showCommunityOperationModalSheet(communityModel: community, context: context, onHideUnhide: onHideCommunity);
        } else {
          /// If the user is not a member of the community, show the modal sheet with  report  + hide options
          Methods.showCommunityOperationModalSheet(
              communityModel: community,
              context: context,
              showLeave: false,
              showPin: false,
              showNotification: false,
              onHideUnhide: onHideCommunity);
        }
      },
      communityId: community.communityId ?? "",
      onTap: () async {
        context.read<CommunitiesController>().isReadMore = false;
        Methods.showModalSheetToJoinCommunity(communityId: community.communityId, ctx: context);
      },
      image: community.CommunityPic.toString(),
      communityName: community.communityName.toString(),
      numberOfMemebers: totalMembersCount.toString().toSocialFriendly(),
      opacity: 0.9,
    );
  }
}
