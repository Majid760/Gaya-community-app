import 'package:flutter/material.dart';
import 'package:gaya/components/textfield.component.dart';
import 'package:gaya/utils/const.dart';
import 'package:gaya/utils/language/translation.dart';
import 'package:gaya/utils/textstyles.dart';
import 'package:gaya/utils/vallidation.dart';
import 'package:gaya/view/community/create_community/controllers/create_community_controller.dart';
import 'package:get/get.dart';

class CommunityView3 extends StatelessWidget {
  const CommunityView3({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    final validation = FormValidation();
    return GetBuilder<CreateCommunityController>(builder: (controller) {
      return Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            GayaStrings.add_description.tr,
            style: CustomTypography.bodyStyle,
          ),
          const SizedBox(
            height: distance_10,
          ),
          Text(
            GayaStrings.describe_community.tr,
            style: CustomTypography.secondaryFontStyleWeight,
          ),
          const SizedBox(
            height: distance_25,
          ),
          Text(
            GayaStrings.description_txt.tr,
            style: CustomTypography.secondaryFontStyleWeight,
          ),
          const SizedBox(
            height: distance_5,
          ),
          textField(
              maxlength: 200,
              maxlines: null,
              isPassword: false,
              inputType: TextInputType.multiline,
              hintText: GayaStrings.describe_community_txt.tr,
              controller: controller.description,
              validation: validation.firstNameValidator,
              borderColor: borderColor),
        ],
      );
    });
  }
}
