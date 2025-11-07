import 'package:flutter/material.dart';
import 'package:gaya/components/gradient_text_widget.dart';
import 'package:gaya/utils/language/translation.dart';
import 'package:gaya/utils/theme/app_colors.dart';
import 'package:gaya/widgets/create_recipe_widgets/show.groups.dart';
import 'package:get/get.dart';

import '../../controller/create.post.controller.dart';
import '../../model/community.model.dart';
import '../../utils/const.dart';
import '../../utils/textstyles.dart';

void chooseGroup(BuildContext context, CreatePostController createPostController, {required List<Community> communities}) {
  showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      enableDrag: true,
      shape: const RoundedRectangleBorder(borderRadius: BorderRadius.only(topLeft: Radius.circular(13.0), topRight: Radius.circular(13.0))),
      builder: (context) {
        return Padding(
          padding: EdgeInsets.only(bottom: MediaQuery.viewInsetsOf(context).bottom),
          child: Container(
            constraints: BoxConstraints(maxHeight: MediaQuery.sizeOf(context).height * 0.5),
            width: MediaQuery.sizeOf(context).width,
            // height: MediaQuery.of(context).padding.bottom + MediaQuery.sizeOf(context).height * 0.5,
            decoration: const BoxDecoration(
              borderRadius: BorderRadius.only(topLeft: Radius.circular(16.0), topRight: Radius.circular(16.0)),
              color: kWhiteColor,
            ),
            child: Column(
              children: [
                Padding(
                  padding: const EdgeInsets.symmetric(vertical: 10, horizontal: 20),
                  child: Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      TextButton(
                        style: ButtonStyle(overlayColor: MaterialStateProperty.all(kBaseGrey)),
                        onPressed: () => Navigator.pop(context),
                        child: Text(GayaStrings.cancel_txt.tr, style: CustomTypography.body2DisableStyle),
                      ),
                      Text(GayaStrings.choose_group.tr, style: CustomTypography.bodyStyle),
                      TextButton(
                        onPressed: () => Navigator.pop(context),
                        child: GradientTextWidget(
                            GayaStrings.done.tr,
                            style: CustomTypography.body2StyleWeightkPrimary,
                            gradient: AppColors.textGradient,
                          )),
                    ],
                  ),
                ),
                Expanded(child: ShowUserCommunitiesList(createPostController: createPostController, communities: communities)),
                const SizedBox(height: 10),
              ],
            ),
          ),
        );
      });
}
