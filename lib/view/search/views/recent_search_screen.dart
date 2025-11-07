import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:gaya/utils/language/translation.dart';
import 'package:get/get.dart';

import '../../../routing/getx_route_methods.dart';
import '../../../shared/view/widget/gaya_back_button.dart';
import '../../../utils/const.dart';
import '../../../utils/textstyles.dart';
import '../../../utils/theme/app_colors.dart';
import '../controllers/search_controller.dart';
import '../widgets/recent_search_user_item.dart';

class RecentSearchesScreen extends StatelessWidget {
  const RecentSearchesScreen({super.key});

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
            automaticallyImplyLeading: false,
            leading: const GayaBackButton(),
            iconTheme: const IconThemeData(color: Colors.black),
            backgroundColor: kTransparentColor,
            elevation: 0,
            shape: const Border(bottom: BorderSide(color: kBaseGrey)),
            centerTitle: true,
            title: Text(GayaStrings.recent_searches.tr, style: CustomTypography.bodyStyle),
          ),
          body: searchController.recentSearches.isEmpty
              ? Padding(
                  padding: EdgeInsets.symmetric(horizontal: 16.0.w),
                  child: SizedBox(
                    width: double.infinity,
                    child: Center(
                      child: Text(
                        GayaStrings.no_recent_searches.tr,
                        style: CustomTypography.body2StyleWeightBlack.copyWith(
                          color: AppColors.secondary,
                          fontSize: 14.0,
                          fontWeight: FontWeight.w500,
                        ),
                      ),
                    ),
                  ),
                )
              : ListView.builder(
                  primary: false,
                  shrinkWrap: true,
                  itemCount: searchController.recentSearches.length,
                  itemBuilder: (_, index) {
                    String recentItem = searchController.recentSearches[index];
                    return RecentSearchUserItem(
                      profileImage:
                          'https://images.unsplash.com/photo-1682686578707-140b042e8f19?ixlib=rb-4.0.3&ixid=M3wxMjA3fDF8MHxlZGl0b3JpYWwtZmVlZHwxfHx8ZW58MHx8fHx8&auto=format&fit=crop&w=500&q=60',
                      username: recentItem,
                      onDeleteItemTap: () => searchController.removeFromRecentSearch(index),
                      onRecentSearchItemTap: () => _onSearchTextSubmitted(recentItem, searchController, context),
                    );
                  },
                ),
        );
      },
    );
  }

  // Invoke to submit text for search
  _onSearchTextSubmitted(
    String textToSearch,
    GayaSearchController searchController,
    BuildContext context,
  ) {
    // popping recent searches dialog
    Navigator.pop(context);
    // assigning searchableText to searchTextEditingController for searching
    searchController.searchTextEditingController.text = textToSearch;
    // add textToSearch to recent search
    searchController.addToRecentSearch(textToSearch);
    // navigation to search screen
    Routes.gotoSearchScreen();
    // showCupertinoDialog(
    //   context: context,
    //   builder: (_) => const SearchScreen(),
    // );
  }
}
