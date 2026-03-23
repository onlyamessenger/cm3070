import 'package:core/core.dart';
import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:provider/provider.dart';
import 'package:fortify/config/theme/admin_colors.dart';
import 'package:fortify/controllers/admin/admin_level_controller.dart';
import 'package:fortify/pages/admin/levels/admin_level_form.dart';
import 'package:fortify/state/admin/admin_level_state.dart';
import 'package:fortify/widgets/admin/admin_page_header.dart';

class AdminLevelEditPage extends StatefulWidget {
  final String levelId;

  const AdminLevelEditPage({super.key, required this.levelId});

  @override
  State<AdminLevelEditPage> createState() => _AdminLevelEditPageState();
}

class _AdminLevelEditPageState extends State<AdminLevelEditPage> {
  late final AdminLevelController _controller = Inject.get<AdminLevelController>();

  @override
  void initState() {
    super.initState();
    final AdminLevelState state = Inject.get<AdminLevelState>();
    final Level? existing = state.getItemById(widget.levelId);
    if (existing == null) {
      WidgetsBinding.instance.addPostFrameCallback((_) {
        _controller.loadItems();
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    return Consumer<AdminLevelState>(
      builder: (BuildContext context, AdminLevelState state, Widget? child) {
        final Level? level = state.getItemById(widget.levelId);

        if (state.loading && level == null) {
          return const Center(child: CircularProgressIndicator(color: AdminColors.primary));
        }

        if (level == null) {
          return const Center(
            child: Text('Level not found', style: TextStyle(color: AdminColors.onSurfaceVariant)),
          );
        }

        return SingleChildScrollView(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: <Widget>[
              const AdminPageHeader(title: 'Edit Level', subtitle: 'Update level details', showBack: true),
              const Divider(height: 1),
              if (state.loading) const LinearProgressIndicator(color: AdminColors.primary, minHeight: 2),
              Padding(
                padding: const EdgeInsets.all(24),
                child: AdminLevelForm(
                  level: level,
                  isLoading: state.loading,
                  onSave: (Level updated) => _handleSave(context, updated),
                ),
              ),
            ],
          ),
        );
      },
    );
  }

  Future<void> _handleSave(BuildContext context, Level updated) async {
    await _controller.updateItem(updated);

    if (!context.mounted) {
      return;
    }

    final AdminLevelState state = context.read<AdminLevelState>();
    if (state.error == null) {
      context.go('/admin/levels');
    }
  }
}
