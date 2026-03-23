import 'package:flutter/material.dart';
import 'package:fortify/config/theme/admin_colors.dart';

class AdminColumn {
  final String label;
  final double? width;
  final bool sortable;
  const AdminColumn({required this.label, this.width, this.sortable = false});
}

class AdminDataTable<T> extends StatelessWidget {
  final List<AdminColumn> columns;
  final List<T> rows;
  final List<Widget> Function(T item) cellBuilder;
  final void Function(T item)? onRowTap;
  final Set<String>? selectedIds;
  final String Function(T item)? idAccessor;
  final void Function(T item)? onSelectItem;
  final VoidCallback? onSelectAll;

  const AdminDataTable({
    super.key,
    required this.columns,
    required this.rows,
    required this.cellBuilder,
    this.onRowTap,
    this.selectedIds,
    this.idAccessor,
    this.onSelectItem,
    this.onSelectAll,
  });

  bool get _selectable => selectedIds != null && idAccessor != null && onSelectItem != null;

  @override
  Widget build(BuildContext context) {
    if (rows.isEmpty) {
      return const Center(
        child: Padding(
          padding: EdgeInsets.all(48),
          child: Text('No items found', style: TextStyle(color: AdminColors.onSurfaceVariant, fontSize: 14)),
        ),
      );
    }
    return Container(
      decoration: BoxDecoration(
        borderRadius: BorderRadius.circular(8),
        border: Border.all(color: AdminColors.surfaceBorder),
      ),
      child: ClipRRect(
        borderRadius: BorderRadius.circular(8),
        child: Column(
          children: <Widget>[
            Container(
              color: AdminColors.surfaceContainer.withValues(alpha: 0.5),
              padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 10),
              child: Row(
                children: <Widget>[
                  if (_selectable) ...<Widget>[
                    SizedBox(
                      width: 40,
                      child: Checkbox(
                        value: selectedIds!.length == rows.length && rows.isNotEmpty,
                        tristate: true,
                        onChanged: (_) => onSelectAll?.call(),
                        activeColor: AdminColors.primary,
                        side: const BorderSide(color: AdminColors.onSurfaceVariant),
                      ),
                    ),
                  ],
                  ...columns.map((AdminColumn col) {
                    return col.width != null
                        ? SizedBox(width: col.width, child: _headerCell(col.label))
                        : Expanded(child: _headerCell(col.label));
                  }),
                ],
              ),
            ),
            const Divider(height: 1),
            ...rows.map((T item) {
              final bool isSelected = _selectable && selectedIds!.contains(idAccessor!(item));
              return _DataRow<T>(
                columns: columns,
                item: item,
                cellBuilder: cellBuilder,
                onTap: onRowTap,
                selectable: _selectable,
                isSelected: isSelected,
                onSelect: onSelectItem,
              );
            }),
          ],
        ),
      ),
    );
  }

  Widget _headerCell(String label) {
    return Text(
      label.toUpperCase(),
      style: const TextStyle(
        color: AdminColors.onSurfaceVariant,
        fontSize: 11,
        fontWeight: FontWeight.w600,
        letterSpacing: 0.5,
      ),
    );
  }
}

class _DataRow<T> extends StatefulWidget {
  final List<AdminColumn> columns;
  final T item;
  final List<Widget> Function(T item) cellBuilder;
  final void Function(T item)? onTap;
  final bool selectable;
  final bool isSelected;
  final void Function(T item)? onSelect;

  const _DataRow({
    required this.columns,
    required this.item,
    required this.cellBuilder,
    this.onTap,
    this.selectable = false,
    this.isSelected = false,
    this.onSelect,
  });

  @override
  State<_DataRow<T>> createState() => _DataRowState<T>();
}

class _DataRowState<T> extends State<_DataRow<T>> {
  bool _isHovered = false;

  @override
  Widget build(BuildContext context) {
    final List<Widget> cells = widget.cellBuilder(widget.item);
    final Color backgroundColor = widget.isSelected
        ? AdminColors.primaryOverlay
        : _isHovered
        ? AdminColors.primaryTint
        : Colors.transparent;
    return MouseRegion(
      onEnter: (_) => setState(() => _isHovered = true),
      onExit: (_) => setState(() => _isHovered = false),
      child: GestureDetector(
        onTap: widget.onTap != null ? () => widget.onTap!(widget.item) : null,
        child: Container(
          color: backgroundColor,
          padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 16),
          child: Row(
            children: <Widget>[
              if (widget.selectable) ...<Widget>[
                SizedBox(
                  width: 40,
                  child: Checkbox(
                    value: widget.isSelected,
                    onChanged: (_) => widget.onSelect?.call(widget.item),
                    activeColor: AdminColors.primary,
                    side: const BorderSide(color: AdminColors.onSurfaceVariant),
                  ),
                ),
              ],
              ...List<Widget>.generate(cells.length, (int i) {
                return widget.columns[i].width != null
                    ? SizedBox(width: widget.columns[i].width, child: cells[i])
                    : Expanded(child: cells[i]);
              }),
            ],
          ),
        ),
      ),
    );
  }
}
