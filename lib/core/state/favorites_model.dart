// favorites_model.dart
import 'package:flutter/foundation.dart';

/// ChangeNotifier that tracks a set of favourite product IDs.
class FavoritesModel extends ChangeNotifier {
  final Set<String> _ids = {};

  /// Returns an unmodifiable view of the current favourite IDs.
  Set<String> get ids => Set.unmodifiable(_ids);

  /// Returns `true` if [id] is in the favourites list.
  bool contains(String id) => _ids.contains(id);

  /// Adds [id] if it is not present, removes it if it is.
  void toggle(String id) {
    if (_ids.contains(id)) {
      _ids.remove(id);
    } else {
      _ids.add(id);
    }
    notifyListeners();
  }

  /// Removes all favourites.
  void clear() {
    _ids.clear();
    notifyListeners();
  }
}
