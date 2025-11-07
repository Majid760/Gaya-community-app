import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:gaya/routing/getx_route_methods.dart';
import 'package:get/get.dart';
import 'package:provider/provider.dart';

import '../../../components/textfield.component.dart';
import '../../../controller/communities.controller.dart';
import '../../../controller/firebase_analytics_controller.dart';
import '../../../model/community.model.dart';
import '../../../model/user.model.dart';
import '../../../shared/controller/gaya_search_controllers/feed_search_controller.dart';
import '../../../shared/view/screen/gaya_search_screens/feed_search_screen.dart';
import '../../../shared/view/widget/gaya_back_button.dart';
import '../../../utils/const.dart';
import '../../../utils/enum.dart';
import '../../../utils/language/translation.dart';
import '../../../utils/methods.dart';
import '../../../utils/textstyles.dart';
import '../../../utils/theme/app_colors.dart';
import '../../../utils/theme/app_typography.dart';
import '../controllers/search_controller.dart';
import '../models/searched_community_item.dart';
import '../widgets/community_container/community_container.dart';
import '../widgets/landing_search_screen_title.dart';
import '../widgets/recent_search_user_item.dart';
import 'recent_search_screen.dart';

class LandingSearchScreen extends StatelessWidget {
  const LandingSearchScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final controller = GayaSearchController.to;
    final hotCommunities = controller.getRandomCommunities();

    /* -------------------------------------------------------------------------- */
    /*                       main scaffold widget [Scaffold]                      */
    /* -------------------------------------------------------------------------- */
    return GetBuilder<GayaSearchController>(
      builder: (searchController) {
        return Scaffold(
          resizeToAvoidBottomInset: false,
          backgroundColor: AppColors.white,
          /* ------------------------- screen app bar [AppBar] ------------------------ */
          appBar: AppBar(
            systemOverlayStyle: SystemUiOverlayStyle.dark,
            shape: Border(bottom: BorderSide(color: kBaseGrey.withOpacity(0.5))),
            backgroundColor: kTransparentColor,
            elevation: 0,
            automaticallyImplyLeading: false,
            leading: const GayaBackButton(),
            title: Padding(
              padding: const EdgeInsets.symmetric(vertical: distance_15),
              child: GayaSearchTextField(
                autofocus: true,
                onChanged: (query) => _onSearchChange(query, searchController),
                controller: searchController.searchTextEditingController,
                onSubmitted: (textToSearch) => _onSearchTextSubmitted(textToSearch, searchController, context),
                decoration: BoxDecoration(borderRadius: BorderRadius.circular(12.0.r), color: MyColorHex().blackShade5),
                hintText: GayaStrings.search.tr,
                placeHolderStyle: GayaTypography.subtitleRegular.copyWith(color: kSecondaryColor),
                prefixIconSize: 16.0.w,
              ),
            ),
          ),
          body: searchController.screenType == SearchScreenType.suggestions
              ? const FeedSearchScreen()
              : ListView(
                  children: [
                    SizedBox(height: 16.0.h),
                    /* ---------------------------- communities title --------------------------- */
                    LandingSearchScreenTitle(title: GayaStrings.communities.tr),
                    SizedBox(height: 16.0.h),
                    /* -------------------- recent searched communities list -------------------- */
                    FutureBuilder<List<Community>>(
                        future: hotCommunities,
                        builder: (context, snapshot) {
                          if (snapshot.connectionState == ConnectionState.waiting || snapshot.connectionState == ConnectionState.none) {
                            return SizedBox(
                              height: _communityContainerHeight,
                              child: ListView.builder(
                                padding: EdgeInsets.only(left: 16.0.w),
                                shrinkWrap: true,
                                primary: false,
                                scrollDirection: Axis.horizontal,
                                itemCount: 3,
                                itemBuilder: (context, index) {
                                  return Container(
                                    margin: EdgeInsets.only(right: 16.0.w),
                                    width: 1.0.sw - 64.0.w,
                                    decoration: BoxDecoration(
                                      borderRadius: BorderRadius.circular(12.0.r),
                                      color: AppColors.black5,
                                    ),
                                  );
                                },
                              ),
                            );
                          }

                          if (snapshot.hasData) {
                            return SizedBox(
                              height: _communityContainerHeight,
                              child: ListView.builder(
                                padding: EdgeInsets.only(left: 16.0.w),
                                shrinkWrap: true,
                                primary: false,
                                scrollDirection: Axis.horizontal,
                                itemCount: snapshot.data!.length,
                                itemBuilder: (context, index) {
                                  // getting community instance at specific index
                                  Community community = snapshot.data![index];

                                  return Padding(
                                    padding: EdgeInsets.only(right: 16.0.w),
                                    child: SizedBox(
                                      width: 1.0.sw - 80.0.w,
                                      child: GetBuilder<GayaSearchController>(
                                        id: community.communityId,
                                        builder: (controller) {
                                          // checking whether [community] is already joined
                                          bool isCommunityJoined = controller.checkIsCommunityJoined(community.communityId ?? '');
                                          // checking whether [community] request is in pending
                                          bool isCommunityRequestSent =
                                              controller.checkIsCommunityJoinRequestSent(community.communityId ?? '');

                                          return CommunityContainer(
                                            searchedCommunityItem: SearchedCommunityItem(
                                              communityId: community.communityId ?? '',
                                              communityCover: community.coverPicture ?? '',
                                              communityDp: community.CommunityPic ?? '',
                                              communityName: community.communityName ?? '',
                                              communityType: community.communityType ?? '',
                                              communityBioContent: community.communityDescription ?? '',
                                              communityJoiningStatus: isCommunityJoined
                                                  ? CommunityJoiningStatus.joined
                                                  : isCommunityRequestSent
                                                      ? CommunityJoiningStatus.waitingForApproval
                                                      : CommunityJoiningStatus.notJoined,
                                            ),
                                            isHorizontalTile: true,
                                            onCommunityContainerTap: () => joinOrOpenCommunity(context, community),
                                            onJoinOrLeaveCommunityTap: !isCommunityRequestSent && !isCommunityJoined
                                                ? () => joinOrOpenCommunity(context, community)
                                                : () {
                                                    // opening leave community dialog
                                                    Methods.showLeaveCommunityAlert(
                                                      communityModel: community,
                                                      context: context,
                                                      onLeave: () {},
                                                    );
                                                  },
                                          );
                                        },
                                      ),
                                    ),
                                  );
                                },
                              ),
                            );
                          }
                          return Padding(
                            padding: EdgeInsets.only(bottom: 16.0.w),
                            child: SizedBox(
                              width: double.infinity,
                              child: Center(
                                child: Text(
                                  GayaStrings.no_community_found.tr,
                                  style: CustomTypography.body2StyleWeightBlack.copyWith(
                                    color: AppColors.secondary,
                                    fontSize: 14.0,
                                    fontWeight: FontWeight.w500,
                                  ),
                                ),
                              ),
                            ),
                          );
                        }),
                    SizedBox(height: 16.0.h),

                    /* -------------------------- recent searches title ------------------------- */
                    LandingSearchScreenTitle(
                      title: GayaStrings.recent_searches.tr,
                      hasSeeAllButton: searchController.recentSearches.isNotEmpty,
                      hasSeeAllButtonOnTap: () {
                        // navigation to RecentSearchesScreen
                        showCupertinoDialog(
                          context: context,
                          builder: (_) => const RecentSearchesScreen(),
                        );
                      },
                    ),
                    if (searchController.recentSearches.isEmpty) SizedBox(height: 16.0.h),
                    /* -------------------------- recent searches list -------------------------- */
                    if (searchController.recentSearches.isEmpty)
                      Padding(
                        padding: EdgeInsets.symmetric(horizontal: 16.0.w),
                        child: SizedBox(
                          width: double.infinity,
                          child: Center(
                            child: Text(
                              GayaStrings.no_recent_searches.tr,
                              style: CustomTypography.body2StyleWeightBlack.copyWith(
                                color: AppColors.secondary,
                                fontSize: 14.0,
                                fontWeight: FontWeight.w500,
                              ),
                            ),
                          ),
                        ),
                      )
                    else
                      ListView.builder(
                        primary: false,
                        shrinkWrap: true,
                        itemCount: searchController.recentSearches.length,
                        itemBuilder: (_, index) {
                          String recentItem = searchController.recentSearches[index];
                          return RecentSearchUserItem(
                            profileImage:
                                'https://images.unsplash.com/photo-1682686578707-140b042e8f19?ixlib=rb-4.0.3&ixid=M3wxMjA3fDF8MHxlZGl0b3JpYWwtZmVlZHwxfHx8ZW58MHx8fHx8&auto=format&fit=crop&w=500&q=60',
                            username: recentItem,
                            onDeleteItemTap: () => searchController.removeFromRecentSearch(index),
                            onRecentSearchItemTap: () => _onSearchTextSubmitted(recentItem, searchController, context),
                          );
                        },
                      ),
                  ],
                ),
        );
      },
    );
  }

  double get _communityContainerHeight => 100.0.h + 16.0.h + 8.0.h + 16.sp + 8.0 + 16.0.h + 14.22.sp + 8.0.h + 16.0.w + 12.64.sp + 12.64.sp;

  // Invoke to submit text for search
  _onSearchTextSubmitted(
    String textToSearch,
    GayaSearchController searchController,
    BuildContext context,
  ) {
    // assigning searchableText to searchTextEditingController for searching
    searchController.searchTextEditingController.text = textToSearch;
    // add textToSearch to recent search
    searchController.addToRecentSearch(textToSearch);

    // Logging user search analytics event
    AnalyticsController.to.instance.logUserSearch(
      searchedText: textToSearch,
      userId: UserModel.to.uId ?? '',
    );

    // navigation to search screen
    Routes.gotoSearchScreen();
    // showCupertinoDialog(
    //   context: context,
    //   builder: (_) => const SearchScreen(),
    // );
  }

  // Invoke to search on changing text
  _onSearchChange(
    String query,
    GayaSearchController searchController,
  ) {
    if (query.isBlank == true) {
      searchController.setScreenType(SearchScreenType.search);
    } else {
      searchController.setScreenType(SearchScreenType.suggestions);
    }
    return FeedSearchController.to.searchFeeds(query);
  }

  /// call to join or open community
  void joinOrOpenCommunity(BuildContext context, Community community) {
    context.read<CommunitiesController>().isReadMore = false;
    Methods.showModalSheetToJoinCommunity(communityId: community.communityId, ctx: context);
  }
}
