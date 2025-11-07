import 'package:cached_network_image/cached_network_image.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:gaya/components/textfield.component.dart';
import 'package:gaya/controller/communities.controller.dart';
import 'package:gaya/gen/assets.gen.dart';
import 'package:gaya/utils/app_data.dart';
import 'package:gaya/utils/const.dart';
import 'package:gaya/utils/language/translation.dart';
import 'package:gaya/utils/methods.dart';
import 'package:gaya/utils/textstyles.dart';
import 'package:gaya/utils/theme/app_colors.dart';
import 'package:gaya/utils/theme/button_styles.dart';
import 'package:get/get.dart';
import 'package:provider/provider.dart';

import '../../../model/community.model.dart';

class MyCommunitiesViewSearch extends StatefulWidget {
  const MyCommunitiesViewSearch({super.key, this.isCommunityUsersSearch = false, this.communityId = ''});

  final bool isCommunityUsersSearch;
  final String communityId;

  @override
  State<MyCommunitiesViewSearch> createState() => _MyCommunitiesViewSearchState();
}

class _MyCommunitiesViewSearchState extends State<MyCommunitiesViewSearch> {
  late Future<List<Community>> joinedCommunities;
  late TextEditingController _searchController;
  List<dynamic>? recentSearchList = [];
  late CommunitiesController communitiesController;

  @override
  void initState() {
    communitiesController = Provider.of<CommunitiesController>(context, listen: false);
    joinedCommunities = CommunitiesController().getJoinedCommunities();
    _searchController = TextEditingController();
    super.initState();
  }

  @override
  void dispose() {
    super.dispose();
    communitiesController.userSpecificSearchedCommunities = [];
    communitiesController.userSpecificCommunties = [];
    _searchController.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.white,
      appBar: AppBar(
        systemOverlayStyle: SystemUiOverlayStyle.dark,
        shape: Border(bottom: BorderSide(color: kBaseGrey.withOpacity(0.5))),
        backgroundColor: kTransparentColor,
        elevation: 0,
        automaticallyImplyLeading: false,
        title: Container(
            padding: const EdgeInsets.symmetric(vertical: distance_15).r,
            child: Row(
              children: [
                Expanded(
                    child: GayaSearchTextField(
                  hintText: widget.isCommunityUsersSearch ? GayaStrings.search_user.tr : GayaStrings.search_communities.tr,
                  autofocus: true,
                  controller: _searchController,
                  onChanged: (query) {
                    setState(() {});
                    communitiesController.userSpecificCommunitiesSearch(query);
                  },
                )),
                SizedBox(width: 10.w),
                TextButton(
                  style: GayaButtonStyles.actionRowTextButtonStyle2.copyWith(
                      tapTargetSize: MaterialTapTargetSize.shrinkWrap,
                      padding: MaterialStateProperty.all(EdgeInsets.zero),
                      visualDensity: VisualDensity.compact),
                  onPressed: () => Navigator.pop(context),
                  child: Text(GayaStrings.cancel_txt.tr, style: CustomTypography.body2EnableStyle1),
                ),
              ],
            )),
      ),
      body: FutureProvider<List<Community>>(
        initialData: const [],
        create: (context) => joinedCommunities,
        child: Consumer<List<Community>>(builder: (context, value, _) {
          print("value.length ${value.length}");
          return value.isEmpty
              ? SizedBox(
                  height: MediaQuery.sizeOf(context).height * 0.4,
                  child: Center(child: Text(GayaStrings.no_community_found.tr, style: CustomTypography.body2DisableStyle)),
                )
              : Builder(builder: (context) {
                  communitiesController.userSpecificCommunties = [];
                  for (var communityModel in value) {
                    communitiesController.userSpecificCommunties.add(communityModel);
                  }

                  print(
                      "communitiesController.userSpecificCommunties.length ${communitiesController.userSpecificSearchedCommunities.length}");
                  return ListView.builder(
                      keyboardDismissBehavior: ScrollViewKeyboardDismissBehavior.onDrag,
                      prototypeItem: SizedBox(height: 70.h),
                      physics: const ClampingScrollPhysics(),
                      itemCount: communitiesController.userSpecificSearchedCommunities.length,
                      itemBuilder: (context, index) {
                        final searchCommunities = communitiesController.userSpecificSearchedCommunities[index];
                        final totalMembersCount = searchCommunities.communityMembers ?? 0;

                        return ListTile(
                          splashColor: kTransparentColor,
                          selectedColor: kTransparentColor,
                          selectedTileColor: kTransparentColor,
                          focusColor: kTransparentColor,
                          hoverColor: kTransparentColor,
                          onTap: searchCommunities.communityId == null
                              ? null
                              : () async {
                                  FocusScope.of(context).unfocus();
                                  if (searchCommunities.communityId == null) return;
                                  Methods.showModalSheetToJoinCommunity(communityId: searchCommunities.communityId, ctx: context);
                                  if (!(recentSearchList!.contains(searchCommunities.communityName!))) {
                                    recentSearchList!.add(searchCommunities.communityName!);
                                    // getStorage.storeRecentCommunitySearchedList(recentSearches: recentSearchList!);
                                  }
                                },
                          leading: CircleAvatar(
                              radius: 24.r,
                              backgroundColor: kBaseGrey,
                              child: CachedNetworkImage(
                                memCacheHeight: 50,
                                memCacheWidth: 50,
                                imageUrl: searchCommunities.CommunityPic ?? '',
                                imageBuilder: (context, imageProvider) {
                                  return Container(
                                    decoration: BoxDecoration(
                                      shape: BoxShape.circle,
                                      image: DecorationImage(image: imageProvider, fit: BoxFit.cover),
                                    ),
                                  );
                                },
                                fit: BoxFit.cover,
                                errorWidget: (context, url, error) => AppData.defaultGreyCircleImage,
                                placeholder: (context, url) => CircleAvatar(
                                  backgroundImage: AssetImage(Assets.assets.images.communityLogo),
                                  backgroundColor: kSecondaryColor,
                                  radius: 40.r,
                                ),
                                // placeholder: (context, url) =>
                                //     Image.asset(Assets.assets.images.communityLogo, cacheHeight: 50, cacheWidth: 50),
                              )),
                          title: Text(
                            searchCommunities.communityName.toString(),
                            style: GayaTypography.titleMedium,
                            maxLines: 1,
                            overflow: TextOverflow.ellipsis,
                          ),
                          subtitle: Text(
                            totalMembersCount > 1
                                ? "$totalMembersCount ${GayaStrings.members_txt.tr}"
                                : "$totalMembersCount ${GayaStrings.members_txt.tr}",
                            style: GayaTypography.caption,
                          ),
                          trailing: Container(
                            width: 20.w,
                            decoration: BoxDecoration(
                              shape: BoxShape.circle,
                              border: Border.all(color: kBlackColor),
                            ),
                            child: Icon(
                              Icons.keyboard_arrow_right_outlined,
                              size: 16.r,
                            ),
                          ),
                        );
                      });
                });
        }),
      ),
    );
  }
}
