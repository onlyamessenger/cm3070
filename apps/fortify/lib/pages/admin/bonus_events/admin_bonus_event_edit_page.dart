import 'package:core/core.dart';
import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:provider/provider.dart';
import 'package:fortify/config/theme/admin_colors.dart';
import 'package:fortify/controllers/admin/admin_bonus_event_controller.dart';
import 'package:fortify/pages/admin/bonus_events/admin_bonus_event_form.dart';
import 'package:fortify/state/admin/admin_bonus_event_state.dart';
import 'package:fortify/widgets/admin/admin_page_header.dart';

class AdminBonusEventEditPage extends StatefulWidget {
  final String bonusEventId;

  const AdminBonusEventEditPage({super.key, required this.bonusEventId});

  @override
  State<AdminBonusEventEditPage> createState() => _AdminBonusEventEditPageState();
}

class _AdminBonusEventEditPageState extends State<AdminBonusEventEditPage> {
  late final AdminBonusEventController _controller = Inject.get<AdminBonusEventController>();

  @override
  void initState() {
    super.initState();
    final AdminBonusEventState state = Inject.get<AdminBonusEventState>();
    final BonusEvent? existing = state.getItemById(widget.bonusEventId);
    if (existing == null) {
      WidgetsBinding.instance.addPostFrameCallback((_) {
        _controller.loadItems();
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    return Consumer<AdminBonusEventState>(
      builder: (BuildContext context, AdminBonusEventState state, Widget? child) {
        final BonusEvent? bonusEvent = state.getItemById(widget.bonusEventId);

        if (state.loading && bonusEvent == null) {
          return const Center(child: CircularProgressIndicator(color: AdminColors.primary));
        }

        if (bonusEvent == null) {
          return const Center(
            child: Text('Bonus event not found', style: TextStyle(color: AdminColors.onSurfaceVariant)),
          );
        }

        return SingleChildScrollView(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: <Widget>[
              const AdminPageHeader(title: 'Edit Bonus Event', subtitle: 'Update bonus event details', showBack: true),
              const Divider(height: 1),
              if (state.loading) const LinearProgressIndicator(color: AdminColors.primary, minHeight: 2),
              Padding(
                padding: const EdgeInsets.all(24),
                child: AdminBonusEventForm(
                  bonusEvent: bonusEvent,
                  isLoading: state.loading,
                  onSave: (BonusEvent updated) => _handleSave(context, updated),
                ),
              ),
            ],
          ),
        );
      },
    );
  }

  Future<void> _handleSave(BuildContext context, BonusEvent updated) async {
    await _controller.updateItem(updated);

    if (!context.mounted) {
      return;
    }

    final AdminBonusEventState state = context.read<AdminBonusEventState>();
    if (state.error == null) {
      context.go('/admin/bonus-events');
    }
  }
}
