/// Constantes con los nombres de colecciones y campos de Firestore.
/// Usar estas constantes evita errores por typos en strings.
///
/// Ejemplo de uso:
/// ```dart
/// FirebaseFirestore.instance
///   .collection(FirestoreCollections.tours)
///   .where(TourFields.isActive, isEqualTo: true)
///   .get();
/// ```
library firestore_constants;

// ── Nombres de colecciones ────────────────────────────────────────────────────

class FirestoreCollections {
  FirestoreCollections._();

  static const String users        = 'users';
  static const String destinations = 'destinations';
  static const String tours        = 'tours';
  static const String reservations = 'reservations';
  static const String reviews      = 'reviews';

  // Subcolección dentro de users/{uid}
  static const String favorites    = 'favorites';
}

// ── Campos por colección ──────────────────────────────────────────────────────

class UserFields {
  UserFields._();
  static const String name      = 'name';
  static const String email     = 'email';
  static const String role      = 'role';
  static const String photoUrl  = 'photoUrl';
  static const String phone     = 'phone';
  static const String createdAt = 'createdAt';
}

class DestinationFields {
  DestinationFields._();
  static const String name        = 'name';
  static const String country     = 'country';
  static const String city        = 'city';
  static const String description = 'description';
  static const String imageUrl    = 'imageUrl';
  static const String activities  = 'activities';
  static const String isActive    = 'isActive';
  static const String createdAt   = 'createdAt';
}

class TourFields {
  TourFields._();
  static const String title           = 'title';
  static const String description     = 'description';
  static const String price           = 'price';
  static const String imageUrl        = 'imageUrl';
  static const String destinationId   = 'destinationId';
  static const String destinationName = 'destinationName';
  static const String categories      = 'categories';
  static const String durationDays    = 'durationDays';
  static const String capacity        = 'capacity';
  static const String availableSpots  = 'availableSpots';
  static const String averageRating   = 'averageRating';
  static const String reviewCount     = 'reviewCount';
  static const String isActive        = 'isActive';
  static const String createdAt       = 'createdAt';
}

class ReservationFields {
  ReservationFields._();
  static const String userId          = 'userId';
  static const String userName        = 'userName';
  static const String tourId          = 'tourId';
  static const String tourTitle       = 'tourTitle';
  static const String tourImageUrl    = 'tourImageUrl';
  static const String destinationName = 'destinationName';
  static const String pricePerPerson  = 'pricePerPerson';
  static const String participants    = 'participants';
  static const String totalPrice      = 'totalPrice';
  static const String travelDate      = 'travelDate';
  static const String status          = 'status';
  static const String notes           = 'notes';
  static const String createdAt       = 'createdAt';
}

class ReviewFields {
  ReviewFields._();
  static const String userId       = 'userId';
  static const String userName     = 'userName';
  static const String userPhotoUrl = 'userPhotoUrl';
  static const String tourId       = 'tourId';
  static const String tourTitle    = 'tourTitle';
  static const String rating       = 'rating';
  static const String comment      = 'comment';
  static const String createdAt    = 'createdAt';
}

class FavoriteFields {
  FavoriteFields._();
  static const String tourId          = 'tourId';
  static const String tourTitle       = 'tourTitle';
  static const String tourImageUrl    = 'tourImageUrl';
  static const String destinationName = 'destinationName';
  static const String price           = 'price';
  static const String savedAt         = 'savedAt';
}
