/// A reusable planned work block for one weekday.
///
/// Applying a template creates date-specific [PlannedBlock] records. Template
/// rows therefore remain reusable and are not tied to a particular date.
class WeeklyTemplate {
  WeeklyTemplate({
    required this.id,
    required this.name,
    required this.weekday,
    required this.startMinute,
    required this.endMinute,
    this.note,
  }) {
    if (name.trim().isEmpty) {
      throw ArgumentError.value(name, 'name', 'must not be empty');
    }
    if (weekday < DateTime.monday || weekday > DateTime.sunday) {
      throw ArgumentError.value(
        weekday,
        'weekday',
        'must be between 1 (Monday) and 7 (Sunday)',
      );
    }
    _validateMinutes(startMinute, endMinute);
  }

  final String id;
  final String name;
  final int weekday;
  final int startMinute;
  final int endMinute;
  final String? note;

  Duration get duration => Duration(minutes: endMinute - startMinute);

  static void _validateMinutes(int startMinute, int endMinute) {
    if (startMinute < 0 || startMinute > 1439) {
      throw ArgumentError.value(
        startMinute,
        'startMinute',
        'must be between 0 and 1439',
      );
    }
    if (endMinute < 1 || endMinute > 1440) {
      throw ArgumentError.value(
        endMinute,
        'endMinute',
        'must be between 1 and 1440',
      );
    }
    if (endMinute <= startMinute) {
      throw ArgumentError.value(
        endMinute,
        'endMinute',
        'must be greater than startMinute',
      );
    }
  }
}
