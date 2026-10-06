import 'package:flutter_test/flutter_test.dart';

import '../helpers/in_memory_database.dart';

void main() {
  test(
    'an in-memory database opens and closes without touching disk',
    () async {
      final db = openInMemoryDatabase();

      await db.close();
    },
  );
}
