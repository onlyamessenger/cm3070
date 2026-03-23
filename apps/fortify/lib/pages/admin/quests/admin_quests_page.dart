import 'package:core/core.dart';
import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:provider/provider.dart';
import 'package:fortify/controllers/admin/admin_quest_controller.dart';
import 'package:fortify/state/admin/admin_quest_state.dart';
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
import 'package:fortify/pages/admin/quests/generate_quests_modal.dart';

class AdminQuestsPage extends StatefulWidget {
  const AdminQuestsPage({super.key});

  @override
  State<AdminQuestsPage> createState() => _AdminQuestsPageState();
}

class _AdminQuestsPageState extends State<AdminQuestsPage> {
  late final AdminQuestController _controller = Inject.get<AdminQuestController>();

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
    FilterField(
      key: 'difficulty',
      label: 'Difficulty',
      options: <FilterOption>[
        FilterOption(label: 'Beginner', value: 'beginner'),
        FilterOption(label: 'Intermediate', value: 'intermediate'),
        FilterOption(label: 'Advanced', value: 'advanced'),
      ],
    ),
    FilterField(
      key: 'disasterType',
      label: 'Disaster Type',
      options: <FilterOption>[
        FilterOption(label: 'Flood', value: 'flood'),
        FilterOption(label: 'Bushfire', value: 'bushfire'),
        FilterOption(label: 'Earthquake', value: 'earthquake'),
        FilterOption(label: 'Cyclone', value: 'cyclone'),
        FilterOption(label: 'Storm', value: 'storm'),
      ],
    ),
  ];

  static const List<AdminColumn> _columns = <AdminColumn>[
    AdminColumn(label: 'Title'),
    AdminColumn(label: 'Days', width: 80),
    AdminColumn(label: 'Difficulty', width: 120),
    AdminColumn(label: 'Disaster', width: 120),
    AdminColumn(label: 'Region', width: 100),
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
    return Consumer<AdminQuestState>(
      builder: (BuildContext context, AdminQuestState state, Widget? child) {
        final List<Quest> items = _applyFilters(state);

        return Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: <Widget>[
            AdminPageHeader(
              title: 'Quests',
              subtitle: 'Manage quest content',
              actions: <Widget>[
                AdminFilterButton(
                  activeFilterCount: state.activeFilters.length,
                  onPressed: () => _openFilters(context, state),
                ),
                const SizedBox(width: 8),
                AdminButton(label: 'Generate', icon: Icons.auto_awesome, onPressed: () => _openGenerateModal(context)),
                const SizedBox(width: 8),
                AdminButton(label: 'Add Quest', icon: Icons.add, onPressed: () => context.go('/admin/quests/add')),
              ],
            ),
            const Divider(height: 1),
            Padding(
              padding: const EdgeInsets.fromLTRB(24, 16, 24, 8),
              child: AdminSearchField(onChanged: (String query) => _controller.search(query)),
            ),
            Expanded(
              child: AdminResponsiveList<Quest>(
                items: items,
                columns: _columns,
                cellBuilder: (Quest quest) => _buildCells(context, quest),
                cardBuilder: (Quest quest) => _buildCard(context, quest),
                onItemTap: (Quest quest) => context.go('/admin/quests/${quest.id}'),
                idAccessor: (Quest quest) => quest.id,
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

  List<Quest> _applyFilters(AdminQuestState state) {
    List<Quest> items = state.filteredItems;
    final Map<String, dynamic> filters = state.activeFilters;

    if (filters.containsKey('isPublished') && filters['isPublished'] != null) {
      final bool isPublished = filters['isPublished'] as bool;
      items = items.where((Quest q) => q.isPublished == isPublished).toList();
    }
    if (filters.containsKey('source') && filters['source'] != null) {
      final String sourceValue = filters['source'] as String;
      items = items.where((Quest q) => q.source.name == sourceValue).toList();
    }
    if (filters.containsKey('difficulty') && filters['difficulty'] != null) {
      final String difficultyValue = filters['difficulty'] as String;
      items = items.where((Quest q) => q.difficulty.name == difficultyValue).toList();
    }
    if (filters.containsKey('disasterType') && filters['disasterType'] != null) {
      final String disasterValue = filters['disasterType'] as String;
      items = items.where((Quest q) => q.disasterType.name == disasterValue).toList();
    }

    return items;
  }

  List<Widget> _buildCells(BuildContext context, Quest quest) {
    return <Widget>[
      Text(quest.title, overflow: TextOverflow.ellipsis),
      Text(quest.totalDays.toString()),
      Text(quest.difficulty.displayName),
      Text(quest.disasterType.displayName),
      Text(quest.region ?? '-'),
      AdminStatusBadge(isPublished: quest.isPublished),
      Row(
        children: <Widget>[
          if (!quest.isPublished)
            IconButton(
              icon: const Icon(Icons.publish_outlined, size: 20),
              onPressed: () => _confirmPublish(context, quest),
              tooltip: 'Publish',
            ),
          IconButton(
            icon: const Icon(Icons.edit_outlined, size: 20),
            onPressed: () => context.go('/admin/quests/${quest.id}'),
            tooltip: 'Edit',
          ),
          const SizedBox(width: 4),
          IconButton(
            icon: const Icon(Icons.delete_outline, size: 20),
            onPressed: () => _confirmDelete(context, quest),
            tooltip: 'Delete',
          ),
        ],
      ),
    ];
  }

  Widget _buildCard(BuildContext context, Quest quest) {
    return Row(
      children: <Widget>[
        Expanded(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: <Widget>[
              Text(quest.title, style: const TextStyle(fontWeight: FontWeight.w600)),
              Text(
                '${quest.totalDays} days · ${quest.difficulty.displayName} · ${quest.disasterType.displayName}',
                style: const TextStyle(fontSize: 12),
              ),
            ],
          ),
        ),
        AdminStatusBadge(isPublished: quest.isPublished),
        const SizedBox(width: 8),
        if (!quest.isPublished)
          IconButton(
            icon: const Icon(Icons.publish_outlined, size: 18),
            onPressed: () => _confirmPublish(context, quest),
            tooltip: 'Publish',
          ),
        IconButton(
          icon: const Icon(Icons.edit_outlined, size: 18),
          onPressed: () => context.go('/admin/quests/${quest.id}'),
          tooltip: 'Edit',
        ),
        IconButton(
          icon: const Icon(Icons.delete_outline, size: 18),
          onPressed: () => _confirmDelete(context, quest),
          tooltip: 'Delete',
        ),
      ],
    );
  }

  Future<void> _bulkDelete(BuildContext context, Set<String> ids) async {
    final bool? confirmed = await AdminConfirmDialog.show(
      context,
      title: 'Delete ${ids.length} Quests',
      message: 'Are you sure you want to delete ${ids.length} quests? This action cannot be undone.',
    );
    if (confirmed == true && context.mounted) {
      await _controller.bulkDelete(ids);
    }
  }

  Future<void> _bulkPublish(BuildContext context, Set<String> ids) async {
    final bool? confirmed = await AdminConfirmDialog.show(
      context,
      title: 'Publish ${ids.length} Quests',
      message: 'Publish ${ids.length} quests? They will become visible to players.',
      confirmLabel: 'Publish',
    );
    if (confirmed == true && context.mounted) {
      await _controller.bulkPublish(ids);
    }
  }

  Future<void> _confirmDelete(BuildContext context, Quest quest) async {
    final bool? confirmed = await AdminConfirmDialog.show(
      context,
      title: 'Delete Quest',
      message: 'Are you sure you want to delete "${quest.title}"? This action cannot be undone.',
    );

    if (confirmed == true && context.mounted) {
      await _controller.removeItem(quest);
    }
  }

  Future<void> _confirmPublish(BuildContext context, Quest quest) async {
    final bool? confirmed = await AdminConfirmDialog.show(
      context,
      title: 'Publish Quest',
      message: 'Publish "${quest.title}"? It will become visible to players.',
      confirmLabel: 'Publish',
    );

    if (confirmed == true && context.mounted) {
      await _controller.publishItem(quest);
    }
  }

  Future<void> _openGenerateModal(BuildContext context) async {
    await GenerateQuestsModal.show(
      context,
      onGenerate:
          ({
            required int count,
            required String model,
            required String difficulty,
            required String disasterType,
            required String totalDays,
            required int maxDepth,
            required int maxBranches,
            String? guidance,
          }) => _controller.generateQuests(
            count: count,
            model: model,
            difficulty: difficulty,
            disasterType: disasterType,
            totalDays: totalDays,
            maxDepth: maxDepth,
            maxBranches: maxBranches,
            guidance: guidance,
          ),
    );
  }

  Future<void> _openFilters(BuildContext context, AdminQuestState state) async {
    final Map<String, dynamic>? result = await AdminFilterModal.show(
      context,
      fields: _filterFields,
      currentFilters: state.activeFilters,
    );

    if (result != null) {
      _controller.applyFilters(result);
    }
  }
}
