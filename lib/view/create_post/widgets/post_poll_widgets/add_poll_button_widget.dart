import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:gaya/controller/create.post.controller.dart';
import 'package:gaya/utils/assets_icons.dart';
import 'package:gaya/utils/language/translation.dart';
import 'package:gaya/utils/theme/app_colors.dart';
import 'package:gaya/utils/theme/app_typography.dart';
import 'package:gaya/view/create_post/controller/new_post_creation_controller.dart';
import 'package:dotted_border/dotted_border.dart';
import 'package:get/get.dart';
import 'package:provider/provider.dart';

class PollButtonWidget extends StatelessWidget {
  const PollButtonWidget({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    final createPostController = Provider.of<CreatePostController>(context, listen: true);
    return GestureDetector(
      onTap: (){
        createPostController.addPostTileClickOnAddMore();
      },
      child: DottedBorder(
        dashPattern: const [16, 8],
        strokeWidth: 1.w,
        color: AppColors.secondary,
        strokeCap: StrokeCap.round,
        borderType: BorderType.RRect,
        radius: const Radius.circular(4).r,
        child: Center(
          child: Row(
            mainAxisSize: MainAxisSize.min,
            mainAxisAlignment: MainAxisAlignment.center,
            crossAxisAlignment: CrossAxisAlignment.center,
            children: [
              SvgIconWidget.plusOutline(height: 20.r, width: 20.r,color:AppColors.secondary),
              Text(
                GayaStrings.add_option.tr,
                textAlign: TextAlign.center,
                style: GayaTypography.caption4Medium.copyWith(color: AppColors.secondary),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
