import 'package:connectycube_sdk/connectycube_sdk.dart';
import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:gaya/components/gaya_play_button.dart';
import 'package:gaya/components/profile_image_widget.dart';
import 'package:gaya/routing/getx_route_methods.dart';
import 'package:gaya/utils/const.dart';
import 'package:gaya/utils/theme/app_colors.dart';
import 'package:gaya/view/chat/components/text_link_widget.dart';
import 'package:gaya/view/chat/helper/helper_functions.dart';

class PlayVideoWidget extends StatelessWidget {
  PlayVideoWidget({super.key, required this.currentMessage, required this.sentTime, required this.deliveryStatus, required this.mySelf});
  final CubeMessage currentMessage;
  String sentTime = '';
  String deliveryStatus = '';
  bool mySelf = false;
  @override
  Widget build(BuildContext context) {
    return Column(
      children: [
        ClipRRect(
          borderRadius: BorderRadius.circular(4.r),
          child: InkWell(
            onTap: () {
              if ((currentMessage.attachments != null && !isListEmptyOrNull(currentMessage.attachments)) ? true : false) {
                Routes.videoPlayerView(url: currentMessage.attachments!.first.url!);
              }
            },
            child: Stack(
              alignment: Alignment.center,
              children: [
                SizedBox(
                  height: 150.h,
                  width: 160.w,
                  child: PostImageWidget(
                      url: (currentMessage.attachments?.first.data == null)
                          ? null
                          : currentMessage.attachments!.first.data!.replaceAll('%2F', '/').replaceAll('%3A', ':'),
                      fit: BoxFit.cover,
                      height: 132.h,
                      width: 163.w),
                ),
                Positioned(
                    top: 0, bottom: 0.r, right: 0.r, left: 0, child: const GayaPlayButtonWidget(iconPath: "Assets/icons/play_button.svg")),
                Positioned(
                    bottom: 4.r,
                    right: 4.r,
                    child: Row(
                      children: [
                        Text(
                          sentTime,
                          style: TextStyle(color: AppColors.white, fontSize: 10.0.sp, fontStyle: FontStyle.italic),
                        ),
                        (mySelf)
                            ? Row(
                                children: [
                                  SizedBox(
                                    width: 4.r,
                                  ),
                                  getReadDeliveredWidget(deliveryStatus),
                                ],
                              )
                            : const SizedBox.shrink()
                      ],
                    ))
              ],
            ),
          ),
        ),
      ],
    );
  }
}
