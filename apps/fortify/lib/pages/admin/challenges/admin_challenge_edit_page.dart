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

class AdminChallengeEditPage extends StatefulWidget {
  final String challengeId;

  const AdminChallengeEditPage({super.key, required this.challengeId});

  @override
  State<AdminChallengeEditPage> createState() => _AdminChallengeEditPageState();
}

class _AdminChallengeEditPageState extends State<AdminChallengeEditPage> with SingleTickerProviderStateMixin {
  late final AdminChallengeController _controller = Inject.get<AdminChallengeController>();
  late final TabController _tabController = TabController(length: 2, vsync: this);
  final GlobalKey<AdminChallengeFormState> _formKey = GlobalKey<AdminChallengeFormState>();

  List<ChallengeQuestion> _questions = <ChallengeQuestion>[];
  List<ChallengeQuestion> _originalQuestions = <ChallengeQuestion>[];
  bool _questionsLoaded = false;

  @override
  void initState() {
    super.initState();
    final AdminChallengeState state = Inject.get<AdminChallengeState>();
    final Challenge? existing = state.getItemById(widget.challengeId);
    if (existing == null) {
      WidgetsBinding.instance.addPostFrameCallback((_) {
        _controller.loadItems();
      });
    }
    _loadQuestions();
  }

  @override
  void dispose() {
    _tabController.dispose();
    super.dispose();
  }

  Future<void> _loadQuestions() async {
    try {
      final List<ChallengeQuestion> loaded = await _controller.loadQuestionsForChallenge(widget.challengeId);
      loaded.sort((ChallengeQuestion a, ChallengeQuestion b) => a.sortOrder.compareTo(b.sortOrder));
      setState(() {
        _questions = loaded;
        _originalQuestions = List<ChallengeQuestion>.from(loaded);
        _questionsLoaded = true;
      });
    } on Exception {
      setState(() => _questionsLoaded = true);
    }
  }

  @override
  Widget build(BuildContext context) {
    return Consumer<AdminChallengeState>(
      builder: (BuildContext context, AdminChallengeState state, Widget? child) {
        final Challenge? challenge = state.getItemById(widget.challengeId);

        if (state.loading && challenge == null) {
          return const Center(child: CircularProgressIndicator(color: AdminColors.primary));
        }

        if (challenge == null) {
          return const Center(
            child: Text('Challenge not found', style: TextStyle(color: AdminColors.onSurfaceVariant)),
          );
        }

        return Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: <Widget>[
            const AdminPageHeader(title: 'Edit Challenge', subtitle: 'Update challenge details', showBack: true),
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
                        challenge: challenge,
                        isLoading: state.loading,
                        onSave: (Challenge updated) => _handleSave(context, updated),
                      ),
                    ),
                  ),
                  AdminKeepAliveTab(
                    child: Padding(
                      padding: const EdgeInsets.all(24),
                      child: _questionsLoaded
                          ? AdminChallengeQuestionsEditor(
                              questions: _questions,
                              challengeId: widget.challengeId,
                              onChanged: (List<ChallengeQuestion> updated) {
                                setState(() => _questions = updated);
                              },
                            )
                          : const Center(child: CircularProgressIndicator(color: AdminColors.primary)),
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

  Future<void> _handleSave(BuildContext context, Challenge updated) async {
    await _controller.saveWithQuestions(
      challenge: updated,
      currentQuestions: _questions,
      originalQuestions: _originalQuestions,
      isNew: false,
    );

    if (!context.mounted) return;

    final AdminChallengeState state = context.read<AdminChallengeState>();
    if (state.error == null) {
      context.go('/admin/challenges');
    }
  }
}
