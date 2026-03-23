import 'package:core/core.dart';
import 'package:flutter/foundation.dart';

class ReadinessState extends ChangeNotifier {
  List<ReadinessSection> _sections = <ReadinessSection>[];
  List<ReadinessSection> get sections => _sections;

  List<KitItem> _kitItems = <KitItem>[];
  List<KitItem> get kitItems => _kitItems;

  Map<ReadinessSectionType, String?> _unlockHints = <ReadinessSectionType, String?>{};
  Map<ReadinessSectionType, String?> get unlockHints => _unlockHints;

  bool _isLoading = false;
  bool get isLoading => _isLoading;

  String? _error;
  String? get error => _error;

  int get unlockedCount => _sections.where((ReadinessSection s) => s.isUnlocked).length;
  double get readinessProgress => _sections.isEmpty ? 0.0 : unlockedCount / _sections.length;
  int get kitItemsChecked => _kitItems.where((KitItem k) => k.isChecked).length;
  int get kitItemsTotal => _kitItems.length;
  double get kitProgress => kitItemsTotal == 0 ? 0.0 : kitItemsChecked / kitItemsTotal;

  void setSections(List<ReadinessSection> sections) {
    _sections = sections;
    notifyListeners();
  }

  void setKitItems(List<KitItem> items) {
    _kitItems = items;
    notifyListeners();
  }

  void updateKitItem(KitItem item) {
    _kitItems = _kitItems.map((KitItem k) => k.id == item.id ? item : k).toList();
    notifyListeners();
  }

  void setUnlockHints(Map<ReadinessSectionType, String?> hints) {
    _unlockHints = hints;
    notifyListeners();
  }

  void setLoading(bool loading) {
    _isLoading = loading;
    notifyListeners();
  }

  void setError(String? error) {
    _error = error;
    notifyListeners();
  }
}
