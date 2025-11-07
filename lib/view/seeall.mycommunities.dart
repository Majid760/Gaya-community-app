import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:easy_refresh/easy_refresh.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:gaya/controller/app_config_controller.dart';
import 'package:gaya/controller/communities.controller.dart';
import 'package:gaya/shared/view/widget/gaya_back_button.dart';
import 'package:gaya/shared/view/widget/gaya_snackbar.dart';
import 'package:gaya/utils/animation.dart';
import 'package:gaya/utils/asset_images.dart';
import 'package:gaya/utils/const.dart';
import 'package:gaya/utils/extension.dart';
import 'package:gaya/utils/methods.dart';
import 'package:gaya/utils/refresh_builder_utils.dart';
import 'package:gaya/view/profile/view/my_communities_search_view.dart';
import 'package:get/get.dart';
import 'package:provider/provider.dart';

import '../model/community.model.dart';
import '../model/user.communities.model.dart';
import '../services/services.dart';
import '../utils/language/translation.dart';
import '../utils/textstyles.dart';
import '../widgets/community_view_widgets/communities.skeleton.widget.dart';
import '../widgets/community_view_widgets/community.widget.dart';
import 'community/communities/components/loading_communities_skeleton_gridview.dart';
import 'community/controllers/base_controller.dart';

typedef CommunityReference = DocumentReference<Map<String, dynamic>> Function(String communityId);

class SeeAllMyCommunities extends StatefulWidget {
  final List<DocumentReference<Object?>> pinnedCommunities;

  const SeeAllMyCommunities({Key? key, this.pinnedCommunities = const []}) : super(key: key);

  @override
  State<SeeAllMyCommunities> createState() => _SeeAllMyCommunitiesState();
}

class _SeeAllMyCommunitiesState extends State<SeeAllMyCommunities> {
  late Future<QuerySnapshot<Object?>?> allUserCommunities;

  @override
  void initState() {
    allUserCommunities = context.read<CommunitiesController>().getUserCommunities();
    super.initState();
  }

  void onRefresh() {
    setState(() {
      allUserCommunities = context.read<CommunitiesController>().getUserCommunities();
    });
  }

  final Services services = Services();

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
        shape: const Border(bottom: BorderSide(color: kBaseGrey)),
        centerTitle: true,
        title: Text(GayaStrings.my_communities.tr, style: CustomTypography.bodyStyle),
        actions: [
          IconButton(
              onPressed: () => Get.to(() => const MyCommunitiesViewSearch()),
              tooltip: GayaStrings.search_txt.tr,
              splashRadius: 25.r,
              padding: EdgeInsets.zero,
              icon: SvgIcons.searchIcon),
          const SizedBox(width: distance_10),
        ],
      ),
      body: Padding(
        padding: const EdgeInsets.only(top: 10.0).r,
        child: FutureBuilder<QuerySnapshot?>(
            future: allUserCommunities,
            builder: (context, allUserCommunitiesDetails) {
              if (allUserCommunitiesDetails.connectionState == ConnectionState.waiting) {
                return const ShowCommunityShimmer();
              } else if (allUserCommunitiesDetails.connectionState == ConnectionState.done) {
                if (allUserCommunitiesDetails.hasData) {
                  var queryData = allUserCommunitiesDetails.data as QuerySnapshot;
                  List<UserCommunities> userCommunities =
                      queryData.docs.map((e) => UserCommunities.fromMap(e.data() as Map<String, dynamic>)).toList();
                  return GetBuilder<MyCommunitiesController>(
                      init: MyCommunitiesController(communities: userCommunities, pinnedCommunities: widget.pinnedCommunities),
                      builder: (controller) {
                        if (controller.isLoading) {
                          return const LoadingCommunitiesSkeletonGridView();
                        }
                        return EasyRefresh(
                          simultaneously: true,
                          // noMoreLoad: false,
                          controller: controller.refreshController,
                          header: RefreshBuilderUtils.headerAbove,
                          //hidden
                          footer: const CupertinoFooter(
                            position: IndicatorPosition.locator,
                            userWaterDrop: false,
                            emptyWidget: SizedBox(),
                          ),
                          onLoad: () async {
                            bool isFetched = await controller.onLoad();
                            if (!isFetched) {
                              return IndicatorResult.noMore;
                            }
                          },
                          onRefresh: () => controller.onRefresh(),
                          child: GridView.builder(
                              padding: const EdgeInsets.symmetric(horizontal: 10),
                              gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
                                crossAxisCount: 2,
                                mainAxisSpacing: 2,
                                childAspectRatio: 1.5,
                              ),
                              itemCount: controller.allCommunities.length,
                              itemBuilder: (context, index) {
                                final community = controller.allCommunities[index];
                                bool isPinned = userCommunities[index].isPinned ?? false;
                                final totalMembersCount = community.communityMembers ?? 0;
                                return Padding(
                                  padding: const EdgeInsets.all(8.0),
                                  child: CommunityWidget(
                                    isGridView: true,
                                    onLongTap: () {
                                      Methods.showCommunityOperationModalSheet(
                                        communityModel: community,
                                        context: context,
                                        isPinned: isPinned,
                                        onHideUnhide: () {
                                          controller.hideACommunity(id: community.communityId ?? "");
                                          DefaultSnackBar.hideOrUnHideCommunity(context: context);
                                        },
                                        onPin: () => controller.onPinCommunity(community: community, isPinned: isPinned),
                                      );
                                    },
                                    communityId: community.communityId ?? "",
                                    onTap: () => Methods.routeToGroup(community: community),
                                    communityName: community.communityName.toString(),
                                    numberOfMemebers: totalMembersCount.toString().toSocialFriendly(),
                                    numberOfNewPosts: '',
                                    isPinned: isPinned,
                                    opacity: 0.81,
                                    image: community.CommunityPic.toString(),
                                  ),
                                );
                              }),
                        );
                      });
                }
              }

              return const AnimationLottie();
            }),
      ),
    );
  }
}

class MyCommunitiesController extends BaseController {
  List<UserCommunities> communities;
  List<DocumentReference<Object?>> pinnedCommunities;

  MyCommunitiesController({required this.communities, required this.pinnedCommunities});

  /// current chunk index
  int index = 1;

  final EasyRefreshController refreshController = EasyRefreshController();
  final Services services = Services();

  /// chunked communities ids
  List<List<String>> chunks = [];

  /// all communities without chunking
  List<Community> allCommunities = [];

  @override
  void onInit() {
    super.onInit();

    /// remove hidden communities
    communities.removeWhere((community) => AppConfigurationController.to.isHiddenCommunity(communityId: community.communityId ?? ""));

    /// split the communities into chunks of 10
    chunks = splitIntoChunks(communities.map((e) => e.communityId ?? "").toList(), 20);

    // load 20 items initially

    onLoad(isInitial: true);
  }

  /// Get the communities from the database
  /// add the communities to the list of communities
  /// update the UI
  Future<void> getCommunities(List<String> communityIds, {bool isInitial = false}) async {
    if (isInitial) {
      setLoading(true);
    }

    List<List<String>> ids = splitIntoChunks(communityIds, 10);

    final rawCommunities = await Future.wait(
      /// Skip Archived Communities
      ids.map((communityIds) => FirebaseFirestore.instance
          .collection('communities')
          .where("communityId", whereIn: communityIds)
          .where('isArchived', isEqualTo: false)
          .get()),
    );
    for (var element in rawCommunities) {
      for (var element in element.docs) {
        try {
          allCommunities.add(Community.fromMap(element.data()));
        } catch (_) {}
      }
    }

    setLoading(false);
  }

  /// Pin the community, remove other pinned community
  /// if the community is already pinned, unpin it
  void onPinCommunity({required Community community, required bool isPinned}) async {
    // locally
    _updatePinnedCommunityLocally(community: community, isPinned: isPinned);

    /// db call
    _updatePinnedCommunity(community: community, isPinned: isPinned);
  }

  /// Load more communities
  /// if the index is greater than the length of the chunks, return false
  Future<bool> onLoad({bool isInitial = false}) async {
    if (index > chunks.length) {
      return false;
    }
    await getCommunities(chunks[index - 1], isInitial: isInitial);
    index++;
    return true;
  }

  /// Refresh the communities
  /// clear the list of communities
  /// set the index to 1
  Future<void> onRefresh() async {
    allCommunities.clear();
    index = 1;
    await onLoad(isInitial: true);
  }

  /// update locally
  /// update the pinned communities list
  /// update the UI
  void _updatePinnedCommunityLocally({required Community community, required bool isPinned}) {
    /// remove all pinned communities
    /// only one community can be pinned
    for (int i = 0; i < communities.length; i++) {
      if (communities[i].isPinned == true) communities[i].isPinned = false;
    }

    /// add the community to the pinned communities list
    pinnedCommunities.add(_makeCommunityReference(communityId: community.communityId!));
    // update the pinned community in the communities list
    if (isPinned == true) {
      communities.firstWhere((element) => element.communityId == community.communityId).isPinned = false;
    } else {
      communities.firstWhere((element) => element.communityId == community.communityId).isPinned = true;
    }

    update();
  }

  /// Pin or unpin the community from the pinned communities list
  /// firebase call
  void _updatePinnedCommunity({required Community community, required bool isPinned}) async {
    await services.pinOrUnpinCommunity(communityId: community.communityId, shouldPin: !isPinned, pinnedCommunities: pinnedCommunities);
  }

  DocumentReference<Object?> _makeCommunityReference({required String communityId}) {
    DocumentReference<Map<String, dynamic>> reference = FirebaseFirestore.instance.collection('communities').doc(communityId);
    return reference;
  }

  void hideACommunity({required String id}) {
    AppConfigurationController.to.hideOrUnHideCommunity(communityId: id);
    allCommunities.removeWhere((element) => element.communityId == id);
    update();
  }

  //// Split the list into chunks
  List<List<String>> splitIntoChunks(List<String> list, int chunkSize) {
    List<List<String>> chunks = [];
    for (int i = 0; i < list.length; i += chunkSize) {
      int end = i + chunkSize;
      if (end > list.length) {
        end = list.length;
      }
      chunks.add(list.sublist(i, end));
    }
    return chunks;
  }
}
