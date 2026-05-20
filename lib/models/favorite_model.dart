import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:equatable/equatable.dart';

/// Modelo que representa un documento de la subcolección [favorites] en Firestore.
///
/// Ruta en Firestore:
/// ```
/// users/{userId}/favorites/{tourId}
///   ├── tourId:          String   (mismo que el id del documento)
///   ├── tourTitle:       String   (desnormalizado)
///   ├── tourImageUrl:    String   (desnormalizado)
///   ├── destinationName: String   (desnormalizado)
///   ├── price:           double   (desnormalizado)
///   └── savedAt:         Timestamp
/// ```
///
/// Se usa subcolección en lugar de array dentro de [users] para facilitar
/// paginación y consultas independientes.
class FavoriteModel extends Equatable {
  final String tourId;
  final String tourTitle;
  final String tourImageUrl;
  final String destinationName;
  final double price;
  final DateTime savedAt;

  const FavoriteModel({
    required this.tourId,
    required this.tourTitle,
    required this.tourImageUrl,
    required this.destinationName,
    required this.price,
    required this.savedAt,
  });

  // ── Firestore ────────────────────────────────────────────────────────────────

  factory FavoriteModel.fromMap(Map<String, dynamic> map, String tourId) {
    return FavoriteModel(
      tourId: tourId,
      tourTitle: map['tourTitle'] as String,
      tourImageUrl: map['tourImageUrl'] as String,
      destinationName: map['destinationName'] as String,
      price: (map['price'] as num).toDouble(),
      savedAt: (map['savedAt'] as Timestamp).toDate(),
    );
  }

  factory FavoriteModel.fromDocumentSnapshot(DocumentSnapshot doc) {
    return FavoriteModel.fromMap(doc.data() as Map<String, dynamic>, doc.id);
  }

  Map<String, dynamic> toMap() => {
        'tourId': tourId,
        'tourTitle': tourTitle,
        'tourImageUrl': tourImageUrl,
        'destinationName': destinationName,
        'price': price,
        'savedAt': Timestamp.fromDate(savedAt),
      };

  @override
  List<Object?> get props =>
      [tourId, tourTitle, tourImageUrl, destinationName, price, savedAt];

  @override
  String toString() => 'FavoriteModel(tourId: $tourId, tourTitle: $tourTitle)';
}
