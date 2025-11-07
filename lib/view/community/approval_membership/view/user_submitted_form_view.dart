import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:gaya/model/communities.memebers.model.dart';
import 'package:gaya/utils/theme/app_colors.dart';
import 'package:gaya/utils/theme/app_typography.dart';

import '../../../../components/button.component.dart';
import '../../../../components/textfield.component.dart';
import '../../../../shared/view/widget/gaya_back_button.dart';
import '../../../../utils/const.dart';
import '../../../../utils/language/translation.dart';
import '../../../../utils/textstyles.dart';
import '../../../../utils/theme/app_spaces.dart';

class UserSubmittedFormView extends StatelessWidget {
  final CommunityMembership communityMembership;
  final String userName;

  const UserSubmittedFormView({Key? key, required this.communityMembership, required this.userName}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    final String title = "${userName.length > 15 ? userName.substring(0, 15) : userName} entry answers";
    return Scaffold(
      appBar: AppBar(
          systemOverlayStyle: SystemUiOverlayStyle.dark,
          iconTheme: IconThemeData(color: AppColors.black),
          shape: const Border(bottom: BorderSide(color: kBaseGrey)),
          automaticallyImplyLeading: false,
          leading: const GayaBackButton(),
          title: Text(title, style: CustomTypography.bodyStyle),
          centerTitle: true,
          backgroundColor: kTransparentColor,
          elevation: 0),
      body: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          SizedBox(height: MySpaces.gap6.h),
          Expanded(
            child: ListView.builder(
              physics: const BouncingScrollPhysics(),
              shrinkWrap: true,
              itemCount: communityMembership.questionnaires?.length,
              itemBuilder: (ctx, index) {
                final questionnaire = communityMembership.questionnaires![index];
                return QuestionnaireTile(questionnaire: questionnaire, index: index);
              },
            ),
          ),
          SizedBox(
            height: MySpaces.gap2.h,
          ),
          Padding(
            padding: const EdgeInsets.only(left: 20, right: 20).r,
            child: GayaButton(
              onPressed: () async {
                Navigator.pop(context);
              },
              height: 50.h,
              title: "Back",
              primaryColor: AppColors.divider,
              textStyle: GayaTypography.subtitleMedium,
            ),
          ),
          Spacer(flex: 1),
        ],
      ),
    );
  }
}

class QuestionnaireTile extends StatelessWidget {
  final Questionnaires questionnaire;
  final int index;

  const QuestionnaireTile({Key? key, required this.questionnaire, required this.index}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.only(left: 20, right: 20).r,
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            questionnaire.question,
            style: GayaTypography.titleMedium.copyWith(height: 1.2.h),
          ),
          SizedBox(
            height: MySpaces.gap2.h,
          ),
          IgnorePointer(
            child: textField(
                inputType: TextInputType.text,
                hintText: GayaStrings.answer,
                controller: TextEditingController(text: questionnaire.answer),
                borderColor: borderColor),
          ),
          SizedBox(
            height: MySpaces.gap2.h,
          ),
        ],
      ),
    );
  }
}
