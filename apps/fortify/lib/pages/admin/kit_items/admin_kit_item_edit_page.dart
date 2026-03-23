import 'package:core/core.dart';
import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:provider/provider.dart';
import 'package:fortify/config/theme/admin_colors.dart';
import 'package:fortify/controllers/admin/admin_kit_item_controller.dart';
import 'package:fortify/pages/admin/kit_items/admin_kit_item_form.dart';
import 'package:fortify/state/admin/admin_kit_item_state.dart';
import 'package:fortify/widgets/admin/admin_page_header.dart';

class AdminKitItemEditPage extends StatefulWidget {
  final String kitItemId;

  const AdminKitItemEditPage({super.key, required this.kitItemId});

  @override
  State<AdminKitItemEditPage> createState() => _AdminKitItemEditPageState();
}

class _AdminKitItemEditPageState extends State<AdminKitItemEditPage> {
  late final AdminKitItemController _controller = Inject.get<AdminKitItemController>();

  @override
  void initState() {
    super.initState();
    final AdminKitItemState state = Inject.get<AdminKitItemState>();
    final KitItem? existing = state.getItemById(widget.kitItemId);
    if (existing == null) {
      WidgetsBinding.instance.addPostFrameCallback((_) {
        _controller.loadItems();
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    return Consumer<AdminKitItemState>(
      builder: (BuildContext context, AdminKitItemState state, Widget? child) {
        final KitItem? kitItem = state.getItemById(widget.kitItemId);

        if (state.loading && kitItem == null) {
          return const Center(child: CircularProgressIndicator(color: AdminColors.primary));
        }

        if (kitItem == null) {
          return const Center(
            child: Text('Kit item not found', style: TextStyle(color: AdminColors.onSurfaceVariant)),
          );
        }

        return SingleChildScrollView(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: <Widget>[
              const AdminPageHeader(title: 'Edit Kit Item', subtitle: 'Update kit item details', showBack: true),
              const Divider(height: 1),
              if (state.loading) const LinearProgressIndicator(color: AdminColors.primary, minHeight: 2),
              Padding(
                padding: const EdgeInsets.all(24),
                child: AdminKitItemForm(
                  kitItem: kitItem,
                  isLoading: state.loading,
                  onSave: (KitItem updated) => _handleSave(context, updated),
                ),
              ),
            ],
          ),
        );
      },
    );
  }

  Future<void> _handleSave(BuildContext context, KitItem updated) async {
    await _controller.updateItem(updated);

    if (!context.mounted) {
      return;
    }

    final AdminKitItemState state = context.read<AdminKitItemState>();
    if (state.error == null) {
      context.go('/admin/kit-items');
    }
  }
}
