import 'package:cached_network_image/cached_network_image.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_phone_auth_handler/firebase_phone_auth_handler.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:gaya/routing/getx_route_methods.dart';
import 'package:gaya/utils/app_data.dart';
import 'package:gaya/utils/assets_icons.dart';
import 'package:gaya/utils/language/translation.dart';
import 'package:gaya/utils/local.storage.dart';
import 'package:gaya/utils/methods.dart';
import 'package:gaya/utils/theme/app_colors.dart';
import 'package:gaya/utils/theme/button_styles.dart';
import 'package:gaya/view/Auth/controller/require.sigin.register.dart';
import 'package:get/get.dart';
import 'package:provider/provider.dart';

import '../components/textfield.component.dart';
import '../controller/communities.controller.dart';
import '../gen/assets.gen.dart';
import '../model/community.model.dart';
import '../utils/const.dart';
import '../utils/textstyles.dart';

class SearchCommunities extends StatefulWidget {
  const SearchCommunities({super.key, this.isCommunityUsersSearch = false, this.communityId = ''});

  final bool isCommunityUsersSearch;
  final String communityId;

  @override
  State<SearchCommunities> createState() => _SearchCommunitiesState();
}

class _SearchCommunitiesState extends State<SearchCommunities> {
  var searchAllTheCommunities;
  late TextEditingController _searchController;
  List<dynamic>? recentSearchList = [];
  GetCommunityStorageController getStorage = Get.find<GetCommunityStorageController>();
  GetCommunityUsersStorageController getUserStorage = Get.find<GetCommunityUsersStorageController>();
  final maxItems = 10;
  late CommunitiesController communitiesController;

  @override
  void initState() {
    if (widget.isCommunityUsersSearch) {
      communitiesController = Provider.of<CommunitiesController>(context, listen: false);
      communitiesController.getCommunityMembersProfile(widget.communityId);
    } else {
      searchAllTheCommunities = context.read<CommunitiesController>().searchAllTheCommunities();
    }
    // context.read<CommunitiesController>().searchController.clear();
    _searchController = TextEditingController();
    if (widget.isCommunityUsersSearch) {
      recentSearchList = getUserStorage.getRecentSearchedList();
      recentSearchList ??= [];
    } else {
      recentSearchList = getStorage.getRecentSearchedList();
      recentSearchList ??= [];
    }
    super.initState();
  }

  @override
  void dispose() {
    super.dispose();
    _searchController.dispose();
    communitiesController.resetAllUsersOfCommunity();
  }

  @override
  Widget build(BuildContext context) {
    final searchListLength = (recentSearchList?.length ?? 0) > maxItems ? maxItems : recentSearchList?.length;

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
                    if (widget.isCommunityUsersSearch) {
                      communitiesController.searchMembers(query);
                    } else {
                      communitiesController.searchFeed(query);
                    }
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
      body: Consumer<CommunitiesController>(
        builder: ((context, value, child) {
          return _searchController.text.isEmpty
              ? recentSearchList!.isEmpty
                  ? CustomScrollView(slivers: [
                      SliverFillRemaining(
                          hasScrollBody: false,
                          child: Column(
                            mainAxisAlignment: MainAxisAlignment.center,
                            crossAxisAlignment: CrossAxisAlignment.center,
                            children: [
                              Text(GayaStrings.no_recent_searches.tr, style: CustomTypography.headingStyle),
                              SizedBox(height: 5.h),
                              Text(GayaStrings.search_what_want.tr, style: CustomTypography.secondaryFontStyleWeight),
                            ],
                          ))
                    ])
                  : Container(
                      padding: const EdgeInsets.symmetric(vertical: 10, horizontal: 15).r,
                      height: MediaQuery.sizeOf(context).height,
                      width: MediaQuery.sizeOf(context).width,
                      child: SingleChildScrollView(
                        child: Column(
                          mainAxisAlignment: MainAxisAlignment.start,
                          children: [
                            SizedBox(
                              height: 30.r,
                              child: Row(
                                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                                children: [
                                  Text(GayaStrings.recent_searched.tr,
                                      style: TextStyle(color: Colors.black, fontWeight: FontWeight.w600, fontSize: 15.sp)),
                                  TextButton(
                                      style: GayaButtonStyles.actionRowTextButtonStyle2.copyWith(),
                                      onPressed: () {
                                        recentSearchList!.clear();
                                        widget.isCommunityUsersSearch
                                            ? getUserStorage.storeRecentCommunitySearchedList(recentSearches: recentSearchList)
                                            : getStorage.storeRecentCommunitySearchedList(recentSearches: recentSearchList!);
                                        setState(() {});
                                      },
                                      child: Text(GayaStrings.clear_all.tr,
                                          style: TextStyle(color: kprimaryColor, fontWeight: FontWeight.w600, fontSize: 15.sp)))
                                ],
                              ),
                            ),
                            ListView.builder(
                                shrinkWrap: true,
                                prototypeItem: const SizedBox(height: 50),
                                physics: const NeverScrollableScrollPhysics(),
                                itemCount: searchListLength,
                                itemBuilder: (context, index) {
                                  return SizedBox(
                                      height: 60,
                                      child: InkWell(
                                        onTap: () async {
                                          try {
                                            _searchController.text = recentSearchList![index];
                                            searchAllTheCommunities = context.read<CommunitiesController>().searchAllTheCommunities();
                                            var data = await searchAllTheCommunities;
                                            if (data != null && data.docs.isNotEmpty) {
                                              communitiesController.allCommunties.clear();
                                              data.docs.forEach((data) {
                                                Community communityModel = Community.fromMap(data.data() as Map<String, dynamic>);
                                                communitiesController.allCommunties.add(communityModel);
                                              });
                                            }
                                            if (widget.isCommunityUsersSearch) {
                                              communitiesController.searchMembers(recentSearchList![index]);
                                            } else {
                                              communitiesController.searchFeed(recentSearchList![index]);
                                            }
                                            setState(() {});
                                          } catch (e) {
                                            print(e.toString());
                                          }
                                        },
                                        child: Row(
                                          crossAxisAlignment: CrossAxisAlignment.center,
                                          children: [
                                            SvgIconWidget.clockOutline(),
                                            // const Icon(Icons.access_time_rounded),
                                            const SizedBox(width: 20),
                                            Text(recentSearchList![index]),
                                            const Spacer(),
                                            IconButton(
                                              onPressed: () {
                                                recentSearchList!.removeAt(index);
                                                widget.isCommunityUsersSearch
                                                    ? getUserStorage.storeRecentCommunitySearchedList(recentSearches: recentSearchList)
                                                    : getStorage.storeRecentCommunitySearchedList(recentSearches: recentSearchList!);
                                                setState(() {});
                                              },
                                              icon: SvgIconWidget.trashOutline(),
                                              // icon: const Icon(Icons.delete_outline)
                                            ),
                                          ],
                                        ),
                                      ));
                                }),
                          ],
                        ),
                      ),
                    )
              : (widget.isCommunityUsersSearch)
                  ? ListView.builder(
                      // shrinkWrap: true,
                      physics: const ClampingScrollPhysics(),
                      itemCount: value.searchUsers.length,
                      itemBuilder: (context, index) {
                        final searchUser = value.searchUsers[index];
                        return Container(
                            margin: const EdgeInsets.only(bottom: 10).r,
                            child: ListTile(
                              onTap: () {
                                if (FirebaseAuth.instance.currentUser == null) {
                                  Get.to(() => const RequireSignRegisterView(userNotSigin: true), transition: Transition.cupertinoDialog);
                                  return;
                                }
                                if (!(recentSearchList!.contains(searchUser.name))) {
                                  recentSearchList!.add(searchUser.name);
                                  getUserStorage.storeRecentCommunitySearchedList(recentSearches: recentSearchList!);
                                }
                                Routes.viewProfile(uid: searchUser.uId, model: searchUser, shouldReplace: true);
                              },
                              leading: searchUser.profilePicture == '' || searchUser.profilePicture == null
                                  ? CircleAvatar(
                                      radius: 24.r,
                                      backgroundColor: kBaseGrey,
                                      backgroundImage: AssetImage(Assets.assets.images.userDefault),
                                    )
                                  : CircleAvatar(
                                      radius: 24.r,
                                      backgroundColor: kBaseGrey,
                                      child: CachedNetworkImage(
                                        memCacheHeight: 50,
                                        memCacheWidth: 50,
                                        imageUrl: searchUser.profilePicture ?? '',
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
                                        placeholder: (context, url) => Image.asset(Assets.assets.images.userDefault),
                                      )),
                              title: Text(searchUser.name.toString(), style: CustomTypography.bodyStyle, maxLines: 1, overflow: TextOverflow.ellipsis),
                              trailing: Container(
                                width: 20,
                                decoration: BoxDecoration(shape: BoxShape.circle, border: Border.all(color: kBlackColor)),
                                child: Icon(Icons.keyboard_arrow_right_outlined, size: 16.r),
                              ),
                            ));
                      })
                  : FutureProvider<QuerySnapshot?>(
                      initialData: null,
                      create: (context) => searchAllTheCommunities,
                      child: Consumer<QuerySnapshot?>(builder: (context, value, _) {
                        return value == null
                            ? const SizedBox()
                            : Builder(builder: (context) {
                                communitiesController.allCommunties.clear();
                                for (var i in value.docs) {
                                  Community _communityModel = Community.fromMap(i.data() as Map<String, dynamic>);
                                  communitiesController.allCommunties.add(_communityModel);
                                }
                                return ListView.builder(
                                    prototypeItem: SizedBox(height: 70.h),
                                    physics: const ClampingScrollPhysics(),
                                    itemCount: communitiesController.searchCommunities.length,
                                    itemBuilder: (context, index) {
                                      final searchCommunities = communitiesController.searchCommunities[index];
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
                                                Methods.showModalSheetToJoinCommunity(
                                                    communityId: searchCommunities.communityId, ctx: context);
                                                if (!(recentSearchList!.contains(searchCommunities.communityName!))) {
                                                  recentSearchList!.add(searchCommunities.communityName!);
                                                  getStorage.storeRecentCommunitySearchedList(recentSearches: recentSearchList!);
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
                                              ? "$totalMembersCount ${GayaStrings.member_txt.tr}"
                                              : "$totalMembersCount ${GayaStrings.member_txt.tr}",
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
                    );
        }),
      ),
    );
  }
}
