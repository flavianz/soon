(String, String) getTimeDifferenceText(DateTime deadline) {
  final diffInSeconds = (deadline.difference(DateTime.now()).inSeconds);
  if (diffInSeconds.abs() < 3600) {
    return ("${diffInSeconds ~/ 60}", "mins");
  }
  if (diffInSeconds.abs() < 3600 * 24) {
    return ("${diffInSeconds ~/ 3600}", "hours");
  }
  if (diffInSeconds.abs() < 3600 * 24 * 7) {
    return ("${diffInSeconds ~/ (3600 * 24)}", "days");
  }
  return ("${diffInSeconds ~/ (3600 * 24 * 7)}", "weeks");
}

extension DateTimeFormatExtension on DateTime {
  String toFormattedDateString() {
    return "${day.toString().padLeft(2, "0")}.${month.toString().padLeft(2, "0")}.";
  }

  String getMonthName() {
    return switch (month) {
      2 => "Februar",
      3 => "März",
      4 => "April",
      5 => "Mai",
      6 => "Juni",
      7 => "Juli",
      8 => "August",
      9 => "September",
      10 => "Oktober",
      11 => "November",
      12 => "Dezember",
      1 || _ => "Januar",
    };
  }

  String toExtendedFormattedDateString() {
    return "$day. ${getMonthName()}";
  }

  DateTime getWeekStart() {
    return DateTime(year, month, day).subtract(Duration(days: weekday - 1));
  }

  DateTime getDayStart() {
    return DateTime(year, month, day);
  }

  DateTime getMonthStart() {
    return DateTime(year, month);
  }

  String toFormattedDateTimeString() {
    return "${day.toString().padLeft(2, "0")}.${month.toString().padLeft(2, "0")}., ${hour.toString().padLeft(2, "0")}:${minute.toString().padLeft(2, "0")}";
  }

  bool isSameDate(DateTime other) {
    return year == other.year && month == other.month && day == other.day;
  }

  DateTime addDays(int days) {
    return DateTime(year, month, day + days, hour, minute, second, millisecond);
  }

  DateTime addMonths(int months) {
    return DateTime(
      year,
      month + months,
      day,
      hour,
      minute,
      second,
      millisecond,
    );
  }

  int getMonthDayCount() {
    return addMonths(1).addDays(-1).day;
  }

  String getWeekdayAbbreviation() {
    return switch (weekday) {
      2 => "Tue",
      3 => "Wed",
      4 => "Thu",
      5 => "Fri",
      6 => "Sat",
      7 => "Sun",
      _ => "Mon",
    };
  }

  String getWeekday() {
    return switch (weekday) {
      2 => "Dienstag",
      3 => "Mittwoch",
      4 => "Donnerstag",
      5 => "Freitag",
      6 => "Samstag",
      7 => "Sonntag",
      _ => "Montag",
    };
  }

  int get weekOfYear {
    final startOfYear = DateTime(year, 1, 1);
    int weekNumber =
        ((difference(startOfYear).inDays + startOfYear.weekday) / 7).ceil();
    if (weekNumber > 52) {
      weekNumber = weekNumber % 52;
    }
    return weekNumber;
  }
}
