import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:get/get.dart';

import '../../../components/textfield.component.dart';
import '../../../utils/assets_icons.dart';
import '../../../utils/language/translation.dart';
import '../../../utils/theme/app_colors.dart';
import '../../../utils/theme/app_spaces.dart';
import '../../../utils/theme/app_typography.dart';

class ConversationWidget extends StatelessWidget {
   ConversationWidget({Key? key}) : super(key: key);

final conversationController=TextEditingController();

  @override
  Widget build(BuildContext context) {
    return Column(
      children: [

        Text(GayaStrings.jumpstart_the_conversation_with.tr,style: GayaTypography.caption4Medium,),
        SizedBox(height: MySpaces.gap6.h,),
        SizedBox(
          width: MediaQuery.sizeOf(context).width,
          child: Padding(
            padding: const EdgeInsets.symmetric(horizontal: 20).r,
            child: Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Container(
                  padding: const EdgeInsets.symmetric(vertical: 10, horizontal: 16),
                  decoration: BoxDecoration(
                    color: AppColors.divider,
                    borderRadius: BorderRadius.circular(32),
                  ),
                  child: Text("Hello how are you?",style: GayaTypography.subtitleMedium,),
                ),
                Container(
                  padding: const EdgeInsets.symmetric(vertical: 10, horizontal: 16),
                  decoration: BoxDecoration(
                    color: AppColors.divider,
                    borderRadius: BorderRadius.circular(32),
                  ),
                  child: Text("Hi! my name is Omer",style: GayaTypography.subtitleMedium,),
                ),
              ],
            ),
          ),
        ),
        SizedBox(height: MySpaces.gap2.h,),
        SizedBox(
          width: MediaQuery.sizeOf(context).width,
          child: Padding(
            padding: const EdgeInsets.symmetric(horizontal: 20).r,
            child: Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Container(
                  padding: const EdgeInsets.symmetric(vertical: 10, horizontal: 16),
                  decoration: BoxDecoration(
                    color: AppColors.divider,
                    borderRadius: BorderRadius.circular(32),
                  ),
                  child: Text("👋",style: GayaTypography.subtitleMedium,),
                ),
                Container(
                  padding: const EdgeInsets.symmetric(vertical: 10, horizontal: 16),
                  decoration: BoxDecoration(
                    color: AppColors.divider,
                    borderRadius: BorderRadius.circular(32),
                  ),
                  child: Text("Nice to meet you",style: GayaTypography.subtitleMedium,),
                ),
                Container(
                  padding: const EdgeInsets.symmetric(vertical: 10, horizontal: 16),
                  decoration: BoxDecoration(
                    color: AppColors.divider,
                    borderRadius: BorderRadius.circular(32),
                  ),
                  child: Text("Nice to meet you",style: GayaTypography.subtitleMedium,),
                ),
              ],
            ),
          ),
        ),
        SizedBox(height: MySpaces.gap5.h,),
        Padding(
          padding: const EdgeInsets.symmetric(horizontal: 20).r,
          child: Row(
            children: [
              Expanded(
                child: textField(
                  inputType: TextInputType.text,
                  hintText: GayaStrings.conversation_field_hint.tr,
                  hintTextStyle:GayaTypography.subtitleRegular.copyWith(color: AppColors.secondary),
                  borderColor: AppColors.white,
                  controller: conversationController,
                  fillColor: AppColors.white,isFilled: true,
                  border: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(29).r,
                  ),
                  enableBorder:OutlineInputBorder(
                    borderSide: BorderSide(color: AppColors.white),
                    borderRadius: BorderRadius.circular(29).r,
                  ) ,
                  focusBorder: OutlineInputBorder(
                    borderSide: BorderSide(color: AppColors.white),
                    borderRadius: BorderRadius.circular(29).r,
                  ) ,
                ),
              ),

              SizedBox(width: MySpaces.gap2.h,),
              Container(
                height: 46.h,
                width: 46.h,
                alignment: Alignment.center,
                decoration: BoxDecoration(
                  shape: BoxShape.circle,
                  color: AppColors.primary,
                ),
                child:  SvgIconWidget.sendMessageOutline(),
              ),
            ],
          ),
        )
      ],
    );
  }
}
