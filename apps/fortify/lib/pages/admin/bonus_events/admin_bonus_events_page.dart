import 'package:core/core.dart';
import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:provider/provider.dart';
import 'package:fortify/controllers/admin/admin_bonus_event_controller.dart';
import 'package:fortify/state/admin/admin_bonus_event_state.dart';
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
import 'package:fortify/pages/admin/bonus_events/generate_bonus_events_modal.dart';

class AdminBonusEventsPage extends StatefulWidget {
  const AdminBonusEventsPage({super.key});

  @override
  State<AdminBonusEventsPage> createState() => _AdminBonusEventsPageState();
}

class _AdminBonusEventsPageState extends State<AdminBonusEventsPage> {
  late final AdminBonusEventController _controller = Inject.get<AdminBonusEventController>();

  static const List<FilterField> _filterFields = <FilterField>[
    FilterField(
      key: 'isActive',
      label: 'Status',
      options: <FilterOption>[
        FilterOption(label: 'Active', value: true),
        FilterOption(label: 'Inactive', value: false),
      ],
    ),
  ];

  static const List<AdminColumn> _columns = <AdminColumn>[
    AdminColumn(label: 'Title'),
    AdminColumn(label: 'Multiplier', width: 100),
    AdminColumn(label: 'Starts', width: 120),
    AdminColumn(label: 'Ends', width: 120),
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
    return Consumer<AdminBonusEventState>(
      builder: (BuildContext context, AdminBonusEventState state, Widget? child) {
        final List<BonusEvent> items = _applyFilters(state);

        return Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: <Widget>[
            AdminPageHeader(
              title: 'Bonus Events',
              subtitle: 'Manage XP multiplier events',
              actions: <Widget>[
                AdminFilterButton(
                  activeFilterCount: state.activeFilters.length,
                  onPressed: () => _openFilters(context, state),
                ),
                const SizedBox(width: 8),
                AdminButton(label: 'Generate', icon: Icons.auto_awesome, onPressed: () => _openGenerateModal(context)),
                const SizedBox(width: 8),
                AdminButton(
                  label: 'Add Event',
                  icon: Icons.add,
                  onPressed: () => context.go('/admin/bonus-events/add'),
                ),
              ],
            ),
            const Divider(height: 1),
            Padding(
              padding: const EdgeInsets.fromLTRB(24, 16, 24, 8),
              child: AdminSearchField(onChanged: (String query) => _controller.search(query)),
            ),
            Expanded(
              child: AdminResponsiveList<BonusEvent>(
                items: items,
                columns: _columns,
                cellBuilder: (BonusEvent event) => _buildCells(context, event),
                cardBuilder: (BonusEvent event) => _buildCard(context, event),
                onItemTap: (BonusEvent event) => context.go('/admin/bonus-events/${event.id}'),
                idAccessor: (BonusEvent event) => event.id,
                bulkActions: (Set<String> selectedIds) => <AdminBulkAction>[
                  AdminBulkAction(
                    label: 'Activate',
                    icon: Icons.publish_outlined,
                    onPressed: () => _bulkActivate(context, selectedIds),
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

  List<BonusEvent> _applyFilters(AdminBonusEventState state) {
    List<BonusEvent> items = state.filteredItems;
    final Map<String, dynamic> filters = state.activeFilters;

    if (filters.containsKey('isActive') && filters['isActive'] != null) {
      final bool isActive = filters['isActive'] as bool;
      items = items.where((BonusEvent b) => b.isActive == isActive).toList();
    }

    items.sort((BonusEvent a, BonusEvent b) => a.startsAt.compareTo(b.startsAt));
    return items;
  }

  String _formatDate(DateTime date) {
    return '${date.year}-${date.month.toString().padLeft(2, '0')}-${date.day.toString().padLeft(2, '0')}';
  }

  List<Widget> _buildCells(BuildContext context, BonusEvent event) {
    return <Widget>[
      Text(event.title, overflow: TextOverflow.ellipsis),
      Text('${event.multiplier}x'),
      Text(_formatDate(event.startsAt)),
      Text(_formatDate(event.endsAt)),
      AdminStatusBadge(isPublished: event.isActive),
      Row(
        children: <Widget>[
          if (!event.isActive)
            IconButton(
              icon: const Icon(Icons.publish_outlined, size: 20),
              onPressed: () => _confirmActivate(context, event),
              tooltip: 'Activate',
            ),
          IconButton(
            icon: const Icon(Icons.edit_outlined, size: 20),
            onPressed: () => context.go('/admin/bonus-events/${event.id}'),
            tooltip: 'Edit',
          ),
          const SizedBox(width: 4),
          IconButton(
            icon: const Icon(Icons.delete_outline, size: 20),
            onPressed: () => _confirmDelete(context, event),
            tooltip: 'Delete',
          ),
        ],
      ),
    ];
  }

  Widget _buildCard(BuildContext context, BonusEvent event) {
    return Row(
      children: <Widget>[
        Expanded(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: <Widget>[
              Text(event.title, style: const TextStyle(fontWeight: FontWeight.w600)),
              Text(
                '${event.multiplier}x · ${_formatDate(event.startsAt)} - ${_formatDate(event.endsAt)}',
                style: const TextStyle(fontSize: 12),
              ),
            ],
          ),
        ),
        AdminStatusBadge(isPublished: event.isActive),
        const SizedBox(width: 8),
        if (!event.isActive)
          IconButton(
            icon: const Icon(Icons.publish_outlined, size: 18),
            onPressed: () => _confirmActivate(context, event),
            tooltip: 'Activate',
          ),
        IconButton(
          icon: const Icon(Icons.edit_outlined, size: 18),
          onPressed: () => context.go('/admin/bonus-events/${event.id}'),
          tooltip: 'Edit',
        ),
        IconButton(
          icon: const Icon(Icons.delete_outline, size: 18),
          onPressed: () => _confirmDelete(context, event),
          tooltip: 'Delete',
        ),
      ],
    );
  }

  Future<void> _bulkDelete(BuildContext context, Set<String> ids) async {
    final bool? confirmed = await AdminConfirmDialog.show(
      context,
      title: 'Delete ${ids.length} Bonus Events',
      message: 'Are you sure you want to delete ${ids.length} bonus events? This action cannot be undone.',
    );
    if (confirmed == true && context.mounted) {
      await _controller.bulkDelete(ids);
    }
  }

  Future<void> _bulkActivate(BuildContext context, Set<String> ids) async {
    final bool? confirmed = await AdminConfirmDialog.show(
      context,
      title: 'Activate ${ids.length} Bonus Events',
      message: 'Activate ${ids.length} bonus events? They will apply XP multipliers during their scheduled periods.',
      confirmLabel: 'Activate',
    );
    if (confirmed == true && context.mounted) {
      await _controller.bulkActivate(ids);
    }
  }

  Future<void> _confirmActivate(BuildContext context, BonusEvent event) async {
    final bool? confirmed = await AdminConfirmDialog.show(
      context,
      title: 'Activate Bonus Event',
      message: 'Activate "${event.title}"? It will apply XP multipliers to players during the scheduled period.',
      confirmLabel: 'Activate',
    );

    if (confirmed == true && context.mounted) {
      await _controller.activateEvent(event);
    }
  }

  Future<void> _confirmDelete(BuildContext context, BonusEvent event) async {
    final bool? confirmed = await AdminConfirmDialog.show(
      context,
      title: 'Delete Bonus Event',
      message: 'Are you sure you want to delete "${event.title}"? This action cannot be undone.',
    );

    if (confirmed == true && context.mounted) {
      await _controller.removeItem(event);
    }
  }

  Future<void> _openGenerateModal(BuildContext context) async {
    await GenerateBonusEventsModal.show(
      context,
      onGenerate: ({required int count, required String model, String? guidance}) =>
          _controller.generateBonusEvents(count: count, model: model, guidance: guidance),
    );
  }

  Future<void> _openFilters(BuildContext context, AdminBonusEventState state) async {
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
