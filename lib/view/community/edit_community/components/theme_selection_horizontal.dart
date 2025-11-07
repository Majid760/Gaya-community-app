
import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';

import '../../../../utils/const.dart';

/// Horizontal list view for community theme colors
class CommunityThemeHorizontalListView extends StatelessWidget {
  String selectedHexColor;
  final Function(String) onColorSelected;
  final double height;

  CommunityThemeHorizontalListView({Key? key, required this.selectedHexColor, required this.onColorSelected, this.height = 50})
      : super(key: key);

  @override
  Widget build(BuildContext context) {
    return StatefulBuilder(
        builder: (context, updateState) => SizedBox(
          height: height.h,
          width: double.infinity,
          child: ListView.separated(
            separatorBuilder: (context, index) => Padding(padding: const EdgeInsets.only(right: 8).r),
            itemCount: moderatortagColors.length,
            scrollDirection: Axis.horizontal,
            itemBuilder: (context, index) {
              Color? retrieveColor = getColorFromHex(moderatortagColors[index]);
              return GestureDetector(
                onTap: () {
                  // callback
                  onColorSelected(moderatortagColors[index]);
                  //current ui selected color
                  selectedHexColor = moderatortagColors[index];
                  // update ui
                  updateState(() {});
                },
                child: Stack(
                  alignment: Alignment.center,
                  children: [
                    SizedBox(height: 60, width: 60, child: CircleAvatar(backgroundColor: retrieveColor ?? kBaseGrey)),
                    if (selectedHexColor == moderatortagColors[index])
                      const Positioned(left: 0, right: 0, top: 0, bottom: 0, child: Icon(Icons.check, color: kBlackColor))
                  ],
                ),
              );
            },
          ),
        ));
  }
}