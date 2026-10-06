import 'package:flutter_test/flutter_test.dart';
import 'package:timeflow/domain/planned_block.dart';

void main() {
  PlannedBlock block({int start = 9 * 60, int end = 17 * 60}) => PlannedBlock(
    id: 'planned-1',
    localDay: 20_000,
    startMinute: start,
    endMinute: end,
  );

  test('calculates planned duration', () {
    expect(block().duration, const Duration(hours: 8));
  });

  test('accepts the full non-overnight day range', () {
    expect(block(start: 0, end: 1440).duration, const Duration(hours: 24));
  });

  test('rejects a start minute outside the day', () {
    expect(() => block(start: -1), throwsA(isA<ArgumentError>()));
    expect(() => block(start: 1440), throwsA(isA<ArgumentError>()));
  });

  test('rejects an end minute outside the day', () {
    expect(() => block(end: 0), throwsA(isA<ArgumentError>()));
    expect(() => block(end: 1441), throwsA(isA<ArgumentError>()));
  });

  test('rejects zero-length and overnight blocks', () {
    expect(() => block(start: 10 * 60, end: 10 * 60), throwsArgumentError);
    expect(() => block(start: 11 * 60, end: 10 * 60), throwsArgumentError);
  });

  test('preserves identity, day, and note', () {
    final planned = PlannedBlock(
      id: 'planned-2',
      localDay: 20_001,
      startMinute: 8 * 60,
      endMinute: 12 * 60,
      note: 'Office',
    );

    expect(planned.id, 'planned-2');
    expect(planned.localDay, 20_001);
    expect(planned.note, 'Office');
  });
}
