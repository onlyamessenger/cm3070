import 'package:core/core.dart';
import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:provider/provider.dart';
import 'package:fortify/config/theme/admin_colors.dart';
import 'package:fortify/controllers/admin/admin_challenge_controller.dart';
import 'package:fortify/pages/admin/challenges/admin_challenge_form.dart';
import 'package:fortify/state/admin/admin_challenge_state.dart';
import 'package:fortify/widgets/admin/admin_challenge_questions_editor.dart';
import 'package:fortify/widgets/admin/admin_keep_alive_tab.dart';
import 'package:fortify/widgets/admin/admin_page_header.dart';

class AdminChallengeAddPage extends StatefulWidget {
  const AdminChallengeAddPage({super.key});

  @override
  State<AdminChallengeAddPage> createState() => _AdminChallengeAddPageState();
}

class _AdminChallengeAddPageState extends State<AdminChallengeAddPage> with SingleTickerProviderStateMixin {
  late final TabController _tabController = TabController(length: 2, vsync: this);
  final GlobalKey<AdminChallengeFormState> _formKey = GlobalKey<AdminChallengeFormState>();
  List<ChallengeQuestion> _questions = <ChallengeQuestion>[];

  @override
  void dispose() {
    _tabController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final AdminChallengeController controller = Inject.get<AdminChallengeController>();

    return Consumer<AdminChallengeState>(
      builder: (BuildContext context, AdminChallengeState state, Widget? child) {
        return Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: <Widget>[
            const AdminPageHeader(title: 'Add Challenge', subtitle: 'Create a new challenge', showBack: true),
            const Divider(height: 1),
            if (state.loading) const LinearProgressIndicator(color: AdminColors.primary, minHeight: 2),
            TabBar(
              controller: _tabController,
              labelColor: AdminColors.primary,
              unselectedLabelColor: AdminColors.onSurfaceVariant,
              indicatorColor: AdminColors.primary,
              tabs: const <Widget>[
                Tab(text: 'Details'),
                Tab(text: 'Questions'),
              ],
            ),
            Expanded(
              child: TabBarView(
                controller: _tabController,
                children: <Widget>[
                  AdminKeepAliveTab(
                    child: SingleChildScrollView(
                      padding: const EdgeInsets.all(24),
                      child: AdminChallengeForm(
                        key: _formKey,
                        isLoading: state.loading,
                        onSave: (Challenge challenge) => _handleSave(context, controller, challenge),
                      ),
                    ),
                  ),
                  AdminKeepAliveTab(
                    child: Padding(
                      padding: const EdgeInsets.all(24),
                      child: AdminChallengeQuestionsEditor(
                        questions: _questions,
                        challengeId: '',
                        onChanged: (List<ChallengeQuestion> updated) {
                          setState(() => _questions = updated);
                        },
                      ),
                    ),
                  ),
                ],
              ),
            ),
          ],
        );
      },
    );
  }

  Future<void> _handleSave(BuildContext context, AdminChallengeController controller, Challenge challenge) async {
    await controller.saveWithQuestions(
      challenge: challenge,
      currentQuestions: _questions,
      originalQuestions: const <ChallengeQuestion>[],
      isNew: true,
    );

    if (!context.mounted) return;

    final AdminChallengeState state = context.read<AdminChallengeState>();
    if (state.error == null) {
      context.go('/admin/challenges');
    }
  }
}
