import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:flutter_svg/svg.dart';
import 'package:gaya/utils/language/translation.dart';
import 'package:gaya/utils/theme/app_typography.dart';
import 'package:get/get.dart';

import '../../../controller/crowns_controller.dart';
import '../../../model/user.model.dart';
import '../../../utils/const.dart';
import '../../../utils/methods.dart';
import '../../../view/home.view.dart';

class CrownTotalCountHomeWidget extends StatelessWidget {
  const CrownTotalCountHomeWidget({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return UserModel.to.userDailyCrowns != null && UserModel.to.uId != null
        ? GetBuilder<CrownsController>(
            init: Get.find<CrownsController>(),
            builder: (crownsController) {
              return Column(
                children: [
                  Divider(height: 1.h, color: kSecondaryLightColor, thickness: 1.0),
                  InkWell(
                    onTap: () {
                      Methods.showCrownsTotalModalSheet(ctx: context);
                    },
                    child: Container(
                      padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 11).r,
                      child: Row(
                        mainAxisAlignment: MainAxisAlignment.spaceBetween,
                        children: [
                          Row(
                            children: [
                              SvgPicture.asset("Assets/images/filled_crown.svg", height: 20.r),
                              SizedBox(width: 4.w),
                              Text(GayaStrings.crowns_txt.tr, style: GayaTypography.titleSemiBold),
                            ],
                          ),
                          (crownsController.myAppUser.userDailyCrowns == 0)
                              ? const CrownTweenTimer()
                              : Text(
                                  '${crownsController.myAppUser.userDailyCrowns ?? 0}/3 ${GayaStrings.left_txt.tr}',
                                  style: GayaTypography.titleSemiBold,
                                ),
                        ],
                      ),
                    ),
                  ),
                  Divider(height: 1.h, color: kSecondaryLightColor, thickness: 1.0),
                ],
              );
            },
          )
        : const SizedBox.shrink();
  }
}
