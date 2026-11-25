import 'package:fluent_ui/fluent_ui.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:file_picker/file_picker.dart';
import 'package:uuid/uuid.dart';
import '../../core/models/app_shortcut_model.dart';

class AddShortcutDialog extends ConsumerStatefulWidget {
  const AddShortcutDialog({super.key});

  @override
  ConsumerState<AddShortcutDialog> createState() => _AddShortcutDialogState();
}

class _AddShortcutDialogState extends ConsumerState<AddShortcutDialog> {
  final _nameCtrl = TextEditingController();
  final _descCtrl = TextEditingController();
  final _targetCtrl = TextEditingController();
  final _categoryCtrl = TextEditingController();
  ShortcutType _type = ShortcutType.app;
  int _color = 0xFF0078D4;

  @override
  void dispose() {
    _nameCtrl.dispose();
    _descCtrl.dispose();
    _targetCtrl.dispose();
    _categoryCtrl.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return ContentDialog(
      title: const Text('Add Shortcut'),
      content: SingleChildScrollView(
        child: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // Type selector
            const Text('Type', style: TextStyle(fontSize: 12, fontWeight: FontWeight.w600)),
            const SizedBox(height: 6),
            ComboBox<ShortcutType>(
              value: _type,
              items: ShortcutType.values.map((t) => ComboBoxItem<ShortcutType>(
                value: t,
                child: Text(t.name.toUpperCase()),
              )).toList(),
              onChanged: (v) => setState(() => _type = v!),
            ),
            const SizedBox(height: 16),

            // Name
            const Text('Name', style: TextStyle(fontSize: 12, fontWeight: FontWeight.w600)),
            const SizedBox(height: 6),
            TextBox(controller: _nameCtrl, placeholder: 'e.g., Visual Studio Code'),
            const SizedBox(height: 12),

            // Target
            const Text('Target (Path / URL)', style: TextStyle(fontSize: 12, fontWeight: FontWeight.w600)),
            const SizedBox(height: 6),
            Row(
              children: [
                Expanded(
                  child: TextBox(
                    controller: _targetCtrl,
                    placeholder: _type == ShortcutType.website
                        ? 'https://example.com'
                        : r'C:\Path\To\App.exe',
                  ),
                ),
                if (_type != ShortcutType.website) ...[
                  const SizedBox(width: 8),
                  Button(
                    child: const Text('Browse'),
                    onPressed: () async {
                      if (_type == ShortcutType.folder) {
                        final result = await FilePicker.platform.getDirectoryPath();
                        if (result != null) _targetCtrl.text = result;
                      } else {
                        final result = await FilePicker.platform.pickFiles();
                        if (result != null) {
                          _targetCtrl.text = result.files.single.path ?? '';
                          if (_nameCtrl.text.isEmpty) {
                            _nameCtrl.text = result.files.single.name
                                .replaceAll('.exe', '')
                                .replaceAll('.lnk', '');
                          }
                        }
                      }
                      setState(() {});
                    },
                  ),
                ],
              ],
            ),
            const SizedBox(height: 12),

            // Description
            const Text('Description (optional)', style: TextStyle(fontSize: 12, fontWeight: FontWeight.w600)),
            const SizedBox(height: 6),
            TextBox(controller: _descCtrl, placeholder: 'Short description'),
            const SizedBox(height: 12),

            // Category
            const Text('Category (optional)', style: TextStyle(fontSize: 12, fontWeight: FontWeight.w600)),
            const SizedBox(height: 6),
            TextBox(controller: _categoryCtrl, placeholder: 'e.g., Development'),
          ],
        ),
      ),
      actions: [
        Button(
          child: const Text('Cancel'),
          onPressed: () => Navigator.pop(context),
        ),
        FilledButton(
          child: const Text('Add'),
          onPressed: _nameCtrl.text.isEmpty || _targetCtrl.text.isEmpty
              ? null
              : () {
                  final shortcut = AppShortcut(
                    id: const Uuid().v4(),
                    name: _nameCtrl.text.trim(),
                    description: _descCtrl.text.trim().isEmpty
                        ? null
                        : _descCtrl.text.trim(),
                    type: _type,
                    target: _targetCtrl.text.trim(),
                    iconColor: _color,
                    category: _categoryCtrl.text.trim().isEmpty
                        ? null
                        : _categoryCtrl.text.trim(),
                    createdAt: DateTime.now(),
                  );
                  Navigator.pop(context, shortcut);
                },
        ),
      ],
    );
  }
}
