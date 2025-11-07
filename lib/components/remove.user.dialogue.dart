import 'dart:developer';

import 'package:flutter/material.dart';
import 'package:gaya/components/button.component.dart';
import 'package:gaya/controller/group.controller.dart';
import 'package:gaya/model/user.model.dart';
import 'package:gaya/utils/language/translation.dart';
import 'package:gaya/utils/theme/app_colors.dart';
import 'package:get/get.dart';
import 'package:provider/provider.dart';

import '../utils/const.dart';
import '../utils/textstyles.dart';

kickUserFromGroupDialogue(BuildContext context, UserModel userModel, String communityId) {
  return showDialog(
    context: context,
    builder: (context) => AlertDialog(
      title: Text("${GayaStrings.remove_user_msg.tr} ${userModel.name} ${GayaStrings.from_community.tr}"),
      content: Row(
        children: [
          Expanded(
            child: GayaButton(
                textStyle: CustomTypography.body4StyleHeight,
                height: 30,
                title: GayaStrings.no_txt.tr,
                borderColor: kTransparentColor,
                onPressed: () {
                  Navigator.pop(context);
                },
                primaryColor: kBaseGrey),
          ),
          const Spacer(),
          Expanded(child: Consumer<GroupController>(
            builder: (context, removeUser, child) {
              return GayaButton(
                textStyle: CustomTypography.body4StyleWhite,
                height: 30,
                title: GayaStrings.yes_txt.tr,
                borderColor: kTransparentColor,
                onPressed: () async {
                  await removeUser.removeTheuser(communityId, userModel.uId!);
                  await removeUser.removeTheUserFromComm(communityId, userModel.uId!);
                  log('User delete from both sides');
                  Navigator.pop(context);
                },
                primaryColor: AppColors.primary,
              );
            },
          )),
        ],
      ),
    ),
  );
}
