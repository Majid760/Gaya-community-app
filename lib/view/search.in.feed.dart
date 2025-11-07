import 'package:cached_network_image/cached_network_image.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:gaya/routing/getx_route_methods.dart';
import 'package:gaya/utils/app_data.dart';
import 'package:gaya/utils/language/translation.dart';
import 'package:gaya/view/Auth/controller/require.sigin.register.dart';
import 'package:get/get.dart';
import 'package:get/get_rx/src/rx_workers/utils/debouncer.dart';
import 'package:provider/provider.dart';

import '../controller/communities.controller.dart';
import '../gen/assets.gen.dart';
import '../model/community.model.dart';
import '../model/user.model.dart';
import '../utils/const.dart';
import '../utils/local.storage.dart';
import '../utils/textstyles.dart';

class SearchInFeed extends StatefulWidget {
  final String query;

  const SearchInFeed({Key? key, required this.query}) : super(key: key);

  @override
  State<SearchInFeed> createState() => _SearchInFeedState();
}

class _SearchInFeedState extends State<SearchInFeed> {
  var searchAllTheCommunities;
  var allUsers;
  GetStorageController getStorage = Get.find<GetStorageController>();
  List<dynamic>? recentSearchList = [];
  late TextEditingController _searchController;
  final maxItems = 10;
  ScrollController? _scrollController;

  @override
  void initState() {
    _scrollController = ScrollController();
    _searchController = TextEditingController();
    searchAllTheCommunities = context.read<CommunitiesController>().searchAllTheCommunities();
    allUsers = context.read<CommunitiesController>().allUsersFunc();
    super.initState();
    recentSearchList = getStorage.getRecentSearchedList();
    recentSearchList ??= [];
    context.read<CommunitiesController>().searchFeed(widget.query);
    // context.read<CommunitiesController>().searchController.clear();
    setState(() {});
  }

  @override
  void dispose() {
    super.dispose();
    _debouncer.cancel();
    searchAllTheCommunities = null;
    recentSearchList = [];
    _scrollController?.dispose();
    _scrollController = null;
    _searchController.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final communitiesController = Provider.of<CommunitiesController>(context, listen: false);
    return Consumer<CommunitiesController>(
      builder: ((context, value, child) {
      return SingleChildScrollView(
          child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
            //heading communities
            Padding(
              padding: const EdgeInsets.fromLTRB(20, 20, 20, 20).r,
              child: Text(GayaStrings.communities_txt.tr, style: CustomTypography.bodyStyle18),
            ),
            FutureProvider<QuerySnapshot?>(
              initialData: null,
              create: (context) => searchAllTheCommunities,
              child: Consumer<QuerySnapshot?>(builder: (context, value, _) {
                final searchCommunitiesLength = (communitiesController.searchCommunities.length) > maxItems
                          ? maxItems
                          : communitiesController.searchCommunities.length;
                      return value == null
                          ? const SizedBox()
                          : Builder(builder: (context) {
                              communitiesController.allCommunties.clear();
                              for (int i = 0; i < value.docs.length; i++) {
                                try {
                                  Community _communityModel = Community.fromMap(value.docs[i].data() as Map<String, dynamic>);
                                  communitiesController.allCommunties.add(_communityModel);
                                } catch (_) {}
                              }

                              return communitiesController.searchCommunities.isEmpty
                            ? Center(child: Text(GayaStrings.no_community_found.tr, style: CustomTypography.body2DisableStyle))
                            : ListView.builder(
                                keyboardDismissBehavior: ScrollViewKeyboardDismissBehavior.onDrag,
                                controller: _scrollController,
                                prototypeItem: const SizedBox(height: 70),
                                shrinkWrap: true,
                                itemCount: (searchCommunitiesLength) > 15 ? 15 : searchCommunitiesLength,
                                itemBuilder: (context, index) {
                                  final searchCommunities = communitiesController.searchCommunities[index];
                                  final totalMembersCount = searchCommunities.communityMembers ?? 0;
                                  return ListTile(
                                    onTap: () async {
                                            // if (searchCommunities.communityId == null) return;
                                            // Methods.showModalSheetToJoinCommunity(
                                            //     communityId: searchCommunities.communityId, ctx: context);
                                            // if (!(recentSearchList!.contains(searchCommunities.communityName!))) {
                                            //   recentSearchList!.add(searchCommunities.communityName!);
                                            //   getStorage.storeRecentSearchedList(recentSearches: recentSearchList!);
                                            // }
                                          },
                                          leading: CircleAvatar(
                                              radius: 24,
                                              backgroundColor: kBaseGrey,
                                              // backgroundImage:
                                              // CachedNetworkImageProvider(searchCommunities.CommunityPic.toString()),
                                              child: CachedNetworkImage(
                                                memCacheHeight: 50,
                                                memCacheWidth: 50,
                                                imageUrl: searchCommunities.CommunityPic ?? '',
                                                imageBuilder: (context, imageProvider) {
                                                  return Container(
                                                    decoration: BoxDecoration(
                                                      shape: BoxShape.circle,
                                                      image: DecorationImage(
                                                        image: imageProvider,
                                                        fit: BoxFit.cover,
                                                      ),
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
                                                // Container(
                                                //   color: Colors.red,
                                                //   padding: EdgeInsets.all(4.r),
                                                //   // child: Image.asset(
                                                //   //   Assets.assets.images.communityLogo,
                                                //   //   cacheHeight: 50,
                                                //   //   cacheWidth: 50,
                                                //   // ),
                                                // ),
                                              )),
                                          title: Text(
                                            searchCommunities.communityName.toString(),
                                            style: CustomTypography.bodyStyle,
                                          ),
                                          subtitle: Text(
                                            totalMembersCount > 1
                                                ? "$totalMembersCount ${GayaStrings.member_txt.tr}"
                                                : "$totalMembersCount ${GayaStrings.member_txt.tr}",
                                            style: GayaTypography.caption,
                                          ),
                                          trailing: Container(
                                            width: 20,
                                            decoration: BoxDecoration(
                                              shape: BoxShape.circle,
                                              border: Border.all(color: kBlackColor),
                                            ),
                                            child: const Icon(
                                              Icons.keyboard_arrow_right_outlined,
                                              size: 16,
                                            ),
                                          ),
                                        );
                                      });
                            });
                    }),
                  ),
                  //heading users
                  Padding(
                    padding: const EdgeInsets.fromLTRB(20, 20, 20, 20).r,
              child: Text(GayaStrings.users_txt.tr, style: CustomTypography.bodyStyle18),
            ),
                  FutureProvider<QuerySnapshot?>(
                      initialData: null,
                      create: (context) => allUsers,
                      child: Consumer<QuerySnapshot?>(builder: (context, searchUsersValue, _) {
                        return searchUsersValue == null
                            ? const SizedBox()
                            : Builder(builder: (context) {
                                communitiesController.allUsers.clear();
                                for (int i = 0; i < searchUsersValue.docs.length; i++) {
                                  try {
                                    if (searchUsersValue.docs[i].data() == null) continue;
                              UserModel _userModel = UserModel.fromMap(searchUsersValue.docs[i].data() as Map<String, dynamic>,
                                  userId: searchUsersValue.docs[i].id);
                              communitiesController.allUsers.add(_userModel);
                            } catch (_) {}
                                }
                                return communitiesController.searchUsers.isEmpty
                              ? Center(child: Text(GayaStrings.no_user_found.tr, style: CustomTypography.body2DisableStyle))
                              : ListView.builder(
                                  keyboardDismissBehavior: ScrollViewKeyboardDismissBehavior.onDrag,
                                  prototypeItem: const SizedBox(height: 70),
                                  controller: _scrollController,
                                  shrinkWrap: true,
                                  physics: const ClampingScrollPhysics(),
                                  itemCount:
                                      (communitiesController.searchUsers.length) > 15 ? 15 : communitiesController.searchUsers.length,
                                  itemBuilder: (context, index) {
                                    final searchUsers = communitiesController.searchUsers[index];

                                    return Container(
                                              margin: const EdgeInsets.only(bottom: 10),
                                              child: ListTile(
                                                onTap: () {
                                                  if (FirebaseAuth.instance.currentUser == null) {
                                                    Get.to(() => const RequireSignRegisterView(userNotSigin: true),
                                                        transition: Transition.cupertinoDialog);
                                                    return;
                                                  }
                                                  /*
                                                      *Changes By Kamran
                                                      *Users Search Key Addition in Recent Search List.                                                            *
                                                      */
                                                  if (!(recentSearchList!.contains(searchUsers.name!))) {
                                                    recentSearchList!.add(searchUsers.name!);
                                                    getStorage.storeRecentSearchedList(recentSearches: recentSearchList!);
                                                  }
                                                  Routes.viewProfile(uid: searchUsers.uId, model: searchUsers, shouldReplace: true);
                                                },
                                                leading: searchUsers.profilePicture == '' || searchUsers.profilePicture == null
                                                    ? CircleAvatar(
                                                        radius: 24,
                                                        backgroundColor: kBaseGrey,
                                                        backgroundImage: AssetImage(Assets.assets.images.userDefault),
                                                      )
                                                    : CircleAvatar(
                                                        radius: 24,
                                                        backgroundColor: kBaseGrey,
                                                        child: CachedNetworkImage(
                                                          memCacheHeight: 50,
                                                          memCacheWidth: 50,
                                                          imageUrl: searchUsers.profilePicture ?? '',
                                                          imageBuilder: (context, imageProvider) {
                                                            return Container(
                                                              decoration: BoxDecoration(
                                                                shape: BoxShape.circle,
                                                                image: DecorationImage(
                                                                  image: imageProvider,
                                                                  fit: BoxFit.cover,
                                                                ),
                                                              ),
                                                            );
                                                          },
                                                          fit: BoxFit.cover,
                                                          errorWidget: (context, url, error) => Container(
                                                            decoration: BoxDecoration(shape: BoxShape.circle, color: Colors.grey.shade200),
                                                            child: const Center(
                                                                child: Icon(
                                                              Icons.error,
                                                              color: Colors.red,
                                                            )),
                                                          ),
                                                          placeholder: (context, url) => Image.asset(
                                                            Assets.assets.images.userDefault,
                                                          ),
                                                        )),
                                                title: Text(
                                                  searchUsers.name.toString(),
                                                  style: CustomTypography.bodyStyle,
                                                ),
                                                trailing: Container(
                                                  width: 20,
                                                  decoration: BoxDecoration(
                                                    shape: BoxShape.circle,
                                                    border: Border.all(color: kBlackColor),
                                                  ),
                                                  child: const Icon(
                                                    Icons.keyboard_arrow_right_outlined,
                                                    size: 16,
                                                  ),
                                                ),
                                              ));
                                        });
                              });
                      }))
                ]),
              );
      }),
    );

  }

  final Debouncer _debouncer = Debouncer(delay: 500.milliseconds);
}
