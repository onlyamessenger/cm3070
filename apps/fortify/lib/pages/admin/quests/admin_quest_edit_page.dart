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

class AdminQuestEditPage extends StatefulWidget {
  final String questId;

  const AdminQuestEditPage({super.key, required this.questId});

  @override
  State<AdminQuestEditPage> createState() => _AdminQuestEditPageState();
}

class _AdminQuestEditPageState extends State<AdminQuestEditPage> with SingleTickerProviderStateMixin {
  late final AdminQuestController _controller = Inject.get<AdminQuestController>();
  late final TabController _tabController = TabController(length: 2, vsync: this);
  final GlobalKey<AdminQuestFormState> _formKey = GlobalKey<AdminQuestFormState>();

  List<QuestNode> _nodes = <QuestNode>[];
  List<QuestNode> _originalNodes = <QuestNode>[];
  String _startNodeId = '';
  bool _nodesLoaded = false;

  @override
  void initState() {
    super.initState();
    final AdminQuestState state = Inject.get<AdminQuestState>();
    final Quest? existing = state.getItemById(widget.questId);
    if (existing == null) {
      WidgetsBinding.instance.addPostFrameCallback((_) {
        _controller.loadItems();
      });
    } else {
      _startNodeId = existing.startNodeId;
    }
    _loadNodes();
  }

  @override
  void dispose() {
    _tabController.dispose();
    super.dispose();
  }

  Future<void> _loadNodes() async {
    try {
      final List<QuestNode> loaded = await _controller.loadNodesForQuest(widget.questId);
      loaded.sort((QuestNode a, QuestNode b) => a.day.compareTo(b.day));
      setState(() {
        _nodes = loaded;
        _originalNodes = List<QuestNode>.from(loaded);
        _nodesLoaded = true;
      });
    } on Exception {
      setState(() => _nodesLoaded = true);
    }
  }

  @override
  Widget build(BuildContext context) {
    return Consumer<AdminQuestState>(
      builder: (BuildContext context, AdminQuestState state, Widget? child) {
        final Quest? quest = state.getItemById(widget.questId);

        if (state.loading && quest == null) {
          return const Center(child: CircularProgressIndicator(color: AdminColors.primary));
        }

        if (quest == null) {
          return const Center(
            child: Text('Quest not found', style: TextStyle(color: AdminColors.onSurfaceVariant)),
          );
        }

        if (_startNodeId.isEmpty) {
          _startNodeId = quest.startNodeId;
        }

        return Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: <Widget>[
            const AdminPageHeader(title: 'Edit Quest', subtitle: 'Update quest details', showBack: true),
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
                        quest: quest,
                        isLoading: state.loading,
                        startNodeId: _startNodeId,
                        onSave: (Quest updated) => _handleSave(context, updated),
                      ),
                    ),
                  ),

                  // Tab 2: Node tree editor - kept alive so node edits persist across tab switches
                  AdminKeepAliveTab(
                    child: Padding(
                      padding: const EdgeInsets.all(24),
                      child: _nodesLoaded
                          ? AdminQuestNodeTree(
                              nodes: _nodes,
                              questId: widget.questId,
                              startNodeId: _startNodeId,
                              onChanged: (List<QuestNode> updatedNodes, String startNodeId) {
                                setState(() {
                                  _nodes = updatedNodes;
                                  _startNodeId = startNodeId;
                                });
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

  Future<void> _handleSave(BuildContext context, Quest updated) async {
    await _controller.saveWithNodes(
      quest: updated,
      currentNodes: _nodes,
      originalNodes: _originalNodes,
      startNodeId: _startNodeId,
      isNew: false,
    );

    if (!context.mounted) return;

    final AdminQuestState state = context.read<AdminQuestState>();
    if (state.error == null) {
      context.go('/admin/quests');
    }
  }
}
