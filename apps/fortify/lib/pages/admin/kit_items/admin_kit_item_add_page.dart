import 'package:core/core.dart';
import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:provider/provider.dart';
import 'package:fortify/config/theme/admin_colors.dart';
import 'package:fortify/controllers/admin/admin_kit_item_controller.dart';
import 'package:fortify/pages/admin/kit_items/admin_kit_item_form.dart';
import 'package:fortify/state/admin/admin_kit_item_state.dart';
import 'package:fortify/widgets/admin/admin_page_header.dart';

class AdminKitItemAddPage extends StatelessWidget {
  const AdminKitItemAddPage({super.key});

  @override
  Widget build(BuildContext context) {
    final AdminKitItemController controller = Inject.get<AdminKitItemController>();

    return Consumer<AdminKitItemState>(
      builder: (BuildContext context, AdminKitItemState state, Widget? child) {
        return SingleChildScrollView(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: <Widget>[
              const AdminPageHeader(title: 'Add Kit Item', subtitle: 'Create a new kit item template', showBack: true),
              const Divider(height: 1),
              if (state.loading) const LinearProgressIndicator(color: AdminColors.primary, minHeight: 2),
              Padding(
                padding: const EdgeInsets.all(24),
                child: AdminKitItemForm(
                  isLoading: state.loading,
                  onSave: (KitItem kitItem) => _handleSave(context, controller, kitItem),
                ),
              ),
            ],
          ),
        );
      },
    );
  }

  Future<void> _handleSave(BuildContext context, AdminKitItemController controller, KitItem kitItem) async {
    await controller.createItem(kitItem);

    if (!context.mounted) {
      return;
    }

    final AdminKitItemState state = context.read<AdminKitItemState>();
    if (state.error == null) {
      context.go('/admin/kit-items');
    }
  }
}
