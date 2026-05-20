import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:equatable/equatable.dart';

/// Categorías disponibles para clasificar un tour.
enum TourCategory { cultura, agua, aireLibre, comida, templos, museos, historia, restaurantes }

extension TourCategoryExtension on TourCategory {
  String get label {
    switch (this) {
      case TourCategory.cultura:
        return 'Cultura';
      case TourCategory.agua:
        return 'Agua';
      case TourCategory.aireLibre:
        return 'Al aire libre';
      case TourCategory.comida:
        return 'Comida';
      case TourCategory.templos:
        return 'Templos';
      case TourCategory.museos:
        return 'Museos';
      case TourCategory.historia:
        return 'Historia';
      case TourCategory.restaurantes:
        return 'Restaurantes';
    }
  }

  static TourCategory fromString(String value) {
    return TourCategory.values.firstWhere(
      (e) => e.name == value,
      orElse: () => TourCategory.cultura,
    );
  }
}

/// Modelo que representa un documento de la colección [tours] en Firestore.
///
/// Estructura en Firestore:
/// ```
/// tours/{tourId}
///   ├── title:             String
///   ├── description:       String
///   ├── price:             double        (precio por persona en MXN)
///   ├── imageUrl:          String
///   ├── destinationId:     String        (referencia a destinations/{id})
///   ├── destinationName:   String        (desnormalizado para queries rápidos)
///   ├── categories:        List<String>  (nombres de TourCategory)
///   ├── durationDays:      int
///   ├── capacity:          int           (cupos totales)
///   ├── availableSpots:    int
///   ├── averageRating:     double
///   ├── reviewCount:       int
///   ├── isActive:          bool
///   └── createdAt:         Timestamp
/// ```
class TourModel extends Equatable {
  final String id;
  final String title;
  final String description;
  final double price;
  final String imageUrl;
  final String destinationId;
  final String destinationName;
  final List<TourCategory> categories;
  final int durationDays;
  final int capacity;
  final int availableSpots;
  final double averageRating;
  final int reviewCount;
  final bool isActive;
  final DateTime createdAt;

  const TourModel({
    required this.id,
    required this.title,
    required this.description,
    required this.price,
    required this.imageUrl,
    required this.destinationId,
    required this.destinationName,
    this.categories = const [],
    this.durationDays = 1,
    required this.capacity,
    required this.availableSpots,
    this.averageRating = 0.0,
    this.reviewCount = 0,
    this.isActive = true,
    required this.createdAt,
  });

  bool get hasAvailability => availableSpots > 0;

  // ── Firestore ────────────────────────────────────────────────────────────────

  factory TourModel.fromMap(Map<String, dynamic> map, String id) {
    return TourModel(
      id: id,
      title: map['title'] as String,
      description: map['description'] as String,
      price: (map['price'] as num).toDouble(),
      imageUrl: map['imageUrl'] as String,
      destinationId: map['destinationId'] as String,
      destinationName: map['destinationName'] as String,
      categories: (map['categories'] as List? ?? [])
          .map((c) => TourCategoryExtension.fromString(c as String))
          .toList(),
      durationDays: map['durationDays'] as int? ?? 1,
      capacity: map['capacity'] as int,
      availableSpots: map['availableSpots'] as int,
      averageRating: (map['averageRating'] as num? ?? 0).toDouble(),
      reviewCount: map['reviewCount'] as int? ?? 0,
      isActive: map['isActive'] as bool? ?? true,
      createdAt: (map['createdAt'] as Timestamp).toDate(),
    );
  }

  factory TourModel.fromDocumentSnapshot(DocumentSnapshot doc) {
    return TourModel.fromMap(doc.data() as Map<String, dynamic>, doc.id);
  }

  Map<String, dynamic> toMap() => {
        'title': title,
        'description': description,
        'price': price,
        'imageUrl': imageUrl,
        'destinationId': destinationId,
        'destinationName': destinationName,
        'categories': categories.map((c) => c.name).toList(),
        'durationDays': durationDays,
        'capacity': capacity,
        'availableSpots': availableSpots,
        'averageRating': averageRating,
        'reviewCount': reviewCount,
        'isActive': isActive,
        'createdAt': Timestamp.fromDate(createdAt),
      };

  // ── Utilidades ───────────────────────────────────────────────────────────────

  TourModel copyWith({
    String? title,
    String? description,
    double? price,
    String? imageUrl,
    String? destinationId,
    String? destinationName,
    List<TourCategory>? categories,
    int? durationDays,
    int? capacity,
    int? availableSpots,
    double? averageRating,
    int? reviewCount,
    bool? isActive,
  }) {
    return TourModel(
      id: id,
      title: title ?? this.title,
      description: description ?? this.description,
      price: price ?? this.price,
      imageUrl: imageUrl ?? this.imageUrl,
      destinationId: destinationId ?? this.destinationId,
      destinationName: destinationName ?? this.destinationName,
      categories: categories ?? this.categories,
      durationDays: durationDays ?? this.durationDays,
      capacity: capacity ?? this.capacity,
      availableSpots: availableSpots ?? this.availableSpots,
      averageRating: averageRating ?? this.averageRating,
      reviewCount: reviewCount ?? this.reviewCount,
      isActive: isActive ?? this.isActive,
      createdAt: createdAt,
    );
  }

  @override
  List<Object?> get props => [
        id, title, description, price, imageUrl, destinationId,
        destinationName, categories, durationDays, capacity,
        availableSpots, averageRating, reviewCount, isActive, createdAt,
      ];

  @override
  String toString() => 'TourModel(id: $id, title: $title, price: \$$price)';
}
