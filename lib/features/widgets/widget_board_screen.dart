import 'package:fluent_ui/fluent_ui.dart';
import 'package:flutter/material.dart' as material;
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_animate/flutter_animate.dart';
import '../../core/models/widget_config_model.dart';
import '../../core/providers/app_providers.dart';
import '../../shared/components/glass_container.dart';
import 'widgets/clock_widget.dart';
import 'widgets/calendar_widget.dart';
import 'widgets/notes_widget.dart';
import 'widgets/system_widget.dart';
import 'widgets/todo_widget.dart';
import 'widgets/pomodoro_widget.dart';
import 'widgets/quote_widget.dart';

class WidgetBoardScreen extends ConsumerStatefulWidget {
  const WidgetBoardScreen({super.key});

  @override
  ConsumerState<WidgetBoardScreen> createState() => _WidgetBoardScreenState();
}

class _WidgetBoardScreenState extends ConsumerState<WidgetBoardScreen> {
  bool _editMode = false;

  @override
  Widget build(BuildContext context) {
    final widgets = ref.watch(widgetBoardProvider);
    final theme = ref.watch(themeProvider);

    return material.Scaffold(
      backgroundColor: Colors.transparent,
      body: Padding(
        padding: EdgeInsets.all(theme.margin),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // Toolbar
            Row(
              children: [
                Text('Widgets',
                    style: TextStyle(
                      color: Color(theme.textColor),
                      fontSize: 20,
                      fontWeight: FontWeight.bold,
                    )),
                const Spacer(),
                ToggleButton(
                  checked: _editMode,
                  onChanged: (v) => setState(() => _editMode = v),
                  child: Row(
                    children: [
                      Icon(FluentIcons.edit, size: 12, color: Color(theme.textColor)),
                      const SizedBox(width: 4),
                      Text(_editMode ? 'Done' : 'Edit',
                          style: TextStyle(color: Color(theme.textColor), fontSize: 12)),
                    ],
                  ),
                ),
                const SizedBox(width: 8),
                Button(
                  child: Row(
                    mainAxisSize: MainAxisSize.min,
                    children: const [
                      Icon(FluentIcons.add, size: 12),
                      SizedBox(width: 4),
                      Text('Add Widget'),
                    ],
                  ),
                  onPressed: () => _showAddWidgetSheet(context),
                ),
              ],
            )
                .animate()
                .fadeIn(duration: 400.ms)
                .slideY(begin: -0.1),
            const SizedBox(height: 16),

            // Widget board
            Expanded(
              child: widgets.isEmpty
                  ? _EmptyBoard(onAdd: () => _showAddWidgetSheet(context))
                  : _WidgetBoard(
                      widgets: widgets,
                      editMode: _editMode,
                    ),
            ),
          ],
        ),
      ),
    );
  }

  Future<void> _showAddWidgetSheet(BuildContext context) async {
    final selected = await showDialog<WidgetType>(
      context: context,
      builder: (_) => const _WidgetPickerDialog(),
    );
    if (selected != null) {
      await ref.read(widgetBoardProvider.notifier).addWidget(selected);
    }
  }
}

class _WidgetBoard extends ConsumerWidget {
  final List<WidgetConfig> widgets;
  final bool editMode;
  const _WidgetBoard({required this.widgets, required this.editMode});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    return SingleChildScrollView(
      child: Wrap(
        spacing: 16,
        runSpacing: 16,
        children: [
          for (final w in widgets)
            if (w.isVisible || editMode)
              _DraggableWidget(
                widget: w,
                editMode: editMode,
              ),
        ],
      ),
    );
  }
}

class _DraggableWidget extends ConsumerStatefulWidget {
  final WidgetConfig widget;
  final bool editMode;
  const _DraggableWidget({required this.widget, required this.editMode});

  @override
  ConsumerState<_DraggableWidget> createState() => _DraggableWidgetState();
}

class _DraggableWidgetState extends ConsumerState<_DraggableWidget> {
  late double _width;
  late double _height;

  @override
  void initState() {
    super.initState();
    _width = widget.widget.width;
    _height = widget.widget.height;
  }

  @override
  Widget build(BuildContext context) {
    final w = widget.widget;
    final theme = ref.watch(themeProvider);

    return SizedBox(
      width: _width,
      height: _height,
      child: Stack(
        children: [
          GlassContainer(
            padding: const EdgeInsets.all(12),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                // Widget header
                Row(
                  children: [
                    Text(
                      w.title.isEmpty ? w.type.label : w.title,
                      style: TextStyle(
                        color: Color(theme.secondaryTextColor),
                        fontSize: 11,
                        fontWeight: FontWeight.w600,
                        letterSpacing: 0.5,
                      ),
                    ),
                    const Spacer(),
                    if (widget.editMode)
                      GestureDetector(
                        onTap: () => ref
                            .read(widgetBoardProvider.notifier)
                            .removeWidget(w.id),
                        child: Icon(FluentIcons.cancel,
                            size: 12,
                            color: Color(theme.errorColor)),
                      ),
                  ],
                ),
                const SizedBox(height: 8),
                // Widget content
                Expanded(child: _buildWidgetContent(w)),
              ],
            ),
          ),

          // Resize handle (edit mode)
          if (widget.editMode)
            Positioned(
              bottom: 4,
              right: 4,
              child: GestureDetector(
                onPanUpdate: (d) {
                  setState(() {
                    _width = (_width + d.delta.dx).clamp(120.0, 600.0);
                    _height = (_height + d.delta.dy).clamp(80.0, 500.0);
                  });
                },
                onPanEnd: (_) {
                  ref
                      .read(widgetBoardProvider.notifier)
                      .updateSize(w.id, _width, _height);
                },
                child: Icon(
                  FluentIcons.size_legacy,
                  size: 16,
                  color: Color(theme.secondaryTextColor),
                ),
              ),
            ),
        ],
      ),
    );
  }

  Widget _buildWidgetContent(WidgetConfig w) {
    switch (w.type) {
      case WidgetType.clock:
        return ClockWidget(config: w);
      case WidgetType.calendar:
        return CalendarWidget(config: w);
      case WidgetType.notes:
        return NotesWidget(config: w);
      case WidgetType.cpu:
        return SystemWidget(config: w, metric: SystemMetric.cpu);
      case WidgetType.ram:
        return SystemWidget(config: w, metric: SystemMetric.ram);
      case WidgetType.battery:
        return SystemWidget(config: w, metric: SystemMetric.battery);
      case WidgetType.todo:
        return TodoWidget(config: w);
      case WidgetType.pomodoro:
        return PomodoroWidget(config: w);
      case WidgetType.quote:
        return QuoteWidget(config: w);
      default:
        return Center(
          child: Text(
            w.type.icon,
            style: const TextStyle(fontSize: 32),
          ),
        );
    }
  }
}

class _EmptyBoard extends StatelessWidget {
  final VoidCallback onAdd;
  const _EmptyBoard({required this.onAdd});

  @override
  Widget build(BuildContext context) {
    return Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          const Text('🧩', style: TextStyle(fontSize: 64))
              .animate()
              .scale(begin: const Offset(0.5, 0.5))
              .fadeIn(),
          const SizedBox(height: 16),
          const Text('No widgets yet',
              style: TextStyle(fontSize: 18, color: Colors.grey)),
          const SizedBox(height: 8),
          const Text('Add widgets to customize your board.',
              style: TextStyle(color: Colors.grey)),
          const SizedBox(height: 16),
          FilledButton(
            child: const Text('Add Widget'),
            onPressed: onAdd,
          ),
        ],
      ),
    );
  }
}

class _WidgetPickerDialog extends StatelessWidget {
  const _WidgetPickerDialog();

  @override
  Widget build(BuildContext context) {
    return ContentDialog(
      title: const Text('Add Widget'),
      content: SizedBox(
        width: 500,
        height: 400,
        child: GridView.builder(
          gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
            crossAxisCount: 4,
            crossAxisSpacing: 8,
            mainAxisSpacing: 8,
            childAspectRatio: 1,
          ),
          itemCount: WidgetType.values.length,
          itemBuilder: (_, i) {
            final type = WidgetType.values[i];
            return GestureDetector(
              onTap: () => Navigator.pop(context, type),
              child: Container(
                decoration: BoxDecoration(
                  color: Colors.white.withOpacity(0.05),
                  borderRadius: BorderRadius.circular(12),
                  border: Border.all(color: Colors.white.withOpacity(0.1)),
                ),
                child: Column(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    Text(type.icon, style: const TextStyle(fontSize: 24)),
                    const SizedBox(height: 4),
                    Text(type.label,
                        style: const TextStyle(fontSize: 10),
                        textAlign: TextAlign.center,
                        maxLines: 2,
                        overflow: TextOverflow.ellipsis),
                  ],
                ),
              ),
            );
          },
        ),
      ),
      actions: [
        Button(
          child: const Text('Cancel'),
          onPressed: () => Navigator.pop(context),
        ),
      ],
    );
  }
}
