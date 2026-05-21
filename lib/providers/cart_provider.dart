import 'dart:async';
import 'package:flutter/foundation.dart';
import 'package:lifetours/models/models.dart';
import 'package:lifetours/services/services.dart';

class CartProvider extends ChangeNotifier {
  final FirestoreService _firestoreService = FirestoreService();

  List<CartItemModel> _items = [];
  bool _loading = false;
  String? _error;
  String? _userId;
  StreamSubscription? _cartSubscription;

  List<CartItemModel> get items => List.unmodifiable(_items);
  bool get loading => _loading;
  String? get error => _error;
  String? get userId => _userId;
  int get totalItems => _items.length;
  double get grandTotal => _items.fold(0, (sum, item) => sum + item.totalPrice);

  bool containsTour(String tourId) => _items.any((item) => item.tourId == tourId);

  void init(String userId) {
    if (_userId == userId) return;
    _cartSubscription?.cancel();
    _userId = userId;
    _loading = true;
    notifyListeners();
    _cartSubscription =
        _firestoreService.userCartStream(userId).listen((items) {
      _items = items;
      _loading = false;
      notifyListeners();
    }, onError: (e) {
      _error = 'Error al cargar el carrito.';
      _loading = false;
      notifyListeners();
    });
  }

  @override
  void dispose() {
    _cartSubscription?.cancel();
    super.dispose();
  }

  Future<void> addItem(CartItemModel item) async {
    if (_userId == null) return;
    try {
      final existingIndex = _items.indexWhere((i) => i.tourId == item.tourId);
      if (existingIndex >= 0) {
        final combined =
            _items[existingIndex].participants + item.participants;
        await _firestoreService.updateCartItemParticipants(
            _userId!, item.tourId, combined);
      } else {
        await _firestoreService.addCartItem(_userId!, item);
      }
    } catch (e) {
      _error = 'Error al agregar al carrito.';
      notifyListeners();
    }
  }

  Future<void> removeItem(String tourId) async {
    if (_userId == null) return;
    try {
      await _firestoreService.removeCartItem(_userId!, tourId);
    } catch (e) {
      _error = 'Error al eliminar del carrito.';
      notifyListeners();
    }
  }

  Future<void> updateParticipants(String tourId, int participants) async {
    if (_userId == null) return;
    try {
      await _firestoreService.updateCartItemParticipants(
          _userId!, tourId, participants);
    } catch (e) {
      _error = 'Error al actualizar participantes.';
      notifyListeners();
    }
  }

  Future<void> clear() async {
    if (_userId == null) return;
    try {
      await _firestoreService.clearCart(_userId!);
    } catch (e) {
      _error = 'Error al limpiar el carrito.';
      notifyListeners();
    }
  }

  void clearError() {
    _error = null;
    notifyListeners();
  }
}
