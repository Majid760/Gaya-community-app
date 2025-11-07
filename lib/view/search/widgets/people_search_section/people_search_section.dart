import 'package:easy_refresh/easy_refresh.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:gaya/utils/language/translation.dart';
import 'package:get/get.dart';

import '../../../../controller/firebase_analytics_controller.dart';
import '../../../../model/user.model.dart';
import '../../../../routing/getx_route_methods.dart';
import '../../../../utils/enum.dart';
import '../../../../utils/refresh_builder_utils.dart';
import '../../../../utils/theme/app_colors.dart';
import '../../../Auth/controller/require.sigin.register.dart';
import '../../controllers/search_controller.dart';
import '../../models/friendship_status.dart';
import '../../models/searched_person_item.dart';
import '../people_container/people_container.dart';
import '../status_text.dart';

class PeopleSearchSection extends StatelessWidget {
  const PeopleSearchSection({super.key});

  @override
  Widget build(BuildContext context) {
    return GetBuilder<GayaSearchController>(
      builder: (searchController) {
        return EasyRefresh.builder(
          footer: RefreshBuilderUtils.footer,
          controller: searchController.refreshController,
          simultaneously: true,
          onLoad: searchController.people.isEmpty
              ? null
              : () async {
                  await searchController.loadMoreData();
                },
          childBuilder: (context, physics) {
            return searchController.isLoading
                ? ListView.builder(
                    padding: EdgeInsets.only(
                      top: 16.0.w,
                      left: 16.0.w,
                      right: 16.0.w,
                    ),
                    shrinkWrap: true,
                    primary: false,
                    itemCount: 5,
                    itemBuilder: (context, index) {
                      return Container(
                        height: 120.0.h,
                        margin: EdgeInsets.only(bottom: 16.0.w),
                        decoration: BoxDecoration(
                          borderRadius: BorderRadius.circular(12.0.r),
                          color: AppColors.black5,
                        ),
                      );
                    },
                  )
                : searchController.isTabBarViewTabBuildFirstTime
                    ? StatusText(statusText: GayaStrings.search_people.tr)
                    : searchController.people.isEmpty
                        ? StatusText(statusText: GayaStrings.no_user_found.tr)
                        : CustomScrollView(
                            physics: physics,
                            slivers: [
                              SliverList(
                                delegate: SliverChildBuilderDelegate(
                                  childCount: searchController.people.length,
                                  (context, index) {
                                    // getting user instance at specific index
                                    UserModel user = searchController.people[index];

                                    return Padding(
                                      padding: EdgeInsets.only(
                                        bottom: 16.0.w,
                                        right: 16.0.w,
                                        left: 16.0.w,
                                        top: index == 0 ? 16.0.w : 0.0,
                                      ),
                                      child: GetBuilder<GayaSearchController>(
                                        id: user.uId,
                                        builder: (controller) {
                                          // getting FriendshipStatusModel if me and user is already friend
                                          FriendshipStatusModel? friendshipStatusModel = controller.isUserFriend(user.uId ?? '');

                                          return PeopleContainer(
                                            searchedPersonItem: SearchedPersonItem(
                                              username: user.name ?? '',
                                              profileImage: user.profilePicture ?? '',
                                              about: user.bio ?? '',
                                              friendshipStatus: friendshipStatusModel?.friendshipStatus ?? FriendshipStatus.addFriend,
                                            ),
                                            showLoader: controller.isLoading,
                                            onPeopleContainerTap: () {
                                              if (FirebaseAuth.instance.currentUser == null) {
                                                Get.to(() => const RequireSignRegisterView(userNotSigin: true),
                                                    transition: Transition.cupertinoDialog);
                                                return;
                                              }
                                              searchController.addToRecentSearch(user.name ?? '');
                                              Routes.viewProfile(uid: user.uId, model: user, shouldReplace: false);

                                              // Logging user clicked search result analytics event
                                              AnalyticsController.to.instance.logUserClickedSearchResult(
                                                userId: UserModel.to.uId ?? '',
                                                clickedResultIndex: index.toString(),
                                                searchedText: GayaSearchController.to.searchTextEditingController.text,
                                                clickedResultText: user.name ?? '',
                                                itemType: 'user',
                                              );
                                            },
                                            onPeopleContainerButtonTap: () => controller.onPeopleContainerButtonTapCallback(
                                              friendshipStatusModel: friendshipStatusModel,
                                              context: context,
                                              user: user,
                                            ),
                                          );
                                        },
                                      ),
                                    );
                                  },
                                ),
                              ),
                              const FooterLocator.sliver(),
                            ],
                          );
          },
        );
      },
    );
  }
}
