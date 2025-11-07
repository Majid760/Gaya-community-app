// ignore_for_file: library_private_types_in_public_api
import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:get/get.dart';
import 'package:table_calendar/table_calendar.dart';

import '../../controller/event_controller.dart';
import 'calendar_decoration.dart';

class CalendarView extends StatefulWidget {
  final String communityId;

  const CalendarView({super.key, required this.communityId});

  @override
  _CalendarViewState createState() => _CalendarViewState();
}

class _CalendarViewState extends State<CalendarView> {
  final CalendarFormat _calendarFormat = CalendarFormat.month;
  DateTime _focusedDay = DateTime.now();
  DateTime? _selectedDay;

  List<DateTime> datesToHighlight = [];

  @override
  Widget build(BuildContext context) {
    return GetBuilder<EventController>(
        init: EventController.to(tag: widget.communityId),
        builder: (eventController) {
          for (var data in eventController.selectedDateEvents) {
            datesToHighlight.add(data.eventStartTime);
          }
          return TableCalendar(
            calendarBuilders: CalendarBuilders(
              defaultBuilder: (context, day, focusedDay) {
                for (DateTime d in datesToHighlight) {
                  if (day.day == d.day && day.month == d.month && day.year == d.year) {
                    return Padding(
                      padding: const EdgeInsets.only(bottom: 8),
                      child: Container(
                        width: 37.0.h,
                        height: 37.0.w,
                        alignment: Alignment.center,
                        decoration: CalendarDecoration.todayDecoration,
                        child: Text(
                          '${day.day}',
                          style: CalendarDecoration.todayTextStyle,
                        ),
                      ),
                    );
                  }
                }
                return null;
              },
            ),
            firstDay: DateTime.utc(2010, 10, 16),
            lastDay: DateTime.utc(2030, 3, 14),
            focusedDay: _focusedDay,
            headerStyle: const HeaderStyle(formatButtonVisible: false),
            calendarStyle: CalendarStyle(
              weekendDecoration: CalendarDecoration.defaultDecoration,
              weekendTextStyle: CalendarDecoration.defaultTextStyle,
              isTodayHighlighted: true,
              outsideDaysVisible: false,
              selectedDecoration: CalendarDecoration.selectedDecoration,
              holidayDecoration: CalendarDecoration.holidayDecoration,
              todayDecoration: CalendarDecoration.todayDecoration,
              defaultDecoration: CalendarDecoration.defaultDecoration,
              holidayTextStyle: CalendarDecoration.holidayTextStyle,
              selectedTextStyle: CalendarDecoration.selectedTextStyle,
              todayTextStyle: CalendarDecoration.todayTextStyle,
              defaultTextStyle: CalendarDecoration.defaultTextStyle,
            ),
            selectedDayPredicate: (day) => isSameDay(_selectedDay, day),
            calendarFormat: _calendarFormat,
            onDaySelected: (selectedDay, focusedDay) {
              eventController.getCommunityEvents(selectedDay);
              if (!isSameDay(_selectedDay, selectedDay)) {
                setState(() {
                  _selectedDay = selectedDay;
                  _focusedDay = focusedDay;
                });
              }
            },
            onPageChanged: (focusedDay) {
              _focusedDay = focusedDay;
            },
          );
        });
  }
}
