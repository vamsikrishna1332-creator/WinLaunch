import 'package:flutter_test/flutter_test.dart';
import 'package:launchdesk/core/models/app_shortcut_model.dart';

void main() {
  test('shortcut favorite and pinned flags survive serialization', () {
    final item = AppShortcut(
      id: 'shortcut-1',
      name: 'Example',
      type: ShortcutType.app,
      target: r'C:\\Example.exe',
      isFavorite: true,
      isPinned: true,
      createdAt: DateTime.utc(2026, 11, 26),
    );
    final decoded = AppShortcut.fromJson(item.toJson());
    expect(decoded.isFavorite, isTrue);
    expect(decoded.isPinned, isTrue);
    expect(decoded.target, item.target);
  });

  test('group expanded flag survives serialization', () {
    const group = ShortcutGroup(id: 'group-1', name: 'Games', isExpanded: false);
    expect(ShortcutGroup.fromJson(group.toJson()).isExpanded, isFalse);
  });
}
