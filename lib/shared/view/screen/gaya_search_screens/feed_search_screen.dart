import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:flutter/scheduler.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:gaya/model/community.model.dart';
import 'package:gaya/model/user.model.dart';
import 'package:gaya/routing/getx_route_methods.dart';
import 'package:gaya/shared/controller/gaya_search_controllers/feed_search_controller.dart';
import 'package:gaya/shared/view/widget/search_community_tile_view.dart';
import 'package:gaya/shared/view/widget/search_user_tile_view.dart';
import 'package:gaya/utils/methods.dart' as UtilMethods;
import 'package:gaya/utils/textstyles.dart';
import 'package:gaya/view/Auth/controller/require.sigin.register.dart';
import 'package:get/get.dart';
import 'package:get/get_rx/src/rx_workers/utils/debouncer.dart';

import '../../../../controller/firebase_analytics_controller.dart';
import '../../../../utils/language/translation.dart';

class FeedSearchScreen extends StatelessWidget {
  const FeedSearchScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return GetBuilder<FeedSearchController>(
      autoRemove: false,
      init: FeedSearchController.to,
      builder: (searchController) {
        // return
        return SingleChildScrollView(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Padding(
                padding: const EdgeInsets.fromLTRB(20, 20, 20, 20).r,
                child: Text(GayaStrings.communities_txt.tr, style: CustomTypography.bodyStyle18),
              ),
              searchController.communities.isEmpty
                  ? Center(child: Text(GayaStrings.no_community_found.tr, style: CustomTypography.body2DisableStyle))
                  : ListView.builder(
                      controller: searchController.scrollController,
                      shrinkWrap: true,
                      prototypeItem: const SizedBox(height: 70),
                      itemCount: (searchController.communities.length) > 15 ? 15 : searchController.communities.length,
                      itemBuilder: (context, index) {
                        Community community = searchController.communities[index];
                        return CommunityTileView(
                          community: community,
                          onTap: () {
                            if (community.communityId == null) return;

                            // Logging auto complete usage event
                            AnalyticsController.to.instance.logAutocompleteUsage(
                              userId: UserModel.to.uId ?? '',
                              autoCompleteSelectedItemText: community.communityName ?? '',
                              itemType: 'community',
                            );

                            SchedulerBinding.instance.addPostFrameCallback((_) {
                              UtilMethods.Methods.showModalSheetToJoinCommunity(
                                  communityId: community.communityId, ctx: context, shouldReplace: true);
                              searchController.addToRecentSearch(community.communityName ?? '');
                            });
                          },
                        );
                      }),
              Padding(
                  padding: const EdgeInsets.fromLTRB(20, 20, 20, 20).r,
                  child: Text(GayaStrings.users_txt.tr, style: CustomTypography.bodyStyle18)),
              searchController.users.isEmpty
                  ? Center(child: Text(GayaStrings.no_user_found.tr, style: CustomTypography.body2DisableStyle))
                  : ListView.builder(
                      prototypeItem: const SizedBox(height: 70),
                      shrinkWrap: true,
                      controller: searchController.scrollController,
                      physics: const ClampingScrollPhysics(),
                      itemCount: searchController.users.length,
                      itemBuilder: (context, index) {
                        UserModel user = searchController.users[index];
                        return Container(
                            margin: const EdgeInsets.only(bottom: 10),
                            child: UserTileView(
                              user: user,
                              onTap: () {
                                if (FirebaseAuth.instance.currentUser == null) {
                                  Get.to(() => const RequireSignRegisterView(userNotSigin: true), transition: Transition.cupertinoDialog);
                                  return;
                                }

                                // Logging auto complete usage event
                                AnalyticsController.to.instance.logAutocompleteUsage(
                                  userId: UserModel.to.uId ?? '',
                                  autoCompleteSelectedItemText: user.name ?? '',
                                  itemType: 'user',
                                );

                                searchController.addToRecentSearch(user.name ?? '');
                                Routes.viewProfile(uid: user.uId, model: user, shouldReplace: false);
                              },
                            ));
                      })
            ],
          ),
        );
      },
    );
  }
}

final Debouncer _debouncer = Debouncer(delay: 300.milliseconds);
