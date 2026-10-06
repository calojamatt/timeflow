import 'package:flutter_test/flutter_test.dart';
import 'package:timeflow/domain/weekly_template.dart';

void main() {
  WeeklyTemplate template({int weekday = DateTime.monday}) => WeeklyTemplate(
    id: 'template-1',
    name: 'Standard week',
    weekday: weekday,
    startMinute: 9 * 60,
    endMinute: 17 * 60,
  );

  test('calculates template duration', () {
    expect(template().duration, const Duration(hours: 8));
  });

  test('accepts Monday and Sunday', () {
    expect(template(weekday: DateTime.monday).weekday, DateTime.monday);
    expect(template(weekday: DateTime.sunday).weekday, DateTime.sunday);
  });

  test('rejects an invalid weekday', () {
    expect(() => template(weekday: 0), throwsArgumentError);
    expect(() => template(weekday: 8), throwsArgumentError);
  });

  test('rejects an empty name', () {
    expect(
      () => WeeklyTemplate(
        id: 'template-1',
        name: '  ',
        weekday: DateTime.monday,
        startMinute: 9 * 60,
        endMinute: 17 * 60,
      ),
      throwsArgumentError,
    );
  });

  test('rejects invalid time ranges', () {
    expect(
      () => WeeklyTemplate(
        id: 'template-1',
        name: 'Standard week',
        weekday: DateTime.monday,
        startMinute: 17 * 60,
        endMinute: 9 * 60,
      ),
      throwsArgumentError,
    );
  });
}
