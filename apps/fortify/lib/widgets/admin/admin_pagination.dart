import 'package:flutter/material.dart';
import 'package:fortify/config/theme/admin_colors.dart';

class AdminPagination extends StatelessWidget {
  final int currentPage;
  final int totalItems;
  final int itemsPerPage;
  final ValueChanged<int> onPageChanged;

  const AdminPagination({
    super.key,
    required this.currentPage,
    required this.totalItems,
    required this.itemsPerPage,
    required this.onPageChanged,
  });

  int get totalPages => (totalItems / itemsPerPage).ceil();
  int get startItem => totalItems == 0 ? 0 : (currentPage - 1) * itemsPerPage + 1;
  int get endItem => (currentPage * itemsPerPage).clamp(0, totalItems);

  @override
  Widget build(BuildContext context) {
    if (totalItems == 0) return const SizedBox.shrink();
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 12),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: <Widget>[
          Text(
            'Showing $startItem-$endItem of $totalItems',
            style: const TextStyle(color: AdminColors.onSurfaceVariant, fontSize: 13),
          ),
          Row(
            children: <Widget>[
              IconButton(
                icon: const Icon(Icons.chevron_left, size: 20),
                onPressed: currentPage > 1 ? () => onPageChanged(currentPage - 1) : null,
                color: AdminColors.onSurfaceVariant,
              ),
              ...List<Widget>.generate(totalPages, (int index) {
                final int page = index + 1;
                final bool isActive = page == currentPage;
                return Padding(
                  padding: const EdgeInsets.symmetric(horizontal: 2),
                  child: InkWell(
                    onTap: () => onPageChanged(page),
                    borderRadius: BorderRadius.circular(4),
                    child: Container(
                      padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
                      decoration: BoxDecoration(
                        color: isActive ? AdminColors.primaryOverlay : AdminColors.surfaceContainer,
                        border: isActive ? Border.all(color: AdminColors.primary.withValues(alpha: 0.3)) : null,
                        borderRadius: BorderRadius.circular(4),
                      ),
                      child: Text(
                        '$page',
                        style: TextStyle(
                          color: isActive ? AdminColors.primary : AdminColors.onSurfaceVariant,
                          fontSize: 13,
                        ),
                      ),
                    ),
                  ),
                );
              }),
              IconButton(
                icon: const Icon(Icons.chevron_right, size: 20),
                onPressed: currentPage < totalPages ? () => onPageChanged(currentPage + 1) : null,
                color: AdminColors.onSurfaceVariant,
              ),
            ],
          ),
        ],
      ),
    );
  }
}
