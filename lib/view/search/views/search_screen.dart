import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:get/get.dart';

import '../../../components/textfield.component.dart';
import '../../../utils/const.dart';
import '../../../utils/language/translation.dart';
import '../../../utils/textstyles.dart';
import '../../../utils/theme/app_colors.dart';
import '../../../utils/theme/button_styles.dart';
import '../controllers/search_controller.dart';
import '../widgets/communities_search_section/communities_search_section.dart';
import '../widgets/people_search_section/people_search_section.dart';
import '../widgets/posts_search_section/posts_search_section.dart';
import '../widgets/top_search_section/top_search_section.dart';

class SearchScreen extends StatefulWidget {
  const SearchScreen({super.key});

  @override
  State<SearchScreen> createState() => _SearchScreenState();
}

class _SearchScreenState extends State<SearchScreen> with SingleTickerProviderStateMixin {
  @override
  void initState() {
    super.initState();

    GayaSearchController searchController = GayaSearchController.to;

    searchController.searchTabController ??= TabController(
      length: 4,
      vsync: this,
    );
    // checking whether onTabChangeListener from tab controller if already attached
    if (searchController.onTabChangedListenerCallback == null) {
      // attaching attachOnTabChangeListenerToTabController to tab controller
      searchController.attachOnTabChangeListenerToTabController();
    }

    WidgetsBinding.instance.addPostFrameCallback((_) {
      // enabling search on this page on opening
      searchController.searchTCPP(searchController.searchTextEditingController.text);
    });
  }

  @override
  dispose() {
    GayaSearchController.to.disposeTabController();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    /* -------------------------------------------------------------------------- */
    /*                       main scaffold widget [Scaffold]                      */
    /* -------------------------------------------------------------------------- */
    return GetBuilder<GayaSearchController>(
      init: GayaSearchController.to,
      builder: (searchController) {
        return Scaffold(
          resizeToAvoidBottomInset: false,
          backgroundColor: AppColors.white,
          /* ------------------------- screen app bar [AppBar] ------------------------ */
          appBar: AppBar(
            systemOverlayStyle: SystemUiOverlayStyle.dark,
            backgroundColor: kTransparentColor,
            elevation: 0,
            automaticallyImplyLeading: false,
            title: Row(
              children: [
                /* ---------------------------- search text field --------------------------- */
                Expanded(
                  child: Padding(
                    padding: const EdgeInsets.symmetric(vertical: distance_15),
                    child: GayaSearchTextField(
                      controller: searchController.searchTextEditingController,
                      decoration: BoxDecoration(
                        borderRadius: BorderRadius.circular(12.0.r),
                        color: MyColorHex().blackShade5,
                      ),
                      autofocus: true,
                      hintText: GayaStrings.search.tr,
                      placeHolderStyle: GayaTypography.subtitleRegular.copyWith(
                        color: kSecondaryColor,
                      ),
                      prefixIconSize: 16.0.w,
                      onChanged: (searchQueryText) => searchController.searchDebouncer.call(
                        // TCPP --> Top, Communities, Persons, Posts
                        () => searchController.searchTCPP(searchQueryText),
                      ),
                      onSuffixTap: () {
                        searchController.searchTextEditingController.clear();
                        searchController.clearState();
                      },
                    ),
                  ),
                ),
                SizedBox(width: 12.0.w),
                /* ------------------------------ cancel button ----------------------------- */
                TextButton(
                  style: GayaButtonStyles.actionRowTextButtonStyle2.copyWith(
                    tapTargetSize: MaterialTapTargetSize.shrinkWrap,
                    padding: MaterialStateProperty.all(EdgeInsets.zero),
                    visualDensity: VisualDensity.compact,
                  ),
                  onPressed: () {
                    // clearing the search controller state
                    searchController.clearState();
                    Navigator.pop(context);
                  },
                  child: Text(
                    GayaStrings.cancel_txt.tr,
                    style: CustomTypography.body2EnableStyle1,
                  ),
                ),
              ],
            ),
          ),
          body: Column(
            children: [
              /* --------------------------------- tab bar -------------------------------- */
              TabBar(
                controller: searchController.searchTabController,
                unselectedLabelStyle: CustomTypography.searchTabBarInactive,
                labelStyle: CustomTypography.searchTabBarActive,
                indicatorColor: const Color(0xFF8500D6),
                unselectedLabelColor: const Color(0xFF8E8E93),
                labelColor: const Color(0xFF8500D6),
                isScrollable: true,
                labelPadding: EdgeInsets.symmetric(horizontal: 24.0.w),
                tabs: [
                  /* --------------------------------- top tab -------------------------------- */

                  Tab(
                    text: GayaStrings.top.tr,
                    height: 32.0,
                  ),
                  /* ----------------------------- communities tab ---------------------------- */

                  Tab(
                    text: GayaStrings.communities_txt.tr,
                    height: 32.0,
                  ),
                  /* -------------------------------- posts tab ------------------------------- */

                  Tab(
                    text: GayaStrings.posts.tr,
                    height: 32.0,
                  ),
                  /* ------------------------------- people tab ------------------------------- */

                  Tab(
                    text: GayaStrings.people.tr,
                    height: 32.0,
                  ),
                ],
              ),
              /* ------------------------------ tab bar view ------------------------------ */
              Expanded(
                child: TabBarView(
                  controller: searchController.searchTabController,
                  children: const [
                    TopSearchSection(),
                    CommunitiesSearchSection(),
                    PostsSearchSection(),
                    PeopleSearchSection(),
                  ],
                ),
              ),
            ],
          ),
        );
      },
    );
  }
}
