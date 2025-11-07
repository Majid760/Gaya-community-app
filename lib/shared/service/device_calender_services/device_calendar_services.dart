import 'package:add_2_calendar/add_2_calendar.dart';
import 'package:gaya/view/community/events/model/EventModel.dart';

class CalendarServices {
  Event buildEvent({Recurrence? recurrence, required EventModel eventModel}) {
    return Event(
      title: eventModel.eventName,
      description: eventModel.eventType,
      location: null,
      startDate: DateTime.now(),
      endDate: DateTime.now().add(const Duration(minutes: 30)),
      allDay: false,
      recurrence: recurrence,
    );
  }
}
