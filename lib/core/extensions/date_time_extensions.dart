extension DateTimeX on DateTime {
  bool isSameDay(DateTime other) =>
      year == other.year && month == other.month && day == other.day;

  DateTime get dateOnly => DateTime(year, month, day);

  /// Monday of the week containing this date, time stripped.
  DateTime get startOfWeek {
    final d = dateOnly;
    return d.subtract(Duration(days: d.weekday - DateTime.monday));
  }

  String get weekdayShort => const [
        'Mon',
        'Tue',
        'Wed',
        'Thu',
        'Fri',
        'Sat',
        'Sun',
      ][weekday - 1];

  String get monthShort => const [
        'Jan',
        'Feb',
        'Mar',
        'Apr',
        'May',
        'Jun',
        'Jul',
        'Aug',
        'Sep',
        'Oct',
        'Nov',
        'Dec',
      ][month - 1];

  String get friendlyDate => '$weekdayShort, $day $monthShort';
}

enum DayPart { morning, afternoon, evening, night }

extension TimeOfDayGreetingX on DateTime {
  DayPart get dayPart {
    if (hour < 5) return DayPart.night;
    if (hour < 12) return DayPart.morning;
    if (hour < 17) return DayPart.afternoon;
    if (hour < 21) return DayPart.evening;
    return DayPart.night;
  }

  String get greetingWord => switch (dayPart) {
        DayPart.morning => 'Good morning',
        DayPart.afternoon => 'Good afternoon',
        DayPart.evening => 'Good evening',
        DayPart.night => 'Good night',
      };
}
