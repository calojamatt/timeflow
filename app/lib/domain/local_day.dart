/// Returns the device-local calendar day for [dt] as an integer index
/// (number of days since 1970-01-01).
///
/// Bucketing by local calendar day keeps "today's sessions" a cheap indexed
/// query and is independent of the timezone offset (see ADR-0005).
int localDayFrom(DateTime dt) {
  final local = dt.toLocal();
  final day = DateTime.utc(local.year, local.month, local.day);
  return day.difference(DateTime.utc(1970, 1, 1)).inDays;
}
