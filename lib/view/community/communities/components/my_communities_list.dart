import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';
import 'package:flutter/scheduler.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:gaya/controller/app_config_controller.dart';
import 'package:gaya/model/community.model.dart';
import 'package:gaya/model/user.model.dart';
import 'package:gaya/services/services.dart';
import 'package:gaya/utils/extension.dart';
import 'package:gaya/utils/language/translation.dart';
import 'package:gaya/utils/methods.dart';
import 'package:gaya/utils/theme/app_colors.dart';
import 'package:gaya/view/feed/view/community_user_feed/widgets/user_communities_empty.dart';
import 'package:gaya/widgets/community_view_widgets/communities.skeleton.widget.dart';
import 'package:gaya/widgets/community_view_widgets/community.widget.dart';
import 'package:get/get.dart';
import 'package:provider/provider.dart';

import '../../../../controller/communities.controller.dart';
import '../../../../model/user.communities.model.dart';
import '../../../../routing/getx_route_methods.dart';
import '../../../../utils/common_utils.dart';
import '../../../../utils/const.dart';
import '../../../../utils/textstyles.dart';
import '../../../../widgets/community_view_widgets/community.row.widget.dart';
//in stful because always loading new firebase calls.

class MyCommunitiesListView extends StatefulWidget {
  final bool isCallOnHome;
  final bool isHomeFeed;

  const MyCommunitiesListView({Key? key, required this.isCallOnHome, required this.isHomeFeed}) : super(key: key);

  @override
  State<MyCommunitiesListView> createState() => _MyCommunitiesListViewState();
}

class _MyCommunitiesListViewState extends State<MyCommunitiesListView> with AutomaticKeepAliveClientMixin {
  late Stream<QuerySnapshot<Map<String, dynamic>>> myCommunitiesQuery;

  @override
  void initState() {
    myCommunitiesQuery = context.read<CommunitiesController>().getCurrentUserCommunities();
    super.initState();
  }

  @override
  Widget build(BuildContext context) {
    super.build(context);
    if (UserModel.to.uId == null) {
      return const SizedBox.shrink();
    }
    return StreamBuilder<QuerySnapshot<Map<String, dynamic>>>(
        stream: myCommunitiesQuery,
        builder: (BuildContext context, snapshot) {
          print('CommunitiesView build');

          if (snapshot.connectionState == ConnectionState.waiting) {
            return Column(
              mainAxisAlignment: MainAxisAlignment.start,
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                widget.isCallOnHome ? const ShowHomeCommunityShimmer() : 
                Column(
                  mainAxisAlignment: MainAxisAlignment.start,
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    SizedBox(height: 50.r),
                    const ShowCommunityShimmer(),
                  ],
                ),
              ],
            );
          }
          if (snapshot.data == null) {
            return const SizedBox.shrink();
          }
          if (!snapshot.hasData) {
            return Column(
              children: [
                widget.isCallOnHome ? const ShowHomeCommunityShimmer() : const ShowCommunityShimmer(),
              ],
            );
          }
          snapshot.data?.docChanges.forEach((element) {
            if (element.type == DocumentChangeType.added) {
              try {
                final community = Community.fromMap(element.doc.data()!);
                AppConfigurationController.to.joinACommunity(community);
              } catch (e) {
                print(e);
              }
            }
            if (element.type == DocumentChangeType.removed) {
              AppConfigurationController.to.leaveCommunity(element.doc.id);
            }
          });
          final List<QueryDocumentSnapshot> pinnedCommunities = [];
          final List<QueryDocumentSnapshot> unpinnedCommunities = [];

          /// aggregate pinned and unpinned communities
          for (final QueryDocumentSnapshot doc in snapshot.data?.docs ?? []) {
            /// if community is hidden, don't show it
            if (AppConfigurationController.to.isHiddenCommunity(communityId: doc.id)) {
              continue;
            }
            if (CommonUtils.getFirebaseField(fieldName: "isPinned", data: doc.data()) == true) {
              pinnedCommunities.add(doc);
            } else {
              unpinnedCommunities.add(doc);
            }
          }

          final List<QueryDocumentSnapshot> communities = [];
          communities.addAll(pinnedCommunities);
          communities.addAll(unpinnedCommunities);
          final pinnedCommunitiesRef = pinnedCommunities.map((e) => e.reference).toList();

          return communities.isEmpty
              ? widget.isCallOnHome
                  ? const UserNoCommunities()
                  : const SizedBox.shrink()
              : Container(
                  color: widget.isHomeFeed ? AppColors.transparrent : AppColors.white.withOpacity(0.8),
                  child: Column(
                    children: [
                      if (communities.isNotEmpty)
                        if (!widget.isCallOnHome)
                          CommunityRow(
                              onTap: () => Routes.seeAllMyCommunitiesView(pinnedCommunities: pinnedCommunitiesRef),
                              style: TextStyle(color: kprimaryColor, fontSize: 18.sp, fontFamily: GayaFontTheme.primaryFont),
                              typeOfCommunity: GayaStrings.my_communities.tr),
                      SizedBox(
                        height: widget.isCallOnHome ? 96 : 112.h,
                        child: ListView.builder(
                            scrollDirection: Axis.horizontal,
                            itemCount: widget.isCallOnHome
                                ? communities.length
                                : (communities.length > 8)
                                    ? 8
                                    : communities.length,
                            padding: const EdgeInsets.only(right: 20).r,
                            itemBuilder: (context, index) {
                              UserCommunities communitiesModel = UserCommunities.fromMap(communities[index].data() as Map<String, dynamic>);

                              {
                                return MyCommunitiesWidget(
                                  /// to rebuild the list as its not updating..
                                  /// when user join new community, so by having unique key,
                                  /// duplication of the widget is avoided
                                  key: UniqueKey(),
                                  pinnedCommunities: pinnedCommunitiesRef,
                                  communitiesModel: communitiesModel,
                                );
                              }
                            }),
                      ),
                      // const SizedBox(height: distance_10),
                    ],
                  ),
                );
        });
  }

  @override
  bool get wantKeepAlive => true;
}

class MyCommunitiesWidget extends StatefulWidget {
  final UserCommunities communitiesModel;
  final List<DocumentReference<Object?>> pinnedCommunities;

  const MyCommunitiesWidget({Key? key, required this.communitiesModel, required this.pinnedCommunities}) : super(key: key);

  @override
  State<MyCommunitiesWidget> createState() => _MyCommunitiesWidgetState();
}

class _MyCommunitiesWidgetState extends State<MyCommunitiesWidget> with AutomaticKeepAliveClientMixin {
  @override
  bool get wantKeepAlive => true;

  final Services service = Services();

  @override
  Widget build(BuildContext context) {
    super.build(context);
    return FutureBuilder<Community?>(
        future: service.getCommunityDetailsModel(widget.communitiesModel.communityId ?? ""),
        builder: (BuildContext ctx, snap) {
          if (snap.connectionState == ConnectionState.waiting) {
            return const ShowCommunityShimmer();
          }
          if (snap.data == null || snap.hasError || snap.data?.communityName.isBlank == true) {
            return const SizedBox.shrink();
          }
          Community community = snap.data!;
          final totalMembersCount = community.communityMembers ?? 0;
          final isPinned = widget.communitiesModel.isPinned ?? false;

          /// No need to show archived communities
          if (community.isArchive) {
            return const SizedBox.shrink();
          }
          return CommunityWidget(
            communityId: community.communityId ?? "",
            badge: const SizedBox.shrink(),
            isPinned: isPinned,
            onTap: () {
              Methods.routeToGroup(community: community);
            },
            onLongTap: () {
              Methods.showCommunityOperationModalSheet(
                  communityModel: community,
                  context: context,
                  isPinned: isPinned,
                  onPin: () {
                    service.pinOrUnpinCommunity(
                        communityId: community.communityId, shouldPin: !isPinned, pinnedCommunities: widget.pinnedCommunities);
                  });
            },
            communityName: community.communityName.toString(),
            numberOfMemebers: totalMembersCount.toString().toSocialFriendly(),
            numberOfNewPosts: '',
            opacity: 0.81,
            image: community.CommunityPic.toString(),
          );
        });
    return FutureProvider<Community?>(
      initialData: null,
      create: (context) => Services().getCommunityDetailsModel(widget.communitiesModel.communityId ?? ""),
      child: Consumer<Community?>(builder: (context, details, _) {
        return details == null
            ? const ShowCommunityShimmer()
            : Builder(builder: (context) {
                try {
                  Community community = details;
                  final totalMembersCount = community.communityMembers ?? 0;
                  final isPinned = widget.communitiesModel.isPinned ?? false;
                  return CommunityWidget(
                    communityId: community.communityId ?? "",
                    badge: const SizedBox.shrink(),
                    isPinned: isPinned,
                    onTap: () {
                      SchedulerBinding.instance.addPostFrameCallback((_) => Methods.routeToGroup(community: community));
                    },
                    onLongTap: () {
                      Methods.showCommunityOperationModalSheet(
                          communityModel: community,
                          context: context,
                          isPinned: isPinned,
                          onPin: () {
                            service.pinOrUnpinCommunity(
                                communityId: community.communityId, shouldPin: !isPinned, pinnedCommunities: widget.pinnedCommunities);
                          });
                    },
                    communityName: community.communityName.toString(),
                    numberOfMemebers: totalMembersCount < 2 ? "$totalMembersCount member" : "$totalMembersCount members",
                    numberOfNewPosts: '',
                    opacity: 0.81,
                    image: community.CommunityPic.toString(),
                  );
                } catch (_) {
                  return const SizedBox.shrink();
                }
              });
      }),
    );
  }
}
