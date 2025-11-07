import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:gaya/components/button.component.dart';
import 'package:gaya/utils/assets_icons.dart';
import 'package:gaya/utils/const.dart';
import 'package:gaya/utils/extension.dart';
import 'package:gaya/utils/language/translation.dart';
import 'package:gaya/utils/methods.dart';
import 'package:gaya/utils/theme/app_colors.dart';
import 'package:gaya/utils/theme/app_spaces.dart';
import 'package:gaya/utils/theme/app_typography.dart';
import 'package:gaya/view/community/events/model/EventModel.dart';
import 'package:get/get.dart';

import '../controller/event_controller.dart';

class EventCard extends StatelessWidget {
  final String communityId;

  EventCard({Key? key, required this.communityId}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    final gap = SizedBox(height: MySpaces.gap2.h);
    return GetBuilder<EventController>(
        init: EventController.to(tag: communityId),
        builder: (eventController) {
          return Expanded(
            child: ListView.builder(
                itemCount: eventController.selectedDateEvents.isEmpty ? 1 : eventController.selectedDateEvents.length,
                itemBuilder: (context, index) {
                  EventModel? eventModel;
                  if (eventController.selectedDateEvents.isNotEmpty) {
                    eventModel = eventController.selectedDateEvents[index];
                  }
                  if (eventController.isLoading) {
                    return Container(
                      width: double.infinity.w,
                      height: 136.h,
                      decoration: BoxDecoration(
                        borderRadius: BorderRadius.circular(8).r,
                        color: AppColors.skeleton,
                      ),
                    );
                  } else if (eventController.selectedDateEvents.isNotEmpty) {
                    return GestureDetector(
                      onTap: () {
                        calendarBottomSheet(context, eventModel!);
                      },
                      child: Padding(
                        padding: const EdgeInsets.only(bottom: 16).r,
                        child: Stack(
                          children: [
                            Container(
                              width: double.infinity,
                              decoration: BoxDecoration(
                                borderRadius: BorderRadius.circular(8).r,
                                color: AppColors.white,
                                boxShadow: [
                                  BoxShadow(
                                    color: const Color.fromRGBO(0, 0, 0, 0.08),
                                    offset: const Offset(0, 2),
                                    blurRadius: 20.r,
                                  ),
                                ],
                              ),
                              child: Padding(
                                padding: const EdgeInsets.only(left: 16, top: 20, bottom: 27, right: 8).r,
                                child: Column(
                                  crossAxisAlignment: CrossAxisAlignment.start,
                                  mainAxisAlignment: MainAxisAlignment.start,
                                  children: [
                                    Text(eventController.selectedDateEvents[index].eventName,
                                        style: CustomTypography.title24W600.copyWith(fontSize: 16.sp, height: 1.5)),
                                    gap,
                                    Text(eventModel!.eventStartTime.getTwoDifferentTimes(second: eventModel.eventEndTime),
                                        style: CustomTypography.title24W600
                                            .copyWith(fontSize: 14.sp, fontWeight: FontWeight.w500, height: 1.5)),
                                    gap,
                                    Container(
                                      padding: const EdgeInsets.symmetric(vertical: 4, horizontal: 12).r,
                                      decoration: BoxDecoration(
                                        borderRadius: BorderRadius.circular(8).r,
                                        color: AppColors.primary5,
                                      ),
                                      child: Text(eventModel.eventType,
                                          style: CustomTypography.title24W600.copyWith(
                                              fontSize: 12.sp, fontWeight: FontWeight.w500, height: 1.5, color: AppColors.primary2)),
                                    )
                                  ],
                                ),
                              ),
                            ),
                            Positioned(
                              top: 8,
                              right: 16,
                              child: Text(eventModel.eventStartTime.toDate,
                                  style: CustomTypography.title24W600.copyWith(fontSize: 12.sp, fontWeight: FontWeight.w400, height: 2)),
                            )
                          ],
                        ),
                      ),
                    );
                  } else {
                    return Center(
                      child: Text(GayaStrings.no_events.tr, style: CustomTypography.title24W600.copyWith(fontSize: 16.sp, height: 1.5)),
                    );
                  }
                }),
          );
        });
  }

  calendarBottomSheet(BuildContext context, EventModel eventModel) {
    final gap = SizedBox(
      height: distance_10.r,
    );
    return Methods.showCircularModalSheet(

      context,
      GetBuilder<EventController>(
          init: EventController.to(tag: communityId),
          builder: (eventController) {
            return Padding(
              padding: const EdgeInsets.only(left: 20, right: 20, bottom: 27).r,
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.center,
                children: [
                  gap,

                  ///add event text
                  Align(
                    alignment: Alignment.topLeft,
                    child: Text(eventModel.eventName,
                        style: CustomTypography.title24W600.copyWith(fontSize: 16.sp, height: 1.5.h, fontWeight: FontWeight.w600)),
                  ),
                  SizedBox(height: MySpaces.gap2.r),
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      Expanded(
                        child: Text(eventModel.eventStartTime.getTwoDifferentTimes(second: eventModel.eventEndTime),
                            style: CustomTypography.title24W600.copyWith(fontSize: 14.sp, fontWeight: FontWeight.w500, height: 1.5)),
                      ),
                      Flexible(
                        flex: 1,
                        child: Container(
                          padding: const EdgeInsets.symmetric(vertical: 4, horizontal: 12).r,
                          decoration: BoxDecoration(
                            borderRadius: BorderRadius.circular(8).r,
                            color: AppColors.primary5,
                          ),
                          child: Text(
                            eventModel.eventType,
                            style: CustomTypography.title24W600
                                .copyWith(fontSize: 12.sp, fontWeight: FontWeight.w500, height: 1.5, color: AppColors.primary2),
                            maxLines: 3,
                            overflow: TextOverflow.ellipsis,
                          ),
                        ),
                      )
                    ],
                  ),
                  SizedBox(height: distance_15.r),

                  ///add to calendar Button
                  GayaButton(
                      height: 50.h,
                      borderColor: AppColors.divider,
                      textStyle: GayaTypography.subtitleMedium.copyWith(color: AppColors.black),
                      leadingIcon: Padding(
                        padding: const EdgeInsets.only(right: 6).r,
                        child: SvgIconWidget.calendarOutline(height: 20.r, width: 20.r),
                      ),
                      title: GayaStrings.add_calendar.tr,
                      onPressed: () => eventController.addEventToNativeCalendar(eventModel),
                      primaryColor: AppColors.divider),
                  gap,

                  ///ok Button
                  GayaButton(
                      height: 50,
                      borderColor: kTransparentColor,
                      textStyle: GayaTypography.subtitleMedium.copyWith(color: AppColors.white),
                      title: GayaStrings.ok_txt.tr,
                      onPressed: () async {
                        Navigator.pop(context);
                      },
                      primaryColor: kprimaryColor),
                ],
              ),
            );
          }),
    );
  }
}
