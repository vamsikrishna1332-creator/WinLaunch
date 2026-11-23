import 'package:flutter_test/flutter_test.dart';
import 'package:launchdesk/core/models/app_shortcut_model.dart';

void main() {
  test('shortcut model restores persisted boolean flags', () {
    final shortcut = AppShortcut.fromJson({
      'id': 'exhale',
      'name': 'Exhale',
      'type': 'app',
      'target': r'C:\\Apps\\Exhale.exe',
      'isFavorite': true,
      'isPinned': false,
      'createdAt': '2026-11-23T00:00:00.000',
    });

    expect(shortcut.name, 'Exhale');
    expect(shortcut.isFavorite, isTrue);
    expect(shortcut.isPinned, isFalse);
    expect(shortcut.toJson()['isFavorite'], isTrue);
  });
}
