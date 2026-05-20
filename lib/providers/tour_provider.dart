import 'dart:async';
import 'package:flutter/foundation.dart';

import 'package:lifetours/models/models.dart';
import 'package:lifetours/services/services.dart';

class TourProvider extends ChangeNotifier {
  final FirestoreService _firestoreService = FirestoreService();

  List<TourModel> _tours = [];
  List<TourModel> _toursByDestination = [];
  TourModel? _selectedTour;
  bool _loading = true;
  String? _error;
  StreamSubscription? _toursSubscription;

  List<TourModel> get tours => _tours;
  List<TourModel> get toursByDestination => _toursByDestination;
  TourModel? get selectedTour => _selectedTour;
  bool get loading => _loading;
  String? get error => _error;

  TourProvider() {
    _initListener();
  }

  void _initListener() {
    _loading = true;
    notifyListeners();
    _toursSubscription = _firestoreService.toursStream().listen(
      (tours) {
        _tours = tours;
        _loading = false;
        _error = null;
        notifyListeners();
      },
      onError: (e) {
        _error = 'Error al cargar tours.';
        _loading = false;
        notifyListeners();
      },
    );
  }

  StreamSubscription? _toursByDestinationSubscription;

  void loadToursByDestination(String destinationId) {
    _toursByDestinationSubscription?.cancel();
    _toursByDestinationSubscription =
        _firestoreService.toursByDestinationStream(destinationId).listen(
      (tours) {
        _toursByDestination = tours;
        notifyListeners();
      },
      onError: (e) {
        _error = 'Error al cargar tours.';
        notifyListeners();
      },
    );
  }

  void selectTour(TourModel? tour) {
    _selectedTour = tour;
    notifyListeners();
  }

  Future<void> refresh() async {
    _loading = true;
    notifyListeners();
    try {
      _tours = await _firestoreService.getTours();
      _error = null;
    } catch (e) {
      _error = 'Error al cargar tours.';
    }
    _loading = false;
    notifyListeners();
  }

  @override
  void dispose() {
    _toursSubscription?.cancel();
    _toursByDestinationSubscription?.cancel();
    super.dispose();
  }
}
