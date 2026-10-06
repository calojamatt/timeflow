/// A planned period of work assigned to one device-local calendar day.
///
/// Planned time is intentionally modelled with minutes from midnight rather
/// than UTC timestamps. A plan describes a local schedule; an actual
/// [WorkSession] records an absolute instant.
class PlannedBlock {
  PlannedBlock({
    required this.id,
    required this.localDay,
    required this.startMinute,
    required this.endMinute,
    this.note,
  }) {
    _validateMinutes(startMinute, endMinute);
  }

  final String id;
  final int localDay;
  final int startMinute;
  final int endMinute;
  final String? note;

  /// The planned duration of this block.
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
