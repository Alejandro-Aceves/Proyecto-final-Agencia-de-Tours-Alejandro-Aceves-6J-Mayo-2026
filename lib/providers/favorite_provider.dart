import 'dart:async';
import 'package:flutter/foundation.dart';

import 'package:lifetours/models/models.dart';
import 'package:lifetours/services/services.dart';

class FavoriteProvider extends ChangeNotifier {
  final FirestoreService _firestoreService = FirestoreService();

  List<FavoriteModel> _favorites = [];
  bool _loading = false;
  String? _error;
  String? _userId;
  StreamSubscription? _favoritesSubscription;

  List<FavoriteModel> get favorites => _favorites;
  bool get loading => _loading;
  String? get error => _error;
  String? get userId => _userId;

  void init(String userId) {
    if (_userId == userId) return;
    _favoritesSubscription?.cancel();
    _userId = userId;
    _loading = true;
    notifyListeners();
    _favoritesSubscription =
        _firestoreService.userFavoritesStream(userId).listen((favorites) {
      _favorites = favorites;
      _loading = false;
      notifyListeners();
    }, onError: (e) {
      _error = 'Error al cargar favoritos.';
      _loading = false;
      notifyListeners();
    });
  }

  @override
  void dispose() {
    _favoritesSubscription?.cancel();
    super.dispose();
  }

  Future<bool> isFavorite(String tourId) async {
    if (_userId == null) return false;
    return _firestoreService.isFavorite(_userId!, tourId);
  }

  Future<void> toggleFavorite({
    required String tourId,
    required String tourTitle,
    required String tourImageUrl,
    required String destinationName,
    required double price,
  }) async {
    if (_userId == null) return;
    try {
      final alreadyFav = await _firestoreService.isFavorite(_userId!, tourId);
      if (alreadyFav) {
        await _firestoreService.removeFavorite(_userId!, tourId);
      } else {
        await _firestoreService.addFavorite(
          _userId!,
          FavoriteModel(
            tourId: tourId,
            tourTitle: tourTitle,
            tourImageUrl: tourImageUrl,
            destinationName: destinationName,
            price: price,
            savedAt: DateTime.now(),
          ),
        );
      }
    } catch (e) {
      _error = 'Error al actualizar favoritos.';
      notifyListeners();
    }
  }

  void clearError() {
    _error = null;
    notifyListeners();
  }
}
