import 'package:add_2_calendar/add_2_calendar.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';
import 'package:gaya/model/user.model.dart';
import 'package:gaya/shared/service/device_calender_services/device_calendar_services.dart';
import 'package:gaya/view/community/controllers/base_controller.dart';
import 'package:gaya/view/community/events/model/EventModel.dart';
import 'package:get/get.dart';

import '../services/event_services.dart';

class EventController extends BaseController {
  final String communityId;

  EventController({required this.communityId});

  static EventController to({required String tag}) => Get.find(tag: tag);

  UserModel get userModel => UserModel.to;
  final eventFormKey = GlobalKey<FormState>();
  final _eventServices = EventServices();

  /// Device calendar to add events.
  final CalendarServices calendarServices = CalendarServices();

  final TextEditingController eventNameController = TextEditingController();
  final TextEditingController eventTypeController = TextEditingController();
  DateTime? eventStartTime;
  DateTime? eventEndTime;
  final ref = FirebaseFirestore.instance.collection("communities");
  List<EventModel> selectedDateEvents = [];
  List<EventModel> allEvents = [];

  @override
  onInit() {
    super.onInit();
    getAllCommunityEvents();
  }

  ///Add events to firestore, Start and End Time
  Future<void> addEvents({required DateTime eSTime, required DateTime eETime}) async {
    setLoading(true);
    await _eventServices.addEvents(communityId, userModel.uId, eventNameController.text, eventTypeController.text,
        eventStartTime: eSTime, eventEndTime: eETime);
    eventNameController.clear();
    eventTypeController.clear();
    await getAllCommunityEvents();
    setLoading(false);
  }

  ///Get events by date.
  void getCommunityEvents(DateTime selectedDate) async {
    setLoading(true);
    if (allEvents.isEmpty) {
      allEvents = [];
      final eventsData = await _eventServices.getEvents(communityId, selectedDate);
      if (eventsData != null) {
        final eventSnap = await eventsData.get();
        for (var element in eventSnap.docs) {
          allEvents.add(EventModel.fromJson(element.data()));
          selectedDateEvents = allEvents;
          update();
        }
      }
    } else {
      selectedDateEvents = [];
      for (var element in allEvents) {
        if (element.eventStartTime.day == selectedDate.day &&
            element.eventStartTime.month == selectedDate.month &&
            element.eventStartTime.year == selectedDate.year) {
          selectedDateEvents.add(element);
        }
      }
    }
    setLoading(false);
  }

  ///Get all events of the specific community.
  Future getAllCommunityEvents() async {
    allEvents = [];
    setLoading(true);
    final eventsData = await _eventServices.getAllEvents(communityId);
    if (eventsData != null) {
      final eventSnap = await eventsData.get();
      for (var element in eventSnap.docs) {
        allEvents.add(EventModel.fromJson(element.data()));
        selectedDateEvents = allEvents;
        update();
      }
    }
    setLoading(false);
  }

  Future<void> addEventToNativeCalendar(EventModel event) async {
    await Add2Calendar.addEvent2Cal(calendarServices.buildEvent(eventModel: event));
  }
}
