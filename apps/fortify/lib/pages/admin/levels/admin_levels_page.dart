import 'package:core/core.dart';
import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:provider/provider.dart';
import 'package:fortify/controllers/admin/admin_level_controller.dart';
import 'package:fortify/state/admin/admin_level_state.dart';
import 'package:fortify/widgets/admin/admin_button.dart';
import 'package:fortify/widgets/admin/admin_confirm_dialog.dart';
import 'package:fortify/widgets/admin/admin_data_table.dart';
import 'package:fortify/widgets/admin/admin_filter_button.dart';
import 'package:fortify/widgets/admin/admin_filter_modal.dart';
import 'package:fortify/widgets/admin/admin_page_header.dart';
import 'package:fortify/widgets/admin/admin_responsive_list.dart';
import 'package:fortify/config/theme/admin_colors.dart';
import 'package:fortify/widgets/admin/admin_bulk_action_bar.dart';
import 'package:fortify/widgets/admin/admin_search_field.dart';
import 'package:fortify/widgets/admin/admin_status_badge.dart';
import 'package:fortify/pages/admin/levels/generate_levels_modal.dart';

class AdminLevelsPage extends StatefulWidget {
  const AdminLevelsPage({super.key});

  @override
  State<AdminLevelsPage> createState() => _AdminLevelsPageState();
}

class _AdminLevelsPageState extends State<AdminLevelsPage> {
  late final AdminLevelController _controller = Inject.get<AdminLevelController>();

  static const List<FilterField> _filterFields = <FilterField>[
    FilterField(
      key: 'isPublished',
      label: 'Status',
      options: <FilterOption>[
        FilterOption(label: 'Published', value: true),
        FilterOption(label: 'Draft', value: false),
      ],
    ),
    FilterField(
      key: 'source',
      label: 'Source',
      options: <FilterOption>[
        FilterOption(label: 'Human', value: 'human'),
        FilterOption(label: 'LLM', value: 'llm'),
      ],
    ),
  ];

  static const List<AdminColumn> _columns = <AdminColumn>[
    AdminColumn(label: 'Level', width: 80),
    AdminColumn(label: 'Title'),
    AdminColumn(label: 'Icon', width: 80),
    AdminColumn(label: 'XP Threshold', width: 140),
    AdminColumn(label: 'Status', width: 120),
    AdminColumn(label: 'Actions', width: 140),
  ];

  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_) {
      _controller.loadItems();
    });
  }

  @override
  Widget build(BuildContext context) {
    return Consumer<AdminLevelState>(
      builder: (BuildContext context, AdminLevelState state, Widget? child) {
        final List<Level> items = _applyFilters(state);

        return Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: <Widget>[
            AdminPageHeader(
              title: 'Levels',
              subtitle: 'Manage game levels and XP thresholds',
              actions: <Widget>[
                AdminFilterButton(
                  activeFilterCount: state.activeFilters.length,
                  onPressed: () => _openFilters(context, state),
                ),
                const SizedBox(width: 8),
                AdminButton(label: 'Generate', icon: Icons.auto_awesome, onPressed: () => _openGenerateModal(context)),
                const SizedBox(width: 8),
                AdminButton(label: 'Add Level', icon: Icons.add, onPressed: () => context.go('/admin/levels/add')),
              ],
            ),
            const Divider(height: 1),
            Padding(
              padding: const EdgeInsets.fromLTRB(24, 16, 24, 8),
              child: AdminSearchField(
                onChanged: (String query) {
                  _controller.search(query);
                },
              ),
            ),
            Expanded(
              child: AdminResponsiveList<Level>(
                items: items,
                columns: _columns,
                cellBuilder: (Level level) => _buildCells(context, level, state),
                cardBuilder: (Level level) => _buildCard(context, level, state),
                onItemTap: (Level level) => context.go('/admin/levels/${level.id}'),
                idAccessor: (Level level) => level.id,
                bulkActions: (Set<String> selectedIds) => <AdminBulkAction>[
                  AdminBulkAction(
                    label: 'Publish',
                    icon: Icons.publish_outlined,
                    onPressed: () => _bulkPublish(context, selectedIds),
                  ),
                  AdminBulkAction(
                    label: 'Delete',
                    icon: Icons.delete_outline,
                    color: AdminColors.error,
                    onPressed: () => _bulkDelete(context, selectedIds),
                  ),
                ],
              ),
            ),
          ],
        );
      },
    );
  }

  List<Level> _applyFilters(AdminLevelState state) {
    List<Level> items = state.filteredItems;
    final Map<String, dynamic> filters = state.activeFilters;

    if (filters.containsKey('isPublished') && filters['isPublished'] != null) {
      final bool isPublished = filters['isPublished'] as bool;
      items = items.where((Level l) => l.isPublished == isPublished).toList();
    }

    if (filters.containsKey('source') && filters['source'] != null) {
      final String sourceValue = filters['source'] as String;
      items = items.where((Level l) => l.source.name == sourceValue).toList();
    }

    items.sort((Level a, Level b) => a.level.compareTo(b.level));
    return items;
  }

  List<Widget> _buildCells(BuildContext context, Level level, AdminLevelState state) {
    return <Widget>[
      Text(level.level.toString()),
      Text(level.title, overflow: TextOverflow.ellipsis),
      Text(level.icon, overflow: TextOverflow.ellipsis),
      Text(level.xpThreshold.toString()),
      AdminStatusBadge(isPublished: level.isPublished),
      Row(
        children: <Widget>[
          if (!level.isPublished)
            IconButton(
              icon: const Icon(Icons.publish_outlined, size: 20),
              onPressed: () => _confirmPublish(context, level),
              tooltip: 'Publish',
            ),
          IconButton(
            icon: const Icon(Icons.edit_outlined, size: 20),
            onPressed: () => context.go('/admin/levels/${level.id}'),
            tooltip: 'Edit',
          ),
          const SizedBox(width: 4),
          IconButton(
            icon: const Icon(Icons.delete_outline, size: 20),
            onPressed: () => _confirmDelete(context, level),
            tooltip: 'Delete',
          ),
        ],
      ),
    ];
  }

  Widget _buildCard(BuildContext context, Level level, AdminLevelState state) {
    return Row(
      children: <Widget>[
        Padding(
          padding: const EdgeInsets.only(right: 12),
          child: Text(level.icon, style: const TextStyle(fontSize: 24)),
        ),
        Expanded(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: <Widget>[
              Text(level.title, style: const TextStyle(fontWeight: FontWeight.w600)),
              Text('Level ${level.level} · ${level.xpThreshold} XP', style: const TextStyle(fontSize: 12)),
            ],
          ),
        ),
        AdminStatusBadge(isPublished: level.isPublished),
        const SizedBox(width: 8),
        if (!level.isPublished)
          IconButton(
            icon: const Icon(Icons.publish_outlined, size: 18),
            onPressed: () => _confirmPublish(context, level),
            tooltip: 'Publish',
          ),
        IconButton(
          icon: const Icon(Icons.edit_outlined, size: 18),
          onPressed: () => context.go('/admin/levels/${level.id}'),
          tooltip: 'Edit',
        ),
        IconButton(
          icon: const Icon(Icons.delete_outline, size: 18),
          onPressed: () => _confirmDelete(context, level),
          tooltip: 'Delete',
        ),
      ],
    );
  }

  Future<void> _confirmDelete(BuildContext context, Level level) async {
    final bool? confirmed = await AdminConfirmDialog.show(
      context,
      title: 'Delete Level',
      message: 'Are you sure you want to delete "${level.title}"? This action cannot be undone.',
    );

    if (confirmed == true && context.mounted) {
      await _controller.removeItem(level);
    }
  }

  Future<void> _openFilters(BuildContext context, AdminLevelState state) async {
    final Map<String, dynamic>? result = await AdminFilterModal.show(
      context,
      fields: _filterFields,
      currentFilters: state.activeFilters,
    );

    if (result != null) {
      _controller.applyFilters(result);
    }
  }

  Future<void> _openGenerateModal(BuildContext context) async {
    final bool? generated = await GenerateLevelsModal.show(
      context,
      onGenerate: ({required int count, required String model, String? guidance}) {
        return _controller.generateLevels(count: count, model: model, guidance: guidance);
      },
    );

    if (generated == true && context.mounted) {
      ScaffoldMessenger.of(context).showSnackBar(const SnackBar(content: Text('Levels generated successfully')));
    }
  }

  Future<void> _bulkDelete(BuildContext context, Set<String> ids) async {
    final bool? confirmed = await AdminConfirmDialog.show(
      context,
      title: 'Delete ${ids.length} Levels',
      message: 'Are you sure you want to delete ${ids.length} levels? This action cannot be undone.',
    );
    if (confirmed == true && context.mounted) {
      await _controller.bulkDelete(ids);
    }
  }

  Future<void> _bulkPublish(BuildContext context, Set<String> ids) async {
    final bool? confirmed = await AdminConfirmDialog.show(
      context,
      title: 'Publish ${ids.length} Levels',
      message: 'Publish ${ids.length} levels? They will become visible to players.',
      confirmLabel: 'Publish',
    );
    if (confirmed == true && context.mounted) {
      await _controller.bulkPublish(ids);
    }
  }

  Future<void> _confirmPublish(BuildContext context, Level level) async {
    final bool? confirmed = await AdminConfirmDialog.show(
      context,
      title: 'Publish Level',
      message: 'Publish "${level.title}"? It will become visible to players.',
      confirmLabel: 'Publish',
    );

    if (confirmed == true && context.mounted) {
      await _controller.publishItem(level);
    }
  }
}
