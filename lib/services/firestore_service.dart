import 'package:cloud_firestore/cloud_firestore.dart';

import 'package:lifetours/models/models.dart';
import 'package:lifetours/models/firestore_constants.dart';

class FirestoreService {
  final FirebaseFirestore _firestore = FirebaseFirestore.instance;

  // ── Destinations ───────────────────────────────────────────────────────────

  Stream<List<DestinationModel>> destinationsStream() {
    return _firestore
        .collection(FirestoreCollections.destinations)
        .orderBy(DestinationFields.createdAt, descending: true)
        .snapshots()
        .map((snap) => snap.docs
            .map((doc) => DestinationModel.fromDocumentSnapshot(doc))
            .where((d) => d.isActive)
            .toList());
  }

  Future<List<DestinationModel>> getDestinations() async {
    final snap = await _firestore
        .collection(FirestoreCollections.destinations)
        .orderBy(DestinationFields.createdAt, descending: true)
        .get();
    return snap.docs
        .map((doc) => DestinationModel.fromDocumentSnapshot(doc))
        .where((d) => d.isActive)
        .toList();
  }

  Stream<DestinationModel?> destinationStream(String id) {
    return _firestore
        .collection(FirestoreCollections.destinations)
        .doc(id)
        .snapshots()
        .map((doc) => doc.exists ? DestinationModel.fromDocumentSnapshot(doc) : null);
  }

  Future<DestinationModel?> getDestination(String id) async {
    final doc = await _firestore.collection(FirestoreCollections.destinations).doc(id).get();
    if (!doc.exists) return null;
    return DestinationModel.fromDocumentSnapshot(doc);
  }

  Future<void> addDestination(DestinationModel destination) async {
    await _firestore.collection(FirestoreCollections.destinations).doc(destination.id).set(destination.toMap());
  }

  Future<void> updateDestination(DestinationModel destination) async {
    await _firestore.collection(FirestoreCollections.destinations).doc(destination.id).update(destination.toMap());
  }

  Future<void> deleteDestination(String id) async {
    await _firestore.collection(FirestoreCollections.destinations).doc(id).update({DestinationFields.isActive: false});
  }

  // ── Tours ──────────────────────────────────────────────────────────────────

  Stream<List<TourModel>> toursStream() {
    return _firestore
        .collection(FirestoreCollections.tours)
        .orderBy(TourFields.createdAt, descending: true)
        .snapshots()
        .map((snap) => snap.docs
            .map((doc) => TourModel.fromDocumentSnapshot(doc))
            .where((t) => t.isActive)
            .toList());
  }

  Future<List<TourModel>> getTours() async {
    final snap = await _firestore
        .collection(FirestoreCollections.tours)
        .orderBy(TourFields.createdAt, descending: true)
        .get();
    return snap.docs
        .map((doc) => TourModel.fromDocumentSnapshot(doc))
        .where((t) => t.isActive)
        .toList();
  }

  Future<List<TourModel>> getToursByDestination(String destinationId) async {
    final snap = await _firestore
        .collection(FirestoreCollections.tours)
        .where(TourFields.destinationId, isEqualTo: destinationId)
        .get();
    return snap.docs
        .map((doc) => TourModel.fromDocumentSnapshot(doc))
        .where((t) => t.isActive)
        .toList();
  }

  Stream<List<TourModel>> toursByDestinationStream(String destinationId) {
    return _firestore
        .collection(FirestoreCollections.tours)
        .where(TourFields.destinationId, isEqualTo: destinationId)
        .snapshots()
        .map((snap) => snap.docs
            .map((doc) => TourModel.fromDocumentSnapshot(doc))
            .where((t) => t.isActive)
            .toList());
  }

  Stream<TourModel?> tourStream(String id) {
    return _firestore
        .collection(FirestoreCollections.tours)
        .doc(id)
        .snapshots()
        .map((doc) => doc.exists ? TourModel.fromDocumentSnapshot(doc) : null);
  }

  Future<TourModel?> getTour(String id) async {
    final doc = await _firestore.collection(FirestoreCollections.tours).doc(id).get();
    if (!doc.exists) return null;
    return TourModel.fromDocumentSnapshot(doc);
  }

  Future<void> addTour(TourModel tour) async {
    await _firestore.collection(FirestoreCollections.tours).doc(tour.id).set(tour.toMap());
  }

  Future<void> updateTour(TourModel tour) async {
    await _firestore.collection(FirestoreCollections.tours).doc(tour.id).update(tour.toMap());
  }

  Future<void> deleteTour(String id) async {
    await _firestore.collection(FirestoreCollections.tours).doc(id).update({TourFields.isActive: false});
  }

  // ── Reservations ───────────────────────────────────────────────────────────

  Stream<List<ReservationModel>> userReservationsStream(String userId) {
    return _firestore
        .collection(FirestoreCollections.reservations)
        .where(ReservationFields.userId, isEqualTo: userId)
        .orderBy(ReservationFields.createdAt, descending: true)
        .snapshots()
        .map((snap) => snap.docs.map((doc) => ReservationModel.fromDocumentSnapshot(doc)).toList());
  }

  Stream<List<ReservationModel>> allReservationsStream() {
    return _firestore
        .collection(FirestoreCollections.reservations)
        .orderBy(ReservationFields.createdAt, descending: true)
        .snapshots()
        .map((snap) => snap.docs.map((doc) => ReservationModel.fromDocumentSnapshot(doc)).toList());
  }

  Future<List<ReservationModel>> getUserReservations(String userId) async {
    final snap = await _firestore
        .collection(FirestoreCollections.reservations)
        .where(ReservationFields.userId, isEqualTo: userId)
        .orderBy(ReservationFields.createdAt, descending: true)
        .get();
    return snap.docs.map((doc) => ReservationModel.fromDocumentSnapshot(doc)).toList();
  }

  Future<void> addReservation(ReservationModel reservation) async {
    await _firestore.collection(FirestoreCollections.reservations).doc(reservation.id).set(reservation.toMap());
  }

  Future<void> updateReservationStatus(String id, String status) async {
    await _firestore.collection(FirestoreCollections.reservations).doc(id).update({ReservationFields.status: status});
  }

  // ── Reviews ────────────────────────────────────────────────────────────────

  Stream<List<ReviewModel>> reviewsStream() {
    return _firestore
        .collection(FirestoreCollections.reviews)
        .orderBy(ReviewFields.createdAt, descending: true)
        .snapshots()
        .map((snap) => snap.docs.map((doc) => ReviewModel.fromDocumentSnapshot(doc)).toList());
  }

  Stream<List<ReviewModel>> reviewsByTourStream(String tourId) {
    return _firestore
        .collection(FirestoreCollections.reviews)
        .where(ReviewFields.tourId, isEqualTo: tourId)
        .orderBy(ReviewFields.createdAt, descending: true)
        .snapshots()
        .map((snap) => snap.docs.map((doc) => ReviewModel.fromDocumentSnapshot(doc)).toList());
  }

  Future<List<ReviewModel>> getReviewsByTour(String tourId) async {
    final snap = await _firestore
        .collection(FirestoreCollections.reviews)
        .where(ReviewFields.tourId, isEqualTo: tourId)
        .orderBy(ReviewFields.createdAt, descending: true)
        .get();
    return snap.docs.map((doc) => ReviewModel.fromDocumentSnapshot(doc)).toList();
  }

  Future<void> addReview(ReviewModel review) async {
    await _firestore.collection(FirestoreCollections.reviews).doc(review.id).set(review.toMap());
  }

  // ── Favorites ──────────────────────────────────────────────────────────────

  Stream<List<FavoriteModel>> userFavoritesStream(String userId) {
    return _firestore
        .collection(FirestoreCollections.users)
        .doc(userId)
        .collection(FirestoreCollections.favorites)
        .orderBy(FavoriteFields.savedAt, descending: true)
        .snapshots()
        .map((snap) => snap.docs.map((doc) => FavoriteModel.fromDocumentSnapshot(doc)).toList());
  }

  Future<List<FavoriteModel>> getUserFavorites(String userId) async {
    final snap = await _firestore
        .collection(FirestoreCollections.users)
        .doc(userId)
        .collection(FirestoreCollections.favorites)
        .orderBy(FavoriteFields.savedAt, descending: true)
        .get();
    return snap.docs.map((doc) => FavoriteModel.fromDocumentSnapshot(doc)).toList();
  }

  Future<bool> isFavorite(String userId, String tourId) async {
    final doc = await _firestore
        .collection(FirestoreCollections.users)
        .doc(userId)
        .collection(FirestoreCollections.favorites)
        .doc(tourId)
        .get();
    return doc.exists;
  }

  Future<void> addFavorite(String userId, FavoriteModel favorite) async {
    await _firestore
        .collection(FirestoreCollections.users)
        .doc(userId)
        .collection(FirestoreCollections.favorites)
        .doc(favorite.tourId)
        .set(favorite.toMap());
  }

  Future<void> removeFavorite(String userId, String tourId) async {
    await _firestore
        .collection(FirestoreCollections.users)
        .doc(userId)
        .collection(FirestoreCollections.favorites)
        .doc(tourId)
        .delete();
  }

  // ── Users ──────────────────────────────────────────────────────────────────

  Stream<List<UserModel>> allUsersStream() {
    return _firestore
        .collection(FirestoreCollections.users)
        .orderBy(UserFields.createdAt, descending: true)
        .snapshots()
        .map((snap) => snap.docs.map((doc) => UserModel.fromDocumentSnapshot(doc)).toList());
  }

  Future<List<UserModel>> getAllUsers() async {
    final snap = await _firestore
        .collection(FirestoreCollections.users)
        .orderBy(UserFields.createdAt, descending: true)
        .get();
    return snap.docs.map((doc) => UserModel.fromDocumentSnapshot(doc)).toList();
  }

  Future<void> updateUser(UserModel user) async {
    await _firestore.collection(FirestoreCollections.users).doc(user.uid).update(user.toMap());
  }
}
