import 'package:core/core.dart';
import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:provider/provider.dart';
import 'package:fortify/config/theme/admin_colors.dart';
import 'package:fortify/controllers/admin/admin_bonus_event_controller.dart';
import 'package:fortify/pages/admin/bonus_events/admin_bonus_event_form.dart';
import 'package:fortify/state/admin/admin_bonus_event_state.dart';
import 'package:fortify/widgets/admin/admin_page_header.dart';

class AdminBonusEventAddPage extends StatelessWidget {
  const AdminBonusEventAddPage({super.key});

  @override
  Widget build(BuildContext context) {
    final AdminBonusEventController controller = Inject.get<AdminBonusEventController>();

    return Consumer<AdminBonusEventState>(
      builder: (BuildContext context, AdminBonusEventState state, Widget? child) {
        return SingleChildScrollView(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: <Widget>[
              const AdminPageHeader(
                title: 'Add Bonus Event',
                subtitle: 'Create a new XP multiplier event',
                showBack: true,
              ),
              const Divider(height: 1),
              if (state.loading) const LinearProgressIndicator(color: AdminColors.primary, minHeight: 2),
              Padding(
                padding: const EdgeInsets.all(24),
                child: AdminBonusEventForm(
                  isLoading: state.loading,
                  onSave: (BonusEvent event) => _handleSave(context, controller, event),
                ),
              ),
            ],
          ),
        );
      },
    );
  }

  Future<void> _handleSave(BuildContext context, AdminBonusEventController controller, BonusEvent event) async {
    await controller.createItem(event);

    if (!context.mounted) {
      return;
    }

    final AdminBonusEventState state = context.read<AdminBonusEventState>();
    if (state.error == null) {
      context.go('/admin/bonus-events');
    }
  }
}
