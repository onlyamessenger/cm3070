import 'dart:ui';

import 'package:core/core.dart';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import 'package:fortify/config/theme/admin_colors.dart';
import 'package:fortify/controllers/admin/admin_role_controller.dart';
import 'package:fortify/models/role_member.dart';
import 'package:fortify/state/admin/admin_role_state.dart';
import 'package:fortify/widgets/admin/admin_button.dart';
import 'package:fortify/widgets/admin/admin_confirm_dialog.dart';
import 'package:fortify/widgets/admin/admin_data_table.dart';
import 'package:fortify/widgets/admin/admin_page_header.dart';

/// Admin page for managing roles and team members.
///
/// Displays a table of current role members with the ability to invite
/// new members by email and remove existing ones.
class AdminRolesPage extends StatefulWidget {
  const AdminRolesPage({super.key});

  @override
  State<AdminRolesPage> createState() => _AdminRolesPageState();
}

class _AdminRolesPageState extends State<AdminRolesPage> {
  late final AdminRoleController _controller = Inject.get<AdminRoleController>();

  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_) {
      _controller.loadMembers();
    });
  }

  Future<void> _showInviteDialog(BuildContext context) async {
    final TextEditingController emailController = TextEditingController();
    await showDialog<void>(
      context: context,
      builder: (BuildContext dialogContext) => _InviteDialog(
        emailController: emailController,
        onSend: (String email) async {
          Navigator.of(dialogContext).pop();
          await _controller.inviteMember(email: email);
        },
      ),
    );
    emailController.dispose();
  }

  Future<void> _handleRemove(BuildContext context, RoleMember member) async {
    final bool? confirmed = await AdminConfirmDialog.show(
      context,
      title: 'Remove Member',
      message: 'Are you sure you want to remove ${member.userName} from the team?',
      confirmLabel: 'Remove',
    );
    if (confirmed == true && context.mounted) {
      await _controller.removeMember(memberId: member.id);
    }
  }

  @override
  Widget build(BuildContext context) {
    return Consumer<AdminRoleState>(
      builder: (BuildContext context, AdminRoleState state, Widget? child) {
        return Scaffold(
          backgroundColor: AdminColors.background,
          body: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: <Widget>[
              AdminPageHeader(
                title: 'Roles',
                subtitle: 'Manage admin team members',
                actions: <Widget>[
                  AdminButton(
                    label: 'Invite Member',
                    icon: Icons.person_add_outlined,
                    onPressed: () => _showInviteDialog(context),
                  ),
                ],
              ),
              const Divider(height: 1, color: AdminColors.surfaceBorder),
              if (state.error != null)
                Padding(
                  padding: const EdgeInsets.fromLTRB(24, 16, 24, 0),
                  child: _ErrorBanner(message: state.error!),
                ),
              if (state.isLoading)
                const Expanded(
                  child: Center(child: CircularProgressIndicator(color: AdminColors.primary)),
                )
              else
                Expanded(
                  child: SingleChildScrollView(
                    padding: const EdgeInsets.all(24),
                    child: AdminDataTable<RoleMember>(
                      columns: const <AdminColumn>[
                        AdminColumn(label: 'Name'),
                        AdminColumn(label: 'Email'),
                        AdminColumn(label: 'Role', width: 140),
                        AdminColumn(label: 'Joined', width: 140),
                        AdminColumn(label: 'Actions', width: 100),
                      ],
                      rows: state.members.toList(),
                      cellBuilder: (RoleMember member) => <Widget>[
                        Text(
                          member.userName,
                          style: const TextStyle(color: AdminColors.onSurface, fontWeight: FontWeight.w500),
                        ),
                        Text(member.userEmail, style: const TextStyle(color: AdminColors.onSurfaceVariant)),
                        _RoleChip(role: member.role),
                        Text(
                          _formatDate(member.joinedAt),
                          style: const TextStyle(color: AdminColors.onSurfaceVariant, fontSize: 13),
                        ),
                        IconButton(
                          icon: Icon(
                            Icons.person_remove_outlined,
                            color: AdminColors.error.withValues(alpha: 0.6),
                            size: 18,
                          ),
                          onPressed: () => _handleRemove(context, member),
                          tooltip: 'Remove member',
                        ),
                      ],
                    ),
                  ),
                ),
            ],
          ),
        );
      },
    );
  }

  String _formatDate(DateTime date) {
    final String day = date.day.toString().padLeft(2, '0');
    final String month = date.month.toString().padLeft(2, '0');
    final String year = date.year.toString();
    return '$day/$month/$year';
  }
}

class _InviteDialog extends StatelessWidget {
  final TextEditingController emailController;
  final Future<void> Function(String email) onSend;

  const _InviteDialog({required this.emailController, required this.onSend});

  @override
  Widget build(BuildContext context) {
    return BackdropFilter(
      filter: ImageFilter.blur(sigmaX: 10, sigmaY: 10),
      child: AlertDialog(
        backgroundColor: AdminColors.surfaceContainer.withValues(alpha: 0.95),
        title: const Text('Invite Member', style: TextStyle(color: AdminColors.onSurface)),
        content: SizedBox(
          width: 360,
          child: TextField(
            controller: emailController,
            keyboardType: TextInputType.emailAddress,
            style: const TextStyle(color: AdminColors.onSurface),
            decoration: const InputDecoration(labelText: 'Email address', hintText: 'member@example.com'),
            autofocus: true,
          ),
        ),
        actions: <Widget>[
          TextButton(onPressed: () => Navigator.of(context).pop(), child: const Text('Cancel')),
          ElevatedButton(
            onPressed: () => onSend(emailController.text.trim()),
            style: ElevatedButton.styleFrom(
              backgroundColor: AdminColors.primary,
              foregroundColor: AdminColors.background,
            ),
            child: const Text('Send Invite'),
          ),
        ],
      ),
    );
  }
}

class _RoleChip extends StatelessWidget {
  final String role;

  const _RoleChip({required this.role});

  @override
  Widget build(BuildContext context) {
    final String label = role.isNotEmpty ? role.substring(0, 1).toUpperCase() + role.substring(1) : 'Member';
    return Row(
      mainAxisSize: MainAxisSize.min,
      children: <Widget>[
        Container(
          padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
          decoration: BoxDecoration(
            color: AdminColors.warning.withValues(alpha: 0.12),
            borderRadius: BorderRadius.circular(12),
            border: Border.all(color: AdminColors.warning.withValues(alpha: 0.3)),
          ),
          child: Text(
            label,
            style: const TextStyle(color: AdminColors.warning, fontSize: 12, fontWeight: FontWeight.w600),
          ),
        ),
      ],
    );
  }
}

class _ErrorBanner extends StatelessWidget {
  final String message;

  const _ErrorBanner({required this.message});

  @override
  Widget build(BuildContext context) {
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.all(12),
      decoration: BoxDecoration(
        color: AdminColors.error.withValues(alpha: 0.15),
        borderRadius: BorderRadius.circular(8),
        border: Border.all(color: AdminColors.error.withValues(alpha: 0.4)),
      ),
      child: Row(
        children: <Widget>[
          const Icon(Icons.error_outline, color: AdminColors.error, size: 16),
          const SizedBox(width: 8),
          Expanded(
            child: Text(message, style: const TextStyle(color: AdminColors.error, fontSize: 13)),
          ),
        ],
      ),
    );
  }
}
