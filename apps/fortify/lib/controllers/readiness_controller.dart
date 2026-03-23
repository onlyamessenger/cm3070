import 'package:core/core.dart';

import 'package:fortify/state/readiness_state.dart';

class ReadinessController {
  final DataSource<ReadinessSection> _sectionDataSource;
  final DataSource<KitItem> _kitItemDataSource;
  final DataSource<Quest> _questDataSource;
  final DataSource<QuestNode> _questNodeDataSource;
  final DataSource<Challenge> _challengeDataSource;
  final ReadinessState _state;

  ReadinessController({
    required DataSource<ReadinessSection> sectionDataSource,
    required DataSource<KitItem> kitItemDataSource,
    required DataSource<Quest> questDataSource,
    required DataSource<QuestNode> questNodeDataSource,
    required DataSource<Challenge> challengeDataSource,
    required ReadinessState state,
  }) : _sectionDataSource = sectionDataSource,
       _kitItemDataSource = kitItemDataSource,
       _questDataSource = questDataSource,
       _questNodeDataSource = questNodeDataSource,
       _challengeDataSource = challengeDataSource,
       _state = state;

  Future<void> loadSections(String userId) async {
    _state.setLoading(true);
    _state.setError(null);
    try {
      final List<ReadinessSection> sections = await _sectionDataSource.readItemsWhere('userId', userId);
      _state.setSections(sections);
    } on Exception catch (e) {
      _state.setError(e.toString());
    } finally {
      _state.setLoading(false);
    }
  }

  Future<void> loadKitItems(String userId) async {
    try {
      final List<KitItem> items = await _kitItemDataSource.readItemsWhere('userId', userId);
      items.sort((KitItem a, KitItem b) => a.sortOrder.compareTo(b.sortOrder));
      _state.setKitItems(items);
    } on Exception catch (e) {
      _state.setError(e.toString());
    }
  }

  Future<void> toggleKitItem(KitItem item) async {
    final bool newChecked = !item.isChecked;
    final KitItem updated;
    if (newChecked) {
      updated = item.copyWith(isChecked: true, checkedAt: DateTime.now());
    } else {
      // Construct directly to clear checkedAt to null - copyWith cannot set nullable fields to null.
      updated = KitItem(
        id: item.id,
        created: item.created,
        updated: item.updated,
        createdBy: item.createdBy,
        updatedBy: item.updatedBy,
        isDeleted: item.isDeleted,
        source: item.source,
        isPublished: item.isPublished,
        userId: item.userId,
        itemName: item.itemName,
        description: item.description,
        sortOrder: item.sortOrder,
        isChecked: false,
        checkedAt: null,
      );
    }

    _state.updateKitItem(updated);

    try {
      await _kitItemDataSource.updateItem(updated);
    } on Exception catch (e) {
      _state.updateKitItem(item);
      _state.setError(e.toString());
    }
  }

  Future<void> resolveUnlockHints() async {
    try {
      final Map<ReadinessSectionType, String?> hints = <ReadinessSectionType, String?>{};

      final List<Challenge> challenges = await _challengeDataSource.readItems();
      for (final Challenge challenge in challenges) {
        if (challenge.isPublished && challenge.unlocksSectionType != null) {
          final ReadinessSectionType type = ReadinessSectionType.fromString(challenge.unlocksSectionType!);
          hints[type] = 'Complete "${challenge.title}" challenge to unlock';
        }
      }

      final List<Quest> quests = await _questDataSource.readItems();
      final List<QuestNode> allNodes = await _questNodeDataSource.readItems();
      for (final QuestNode node in allNodes) {
        if (node.unlocksSectionType != null) {
          final ReadinessSectionType type = ReadinessSectionType.fromString(node.unlocksSectionType!);
          if (!hints.containsKey(type)) {
            final Quest? quest = quests.where((Quest q) => q.isPublished && q.id == node.questId).firstOrNull;
            if (quest != null) {
              hints[type] = 'Complete "${quest.title}" quest to unlock';
            }
          }
        }
      }

      _state.setUnlockHints(hints);
    } on Exception catch (e) {
      _state.setError(e.toString());
    }
  }

  Future<void> refreshAfterUnlock(String userId) async {
    await loadSections(userId);
  }
}
