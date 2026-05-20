import 'package:flutter/foundation.dart';
import 'package:uuid/uuid.dart';

import 'package:lifetours/models/models.dart';
import 'package:lifetours/services/services.dart';

class ReviewProvider extends ChangeNotifier {
  final FirestoreService _firestoreService = FirestoreService();

  List<ReviewModel> _reviews = [];
  bool _loading = false;
  String? _error;

  List<ReviewModel> get reviews => _reviews;
  bool get loading => _loading;
  String? get error => _error;

  ReviewProvider() {
    _initListener();
  }

  void _initListener() {
    _firestoreService.reviewsStream().listen((reviews) {
      _reviews = reviews;
      _loading = false;
      notifyListeners();
    }).onError((e) {
      _error = 'Error al cargar opiniones.';
      _loading = false;
      notifyListeners();
    });
  }

  Future<bool> addReview({
    required String userId,
    required String userName,
    String? userPhotoUrl,
    required String tourId,
    required String tourTitle,
    required int rating,
    required String comment,
  }) async {
    _loading = true;
    _error = null;
    notifyListeners();
    try {
      final review = ReviewModel(
        id: const Uuid().v4(),
        userId: userId,
        userName: userName,
        userPhotoUrl: userPhotoUrl,
        tourId: tourId,
        tourTitle: tourTitle,
        rating: rating,
        comment: comment,
        createdAt: DateTime.now(),
      );
      await _firestoreService.addReview(review);
      _loading = false;
      notifyListeners();
      return true;
    } catch (e) {
      _error = 'Error al publicar la opinión. Intenta de nuevo.';
      _loading = false;
      notifyListeners();
      return false;
    }
  }

  void clearError() {
    _error = null;
    notifyListeners();
  }
}
