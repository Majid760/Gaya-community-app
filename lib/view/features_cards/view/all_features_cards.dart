import 'package:flutter/material.dart';
import 'package:gaya/shared/view/widget/gaya_back_button.dart';
import 'package:gaya/utils/const.dart';
import 'package:gaya/utils/language/translation.dart';
import 'package:gaya/utils/textstyles.dart';
import 'package:gaya/utils/theme/app_colors.dart';
import 'package:gaya/view/features_cards/view/widgets/child_widgets/child_widgets.dart';
import 'package:gaya/view/features_cards/view/widgets/feature_card.dart';
import 'package:get/get.dart';

class AllCards extends StatelessWidget {
  const AllCards({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.borderColor,
      appBar: AppBar(
        iconTheme: const IconThemeData(color: kBlackColor),
        elevation: 0,
        backgroundColor: kWhiteColor,
        automaticallyImplyLeading: false,
        leading: const GayaBackButton(),
        title: Row(
          children: [
            Flexible(
              child: SizedBox(
                child: Text(
                  "All Cards",
                  style: CustomTypography.bodyStyle.copyWith(fontSize: 20),
                  maxLines: 1,
                ),
              ),
            ),
          ],
        ),

      ),
      body: SingleChildScrollView(
        child: Column(
          children:  [
            FeatureCardWidget(title: GayaStrings.crown_feature_title.tr,description:
            GayaStrings.crown_feature_des.tr,
              widget1: crownChildWidget(),
              ),
            FeatureCardWidget(title: GayaStrings.post_exposure_title1.tr,description:
            GayaStrings.post_exposure_des1.tr,
              widget1: postExposureFeatureCardWidget(),
            ),
            FeatureCardWidget(title: GayaStrings.post_exposure_title2.tr,description:
            GayaStrings.post_exposure_des2.tr,
              widget1: postExposureFeatureCard2Widget(),
             ),
            FeatureCardWidget(title: GayaStrings.secret_community_feature_title.tr,description:
            GayaStrings.secret_community_feature_des.tr,
              widget1: secretCommunityFeatureCardWidget(),
             ),
            FeatureCardWidget(title: GayaStrings.get_more_crown_feature_title.tr,description:
            GayaStrings.get_more_crown_feature_des.tr,
              widget1: getMoreCrownsWidget(),
             ),
            FeatureCardWidget(title: GayaStrings.secret_community_help_feature_title.tr,description:
            GayaStrings.secret_community_help_feature_des.tr,
              widget1: needHelpWithGayaWidget(),
              ),
            FeatureCardWidget(title: GayaStrings.hide_community_feature_title.tr,description:
            GayaStrings.hide_community_feature_des.tr,
              widget1: hideCommunityWidget(),
              ),
            FeatureCardWidget(title: GayaStrings.grow_community_feature_title.tr,description:
            GayaStrings.grow_community_feature_des.tr,
              widget1: growCommunityWidget(),
              ),
            FeatureCardWidget(title: GayaStrings.hide_community_feature_title2.tr,description:
            GayaStrings.hide_community_feature_des2.tr,
              widget1: interestCommunityWidget(),
              ),

          ],
        ),
      ),
    );
  }
}
