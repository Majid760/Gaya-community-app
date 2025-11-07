// ignore_for_file: use_build_context_synchronously

import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:gaya/components/button.component.dart';
import 'package:gaya/components/custom_snackbars.dart';
import 'package:gaya/components/textfield.component.dart';
import 'package:gaya/shared/view/widget/gaya_back_button.dart';
import 'package:gaya/shared/view/widget/gaya_snackbar.dart';
import 'package:gaya/utils/assets_icons.dart';
import 'package:gaya/utils/methods.dart';
import 'package:gaya/utils/textstyles.dart';
import 'package:gaya/utils/theme/app_colors.dart';
import 'package:gaya/utils/theme/app_typography.dart';
import 'package:gaya/utils/vallidation.dart';
import 'package:gaya/view/community/events/widgets/event_card.dart';
import 'package:get/get.dart';

import '../../../../utils/const.dart';
import '../../../../utils/language/translation.dart';
import '../controller/event_controller.dart';
import '../widgets/calendar/calendar.dart';

class CommunityCalendarScreen extends StatelessWidget {
  final String communityId;
  final bool isEditable;

  CommunityCalendarScreen({Key? key, required this.communityId, required this.isEditable}) : super(key: key);
  final scaffoldMessengerKey = GlobalKey<ScaffoldMessengerState>();

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      key: scaffoldMessengerKey,
      appBar: AppBar(
          systemOverlayStyle: SystemUiOverlayStyle.dark,
          shape: Border(bottom: BorderSide(color: kBaseGrey.withOpacity(0.5))),
          automaticallyImplyLeading: false,
          leading: const GayaBackButton(),
          iconTheme: const IconThemeData(color: kBlackColor),
          title: Text(GayaStrings.community_calendar.tr, style: CustomTypography.bodyStyle),
          centerTitle: true,
          backgroundColor: kTransparentColor,
          elevation: 0,
          actions: isEditable
              ? [
                  IconButton(
                    icon: SvgIconWidget.plusOutline(height: 20.h, color: AppColors.primary),
                    color: kBlackColor,
                    onPressed: () => addEventBottomSheet(context),
                  ),
                ]
              : []),
      body: Padding(
        padding: const EdgeInsets.only(left: 16, right: 16).r,
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          mainAxisAlignment: MainAxisAlignment.start,
          children: [
            CalendarView(communityId: communityId),
            Text(
              GayaStrings.event.tr,
              style: CustomTypography.title24W600.copyWith(fontSize: 24.sp, fontWeight: FontWeight.w400, height: 1.5),
            ),
            SizedBox(height: 12.r),
            EventCard(communityId: communityId)
          ],
        ),
      ),
    );
  }

  ///
  void addEventBottomSheet(BuildContext context) {
    Methods.showCircularModalSheet(context, AddEventModalView(communityId: communityId));
  }
}

class AddEventModalView extends StatelessWidget {
  final String communityId;

  const AddEventModalView({Key? key, required this.communityId}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    final gap = SizedBox(height: distance_10.r);
    final gap2 = SizedBox(height: distance_5.r);

    return GetBuilder<EventController>(
        init: EventController.to(tag: communityId),
        builder: (eventController) {
          return Padding(
            padding: const EdgeInsets.only(left: 20, right: 20, bottom: 27).r,
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                gap,
                Align(alignment: Alignment.topCenter, child: Text(GayaStrings.add_event.tr, style: GayaTypography.titleMedium)),
                Form(
                    key: eventController.eventFormKey,
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(GayaStrings.event_name.tr, style: GayaTypography.subtitleRegular.copyWith(height: 1.5.h)),
                        gap2,
                        textField(
                          inputType: TextInputType.text,
                          hintText: GayaStrings.event_name_hint.tr,
                          controller: eventController.eventNameController,
                          borderColor: AppColors.secondary,
                        ),
                        gap,
                        Text(GayaStrings.event_type.tr, style: GayaTypography.subtitleRegular.copyWith(height: 1.5.h)),
                        gap2,
                        textField(
                          inputType: TextInputType.text,
                          hintText: GayaStrings.event_type_hint.tr,
                          controller: eventController.eventTypeController,
                          borderColor: AppColors.secondary,
                        ),
                      ],
                    )),
                gap,
                Text(GayaStrings.event_time.tr, style: GayaTypography.subtitleRegular.copyWith(height: 1.5.h)),

                TimePickerTabBarView(eventController: eventController),

                ///add to calendar Button
                gap,

                ///ok Button
                GayaButton(
                    height: 50.h,
                    isLoading: eventController.isLoading,
                    borderColor: kTransparentColor,
                    textStyle: GayaTypography.subtitleMedium.copyWith(color: AppColors.white),
                    title: GayaStrings.create_event.tr,
                    onPressed: () async {
                      /// check name and type
                      if (eventController.eventNameController.text.isNotEmpty && eventController.eventTypeController.text.isNotEmpty) {
                        /// show error message for start and end time
                        final errorMessage =
                            FormValidation.validateStartAndEndDate(eventController.eventStartTime, eventController.eventEndTime);

                        /// show appropriate error message for start and end time
                        if (errorMessage != null) {
                          return CustomSnackBar.showCustomErrorToast(message: errorMessage);
                        }

                        await eventController.addEvents(eSTime: eventController.eventStartTime!, eETime: eventController.eventEndTime!);
                        Navigator.pop(context);
                      } else {
                        /// show error message for name and type
                        Navigator.pop(context);

                        GayaSnackBar.show(context: context, type: GayaSnackBarType.error, text: GayaStrings.question_alert.tr);
                      }
                    },
                    primaryColor: kprimaryColor),
              ],
            ),
          );
        });
  }
}

class TimePickerTabBarView extends StatefulWidget {
  final EventController eventController;

  const TimePickerTabBarView({Key? key, required this.eventController}) : super(key: key);

  @override
  State<TimePickerTabBarView> createState() => _TimePickerTabBarViewState();
}

class _TimePickerTabBarViewState extends State<TimePickerTabBarView> with SingleTickerProviderStateMixin {
  @override
  void initState() {
    super.initState();
    widget.eventController.eventEndTime = null;
    widget.eventController.eventStartTime = null;
    widget.eventController.eventNameController.clear();
    widget.eventController.eventTypeController.clear();
    _tabController = TabController(length: 2, vsync: this);
  }

  late TabController _tabController;

  @override
  Widget build(BuildContext context) {
    return SizedBox(
        height: 250.h,
        child: Column(
          children: [
            TabBar(
              controller: _tabController,
              indicatorSize: TabBarIndicatorSize.label,
              indicatorColor: AppColors.primary,
              labelColor: AppColors.primary,
              unselectedLabelColor: AppColors.secondary,
              tabs: [
                Tab(text: GayaStrings.start_date_txt.tr),
                Tab(text: GayaStrings.endt_date_txt.tr),
              ],
            ),
            Expanded(
              child: TabBarView(controller: _tabController, children: [
                CupertinoDatePicker(
                    initialDateTime: widget.eventController.eventStartTime,
                    dateOrder: DatePickerDateOrder.dmy,
                    mode: CupertinoDatePickerMode.dateAndTime,
                    backgroundColor: const Color.fromRGBO(255, 255, 255, 0.0),
                    onDateTimeChanged: (val) {
                      widget.eventController.eventStartTime = val;
                      widget.eventController.eventEndTime = val.add(30.minutes);
                      setState(() {});
                    }),
                CupertinoDatePicker(
                    initialDateTime: widget.eventController.eventEndTime,
                    dateOrder: DatePickerDateOrder.dmy,
                    mode: CupertinoDatePickerMode.dateAndTime,
                    backgroundColor: const Color.fromRGBO(255, 255, 255, 0.0),
                    onDateTimeChanged: (val) {
                      widget.eventController.eventEndTime = val;
                    }),
              ]),
            ),
          ],
        ));
  }
}
