import 'dart:async';
import 'package:flutter/foundation.dart';
import 'package:uuid/uuid.dart';

import 'package:lifetours/models/models.dart';
import 'package:lifetours/services/services.dart';

class ReservationProvider extends ChangeNotifier {
  final FirestoreService _firestoreService = FirestoreService();

  List<ReservationModel> _reservations = [];
  bool _loading = false;
  String? _error;
  String? _userId;
  StreamSubscription? _reservationsSubscription;

  List<ReservationModel> get reservations => _reservations;
  bool get loading => _loading;
  String? get error => _error;
  String? get userId => _userId;

  void init(String userId) {
    if (_userId == userId) return;
    _reservationsSubscription?.cancel();
    _userId = userId;
    _loading = true;
    notifyListeners();
    _reservationsSubscription =
        _firestoreService.userReservationsStream(userId).listen(
      (reservations) {
        _reservations = reservations;
        _loading = false;
        notifyListeners();
      },
      onError: (e) {
        _error = 'Error al cargar reservas.';
        _loading = false;
        notifyListeners();
      },
    );
  }

  @override
  void dispose() {
    _reservationsSubscription?.cancel();
    super.dispose();
  }

  Future<bool> createReservation({
    required String userId,
    required String userName,
    required String tourId,
    required String tourTitle,
    required String tourImageUrl,
    required String destinationName,
    required double pricePerPerson,
    required int participants,
    required double totalPrice,
    required DateTime travelDate,
    String? notes,
  }) async {
    _loading = true;
    _error = null;
    notifyListeners();
    try {
      final reservation = ReservationModel(
        id: const Uuid().v4(),
        userId: userId,
        userName: userName,
        tourId: tourId,
        tourTitle: tourTitle,
        tourImageUrl: tourImageUrl,
        destinationName: destinationName,
        pricePerPerson: pricePerPerson,
        participants: participants,
        totalPrice: totalPrice,
        travelDate: travelDate,
        createdAt: DateTime.now(),
        notes: notes,
      );
      await _firestoreService.addReservation(reservation);
      _loading = false;
      notifyListeners();
      return true;
    } catch (e) {
      _error = 'Error al crear la reserva. Intenta de nuevo.';
      _loading = false;
      notifyListeners();
      return false;
    }
  }

  Future<bool> cancelReservation(String id) async {
    try {
      await _firestoreService.updateReservationStatus(id, 'cancelled');
      return true;
    } catch (e) {
      _error = 'Error al cancelar la reserva.';
      notifyListeners();
      return false;
    }
  }

  void clearError() {
    _error = null;
    notifyListeners();
  }
}
