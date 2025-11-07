import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:get/get.dart';
import 'package:get/get_rx/src/rx_workers/utils/debouncer.dart';
import 'package:pinput/pinput.dart';

import '../../../../components/textfield.component.dart';
import '../../../../model/community.model.dart';
import '../../../../utils/assets_icons.dart';
import '../../../../utils/const.dart';
import '../../../../utils/language/translation.dart';
import '../../../../utils/methods.dart' as UtilMethods;
import '../../../../utils/textstyles.dart';
import '../../../../utils/theme/button_styles.dart';
import '../../../controller/gaya_search_controllers/community_search_controller.dart';
import '../../widget/search_community_tile_view.dart';

class CommunitySearchScreen extends StatefulWidget {
  const CommunitySearchScreen({super.key});

  @override
  State<CommunitySearchScreen> createState() => _CommunitySearchScreenState();
}

class _CommunitySearchScreenState extends State<CommunitySearchScreen> {
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
    debugPrint("CommunitySearchScreen build");
    final searchController = Get.put(CommunitySearchController());
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
                        searchController.searchCommunity(query);
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
        body: GetBuilder<CommunitySearchController>(
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
                                      child: Text(GayaStrings.clear_all.tr,
                                          style: const TextStyle(color: kprimaryColor, fontWeight: FontWeight.w600, fontSize: 15)))
                                ],
                              ),
                            ),
                            Expanded(
                              child: ListView.builder(
                                  keyboardDismissBehavior: ScrollViewKeyboardDismissBehavior.onDrag,
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
                                            communitySearchController.searchCommunity(_searchController.text);
                                            _searchController.moveCursorToEnd();
                                          },
                                          child: Row(
                                            crossAxisAlignment: CrossAxisAlignment.center,
                                            children: [
                                              SvgIconWidget.clockOutline(),
                                              // const Icon(Icons.access_time_rounded),
                                              const SizedBox(width: 20),
                                              Text(searchController.recentSearches[index]),
                                              const Spacer(),
                                              IconButton(
                                                onPressed: () => searchController.removeFromRecentSearch(index),
                                                icon: SvgIconWidget.trashOutline(),
                                                // icon: const Icon(Icons.delete_outline)
                                              ),
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
                          child: Text("Communities", style: CustomTypography.bodyStyle18),
                        ),
                        communitySearchController.communities.isEmpty
                            ? Center(child: Text("No Community found!", style: CustomTypography.body2DisableStyle))
                            : ListView.builder(
                                keyboardDismissBehavior: ScrollViewKeyboardDismissBehavior.onDrag,
                                controller: _scrollController,
                                shrinkWrap: true,
                                prototypeItem: const SizedBox(height: 70),
                                itemCount: communitySearchController.communities.length,
                                itemBuilder: (context, index) {
                                  Community community = communitySearchController.communities[index];
                                  return CommunityTileView(
                                      community: community,
                                      onTap: () async {
                                        if (community.communityId == null) return;
                                        UtilMethods.Methods.showModalSheetToJoinCommunity(communityId: community.communityId, ctx: context);
                                        communitySearchController.addToRecentSearch(community.communityName ?? '');
                                      });
                                }),
                      ],
                    ),
                  );
          },
        ));
  }
}

final Debouncer _debouncer = Debouncer(delay: 300.milliseconds);
