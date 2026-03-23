import 'package:core/core.dart';
import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:provider/provider.dart';
import 'package:fortify/controllers/admin/admin_kit_item_controller.dart';
import 'package:fortify/state/admin/admin_kit_item_state.dart';
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
import 'package:fortify/pages/admin/kit_items/generate_kit_items_modal.dart';

class AdminKitItemsPage extends StatefulWidget {
  const AdminKitItemsPage({super.key});

  @override
  State<AdminKitItemsPage> createState() => _AdminKitItemsPageState();
}

class _AdminKitItemsPageState extends State<AdminKitItemsPage> {
  late final AdminKitItemController _controller = Inject.get<AdminKitItemController>();

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
    AdminColumn(label: 'Item Name'),
    AdminColumn(label: 'Sort Order', width: 120),
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
    return Consumer<AdminKitItemState>(
      builder: (BuildContext context, AdminKitItemState state, Widget? child) {
        final List<KitItem> items = _applyFilters(state);

        return Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: <Widget>[
            AdminPageHeader(
              title: 'Kit Items',
              subtitle: 'Manage emergency kit item templates',
              actions: <Widget>[
                AdminFilterButton(
                  activeFilterCount: state.activeFilters.length,
                  onPressed: () => _openFilters(context, state),
                ),
                const SizedBox(width: 8),
                AdminButton(label: 'Generate', icon: Icons.auto_awesome, onPressed: () => _openGenerateModal(context)),
                const SizedBox(width: 8),
                AdminButton(
                  label: 'Add Kit Item',
                  icon: Icons.add,
                  onPressed: () => context.go('/admin/kit-items/add'),
                ),
              ],
            ),
            const Divider(height: 1),
            Padding(
              padding: const EdgeInsets.fromLTRB(24, 16, 24, 8),
              child: AdminSearchField(onChanged: (String query) => _controller.search(query)),
            ),
            Expanded(
              child: AdminResponsiveList<KitItem>(
                items: items,
                columns: _columns,
                cellBuilder: (KitItem kitItem) => _buildCells(context, kitItem),
                cardBuilder: (KitItem kitItem) => _buildCard(context, kitItem),
                onItemTap: (KitItem kitItem) => context.go('/admin/kit-items/${kitItem.id}'),
                idAccessor: (KitItem kitItem) => kitItem.id,
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

  List<KitItem> _applyFilters(AdminKitItemState state) {
    List<KitItem> items = state.filteredItems;
    final Map<String, dynamic> filters = state.activeFilters;

    if (filters.containsKey('isPublished') && filters['isPublished'] != null) {
      final bool isPublished = filters['isPublished'] as bool;
      items = items.where((KitItem k) => k.isPublished == isPublished).toList();
    }
    if (filters.containsKey('source') && filters['source'] != null) {
      final String sourceValue = filters['source'] as String;
      items = items.where((KitItem k) => k.source.name == sourceValue).toList();
    }

    items.sort((KitItem a, KitItem b) => a.sortOrder.compareTo(b.sortOrder));
    return items;
  }

  List<Widget> _buildCells(BuildContext context, KitItem kitItem) {
    return <Widget>[
      Text(kitItem.itemName, overflow: TextOverflow.ellipsis),
      Text(kitItem.sortOrder.toString()),
      AdminStatusBadge(isPublished: kitItem.isPublished),
      Row(
        children: <Widget>[
          if (!kitItem.isPublished)
            IconButton(
              icon: const Icon(Icons.publish_outlined, size: 20),
              onPressed: () => _confirmPublish(context, kitItem),
              tooltip: 'Publish',
            ),
          IconButton(
            icon: const Icon(Icons.edit_outlined, size: 20),
            onPressed: () => context.go('/admin/kit-items/${kitItem.id}'),
            tooltip: 'Edit',
          ),
          const SizedBox(width: 4),
          IconButton(
            icon: const Icon(Icons.delete_outline, size: 20),
            onPressed: () => _confirmDelete(context, kitItem),
            tooltip: 'Delete',
          ),
        ],
      ),
    ];
  }

  Widget _buildCard(BuildContext context, KitItem kitItem) {
    return Row(
      children: <Widget>[
        Expanded(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: <Widget>[
              Text(kitItem.itemName, style: const TextStyle(fontWeight: FontWeight.w600)),
              Text('Sort order: ${kitItem.sortOrder}', style: const TextStyle(fontSize: 12)),
            ],
          ),
        ),
        AdminStatusBadge(isPublished: kitItem.isPublished),
        const SizedBox(width: 8),
        if (!kitItem.isPublished)
          IconButton(
            icon: const Icon(Icons.publish_outlined, size: 18),
            onPressed: () => _confirmPublish(context, kitItem),
            tooltip: 'Publish',
          ),
        IconButton(
          icon: const Icon(Icons.edit_outlined, size: 18),
          onPressed: () => context.go('/admin/kit-items/${kitItem.id}'),
          tooltip: 'Edit',
        ),
        IconButton(
          icon: const Icon(Icons.delete_outline, size: 18),
          onPressed: () => _confirmDelete(context, kitItem),
          tooltip: 'Delete',
        ),
      ],
    );
  }

  Future<void> _bulkDelete(BuildContext context, Set<String> ids) async {
    final bool? confirmed = await AdminConfirmDialog.show(
      context,
      title: 'Delete ${ids.length} Kit Items',
      message: 'Are you sure you want to delete ${ids.length} kit items? This action cannot be undone.',
    );
    if (confirmed == true && context.mounted) {
      await _controller.bulkDelete(ids);
    }
  }

  Future<void> _bulkPublish(BuildContext context, Set<String> ids) async {
    final bool? confirmed = await AdminConfirmDialog.show(
      context,
      title: 'Publish ${ids.length} Kit Items',
      message: 'Publish ${ids.length} kit items? They will become visible to players.',
      confirmLabel: 'Publish',
    );
    if (confirmed == true && context.mounted) {
      await _controller.bulkPublish(ids);
    }
  }

  Future<void> _confirmDelete(BuildContext context, KitItem kitItem) async {
    final bool? confirmed = await AdminConfirmDialog.show(
      context,
      title: 'Delete Kit Item',
      message: 'Are you sure you want to delete "${kitItem.itemName}"? This action cannot be undone.',
    );

    if (confirmed == true && context.mounted) {
      await _controller.removeItem(kitItem);
    }
  }

  Future<void> _confirmPublish(BuildContext context, KitItem kitItem) async {
    final bool? confirmed = await AdminConfirmDialog.show(
      context,
      title: 'Publish Kit Item',
      message: 'Publish "${kitItem.itemName}"? It will become visible to players.',
      confirmLabel: 'Publish',
    );

    if (confirmed == true && context.mounted) {
      await _controller.publishItem(kitItem);
    }
  }

  Future<void> _openGenerateModal(BuildContext context) async {
    await GenerateKitItemsModal.show(
      context,
      onGenerate: ({required int count, required String model, String? guidance}) =>
          _controller.generateKitItems(count: count, model: model, guidance: guidance),
    );
  }

  Future<void> _openFilters(BuildContext context, AdminKitItemState state) async {
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
