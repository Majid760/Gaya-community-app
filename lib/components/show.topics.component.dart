import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:gaya/controller/topics.controller.dart';
import 'package:gaya/utils/const.dart';
import 'package:gaya/utils/language/translation.dart';
import 'package:gaya/utils/theme/button_styles.dart';
import 'package:get/get.dart';
import 'package:provider/provider.dart';

import '../utils/textstyles.dart';
import '../utils/theme/app_colors.dart';
import '../widgets/topic_view_widgets/interest.widget.dart';
import 'gradient_text_widget.dart';

void showTopic(
  BuildContext context,
  VoidCallback onTap,
) {
  final topicController = Provider.of<TopicsController>(context, listen: false);
  showModalBottomSheet(
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(16.0)),
      ),
      context: context,
      builder: (BuildContext bc) {
        return SafeArea(
          minimum: const EdgeInsets.symmetric(horizontal: 20, vertical: 10).r,
          child: StatefulBuilder(
            builder: (context, setState) => SingleChildScrollView(
              child: Column(
                children: [
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      InkWell(
                        onTap: () {
                          Navigator.pop(context);
                        },
                        child: Text(
                          GayaStrings.cancel_txt.tr,
                          style: CustomTypography.body2EnableStyle1,
                        ),
                      ),
                      Text(
                        GayaStrings.choose_topic.tr,
                        style: CustomTypography.body2StyleWeightBlack,
                      ),
                      TextButton(
                          style: GayaButtonStyles.actionRowTextButtonStyle2,
                          onPressed: onTap,
                          child: GradientTextWidget(
                            GayaStrings.done.tr,
                            style: CustomTypography.body2EnableStyle1.copyWith(color: kprimaryColor, fontWeight: FontWeight.bold),
                            gradient: AppColors.textGradient,
                          )),
                    ],
                  ),
                  const SizedBox(
                    height: distance_15,
                  ),
                  Wrap(
                    direction: Axis.horizontal,
                    runAlignment: WrapAlignment.start,
                    runSpacing: distance_10,
                    spacing: distance_10,
                    children: List.generate(topicController.allTopics.length, (index) {
                      final topic = topicController.allTopics[index];
                      return InterestWidget(
                        textstyle: topicController.selectedList.contains(topic)
                            ? CustomTypography.body4KStylePrimary
                            : CustomTypography.secondaryFontStyle,
                        horizontalDistance: distance_15,
                        image: topic.image,
                        title: topic.title,
                        onTap: () {
                          setState(() {
                            if (!topicController.selectedItems.contains(topic)) {
                              if (topicController.selectedList.isEmpty) {
                                context.read<TopicsController>().addTopics(topic);
                              }
                            } else {
                              context.read<TopicsController>().removeTopics(topic);
                            }
                          });
                        },
                        color: topicController.selectedList.contains(topic) ? kprimaryColorLight : kBaseGrey,
                      );
                    }),
                  ),
                ],
              ),
            ),
          ),
        );
      });
}

void showTopic1(
  BuildContext context,
  VoidCallback onTap,
) {
  final topicController = Provider.of<TopicsController>(context, listen: false);
  showModalBottomSheet(
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(
          top: Radius.circular(16.0),
        ),
      ),
      context: context,
      builder: (BuildContext bc) {
        return StatefulBuilder(
          builder: (context, setState) => Padding(
            padding: const EdgeInsets.symmetric(vertical: 10, horizontal: 20),
            child: SingleChildScrollView(
              child: Column(
                children: [
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      InkWell(
                        onTap: () {
                          Navigator.pop(context);
                        },
                        child: Text(
                          GayaStrings.cancel_txt.tr,
                          style: CustomTypography.body2EnableStyle1,
                        ),
                      ),
                      Text(
                        GayaStrings.choose_topic.tr,
                        style: CustomTypography.body2StyleWeightBlack,
                      ),
                      TextButton(
                          style: GayaButtonStyles.actionRowTextButtonStyle2,
                          onPressed: onTap,
                          child: GradientTextWidget(
                            GayaStrings.done.tr,
                            style: CustomTypography.body2EnableStyle1.copyWith(color: kprimaryColor, fontWeight: FontWeight.bold),
                            gradient: AppColors.textGradient,
                          ))
                    ],
                  ),
                  Wrap(
                    direction: Axis.horizontal,
                    runAlignment: WrapAlignment.start,
                    runSpacing: distance_10,
                    spacing: distance_10,
                    children: List.generate(topicController.allTopics.length, (index) {
                      var topic = topicController.allTopics[index];
                      return InterestWidget(
                        textstyle: topicController.selectedList.contains(topic)
                            ? CustomTypography.body4KStylePrimary
                            : CustomTypography.secondaryFontStyle,
                        horizontalDistance: distance_15,
                        image: topic.image,
                        title: topic.title,
                        onTap: () {
                          setState(
                            () {
                              if (!topicController.selectedItems.contains(topic)) {
                                // if (topicController.selectedList.length < 4) {
                                context.read<TopicsController>().addTopics(topic);
                                // }
                              } else {
                                context.read<TopicsController>().removeTopics(topic);
                              }
                            },
                          );
                        },
                        color: topicController.selectedList.contains(topic) ? kprimaryColorLight : kBaseGrey,
                      );
                    }),
                  ),
                ],
              ),
            ),
          ),
        );
      });
}
