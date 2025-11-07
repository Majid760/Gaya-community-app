import 'package:easy_refresh/easy_refresh.dart';
import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:gaya/utils/language/translation.dart';
import 'package:get/get.dart';

import '../../../../model/create.post.model.dart';
import '../../../../utils/refresh_builder_utils.dart';
import '../../../../utils/theme/app_colors.dart';
import '../../../feed/components/post_tile.dart';
import '../../controllers/search_controller.dart';
import '../status_text.dart';

class PostsSearchSection extends StatelessWidget {
  const PostsSearchSection({super.key});

  @override
  Widget build(BuildContext context) {
    return GetBuilder<GayaSearchController>(
      builder: (searchController) {
        return EasyRefresh.builder(
          controller: searchController.refreshController,
          footer: RefreshBuilderUtils.footer,
          simultaneously: true,
          onLoad: searchController.posts.isEmpty
              ? null
              : () async {
                  await searchController.loadMoreData();
                },
          childBuilder: (context, physics) {
            return searchController.isLoading
                ? ListView.builder(
                    padding: EdgeInsets.only(top: 16.0.w),
                    shrinkWrap: true,
                    primary: false,
                    itemCount: 3,
                    itemBuilder: (context, index) {
                      return Container(
                        height: 160.0.h,
                        margin: EdgeInsets.only(
                          left: 16.0.w,
                          right: 16.0.w,
                          bottom: 16.0.w,
                        ),
                        decoration: BoxDecoration(
                          borderRadius: BorderRadius.circular(12.0.r),
                          color: AppColors.black5,
                        ),
                      );
                    },
                  )
                : searchController.isTabBarViewTabBuildFirstTime
                    ? StatusText(statusText: GayaStrings.search_post.tr)
                    : searchController.posts.isEmpty
                        ? StatusText(statusText: GayaStrings.no_post_found.tr)
                        : CustomScrollView(
                            physics: physics,
                            slivers: [
                              SliverList(
                                delegate: SliverChildBuilderDelegate(
                                  childCount: searchController.posts.length,
                                  (context, index) {
                                    // getting post instance at specific index
                                    Post post = searchController.posts[index];

                                    return Padding(
                                      padding: EdgeInsets.only(
                                        bottom: 16.0.w,
                                      ),
                                      child: GetBuilder<GayaSearchController>(
                                        id: post.postid,
                                        builder: (controller) {
                                          // getting post instance at specific index
                                          Post post = searchController.posts[index];
                                          return PostTile(
                                            postModel: post,
                                            inSearchScreen: true,
                                            index: index,
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
