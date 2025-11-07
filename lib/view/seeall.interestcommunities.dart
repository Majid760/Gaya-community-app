import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:gaya/controller/communities.controller.dart';
import 'package:gaya/utils/animation.dart';
import 'package:gaya/utils/extension.dart';
import 'package:gaya/utils/theme/app_typography.dart';
import 'package:gaya/widgets/community_view_widgets/communities.skeleton.widget.dart';
import 'package:get/get.dart';
import 'package:provider/provider.dart';

import '../controller/app_config_controller.dart';
import '../model/community.model.dart';
import '../shared/view/widget/gaya_back_button.dart';
import '../shared/view/widget/gaya_snackbar.dart';
import '../utils/const.dart';
import '../utils/methods.dart';
import '../widgets/community_view_widgets/community.widget.dart';

class SeeAllInterestCommunities extends StatefulWidget {
  final String communityName;

  const SeeAllInterestCommunities({Key? key, required this.communityName}) : super(key: key);

  @override
  State<SeeAllInterestCommunities> createState() => _SeeAllInterestCommunitiesState();
}

class _SeeAllInterestCommunitiesState extends State<SeeAllInterestCommunities> {
  var communityNameGet;

  @override
  void initState() {
    communityNameGet = context.read<CommunitiesController>().getInterestSeeAll(widget.communityName);
    super.initState();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        systemOverlayStyle: SystemUiOverlayStyle.dark,
        automaticallyImplyLeading: false,
        leading: const GayaBackButton(),
        iconTheme: const IconThemeData(color: Colors.black),
        backgroundColor: kTransparentColor,
        elevation: 0,
        centerTitle: true,
        title: Text(widget.communityName.tr, style: GayaTypography.titleMedium),
      ),
      body: FutureBuilder<QuerySnapshot?>(
          future: communityNameGet,
          builder: (context, snapshot) {
            if (snapshot.connectionState == ConnectionState.waiting) {
              return const ShowCommunityShimmer();
            } else if (snapshot.connectionState == ConnectionState.done) {
              if (snapshot.hasData) {
                QuerySnapshot data = snapshot.data as QuerySnapshot;
                return data.docs.isEmpty
                    ? const AnimationLottie()
                    : ListView(
                        children: [
                          Wrap(
                            children: data.docs.map((rawCommunity) {
                              if (AppConfigurationController.to.isHiddenCommunity(communityId: rawCommunity.id)) {
                                return const SizedBox.shrink();
                              }
                              Community community = Community.fromMap(rawCommunity.data() as Map<String, dynamic>);

                              final totalMembersCount = community.communityMembers ?? 0;

                              return Padding(
                                padding: const EdgeInsets.only(top: 20).r,
                                child: CommunityWidget(
                                  onLongTap: () {
                                    final isJoinedCommunity =
                                    AppConfigurationController.to.getJoinedCommunitiesIds().contains(community.communityId);

                                    /// If the user is already a member of the community, show the full modal sheet
                                    if (isJoinedCommunity) {
                                      Methods.showCommunityOperationModalSheet(communityModel: community, context: context);
                                    } else {
                                      /// If the user is not a member of the community, show the modal sheet with  report  + hide options
                                      Methods.showCommunityOperationModalSheet(
                                          communityModel: community,
                                          context: context,
                                          showLeave: false,
                                          showPin: false,
                                          showNotification: false,
                                          onHideUnhide: () {
                                            setState(() {
                                              AppConfigurationController.to.hideOrUnHideCommunity(communityId: community.communityId);
                                              DefaultSnackBar.hideOrUnHideCommunity(context: context);
                                              communityNameGet =
                                                  context.read<CommunitiesController>().getInterestSeeAll(widget.communityName);
                                            });
                                          });
                                    }
                                  },
                                  communityId: community.communityId ?? "",
                                  communityName: community.communityName.toString(),
                                  numberOfMemebers: totalMembersCount.toString().toSocialFriendly(),
                                  opacity: 0.81,
                                  image: community.CommunityPic.toString(),
                                  onTap: () => Methods.showModalSheetToJoinCommunity(
                                    communityId: community.communityId,
                                    ctx: context,
                                  ),
                                ),
                              );
                            }).toList(),
                          ),
                          // extra space
                          SizedBox(height: 20.h),
                        ],
                      );
              }
            }
            return const AnimationLottie();
          }),
    );
  }
}

class SeeAllByQueryCommunities extends StatefulWidget {
  final Query<Map<String, dynamic>> query;
  final String title;

  const SeeAllByQueryCommunities({Key? key, required this.query, required this.title}) : super(key: key);

  @override
  State<SeeAllByQueryCommunities> createState() => _SeeAllByQueryCommunitiesState();
}

class _SeeAllByQueryCommunitiesState extends State<SeeAllByQueryCommunities> {
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        systemOverlayStyle: SystemUiOverlayStyle.dark,
        automaticallyImplyLeading: false,
        leading: const GayaBackButton(),
        iconTheme: const IconThemeData(color: Colors.black),
        backgroundColor: kTransparentColor,
        elevation: 0,
        centerTitle: true,
        title: Text(widget.title, style: GayaTypography.titleMedium),
      ),
      body: FutureBuilder<QuerySnapshot?>(
          future: widget.query.get(),
          builder: (context, snapshot) {
            if (snapshot.connectionState == ConnectionState.waiting) {
              return const ShowCommunityShimmer();
            } else if (snapshot.connectionState == ConnectionState.done) {
              if (snapshot.hasData) {
                QuerySnapshot data = snapshot.data as QuerySnapshot;
                return data.docs.isEmpty
                    ? const AnimationLottie()
                    : ListView(
                        children: [
                          Wrap(
                            children: data.docs.map((rawCommunity) {
                              Community community = Community.fromMap(rawCommunity.data() as Map<String, dynamic>);

                              final totalMembersCount = community.communityMembers ?? 0;
                              if (AppConfigurationController.to.isHiddenCommunity(communityId: community.communityId ?? "")) {
                                return const SizedBox.shrink();
                              }
                              return Padding(
                                padding: const EdgeInsets.only(top: 20).r,
                                child: CommunityWidget(
                                  onLongTap: () {
                                    final isJoinedCommunity =
                                        AppConfigurationController.to.getJoinedCommunitiesIds().contains(community.communityId);

                                    /// If the user is already a member of the community, show the full modal sheet
                                    if (isJoinedCommunity) {
                                      Methods.showCommunityOperationModalSheet(communityModel: community, context: context);
                                    } else {
                                      /// If the user is not a member of the community, show the modal sheet with  report  + hide options
                                      Methods.showCommunityOperationModalSheet(
                                          communityModel: community,
                                          context: context,
                                          showLeave: false,
                                          showPin: false,
                                          showNotification: false,
                                          onHideUnhide: () {
                                            setState(() {
                                              AppConfigurationController.to.hideOrUnHideCommunity(communityId: community.communityId);
                                              DefaultSnackBar.hideOrUnHideCommunity(context: context);
                                            });
                                          });
                                    }
                                  },
                                  communityId: community.communityId ?? "",
                                  communityName: community.communityName.toString(),
                                  numberOfMemebers: totalMembersCount.toString().toSocialFriendly(),
                                  opacity: 0.81,
                                  image: community.CommunityPic.toString(),
                                  onTap: () => Methods.showModalSheetToJoinCommunity(
                                    communityId: community.communityId,
                                    ctx: context,
                                  ),
                                ),
                              );
                            }).toList(),
                          ),
                          // extra space
                          SizedBox(height: 20.h),
                        ],
                      );
              }
            }
            return const AnimationLottie();
          }),
    );
  }
}
