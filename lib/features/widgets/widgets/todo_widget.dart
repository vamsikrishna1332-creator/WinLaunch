import 'package:fluent_ui/fluent_ui.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:uuid/uuid.dart';
import '../../../core/models/note_model.dart';
import '../../../core/models/widget_config_model.dart';
import '../../../core/providers/app_providers.dart';

class TodoWidget extends ConsumerStatefulWidget {
  final WidgetConfig config;
  const TodoWidget({super.key, required this.config});

  @override
  ConsumerState<TodoWidget> createState() => _TodoWidgetState();
}

class _TodoWidgetState extends ConsumerState<TodoWidget> {
  final _ctrl = TextEditingController();
  bool _adding = false;

  @override
  void dispose() {
    _ctrl.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final theme = ref.watch(themeProvider);
    final todos = ref.watch(todoProvider);
    final notifier = ref.read(todoProvider.notifier);

    return Column(
      children: [
        // Stats
        Row(
          children: [
            Text(
              '${todos.where((t) => t.isCompleted).length}/${todos.length}',
              style: TextStyle(
                color: Color(theme.accentColor),
                fontSize: 18,
                fontWeight: FontWeight.bold,
              ),
            ),
            const SizedBox(width: 4),
            Text('done',
                style: TextStyle(
                  color: Color(theme.secondaryTextColor),
                  fontSize: 11,
                )),
            const Spacer(),
            GestureDetector(
              onTap: () => setState(() => _adding = !_adding),
              child: Icon(
                _adding ? FluentIcons.cancel : FluentIcons.add,
                size: 14,
                color: Color(theme.accentColor),
              ),
            ),
          ],
        ),
        const SizedBox(height: 6),

        // Add input
        if (_adding)
          Row(
            children: [
              Expanded(
                child: TextBox(
                  controller: _ctrl,
                  placeholder: 'New todo...',
                  autofocus: true,
                  onSubmitted: (v) => _addTodo(v, notifier),
                ),
              ),
              const SizedBox(width: 4),
              Button(
                child: const Text('Add'),
                onPressed: () => _addTodo(_ctrl.text, notifier),
              ),
            ],
          ),
        const SizedBox(height: 4),

        // List
        Expanded(
          child: ListView.builder(
            itemCount: todos.length,
            itemBuilder: (_, i) {
              final t = todos[i];
              return GestureDetector(
                onTap: () => notifier.toggle(t.id),
                child: Padding(
                  padding: const EdgeInsets.symmetric(vertical: 3),
                  child: Row(
                    children: [
                      Icon(
                        t.isCompleted
                            ? FluentIcons.checkbox_composite
                            : FluentIcons.checkbox,
                        size: 16,
                        color: t.isCompleted
                            ? Color(theme.accentColor)
                            : Color(theme.secondaryTextColor),
                      ),
                      const SizedBox(width: 8),
                      Expanded(
                        child: Text(
                          t.text,
                          style: TextStyle(
                            color: t.isCompleted
                                ? Color(theme.secondaryTextColor)
                                : Color(theme.textColor),
                            fontSize: 12,
                            decoration: t.isCompleted
                                ? TextDecoration.lineThrough
                                : null,
                          ),
                          maxLines: 2,
                          overflow: TextOverflow.ellipsis,
                        ),
                      ),
                      IconButton(
                        icon: Icon(FluentIcons.delete,
                            size: 10,
                            color: Color(theme.errorColor).withOpacity(0.5)),
                        onPressed: () => notifier.remove(t.id),
                      ),
                    ],
                  ),
                ),
              );
            },
          ),
        ),
      ],
    );
  }

  void _addTodo(String text, TodoNotifier notifier) {
    if (text.trim().isEmpty) return;
    notifier.add(TodoItem(
      id: const Uuid().v4(),
      text: text.trim(),
    ));
    _ctrl.clear();
    setState(() => _adding = false);
  }
}
