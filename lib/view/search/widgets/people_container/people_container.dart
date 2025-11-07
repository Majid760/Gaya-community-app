import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';

import '../../../../utils/const.dart';
import '../../../../utils/theme/app_colors.dart';
import '../../models/searched_person_item.dart';
import 'widgets/people_container_content.dart';

class PeopleContainer extends StatelessWidget {
  const PeopleContainer({
    super.key,
    required this.searchedPersonItem,
    required this.onPeopleContainerTap,
    required this.onPeopleContainerButtonTap,
    required this.showLoader,
  });

  final SearchedPersonItem searchedPersonItem;
  final VoidCallback onPeopleContainerTap;
  final VoidCallback onPeopleContainerButtonTap;
  final bool showLoader;

  @override
  Widget build(BuildContext context) {
    /* -------------------------------------------------------------------------- */
    /*                      main container widget [Container]                     */
    /* -------------------------------------------------------------------------- */
    return GestureDetector(
      onTap: onPeopleContainerTap,
      child: Container(
        padding: EdgeInsets.all(16.0.w),
        clipBehavior: Clip.antiAlias,
        decoration: BoxDecoration(
          color: AppColors.white,
          border: Border.all(
            width: 1.0.w,
            color: kSecondaryLightColor,
          ),
          borderRadius: BorderRadius.circular(12.0.r),
        ),
        child: PeopleContainerContent(
          searchedPersonItem: searchedPersonItem,
          onPeopleContainerButtonTap: onPeopleContainerButtonTap,
          showLoader: showLoader,
        ),
      ),
    );
  }
}
