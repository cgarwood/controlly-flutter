import 'package:flutter/material.dart';

String enumValueToString(var e) {
  return e.toString().split('.').last;
}

T enumValueFromString<T>(String s, List<T> values) =>
    values.firstWhere((v) => s.toLowerCase() == enumValueToString(v).toLowerCase());

String basename(String p) {
  // if (p == null) return '';
  return p.split('/').last;
}

int hms2secs(String hms) {
  var a = hms.split(":").map((e) => int.tryParse(e) ?? 0).toList(); // split it at the colons
  var seconds = a[0] * 60 * 60 + a[1] * 60 + a[2];
  return seconds;
}

TimeOfDay timestring2tod(String timestring) {
  var pattern = RegExp(r'\s*(\d+):(\d+)\s*([AP]M)');
  var match = pattern.firstMatch(timestring);
  if (match == null) return const TimeOfDay(hour: 0, minute: 0);
  var hours = int.parse(match.group(1)!);
  var minutes = int.parse(match.group(2)!);
  var ampm = match.group(3);
  if (ampm == "PM") hours += 12;
  return TimeOfDay(hour: hours, minute: minutes);
}

int timestring2secs(String timestring) {
  var tod = timestring2tod(timestring);
  return (tod.hour * 60 + tod.minute) * 60;
}

String tod2timestring(TimeOfDay tod) {
  // if (tod == null) return '12:00 am';
  var hour = tod.hourOfPeriod;
  if (hour == 0) hour = 12;
  var ampm = tod.period == DayPeriod.am ? 'am' : 'pm';
  var minute = tod.minute.toString().padLeft(2, '0');
  return '$hour:$minute $ampm';
}

String computeStateName(entity) {
  if (entity['attributes']['friendly_name'] == null) {
    return entity['entity_id'].split('.')[1].replaceAll('_', ' ');
  }
  return entity['attributes']['friendly_name'];
}
