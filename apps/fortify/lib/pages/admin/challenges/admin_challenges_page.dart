import 'package:core/core.dart';
import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:provider/provider.dart';
import 'package:fortify/controllers/admin/admin_challenge_controller.dart';
import 'package:fortify/state/admin/admin_challenge_state.dart';
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
import 'package:fortify/controllers/admin/admin_quest_controller.dart';
import 'package:fortify/state/admin/admin_quest_state.dart';
import 'package:fortify/pages/admin/challenges/generate_challenges_modal.dart';

class AdminChallengesPage extends StatefulWidget {
  const AdminChallengesPage({super.key});

  @override
  State<AdminChallengesPage> createState() => _AdminChallengesPageState();
}

class _AdminChallengesPageState extends State<AdminChallengesPage> {
  late final AdminChallengeController _controller = Inject.get<AdminChallengeController>();
  late final AdminQuestController _questController = Inject.get<AdminQuestController>();

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
      key: 'type',
      label: 'Type',
      options: <FilterOption>[
        FilterOption(label: 'Quiz', value: 'quiz'),
        FilterOption(label: 'Checklist', value: 'checklist'),
        FilterOption(label: 'Timed', value: 'timed'),
        FilterOption(label: 'Decision', value: 'decision'),
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
    AdminColumn(label: 'Type', width: 100),
    AdminColumn(label: 'Difficulty', width: 120),
    AdminColumn(label: 'Disaster', width: 120),
    AdminColumn(label: 'XP', width: 80),
    AdminColumn(label: 'Status', width: 120),
    AdminColumn(label: 'Actions', width: 140),
  ];

  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_) {
      _controller.loadItems();
      _questController.loadItems();
    });
  }

  @override
  Widget build(BuildContext context) {
    return Consumer<AdminChallengeState>(
      builder: (BuildContext context, AdminChallengeState state, Widget? child) {
        final List<Challenge> items = _applyFilters(state);

        return Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: <Widget>[
            AdminPageHeader(
              title: 'Challenges',
              subtitle: 'Manage challenge content',
              actions: <Widget>[
                AdminFilterButton(
                  activeFilterCount: state.activeFilters.length,
                  onPressed: () => _openFilters(context, state),
                ),
                const SizedBox(width: 8),
                AdminButton(label: 'Generate', icon: Icons.auto_awesome, onPressed: () => _openGenerateModal(context)),
                const SizedBox(width: 8),
                AdminButton(
                  label: 'Add Challenge',
                  icon: Icons.add,
                  onPressed: () => context.go('/admin/challenges/add'),
                ),
              ],
            ),
            const Divider(height: 1),
            Padding(
              padding: const EdgeInsets.fromLTRB(24, 16, 24, 8),
              child: AdminSearchField(onChanged: (String query) => _controller.search(query)),
            ),
            Expanded(
              child: AdminResponsiveList<Challenge>(
                items: items,
                columns: _columns,
                cellBuilder: (Challenge challenge) => _buildCells(context, challenge),
                cardBuilder: (Challenge challenge) => _buildCard(context, challenge),
                onItemTap: (Challenge challenge) => context.go('/admin/challenges/${challenge.id}'),
                idAccessor: (Challenge challenge) => challenge.id,
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

  List<Challenge> _applyFilters(AdminChallengeState state) {
    List<Challenge> items = state.filteredItems;
    final Map<String, dynamic> filters = state.activeFilters;

    if (filters.containsKey('isPublished') && filters['isPublished'] != null) {
      final bool isPublished = filters['isPublished'] as bool;
      items = items.where((Challenge c) => c.isPublished == isPublished).toList();
    }
    if (filters.containsKey('source') && filters['source'] != null) {
      final String sourceValue = filters['source'] as String;
      items = items.where((Challenge c) => c.source.name == sourceValue).toList();
    }
    if (filters.containsKey('type') && filters['type'] != null) {
      final String typeValue = filters['type'] as String;
      items = items.where((Challenge c) => c.type.name == typeValue).toList();
    }
    if (filters.containsKey('difficulty') && filters['difficulty'] != null) {
      final String difficultyValue = filters['difficulty'] as String;
      items = items.where((Challenge c) => c.difficulty.name == difficultyValue).toList();
    }
    if (filters.containsKey('disasterType') && filters['disasterType'] != null) {
      final String disasterValue = filters['disasterType'] as String;
      items = items.where((Challenge c) => c.disasterType.name == disasterValue).toList();
    }

    return items;
  }

  List<Widget> _buildCells(BuildContext context, Challenge challenge) {
    return <Widget>[
      Text(challenge.title, overflow: TextOverflow.ellipsis),
      Text(challenge.type.displayName),
      Text(challenge.difficulty.displayName),
      Text(challenge.disasterType.displayName),
      Text(challenge.xpReward.toString()),
      AdminStatusBadge(isPublished: challenge.isPublished),
      Row(
        children: <Widget>[
          if (!challenge.isPublished)
            IconButton(
              icon: const Icon(Icons.publish_outlined, size: 20),
              onPressed: () => _confirmPublish(context, challenge),
              tooltip: 'Publish',
            ),
          IconButton(
            icon: const Icon(Icons.edit_outlined, size: 20),
            onPressed: () => context.go('/admin/challenges/${challenge.id}'),
            tooltip: 'Edit',
          ),
          const SizedBox(width: 4),
          IconButton(
            icon: const Icon(Icons.delete_outline, size: 20),
            onPressed: () => _confirmDelete(context, challenge),
            tooltip: 'Delete',
          ),
        ],
      ),
    ];
  }

  Widget _buildCard(BuildContext context, Challenge challenge) {
    return Row(
      children: <Widget>[
        Expanded(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: <Widget>[
              Text(challenge.title, style: const TextStyle(fontWeight: FontWeight.w600)),
              Text(
                '${challenge.type.displayName} · ${challenge.difficulty.displayName} · ${challenge.xpReward} XP',
                style: const TextStyle(fontSize: 12),
              ),
            ],
          ),
        ),
        AdminStatusBadge(isPublished: challenge.isPublished),
        const SizedBox(width: 8),
        if (!challenge.isPublished)
          IconButton(
            icon: const Icon(Icons.publish_outlined, size: 18),
            onPressed: () => _confirmPublish(context, challenge),
            tooltip: 'Publish',
          ),
        IconButton(
          icon: const Icon(Icons.edit_outlined, size: 18),
          onPressed: () => context.go('/admin/challenges/${challenge.id}'),
          tooltip: 'Edit',
        ),
        IconButton(
          icon: const Icon(Icons.delete_outline, size: 18),
          onPressed: () => _confirmDelete(context, challenge),
          tooltip: 'Delete',
        ),
      ],
    );
  }

  Future<void> _bulkDelete(BuildContext context, Set<String> ids) async {
    final bool? confirmed = await AdminConfirmDialog.show(
      context,
      title: 'Delete ${ids.length} Challenges',
      message: 'Are you sure you want to delete ${ids.length} challenges? This action cannot be undone.',
    );
    if (confirmed == true && context.mounted) {
      await _controller.bulkDelete(ids);
    }
  }

  Future<void> _bulkPublish(BuildContext context, Set<String> ids) async {
    final bool? confirmed = await AdminConfirmDialog.show(
      context,
      title: 'Publish ${ids.length} Challenges',
      message: 'Publish ${ids.length} challenges? They will become visible to players.',
      confirmLabel: 'Publish',
    );
    if (confirmed == true && context.mounted) {
      await _controller.bulkPublish(ids);
    }
  }

  Future<void> _confirmDelete(BuildContext context, Challenge challenge) async {
    final bool? confirmed = await AdminConfirmDialog.show(
      context,
      title: 'Delete Challenge',
      message: 'Are you sure you want to delete "${challenge.title}"? This action cannot be undone.',
    );

    if (confirmed == true && context.mounted) {
      await _controller.removeItem(challenge);
    }
  }

  Future<void> _confirmPublish(BuildContext context, Challenge challenge) async {
    final bool? confirmed = await AdminConfirmDialog.show(
      context,
      title: 'Publish Challenge',
      message: 'Publish "${challenge.title}"? It will become visible to players.',
      confirmLabel: 'Publish',
    );

    if (confirmed == true && context.mounted) {
      await _controller.publishItem(challenge);
    }
  }

  Future<void> _openGenerateModal(BuildContext context) async {
    final AdminQuestState questState = Inject.get<AdminQuestState>();
    await GenerateChallengesModal.show(
      context,
      availableQuests: questState.items,
      onGenerate:
          ({
            required int count,
            required int questionsPerChallenge,
            required String model,
            required List<String> challengeTypes,
            required String difficulty,
            required String disasterType,
            List<String>? questIds,
            String? guidance,
          }) => _controller.generateChallenges(
            count: count,
            questionsPerChallenge: questionsPerChallenge,
            model: model,
            challengeTypes: challengeTypes,
            difficulty: difficulty,
            disasterType: disasterType,
            questIds: questIds,
            guidance: guidance,
          ),
    );
  }

  Future<void> _openFilters(BuildContext context, AdminChallengeState state) async {
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
