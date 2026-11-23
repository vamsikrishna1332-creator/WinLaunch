import 'package:fluent_ui/fluent_ui.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../core/models/app_shortcut_model.dart';
import '../../core/providers/app_providers.dart';
import '../../shared/components/glass_container.dart';
import '../../shared/animations/animation_presets.dart';
import 'add_shortcut_dialog.dart';

class LauncherScreen extends ConsumerStatefulWidget {
  const LauncherScreen({super.key});

  @override
  ConsumerState<LauncherScreen> createState() => _LauncherScreenState();
}

class _LauncherScreenState extends ConsumerState<LauncherScreen> {
  final _searchCtrl = TextEditingController();
  bool _editMode = false;

  @override
  void dispose() {
    _searchCtrl.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final launcherState = ref.watch(launcherProvider);
    final settingsAsync = ref.watch(settingsProvider);
    final theme = ref.watch(themeProvider);

    return settingsAsync.when(
      loading: () => const SizedBox.shrink(),
      error: (_, __) => const SizedBox.shrink(),
      data: (settings) {
        final filtered = launcherState.filtered;

        return Padding(
          padding: EdgeInsets.all(theme.margin),
          child: Column(
            children: [
              // Toolbar
              Row(
                children: [
                  // Search
                  if (settings.enableSearch)
                    Expanded(
                      child: TextBox(
                        controller: _searchCtrl,
                        placeholder: 'Search apps, websites, files...',
                        prefix: Padding(
                          padding: const EdgeInsets.only(left: 8),
                          child: Icon(FluentIcons.search,
                              size: 14,
                              color: Color(theme.secondaryTextColor)),
                        ),
                        suffix: _searchCtrl.text.isNotEmpty
                            ? IconButton(
                                icon: const Icon(FluentIcons.clear, size: 12),
                                onPressed: () {
                                  _searchCtrl.clear();
                                  ref.read(launcherProvider.notifier).setSearch('');
                                },
                              )
                            : null,
                        onChanged: (v) =>
                            ref.read(launcherProvider.notifier).setSearch(v),
                      ),
                    )
                  else
                    const Spacer(),
                  const SizedBox(width: 8),

                  // Category filter
                  if (launcherState.categories.isNotEmpty)
                    SizedBox(
                      width: 160,
                      child: ComboBox<String?>(
                        value: launcherState.selectedCategory,
                        placeholder: const Text('All Categories'),
                        items: [
                          const ComboBoxItem<String?>(
                              value: null, child: Text('All Categories')),
                          ...launcherState.categories.map((c) => ComboBoxItem<String?>(
                              value: c, child: Text(c))),
                        ],
                        onChanged: (v) =>
                            ref.read(launcherProvider.notifier).setCategory(v),
                      ),
                    ),
                  const SizedBox(width: 8),

                  // Layout toggle
                  ToggleButton(
                    checked: settings.launcherLayout == 'grid',
                    onChanged: (v) => ref
                        .read(settingsServiceProvider)
                        .updateSetting('launcherLayout', v ? 'grid' : 'list'),
                    child: Icon(FluentIcons.grid_view_medium,
                        size: 14, color: Color(theme.textColor)),
                  ),
                  const SizedBox(width: 4),

                  // Edit mode
                  ToggleButton(
                    checked: _editMode,
                    onChanged: (v) => setState(() => _editMode = v),
                    child: Icon(FluentIcons.edit,
                        size: 14, color: Color(theme.textColor)),
                  ),
                  const SizedBox(width: 8),

                  // Add button
                  FilledButton(
                    child: Row(
                      mainAxisSize: MainAxisSize.min,
                      children: const [
                        Icon(FluentIcons.add, size: 12),
                        SizedBox(width: 4),
                        Text('Add'),
                      ],
                    ),
                    onPressed: () => _showAddDialog(context),
                  ),
                ],
              ),
              const SizedBox(height: 12),

              // Pinned section
              if (filtered.any((s) => s.isPinned)) ...[
                _SectionHeader(label: '📌 Pinned'),
                const SizedBox(height: 8),
                _ShortcutGrid(
                  shortcuts: filtered.where((s) => s.isPinned).toList(),
                  settings: settings,
                  editMode: _editMode,
                  onRemove: (id) =>
                      ref.read(launcherProvider.notifier).removeShortcut(id),
                  onLaunch: (s) =>
                      ref.read(launcherProvider.notifier).launch(s),
                  onToggleFav: (s) => ref
                      .read(launcherProvider.notifier)
                      .updateShortcut(s.copyWith(isFavorite: !s.isFavorite)),
                ),
                const SizedBox(height: 16),
              ],

              // Favorites
              if (filtered.any((s) => s.isFavorite && !s.isPinned)) ...[
                _SectionHeader(label: '⭐ Favorites'),
                const SizedBox(height: 8),
                _ShortcutGrid(
                  shortcuts: filtered
                      .where((s) => s.isFavorite && !s.isPinned)
                      .toList(),
                  settings: settings,
                  editMode: _editMode,
                  onRemove: (id) =>
                      ref.read(launcherProvider.notifier).removeShortcut(id),
                  onLaunch: (s) =>
                      ref.read(launcherProvider.notifier).launch(s),
                  onToggleFav: (s) => ref
                      .read(launcherProvider.notifier)
                      .updateShortcut(s.copyWith(isFavorite: !s.isFavorite)),
                ),
                const SizedBox(height: 16),
              ],

              // Groups
              for (final group in launcherState.groups) ...[
                _SectionHeader(
                  label: group.name,
                  color: Color(group.color),
                ),
                const SizedBox(height: 8),
                _ShortcutGrid(
                  shortcuts: filtered
                      .where((s) => s.groupId == group.id)
                      .toList(),
                  settings: settings,
                  editMode: _editMode,
                  onRemove: (id) =>
                      ref.read(launcherProvider.notifier).removeShortcut(id),
                  onLaunch: (s) =>
                      ref.read(launcherProvider.notifier).launch(s),
                  onToggleFav: (s) => ref
                      .read(launcherProvider.notifier)
                      .updateShortcut(s.copyWith(isFavorite: !s.isFavorite)),
                ),
                const SizedBox(height: 16),
              ],

              // All (ungrouped, not pinned, not fav)
              Expanded(
                child: _ShortcutGrid(
                  shortcuts: filtered
                      .where((s) =>
                          !s.isPinned &&
                          !s.isFavorite &&
                          (s.groupId == null ||
                              !launcherState.groups
                                  .any((g) => g.id == s.groupId)))
                      .toList(),
                  settings: settings,
                  editMode: _editMode,
                  onRemove: (id) =>
                      ref.read(launcherProvider.notifier).removeShortcut(id),
                  onLaunch: (s) =>
                      ref.read(launcherProvider.notifier).launch(s),
                  onToggleFav: (s) => ref
                      .read(launcherProvider.notifier)
                      .updateShortcut(s.copyWith(isFavorite: !s.isFavorite)),
                  scrollable: true,
                ),
              ),
            ],
          ),
        );
      },
    );
  }

  Future<void> _showAddDialog(BuildContext context) async {
    final result = await showDialog<AppShortcut>(
      context: context,
      builder: (_) => const AddShortcutDialog(),
    );
    if (result != null) {
      await ref.read(launcherProvider.notifier).addShortcut(result);
    }
  }
}

class _SectionHeader extends ConsumerWidget {
  final String label;
  final Color? color;
  const _SectionHeader({required this.label, this.color});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final theme = ref.watch(themeProvider);
    return Text(
      label,
      style: TextStyle(
        color: color ?? Color(theme.secondaryTextColor),
        fontSize: 12,
        fontWeight: FontWeight.w600,
        letterSpacing: 1,
      ),
    );
  }
}

class _ShortcutGrid extends ConsumerWidget {
  final List<AppShortcut> shortcuts;
  final dynamic settings;
  final bool editMode;
  final void Function(String id) onRemove;
  final void Function(AppShortcut s) onLaunch;
  final void Function(AppShortcut s) onToggleFav;
  final bool scrollable;

  const _ShortcutGrid({
    required this.shortcuts,
    required this.settings,
    required this.editMode,
    required this.onRemove,
    required this.onLaunch,
    required this.onToggleFav,
    this.scrollable = false,
  });

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    if (shortcuts.isEmpty) return const SizedBox.shrink();

    final isGrid = settings.launcherLayout == 'grid';
    final cols = settings.launcherColumns as int;
    final iconSize = (settings.launcherIconSize as double);

    if (!isGrid) {
      // List view
      final listView = ListView.separated(
        shrinkWrap: !scrollable,
        physics: scrollable ? null : const NeverScrollableScrollPhysics(),
        itemCount: shortcuts.length,
        separatorBuilder: (_, __) => const SizedBox(height: 4),
        itemBuilder: (_, i) => _ShortcutListTile(
          shortcut: shortcuts[i],
          editMode: editMode,
          onRemove: onRemove,
          onLaunch: onLaunch,
          onToggleFav: onToggleFav,
        ).staggerIn(i, baseDelayMs: 30),
      );
      return scrollable ? listView : SizedBox(child: listView);
    }

    // Grid view
    final gridView = GridView.builder(
      shrinkWrap: !scrollable,
      physics: scrollable ? null : const NeverScrollableScrollPhysics(),
      gridDelegate: SliverGridDelegateWithFixedCrossAxisCount(
        crossAxisCount: cols,
        childAspectRatio: 0.85,
        crossAxisSpacing: 8,
        mainAxisSpacing: 8,
      ),
      itemCount: shortcuts.length,
      itemBuilder: (_, i) => _ShortcutCard(
        shortcut: shortcuts[i],
        iconSize: iconSize,
        showLabel: settings.showLauncherLabels as bool,
        editMode: editMode,
        onRemove: onRemove,
        onLaunch: onLaunch,
        onToggleFav: onToggleFav,
      ).staggerIn(i, baseDelayMs: 30),
    );
    return scrollable ? gridView : SizedBox(child: gridView);
  }
}

class _ShortcutCard extends ConsumerStatefulWidget {
  final AppShortcut shortcut;
  final double iconSize;
  final bool showLabel;
  final bool editMode;
  final void Function(String) onRemove;
  final void Function(AppShortcut) onLaunch;
  final void Function(AppShortcut) onToggleFav;

  const _ShortcutCard({
    required this.shortcut,
    required this.iconSize,
    required this.showLabel,
    required this.editMode,
    required this.onRemove,
    required this.onLaunch,
    required this.onToggleFav,
  });

  @override
  ConsumerState<_ShortcutCard> createState() => _ShortcutCardState();
}

class _ShortcutCardState extends ConsumerState<_ShortcutCard> {
  bool _hovered = false;

  @override
  Widget build(BuildContext context) {
    final theme = ref.watch(themeProvider);
    final s = widget.shortcut;

    return MouseRegion(
      onEnter: (_) => setState(() => _hovered = true),
      onExit: (_) => setState(() => _hovered = false),
      cursor: SystemMouseCursors.click,
      child: GestureDetector(
        onTap: () => widget.editMode ? null : widget.onLaunch(s),
        onSecondaryTap: () => _showContextMenu(context),
        child: AnimatedContainer(
          duration: const Duration(milliseconds: 150),
          decoration: BoxDecoration(
            color: _hovered
                ? Colors.white.withOpacity(0.08)
                : Colors.white.withOpacity(0.04),
            borderRadius: BorderRadius.circular(theme.cardBorderRadius),
            border: Border.all(
              color: _hovered
                  ? Colors.white.withOpacity(0.2)
                  : Colors.white.withOpacity(0.06),
            ),
          ),
          child: Stack(
            children: [
              Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  // Icon
                  Container(
                    width: widget.iconSize,
                    height: widget.iconSize,
                    decoration: BoxDecoration(
                      color: Color(s.iconColor).withOpacity(0.15),
                      borderRadius: BorderRadius.circular(widget.iconSize * 0.22),
                    ),
                    child: Icon(
                      _iconForType(s.type),
                      color: Color(s.iconColor),
                      size: widget.iconSize * 0.5,
                    ),
                  ),
                  if (widget.showLabel) ...[
                    const SizedBox(height: 6),
                    Padding(
                      padding: const EdgeInsets.symmetric(horizontal: 4),
                      child: Text(
                        s.name,
                        style: TextStyle(
                          color: Color(theme.textColor),
                          fontSize: 11,
                          fontFamily: theme.fontFamily,
                        ),
                        maxLines: 2,
                        textAlign: TextAlign.center,
                        overflow: TextOverflow.ellipsis,
                      ),
                    ),
                  ],
                ],
              ),

              // Edit mode badge
              if (widget.editMode)
                Positioned(
                  top: 4,
                  right: 4,
                  child: GestureDetector(
                    onTap: () => widget.onRemove(s.id),
                    child: Container(
                      padding: const EdgeInsets.all(2),
                      decoration: BoxDecoration(
                        color: Colors.red.withOpacity(0.8),
                        shape: BoxShape.circle,
                      ),
                      child: const Icon(FluentIcons.cancel, size: 10, color: Colors.white),
                    ),
                  ),
                ),

              // Favorite star
              if (s.isFavorite)
                Positioned(
                   top: 4,
                   left: 4,
                   child: Icon(FluentIcons.favorite_star_fill,
                      size: 10, color: Colors.yellow),
                ),
            ],
          ),
        ),
      ),
    );
  }

  void _showContextMenu(BuildContext context) {
    final s = widget.shortcut;
    showDialog(
      context: context,
      builder: (_) => ContentDialog(
        title: Text(s.name),
        content: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            ListTile(
              leading: Icon(s.isFavorite
                  ? FluentIcons.favorite_star_fill
                  : FluentIcons.favorite_star),
              title: Text(s.isFavorite ? 'Remove from Favorites' : 'Add to Favorites'),
              onPressed: () {
                widget.onToggleFav(s);
                Navigator.pop(context);
              },
            ),
            ListTile(
              leading: const Icon(FluentIcons.delete),
              title: const Text('Remove'),
              onPressed: () {
                widget.onRemove(s.id);
                Navigator.pop(context);
              },
            ),
          ],
        ),
        actions: [
          Button(
            child: const Text('Cancel'),
            onPressed: () => Navigator.pop(context),
          ),
        ],
      ),
    );
  }

  IconData _iconForType(ShortcutType type) {
    switch (type) {
      case ShortcutType.app: return FluentIcons.app_icon_default;
      case ShortcutType.website: return FluentIcons.globe;
      case ShortcutType.folder: return FluentIcons.folder;
      case ShortcutType.file: return FluentIcons.document;
      case ShortcutType.command: return FluentIcons.command_prompt;
    }
  }
}

class _ShortcutListTile extends ConsumerWidget {
  final AppShortcut shortcut;
  final bool editMode;
  final void Function(String) onRemove;
  final void Function(AppShortcut) onLaunch;
  final void Function(AppShortcut) onToggleFav;

  const _ShortcutListTile({
    required this.shortcut,
    required this.editMode,
    required this.onRemove,
    required this.onLaunch,
    required this.onToggleFav,
  });

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final theme = ref.watch(themeProvider);
    final s = shortcut;

    return GlassContainer(
      padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 10),
      onTap: editMode ? null : () => onLaunch(s),
      child: Row(
        children: [
          Container(
            width: 36,
            height: 36,
            decoration: BoxDecoration(
              color: Color(s.iconColor).withOpacity(0.15),
              borderRadius: BorderRadius.circular(8),
            ),
            child: Icon(_iconForType(s.type),
                color: Color(s.iconColor), size: 18),
          ),
          const SizedBox(width: 12),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(s.name,
                    style: TextStyle(
                      color: Color(theme.textColor),
                      fontSize: 13,
                      fontWeight: FontWeight.w500,
                    )),
                if (s.description != null && s.description!.isNotEmpty)
                  Text(s.description!,
                      style: TextStyle(
                        color: Color(theme.secondaryTextColor),
                        fontSize: 11,
                      ),
                      maxLines: 1,
                      overflow: TextOverflow.ellipsis),
              ],
            ),
          ),
          if (s.isFavorite)
            Icon(FluentIcons.favorite_star_fill,
                size: 12, color: Colors.yellow),
          if (editMode) ...[
            const SizedBox(width: 8),
            IconButton(
              icon: Icon(FluentIcons.delete,
                  size: 14, color: Color(theme.errorColor)),
              onPressed: () => onRemove(s.id),
            ),
          ],
        ],
      ),
    );
  }

  IconData _iconForType(ShortcutType type) {
    switch (type) {
      case ShortcutType.app: return FluentIcons.app_icon_default;
      case ShortcutType.website: return FluentIcons.globe;
      case ShortcutType.folder: return FluentIcons.folder;
      case ShortcutType.file: return FluentIcons.document;
      case ShortcutType.command: return FluentIcons.command_prompt;
    }
  }
}
