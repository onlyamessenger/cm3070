import 'package:flutter/material.dart';
import 'package:fortify/widgets/admin/admin_bulk_action_bar.dart';
import 'package:fortify/widgets/admin/admin_data_card.dart';
import 'package:fortify/widgets/admin/admin_data_table.dart';
import 'package:fortify/widgets/admin/admin_pagination.dart';

class AdminResponsiveList<T> extends StatefulWidget {
  final List<T> items;
  final List<AdminColumn> columns;
  final List<Widget> Function(T item) cellBuilder;
  final Widget Function(T item) cardBuilder;
  final void Function(T item)? onItemTap;
  final int itemsPerPage;
  final double breakpoint;
  final String Function(T item)? idAccessor;
  final List<AdminBulkAction> Function(Set<String> selectedIds)? bulkActions;

  const AdminResponsiveList({
    super.key,
    required this.items,
    required this.columns,
    required this.cellBuilder,
    required this.cardBuilder,
    this.onItemTap,
    this.itemsPerPage = 20,
    this.breakpoint = 768,
    this.idAccessor,
    this.bulkActions,
  });

  @override
  State<AdminResponsiveList<T>> createState() => _AdminResponsiveListState<T>();
}

class _AdminResponsiveListState<T> extends State<AdminResponsiveList<T>> {
  int _currentPage = 1;
  final Set<String> _selectedIds = <String>{};

  bool get _selectable => widget.idAccessor != null && widget.bulkActions != null;

  @override
  void didUpdateWidget(AdminResponsiveList<T> oldWidget) {
    super.didUpdateWidget(oldWidget);
    if (oldWidget.items != widget.items) {
      _selectedIds.clear();
    }
  }

  List<T> get _paginatedItems {
    final int start = (_currentPage - 1) * widget.itemsPerPage;
    final int end = start + widget.itemsPerPage;
    return widget.items.sublist(start.clamp(0, widget.items.length), end.clamp(0, widget.items.length));
  }

  void _toggleItem(T item) {
    final String id = widget.idAccessor!(item);
    setState(() {
      if (_selectedIds.contains(id)) {
        _selectedIds.remove(id);
      } else {
        _selectedIds.add(id);
      }
    });
  }

  void _toggleAll() {
    setState(() {
      final List<String> pageIds = _paginatedItems.map((T item) => widget.idAccessor!(item)).toList();
      if (pageIds.every(_selectedIds.contains)) {
        _selectedIds.removeAll(pageIds);
      } else {
        _selectedIds.addAll(pageIds);
      }
    });
  }

  void _clearSelection() {
    setState(() => _selectedIds.clear());
  }

  @override
  Widget build(BuildContext context) {
    return LayoutBuilder(
      builder: (BuildContext context, BoxConstraints constraints) {
        final bool isDesktop = constraints.maxWidth >= widget.breakpoint;
        return Column(
          children: <Widget>[
            if (_selectable && _selectedIds.isNotEmpty)
              AdminBulkActionBar(
                selectedCount: _selectedIds.length,
                actions: widget.bulkActions!(_selectedIds),
                onClearSelection: _clearSelection,
              ),
            Expanded(
              child: SingleChildScrollView(
                child: isDesktop
                    ? Padding(
                        padding: const EdgeInsets.symmetric(horizontal: 24),
                        child: AdminDataTable<T>(
                          columns: widget.columns,
                          rows: _paginatedItems,
                          cellBuilder: widget.cellBuilder,
                          onRowTap: widget.onItemTap,
                          selectedIds: _selectable ? _selectedIds : null,
                          idAccessor: widget.idAccessor,
                          onSelectItem: _selectable ? _toggleItem : null,
                          onSelectAll: _selectable ? _toggleAll : null,
                        ),
                      )
                    : Padding(
                        padding: const EdgeInsets.symmetric(horizontal: 16),
                        child: Column(
                          children: _paginatedItems.map((T item) {
                            final bool isSelected = _selectable && _selectedIds.contains(widget.idAccessor!(item));
                            return Padding(
                              padding: const EdgeInsets.only(bottom: 8),
                              child: AdminDataCard<T>(
                                item: item,
                                builder: widget.cardBuilder,
                                onTap: widget.onItemTap != null ? () => widget.onItemTap!(item) : null,
                                selectable: _selectable,
                                isSelected: isSelected,
                                onSelect: _selectable ? () => _toggleItem(item) : null,
                              ),
                            );
                          }).toList(),
                        ),
                      ),
              ),
            ),
            AdminPagination(
              currentPage: _currentPage,
              totalItems: widget.items.length,
              itemsPerPage: widget.itemsPerPage,
              onPageChanged: (int page) => setState(() => _currentPage = page),
            ),
          ],
        );
      },
    );
  }
}
