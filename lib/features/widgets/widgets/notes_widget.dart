import 'package:fluent_ui/fluent_ui.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:uuid/uuid.dart';
import '../../../core/models/note_model.dart';
import '../../../core/models/widget_config_model.dart';
import '../../../core/providers/app_providers.dart';

class NotesWidget extends ConsumerStatefulWidget {
  final WidgetConfig config;
  const NotesWidget({super.key, required this.config});

  @override
  ConsumerState<NotesWidget> createState() => _NotesWidgetState();
}

class _NotesWidgetState extends ConsumerState<NotesWidget> {
  final _ctrl = TextEditingController();
  bool _editing = false;

  @override
  void dispose() {
    _ctrl.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final theme = ref.watch(themeProvider);
    final notes = ref.watch(notesProvider);

    if (notes.isEmpty && !_editing) {
      return GestureDetector(
        onTap: () => setState(() => _editing = true),
        child: Center(
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Icon(FluentIcons.edit,
                  color: Color(theme.secondaryTextColor), size: 24),
              const SizedBox(height: 4),
              Text('Click to add a note',
                  style: TextStyle(
                    color: Color(theme.secondaryTextColor),
                    fontSize: 11,
                  )),
            ],
          ),
        ),
      );
    }

    if (_editing) {
      return Column(
        children: [
          Expanded(
            child: TextBox(
              controller: _ctrl,
              maxLines: null,
              expands: true,
              placeholder: 'Write your note...',
              style: TextStyle(
                color: Color(theme.textColor),
                fontSize: 12,
              ),
            ),
          ),
          const SizedBox(height: 8),
          Row(
            children: [
              Button(
                child: const Text('Cancel'),
                onPressed: () => setState(() => _editing = false),
              ),
              const SizedBox(width: 8),
              FilledButton(
                child: const Text('Save'),
                onPressed: () {
                  if (_ctrl.text.trim().isEmpty) return;
                  ref.read(notesProvider.notifier).add(Note(
                        id: const Uuid().v4(),
                        title: _ctrl.text.trim().split('\n').first,
                        content: _ctrl.text.trim(),
                        createdAt: DateTime.now(),
                        updatedAt: DateTime.now(),
                      ));
                  _ctrl.clear();
                  setState(() => _editing = false);
                },
              ),
            ],
          ),
        ],
      );
    }

    return Stack(
      children: [
        ListView.separated(
          itemCount: notes.take(5).length,
          separatorBuilder: (_, __) => const SizedBox(height: 6),
          itemBuilder: (_, i) {
            final note = notes[i];
            return Container(
              padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 6),
              decoration: BoxDecoration(
                color: Colors.white.withOpacity(0.05),
                borderRadius: BorderRadius.circular(6),
              ),
              child: Text(
                note.content.isEmpty ? note.title : note.content,
                style: TextStyle(
                  color: Color(theme.textColor),
                  fontSize: 11,
                ),
                maxLines: 3,
                overflow: TextOverflow.ellipsis,
              ),
            );
          },
        ),
        Positioned(
          bottom: 0,
          right: 0,
          child: GestureDetector(
            onTap: () => setState(() => _editing = true),
            child: Container(
              padding: const EdgeInsets.all(6),
              decoration: BoxDecoration(
                color: Color(theme.accentColor),
                shape: BoxShape.circle,
              ),
              child: const Icon(FluentIcons.add, size: 12, color: Colors.white),
            ),
          ),
        ),
      ],
    );
  }
}
