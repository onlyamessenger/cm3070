import 'package:core/core.dart';
import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:provider/provider.dart';
import 'package:fortify/config/theme/admin_colors.dart';
import 'package:fortify/controllers/admin/admin_level_controller.dart';
import 'package:fortify/pages/admin/levels/admin_level_form.dart';
import 'package:fortify/state/admin/admin_level_state.dart';
import 'package:fortify/widgets/admin/admin_page_header.dart';

class AdminLevelAddPage extends StatelessWidget {
  const AdminLevelAddPage({super.key});

  @override
  Widget build(BuildContext context) {
    final AdminLevelController controller = Inject.get<AdminLevelController>();

    return Consumer<AdminLevelState>(
      builder: (BuildContext context, AdminLevelState state, Widget? child) {
        return SingleChildScrollView(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: <Widget>[
              const AdminPageHeader(title: 'Add Level', subtitle: 'Create a new game level', showBack: true),
              const Divider(height: 1),
              if (state.loading) const LinearProgressIndicator(color: AdminColors.primary, minHeight: 2),
              Padding(
                padding: const EdgeInsets.all(24),
                child: AdminLevelForm(
                  isLoading: state.loading,
                  onSave: (Level level) => _handleSave(context, controller, level),
                ),
              ),
            ],
          ),
        );
      },
    );
  }

  Future<void> _handleSave(BuildContext context, AdminLevelController controller, Level level) async {
    await controller.createItem(level);

    if (!context.mounted) {
      return;
    }

    final AdminLevelState state = context.read<AdminLevelState>();
    if (state.error == null) {
      context.go('/admin/levels');
    }
  }
}
