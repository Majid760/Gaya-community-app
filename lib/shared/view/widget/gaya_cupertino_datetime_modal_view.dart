import 'package:flutter/cupertino.dart';

typedef DatetimeCallback = void Function(DateTime dateTime);
void gayaCupertinoDateTimeModal(ctx, TextEditingController dateController,
    {required DatetimeCallback onDateTimeChanged, Color? backgroundColor, DateTime? initialDate}) {
  final currentDate = DateTime.now();
  final minDate = DateTime(currentDate.year - 13, currentDate.month, currentDate.day);
  // showCupertinoModalPopup is a built-in function of the cupertino library
  showCupertinoModalPopup(
    context: ctx,
    barrierColor: const Color.fromRGBO(255, 255, 255, 0.0),
    builder: (_) => Container(
      height: 250,
      color: backgroundColor ?? const Color.fromRGBO(255, 255, 255, 0.0),
      child: CupertinoDatePicker(
        initialDateTime: initialDate ?? minDate,
        dateOrder: DatePickerDateOrder.dmy,
        mode: CupertinoDatePickerMode.date,
        backgroundColor: const Color.fromRGBO(255, 255, 255, 0.0),
        onDateTimeChanged: (val) => onDateTimeChanged(val),
      ),
    ),
  );
}
