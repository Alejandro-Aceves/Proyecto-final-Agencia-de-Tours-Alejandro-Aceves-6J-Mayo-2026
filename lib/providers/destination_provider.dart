import 'dart:async';
import 'package:flutter/foundation.dart';

import 'package:lifetours/models/models.dart';
import 'package:lifetours/services/services.dart';

class DestinationProvider extends ChangeNotifier {
  final FirestoreService _firestoreService = FirestoreService();

  List<DestinationModel> _destinations = [];
  DestinationModel? _selectedDestination;
  bool _loading = true;
  String? _error;
  StreamSubscription? _destinationsSubscription;

  List<DestinationModel> get destinations => _destinations;
  DestinationModel? get selectedDestination => _selectedDestination;
  bool get loading => _loading;
  String? get error => _error;

  DestinationProvider() {
    _initListener();
  }

  void _initListener() {
    _loading = true;
    notifyListeners();
    _destinationsSubscription =
        _firestoreService.destinationsStream().listen((destinations) {
      _destinations = destinations;
      _loading = false;
      _error = null;
      notifyListeners();
    }, onError: (e) {
      _error = 'Error al cargar destinos.';
      _loading = false;
      notifyListeners();
    });
  }

  Future<void> loadDestinations() async {
    _loading = true;
    notifyListeners();
    try {
      _destinations = await _firestoreService.getDestinations();
      _error = null;
    } catch (e) {
      _error = 'Error al cargar destinos.';
    }
    _loading = false;
    notifyListeners();
  }

  void selectDestination(DestinationModel? destination) {
    _selectedDestination = destination;
    notifyListeners();
  }

  Future<void> refresh() async {
    await loadDestinations();
  }

  @override
  void dispose() {
    _destinationsSubscription?.cancel();
    super.dispose();
  }
}
