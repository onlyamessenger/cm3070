import 'package:core/core.dart';
import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:provider/provider.dart';
import 'package:fortify/config/theme/admin_colors.dart';
import 'package:fortify/controllers/admin/admin_quest_controller.dart';
import 'package:fortify/pages/admin/quests/admin_quest_form.dart';
import 'package:fortify/state/admin/admin_quest_state.dart';
import 'package:fortify/widgets/admin/admin_keep_alive_tab.dart';
import 'package:fortify/widgets/admin/admin_page_header.dart';
import 'package:fortify/widgets/admin/admin_quest_node_tree.dart';

class AdminQuestAddPage extends StatefulWidget {
  const AdminQuestAddPage({super.key});

  @override
  State<AdminQuestAddPage> createState() => _AdminQuestAddPageState();
}

class _AdminQuestAddPageState extends State<AdminQuestAddPage> with SingleTickerProviderStateMixin {
  late final TabController _tabController = TabController(length: 2, vsync: this);
  final GlobalKey<AdminQuestFormState> _formKey = GlobalKey<AdminQuestFormState>();
  List<QuestNode> _nodes = <QuestNode>[];
  String _startNodeId = '';

  @override
  void dispose() {
    _tabController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final AdminQuestController controller = Inject.get<AdminQuestController>();

    return Consumer<AdminQuestState>(
      builder: (BuildContext context, AdminQuestState state, Widget? child) {
        return Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: <Widget>[
            const AdminPageHeader(title: 'Add Quest', subtitle: 'Create a new quest', showBack: true),
            const Divider(height: 1),
            if (state.loading) const LinearProgressIndicator(color: AdminColors.primary, minHeight: 2),
            TabBar(
              controller: _tabController,
              labelColor: AdminColors.primary,
              unselectedLabelColor: AdminColors.onSurfaceVariant,
              indicatorColor: AdminColors.primary,
              tabs: const <Widget>[
                Tab(text: 'Details'),
                Tab(text: 'Nodes'),
              ],
            ),
            Expanded(
              child: TabBarView(
                controller: _tabController,
                children: <Widget>[
                  // Tab 1: Quest details form - kept alive so form state persists across tab switches
                  AdminKeepAliveTab(
                    child: SingleChildScrollView(
                      padding: const EdgeInsets.all(24),
                      child: AdminQuestForm(
                        key: _formKey,
                        isLoading: state.loading,
                        startNodeId: _startNodeId,
                        onSave: (Quest quest) => _handleSave(context, controller, quest),
                      ),
                    ),
                  ),

                  // Tab 2: Node tree editor - kept alive so node edits persist across tab switches
                  AdminKeepAliveTab(
                    child: Padding(
                      padding: const EdgeInsets.all(24),
                      child: AdminQuestNodeTree(
                        nodes: _nodes,
                        questId: '',
                        startNodeId: _startNodeId,
                        onChanged: (List<QuestNode> updatedNodes, String startNodeId) {
                          setState(() {
                            _nodes = updatedNodes;
                            _startNodeId = startNodeId;
                          });
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

  Future<void> _handleSave(BuildContext context, AdminQuestController controller, Quest quest) async {
    await controller.saveWithNodes(
      quest: quest,
      currentNodes: _nodes,
      originalNodes: const <QuestNode>[],
      startNodeId: _startNodeId,
      isNew: true,
    );

    if (!context.mounted) return;

    final AdminQuestState state = context.read<AdminQuestState>();
    if (state.error == null) {
      context.go('/admin/quests');
    }
  }
}
