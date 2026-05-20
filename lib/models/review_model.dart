import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:equatable/equatable.dart';

/// Modelo que representa un documento de la colección [reviews] en Firestore.
///
/// Estructura en Firestore:
/// ```
/// reviews/{reviewId}
///   ├── userId:        String     (referencia a users/{uid})
///   ├── userName:      String     (desnormalizado)
///   ├── userPhotoUrl:  String?    (desnormalizado)
///   ├── tourId:        String     (referencia a tours/{id})
///   ├── tourTitle:     String     (desnormalizado)
///   ├── rating:        int        (1 – 5)
///   ├── comment:       String
///   └── createdAt:     Timestamp
/// ```
///
/// Nota: al crear/eliminar una reseña se debe actualizar
/// [tours/{tourId}.averageRating] y [tours/{tourId}.reviewCount]
/// usando una Cloud Function o una transacción de Firestore.
class ReviewModel extends Equatable {
  final String id;
  final String userId;
  final String userName;
  final String? userPhotoUrl;
  final String tourId;
  final String tourTitle;
  final int rating; // 1–5
  final String comment;
  final DateTime createdAt;

  const ReviewModel({
    required this.id,
    required this.userId,
    required this.userName,
    this.userPhotoUrl,
    required this.tourId,
    required this.tourTitle,
    required this.rating,
    required this.comment,
    required this.createdAt,
  }) : assert(rating >= 1 && rating <= 5, 'rating debe estar entre 1 y 5');

  // ── Firestore ────────────────────────────────────────────────────────────────

  factory ReviewModel.fromMap(Map<String, dynamic> map, String id) {
    return ReviewModel(
      id: id,
      userId: map['userId'] as String,
      userName: map['userName'] as String,
      userPhotoUrl: map['userPhotoUrl'] as String?,
      tourId: map['tourId'] as String,
      tourTitle: map['tourTitle'] as String,
      rating: map['rating'] as int,
      comment: map['comment'] as String,
      createdAt: (map['createdAt'] as Timestamp).toDate(),
    );
  }

  factory ReviewModel.fromDocumentSnapshot(DocumentSnapshot doc) {
    return ReviewModel.fromMap(doc.data() as Map<String, dynamic>, doc.id);
  }

  Map<String, dynamic> toMap() => {
        'userId': userId,
        'userName': userName,
        'userPhotoUrl': userPhotoUrl,
        'tourId': tourId,
        'tourTitle': tourTitle,
        'rating': rating,
        'comment': comment,
        'createdAt': Timestamp.fromDate(createdAt),
      };

  // ── Utilidades ───────────────────────────────────────────────────────────────

  ReviewModel copyWith({
    int? rating,
    String? comment,
  }) {
    return ReviewModel(
      id: id,
      userId: userId,
      userName: userName,
      userPhotoUrl: userPhotoUrl,
      tourId: tourId,
      tourTitle: tourTitle,
      rating: rating ?? this.rating,
      comment: comment ?? this.comment,
      createdAt: createdAt,
    );
  }

  @override
  List<Object?> get props =>
      [id, userId, tourId, rating, comment, createdAt];

  @override
  String toString() =>
      'ReviewModel(id: $id, user: $userName, tour: $tourTitle, rating: $rating)';
}
