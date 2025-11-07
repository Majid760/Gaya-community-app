import 'package:firebase_phone_auth_handler/firebase_phone_auth_handler.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:gaya/components/textfield.component.dart';
import 'package:gaya/model/user.model.dart';
import 'package:gaya/routing/getx_route_methods.dart';
import 'package:gaya/shared/controller/gaya_search_controllers/community_member_search_controller.dart';
import 'package:gaya/shared/view/widget/search_user_tile_view.dart';
import 'package:gaya/utils/const.dart';
import 'package:gaya/utils/language/translation.dart';
import 'package:gaya/utils/textstyles.dart';
import 'package:gaya/utils/theme/button_styles.dart';
import 'package:gaya/view/Auth/controller/require.sigin.register.dart';
import 'package:get/get.dart';
import 'package:get/get_rx/src/rx_workers/utils/debouncer.dart';
import 'package:pinput/pinput.dart';

class CommunityMemberSearchScreen extends StatefulWidget {
  const CommunityMemberSearchScreen({super.key});

  @override
  State<CommunityMemberSearchScreen> createState() => _CommunityMemberSearchScreenState();
}

class _CommunityMemberSearchScreenState extends State<CommunityMemberSearchScreen> {
  late TextEditingController _searchController;
  ScrollController? _scrollController;

  @override
  void initState() {
    _scrollController = ScrollController();
    _searchController = TextEditingController();
    super.initState();
  }

  @override
  void dispose() {
    super.dispose();
    _debouncer.cancel();
    _scrollController?.dispose();
    _scrollController = null;
    _searchController.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final searchController = Get.put(CommunityMemberSearchController());
    return Scaffold(
        resizeToAvoidBottomInset: false,
        appBar: AppBar(
          systemOverlayStyle: SystemUiOverlayStyle.dark,
          shape: Border(bottom: BorderSide(color: kBaseGrey.withOpacity(0.5))),
          backgroundColor: kTransparentColor,
          elevation: 0,
          automaticallyImplyLeading: false,
          title: Padding(
              padding: const EdgeInsets.symmetric(vertical: distance_15),
              child: Row(
                children: [
                  Expanded(
                      child: GayaSearchTextField(
                    controller: _searchController,
                    autofocus: true,
                    onChanged: (query) {
                      _debouncer.call(() {
                        searchController.searchCommunityMembers(query);
                      });
                    },
                    onSuffixTap: () {
                      _searchController.clear();
                      searchController.resetSearchFeeds();
                    },
                  )),
                  SizedBox(width: 10.w),
                  TextButton(
                    style: GayaButtonStyles.actionRowTextButtonStyle2.copyWith(
                        tapTargetSize: MaterialTapTargetSize.shrinkWrap,
                        padding: MaterialStateProperty.all(EdgeInsets.zero),
                        visualDensity: VisualDensity.compact),
                    onPressed: () {
                      searchController.resetSearchFeeds();
                      Navigator.pop(context);
                    },
                    child: Text(GayaStrings.cancel_txt.tr, style: CustomTypography.body2EnableStyle1),
                  ),
                ],
              )),
        ),
        body: GetBuilder<CommunityMemberSearchController>(
          init: searchController,
          builder: (communitySearchController) {
            return _searchController.text.isEmpty
                ? searchController.recentSearches.isEmpty
                    ? CustomScrollView(slivers: [
                        SliverFillRemaining(
                            hasScrollBody: false,
                            child: Column(
                              mainAxisAlignment: MainAxisAlignment.center,
                              crossAxisAlignment: CrossAxisAlignment.center,
                              children: [
                                Text(GayaStrings.no_recent_searches.tr, style: CustomTypography.headingStyle),
                                const SizedBox(height: 5),
                                Text(GayaStrings.search_what_want.tr, style: CustomTypography.secondaryFontStyleWeight),
                              ],
                            ))
                      ])
                    : Container(
                        padding: const EdgeInsets.symmetric(vertical: 10, horizontal: 15),
                        child: Column(
                          children: [
                            SizedBox(
                              height: 50,
                              child: Row(
                                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                                children: [
                                    Text(GayaStrings.recent_searched.tr,
                                      style: const TextStyle(color: Colors.black, fontWeight: FontWeight.w600, fontSize: 15)),
                                  TextButton(
                                      onPressed: () => searchController.removeAllFromRecentSearch(),
                                      child:   Text( GayaStrings.clear_all.tr,
                                          style: const TextStyle(color: kprimaryColor, fontWeight: FontWeight.w600, fontSize: 15)))
                                ],
                              ),
                            ),
                            Expanded(
                              child: ListView.builder(
                                  prototypeItem: const SizedBox(height: 70),
                                  physics: const BouncingScrollPhysics(),
                                  itemCount:
                                      (searchController.recentSearches.length ?? 0) > 15 ? 15 : searchController.recentSearches.length ?? 0,
                                  itemBuilder: (context, index) {
                                    return SizedBox(
                                        height: 60,
                                        child: InkWell(
                                          onTap: () {
                                            _searchController.text = searchController.recentSearches[index];
                                            communitySearchController.searchCommunityMembers(_searchController.text);
                                            _searchController.moveCursorToEnd();
                                          },
                                          child: Row(
                                            crossAxisAlignment: CrossAxisAlignment.center,
                                            children: [
                                              const Icon(Icons.access_time_rounded),
                                              const SizedBox(width: 20),
                                              Text(searchController.recentSearches[index]),
                                              const Spacer(),
                                              IconButton(
                                                  onPressed: () => searchController.removeFromRecentSearch(index),
                                                  icon: const Icon(Icons.delete_outline)),
                                            ],
                                          ),
                                        ));
                                  }),
                            ),
                          ],
                        ),
                      )
                : SingleChildScrollView(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Padding(
                          padding: const EdgeInsets.fromLTRB(20, 20, 20, 20).r,
                          child: Text(GayaStrings.communities_member.tr, style: CustomTypography.bodyStyle18),
                        ),
                        communitySearchController.communityUsers.isEmpty
                            ? Center(child: Text(GayaStrings.no_community_members_found.tr, style: CustomTypography.body2DisableStyle))
                            : ListView.builder(
                                controller: _scrollController,
                                shrinkWrap: true,
                                prototypeItem: const SizedBox(height: 70),
                                itemCount: communitySearchController.communityUsers.length,
                                itemBuilder: (context, index) {
                                  UserModel user = communitySearchController.communityUsers[index];
                                  return Container(
                                      margin: const EdgeInsets.only(bottom: 10),
                                      child: UserTileView(
                                        user: user,
                                        onTap: () {
                                          if (FirebaseAuth.instance.currentUser == null) {
                                            Get.to(() => const RequireSignRegisterView(userNotSigin: true),
                                                transition: Transition.cupertinoDialog);
                                            return;
                                          }
                                          searchController.addToRecentSearch(user.name ?? '');
                                          Routes.viewProfile(uid: user.uId, model: user, shouldReplace: true);
                                        },
                                      ));
                                }),
                      ],
                    ),
                  );
          },
        ));
  }
}

final Debouncer _debouncer = Debouncer(delay: 300.milliseconds);
