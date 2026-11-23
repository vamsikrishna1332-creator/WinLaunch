import 'package:fluent_ui/fluent_ui.dart';
import 'package:flutter/material.dart' as material;
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_animate/flutter_animate.dart';
import 'package:intl/intl.dart';
import 'package:uuid/uuid.dart';
import '../../core/models/schedule_model.dart';
import '../../core/providers/app_providers.dart';
import '../../shared/components/glass_container.dart';
import '../../shared/animations/animation_presets.dart';

class ScheduleScreen extends ConsumerWidget {
  const ScheduleScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final schedules = ref.watch(scheduleProvider);
    final theme = ref.watch(themeProvider);

    return Padding(
      padding: EdgeInsets.all(theme.margin),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // Header
          Row(
            children: [
              Text('Schedule',
                  style: TextStyle(
                    color: Color(theme.textColor),
                    fontSize: 20,
                    fontWeight: FontWeight.bold,
                    fontFamily: theme.fontFamily,
                  )),
              const Spacer(),
              Text('${schedules.length}/20 schedules',
                  style: TextStyle(
                    color: Color(theme.secondaryTextColor),
                    fontSize: 12,
                  )),
              const SizedBox(width: 12),
              if (schedules.length < 20)
                FilledButton(
                  child: Row(
                    mainAxisSize: MainAxisSize.min,
                    children: const [
                      Icon(FluentIcons.add, size: 12),
                      SizedBox(width: 4),
                      Text('Add Schedule'),
                    ],
                  ),
                  onPressed: () => _showAddDialog(context, ref),
                ),
            ],
          ).fadeSlideIn(),
          const SizedBox(height: 16),

          // Schedule list
          Expanded(
            child: schedules.isEmpty
                ? Center(
                    child: Column(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        Icon(FluentIcons.calendar,
                            size: 64,
                            color: Color(theme.secondaryTextColor)
                                .withOpacity(0.3)),
                        const SizedBox(height: 16),
                        Text('No schedules yet',
                            style: TextStyle(
                              color: Color(theme.secondaryTextColor),
                              fontSize: 16,
                            )),
                        const SizedBox(height: 8),
                        Button(
                          child: const Text('Add your first schedule'),
                          onPressed: () => _showAddDialog(context, ref),
                        ),
                      ],
                    ),
                  )
                : ListView.separated(
                    itemCount: schedules.length,
                    separatorBuilder: (_, __) => const SizedBox(height: 8),
                    itemBuilder: (_, i) {
                      final s = schedules[i];
                      return _ScheduleCard(schedule: s)
                          .staggerIn(i, baseDelayMs: 40);
                    },
                  ),
          ),
        ],
      ),
    );
  }

  Future<void> _showAddDialog(BuildContext context, WidgetRef ref) async {
    final result = await showDialog<Schedule>(
      context: context,
      builder: (_) => const _ScheduleDialog(),
    );
    if (result != null) {
      await ref.read(scheduleProvider.notifier).add(result);
    }
  }
}

class _ScheduleCard extends ConsumerWidget {
  final Schedule schedule;
  const _ScheduleCard({required this.schedule});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final theme = ref.watch(themeProvider);
    final s = schedule;
    final isRunning = s.isRunning;

    return GlassContainer(
      padding: const EdgeInsets.all(16),
      child: Row(
        children: [
          // Color bar
          Container(
            width: 4,
            height: 60,
            decoration: BoxDecoration(
              color: Color(s.color),
              borderRadius: BorderRadius.circular(2),
            ),
          ),
          const SizedBox(width: 12),

          // Info
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Row(
                  children: [
                    Text(s.title,
                        style: TextStyle(
                          color: Color(theme.textColor),
                          fontSize: 15,
                          fontWeight: FontWeight.w600,
                        )),
                    const SizedBox(width: 8),
                    if (isRunning)
                      Container(
                        padding: const EdgeInsets.symmetric(
                            horizontal: 6, vertical: 2),
                        decoration: BoxDecoration(
                          color: Colors.green.withOpacity(0.2),
                          borderRadius: BorderRadius.circular(10),
                        ),
                        child: Text('RUNNING',
                            style: TextStyle(
                                color: Colors.green,
                                fontSize: 9,
                                fontWeight: FontWeight.bold)),
                      ),
                    Container(
                      padding: const EdgeInsets.symmetric(
                          horizontal: 6, vertical: 2),
                      margin: const EdgeInsets.only(left: 4),
                      decoration: BoxDecoration(
                        color: Color(s.priority.colorValue).withOpacity(0.2),
                        borderRadius: BorderRadius.circular(10),
                      ),
                      child: Text(s.priority.label,
                          style: TextStyle(
                              color: Color(s.priority.colorValue),
                              fontSize: 9,
                              fontWeight: FontWeight.bold)),
                    ),
                  ],
                ),
                if (s.description.isNotEmpty) ...[
                  const SizedBox(height: 2),
                  Text(s.description,
                      style: TextStyle(
                        color: Color(theme.secondaryTextColor),
                        fontSize: 12,
                      ),
                      maxLines: 1,
                      overflow: TextOverflow.ellipsis),
                ],
                const SizedBox(height: 4),
                Text(
                  '${DateFormat('HH:mm').format(s.startTime)} – ${DateFormat('HH:mm').format(s.endTime)}  ·  ${_formatRepeat(s)}',
                  style: TextStyle(
                    color: Color(theme.secondaryTextColor),
                    fontSize: 11,
                  ),
                ),
                if (isRunning) ...[
                  const SizedBox(height: 8),
                  ClipRRect(
                    borderRadius: BorderRadius.circular(4),
                    child: material.LinearProgressIndicator(
                      value: s.progress,
                      backgroundColor: Colors.white.withOpacity(0.1),
                      valueColor: AlwaysStoppedAnimation<Color>(Color(s.color)),
                      minHeight: 4,
                    ),
                  ),
                ],
              ],
            ),
          ),

          // Actions
          Column(
            children: [
              ToggleSwitch(
                checked: s.isActive,
                onChanged: (v) =>
                    ref.read(scheduleProvider.notifier).toggle(s.id, v),
              ),
              const SizedBox(height: 4),
              IconButton(
                icon: Icon(FluentIcons.delete,
                    size: 14, color: Color(theme.errorColor)),
                onPressed: () =>
                    ref.read(scheduleProvider.notifier).remove(s.id),
              ),
            ],
          ),
        ],
      ),
    );
  }

  String _formatRepeat(Schedule s) {
    switch (s.repeat) {
      case RepeatType.none: return 'Once';
      case RepeatType.daily: return 'Daily';
      case RepeatType.weekly: return 'Weekly';
      case RepeatType.monthly: return 'Monthly';
      case RepeatType.yearly: return 'Yearly';
    }
  }
}

class _ScheduleDialog extends ConsumerStatefulWidget {
  const _ScheduleDialog();

  @override
  ConsumerState<_ScheduleDialog> createState() => _ScheduleDialogState();
}

class _ScheduleDialogState extends ConsumerState<_ScheduleDialog> {
  final _titleCtrl = TextEditingController();
  final _descCtrl = TextEditingController();
  DateTime _start = DateTime.now();
  DateTime _end = DateTime.now().add(const Duration(hours: 1));
  RepeatType _repeat = RepeatType.none;
  Priority _priority = Priority.medium;
  int _color = 0xFF0078D4;

  @override
  void dispose() {
    _titleCtrl.dispose();
    _descCtrl.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return ContentDialog(
      title: const Text('New Schedule'),
      content: SingleChildScrollView(
        child: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const Text('Title *', style: TextStyle(fontSize: 12, fontWeight: FontWeight.w600)),
            const SizedBox(height: 6),
            TextBox(controller: _titleCtrl, placeholder: 'e.g., Morning Meeting'),
            const SizedBox(height: 12),

            const Text('Description', style: TextStyle(fontSize: 12, fontWeight: FontWeight.w600)),
            const SizedBox(height: 6),
            TextBox(controller: _descCtrl, placeholder: 'Optional description', maxLines: 2),
            const SizedBox(height: 12),

            Row(
              children: [
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      const Text('Start Time', style: TextStyle(fontSize: 12, fontWeight: FontWeight.w600)),
                      const SizedBox(height: 6),
                      DatePicker(
                        selected: _start,
                        onChanged: (d) => setState(() => _start = DateTime(
                              d.year, d.month, d.day,
                              _start.hour, _start.minute,
                            )),
                      ),
                    ],
                  ),
                ),
                const SizedBox(width: 12),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      const Text('End Time', style: TextStyle(fontSize: 12, fontWeight: FontWeight.w600)),
                      const SizedBox(height: 6),
                      DatePicker(
                        selected: _end,
                        onChanged: (d) => setState(() => _end = DateTime(
                              d.year, d.month, d.day,
                              _end.hour, _end.minute,
                            )),
                      ),
                    ],
                  ),
                ),
              ],
            ),
            const SizedBox(height: 12),

            Row(
              children: [
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      const Text('Repeat', style: TextStyle(fontSize: 12, fontWeight: FontWeight.w600)),
                      const SizedBox(height: 6),
                      ComboBox<RepeatType>(
                        value: _repeat,
                        items: RepeatType.values.map((r) => ComboBoxItem<RepeatType>(
                          value: r,
                          child: Text(r.name[0].toUpperCase() + r.name.substring(1)),
                        )).toList(),
                        onChanged: (v) => setState(() => _repeat = v!),
                      ),
                    ],
                  ),
                ),
                const SizedBox(width: 12),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      const Text('Priority', style: TextStyle(fontSize: 12, fontWeight: FontWeight.w600)),
                      const SizedBox(height: 6),
                      ComboBox<Priority>(
                        value: _priority,
                        items: Priority.values.map((p) => ComboBoxItem<Priority>(
                          value: p,
                          child: Text(p.label),
                        )).toList(),
                        onChanged: (v) => setState(() => _priority = v!),
                      ),
                    ],
                  ),
                ),
              ],
            ),
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
          onPressed: _titleCtrl.text.isEmpty
              ? null
              : () {
                  final schedule = Schedule(
                    id: const Uuid().v4(),
                    title: _titleCtrl.text.trim(),
                    description: _descCtrl.text.trim(),
                    startTime: _start,
                    endTime: _end,
                    repeat: _repeat,
                    color: _color,
                    priority: _priority,
                    createdAt: DateTime.now(),
                  );
                  Navigator.pop(context, schedule);
                },
        ),
      ],
    );
  }
}
