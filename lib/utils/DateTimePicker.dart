import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';

class DateTimePicker {
  Future<DateTime?> selectDate(
    BuildContext context,
    {
      DateTime? initialDate
    }
  ) async {
    return await showDatePicker(
      context: context,
      initialDate: initialDate ?? DateTime.now(),
      firstDate: DateTime(1950),
      lastDate: DateTime(2100)
    );
  }

  Future<TimeOfDay?> selectTime(
    BuildContext context,
    {
      TimeOfDay? initialTime
    }
  ) async {
    return await showTimePicker(
      context: context,
      initialTime: initialTime ?? TimeOfDay.now()
    );
  }

  Future<DateTime?> selectDateTime(
    BuildContext context,
    {
      DateTime? initialDate
    }
  ) async {
    final DateTime? date = await selectDate(context, initialDate: initialDate);
    if (date == null) return null;

    if (!context.mounted) return date;
    final TimeOfDay? time = await selectTime(context, initialTime: TimeOfDay.fromDateTime(initialDate ?? DateTime.now()));
    if (time == null) return date;

    return DateTime(date.year, date.month, date.day, time.hour, time.minute);
  }
}