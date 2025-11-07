import 'package:cached_network_image/cached_network_image.dart';
import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:gaya/controller/create.post.controller.dart';
import 'package:gaya/gen/assets.gen.dart';
import 'package:gaya/shared/widgets/search_list_view/search_list_view.dart';
import 'package:gaya/utils/app_data.dart';
import 'package:gaya/utils/language/translation.dart';
import 'package:gaya/utils/theme/app_colors.dart';
import 'package:get/get.dart';

import '../../model/community.model.dart';
import '../../utils/const.dart';
import '../../utils/textstyles.dart';
import '../../utils/theme/app_typography.dart';

class ShowUserCommunitiesList extends StatefulWidget {
  final CreatePostController createPostController;
  final List<Community> communities;

  const ShowUserCommunitiesList({
    super.key,
    required this.createPostController,
    required this.communities,
  });

  @override
  State<ShowUserCommunitiesList> createState() => _ShowUserCommunitiesListState();
}

class _ShowUserCommunitiesListState extends State<ShowUserCommunitiesList> {
  @override
  Widget build(BuildContext context) {
    final List<Community> joinedCommunities = widget.communities;
    return SearchableList<Community>(
      initialList: joinedCommunities,
      builder: (Community community) {
        bool currentCommunitySelected = isCommunitySelected(community);
        int totalTopicsLength = community.communityTopicList?.length ?? 0;
        return Column(
          mainAxisAlignment: MainAxisAlignment.start,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            ListTile(
              onTap: () {
                /// clear selected topic when changing community
                widget.createPostController.preSelectedTopics.clear();
                widget.createPostController.selectedCommunity.clear();
                if (widget.createPostController.selectedCommunity.isEmpty) {
                  widget.createPostController.selectedCommunity.add(community);
                }
                widget.createPostController.selectedCommunity;
                widget.createPostController.selectedCommunityUpdate();
                setState(() {});
                // Navigator.pop(context);
              },
              leading: CircleAvatar(
                radius: 24,
                backgroundColor: kBaseGrey,
                child: CachedNetworkImage(
                  memCacheHeight: 50,
                  memCacheWidth: 50,
                  imageUrl: community.CommunityPic ?? '',
                  imageBuilder: (context, imageProvider) {
                    return Container(
                      decoration: BoxDecoration(shape: BoxShape.circle, image: DecorationImage(image: imageProvider, fit: BoxFit.cover)),
                    );
                  },
                  fit: BoxFit.cover,
                  errorWidget: (context, url, error) => Container(
                      decoration: BoxDecoration(shape: BoxShape.circle, color: Colors.grey.shade200),
                      child: AppData.defaultGreyCircleImage),
                  placeholder: (context, url) => CircleAvatar(
                    backgroundImage: AssetImage(Assets.assets.images.communityLogo),
                    backgroundColor: kBaseGrey,
                  ),
                ),
              ),
              title: Text((community.communityName ?? '')),
              subtitle: Text(
                '${community.communityMembers ?? 0} ${GayaStrings.members.tr}',
                style: CustomTypography.dark12,
              ),
              trailing: Container(
                height: 20.r,
                width: 20.r,
                decoration: BoxDecoration(
                    border: Border.all(color: currentCommunitySelected ? kprimaryColor : kBaseGrey, width: 2), shape: BoxShape.circle),
                child: Padding(
                  padding: const EdgeInsets.all(3).r,
                  child: Container(
                      decoration: BoxDecoration(shape: BoxShape.circle, color: currentCommunitySelected ? kprimaryColor : kWhiteColor)),
                ),
              ),
            ),

            /// if topics are available and community is selected
            /// then show the topics of that community
            if ((totalTopicsLength != 0) && (currentCommunitySelected))
              SizedBox(
                height: 40.h,
                child: ListView.builder(
                    itemCount: totalTopicsLength,
                    scrollDirection: Axis.horizontal,
                    physics: const BouncingScrollPhysics(),
                    padding: const EdgeInsets.symmetric(horizontal: 15).r,
                    itemBuilder: (ctx, index) {
                      final topicName = community.communityTopicList?[index] ?? "";
                      bool isCurrentTopicSelected = widget.createPostController.preSelectedTopics.contains(topicName);
                      return CommunityTopicListTile(
                          onPressed: (_) {
                            /// if already contains, remove it
                            if (widget.createPostController.preSelectedTopics.contains(topicName)) {
                              widget.createPostController.preSelectedTopics.remove(topicName);
                              setState(() {});
                              return;
                            }

                            /// otherwise add it, clear list and add it
                            widget.createPostController.preSelectedTopics.clear();
                            setState(() => widget.createPostController.preSelectedTopics.add(topicName));
                          },
                          topicName: topicName,
                          topics: community.communityTopicList ?? [],
                          isSelected: isCurrentTopicSelected,
                          backgroundColor: community.communityThemeModel?.toColor);
                    }),
              )
          ],
        );
      },
      filter: (value) => joinedCommunities
          .where(
            (element) => (element.communityName ?? "").toLowerCase().contains(value),
          )
          .toList(),
      emptyWidget: const SizedBox.shrink(),
    );
  }

  /// returns true if community is selected
  bool isCommunitySelected(Community community) {
    return widget.createPostController.selectedCommunity.contains(community);
  }
}

/// Used For Showing Community Topic List in Create Post Screen
/// Chip is used for showing selected topic
class CommunityTopicListTile extends StatelessWidget {
  final String topicName;
  final Function(String) onPressed;
  final List topics;
  final bool isSelected;
  final Color? backgroundColor;

  const CommunityTopicListTile({
    Key? key,
    required this.topicName,
    required this.onPressed,
    required this.topics,
    this.isSelected = false,
    this.backgroundColor,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 5).r,
      child: ActionChip(
        surfaceTintColor: AppColors.transparrent,
        padding: const EdgeInsets.symmetric(horizontal: 10).r,
        elevation: 0,
        label: Text(topicName, style: GayaTypography.caption.copyWith(height: 1.2)),
        onPressed: () => onPressed(topicName),
        backgroundColor: isSelected ? (backgroundColor ?? AppColors.primary) : AppColors.black5,
        shadowColor: AppColors.transparrent,
      ),
    );
  }
}
