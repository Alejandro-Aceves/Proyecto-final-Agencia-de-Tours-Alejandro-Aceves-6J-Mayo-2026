import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:equatable/equatable.dart';

/// Modelo que representa un documento de la colección [destinations] en Firestore.
///
/// Estructura en Firestore:
/// ```
/// destinations/{destinationId}
///   ├── name:         String          (ej. "Barcelona")
///   ├── country:      String          (ej. "España")
///   ├── city:         String
///   ├── description:  String
///   ├── imageUrl:     String
///   ├── activities:   List<String>    (ej. ["Restaurantes", "Cultura", "Museos"])
///   ├── isActive:     bool
///   └── createdAt:    Timestamp
/// ```
class DestinationModel extends Equatable {
  final String id;
  final String name;
  final String country;
  final String city;
  final String description;
  final String imageUrl;
  final List<String> activities;
  final bool isActive;
  final DateTime createdAt;

  const DestinationModel({
    required this.id,
    required this.name,
    required this.country,
    required this.city,
    required this.description,
    required this.imageUrl,
    this.activities = const [],
    this.isActive = true,
    required this.createdAt,
  });

  // ── Firestore ────────────────────────────────────────────────────────────────

  factory DestinationModel.fromMap(Map<String, dynamic> map, String id) {
    return DestinationModel(
      id: id,
      name: map['name'] as String,
      country: map['country'] as String,
      city: map['city'] as String,
      description: map['description'] as String,
      imageUrl: map['imageUrl'] as String,
      activities: List<String>.from(map['activities'] as List? ?? []),
      isActive: map['isActive'] as bool? ?? true,
      createdAt: (map['createdAt'] as Timestamp).toDate(),
    );
  }

  factory DestinationModel.fromDocumentSnapshot(DocumentSnapshot doc) {
    return DestinationModel.fromMap(doc.data() as Map<String, dynamic>, doc.id);
  }

  Map<String, dynamic> toMap() => {
        'name': name,
        'country': country,
        'city': city,
        'description': description,
        'imageUrl': imageUrl,
        'activities': activities,
        'isActive': isActive,
        'createdAt': Timestamp.fromDate(createdAt),
      };

  // ── Utilidades ───────────────────────────────────────────────────────────────

  DestinationModel copyWith({
    String? name,
    String? country,
    String? city,
    String? description,
    String? imageUrl,
    List<String>? activities,
    bool? isActive,
  }) {
    return DestinationModel(
      id: id,
      name: name ?? this.name,
      country: country ?? this.country,
      city: city ?? this.city,
      description: description ?? this.description,
      imageUrl: imageUrl ?? this.imageUrl,
      activities: activities ?? this.activities,
      isActive: isActive ?? this.isActive,
      createdAt: createdAt,
    );
  }

  @override
  List<Object?> get props =>
      [id, name, country, city, description, imageUrl, activities, isActive, createdAt];

  @override
  String toString() => 'DestinationModel(id: $id, name: $name, country: $country)';
}
