import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:equatable/equatable.dart';

/// Roles posibles de un usuario en la aplicación.
enum UserRole { user, admin }

/// Modelo que representa un documento de la colección [users] en Firestore.
///
/// Estructura en Firestore:
/// ```
/// users/{uid}
///   ├── name:        String
///   ├── email:       String
///   ├── role:        "user" | "admin"
///   ├── photoUrl:    String?
///   ├── phone:       String?
///   ├── darkMode:    bool
///   ├── language:    String
///   └── createdAt:   Timestamp
/// ```
class UserModel extends Equatable {
  final String uid;
  final String name;
  final String email;
  final UserRole role;
  final String? photoUrl;
  final String? phone;
  final bool darkMode;
  final String language;
  final DateTime createdAt;

  const UserModel({
    required this.uid,
    required this.name,
    required this.email,
    this.role = UserRole.user,
    this.photoUrl,
    this.phone,
    this.darkMode = false,
    this.language = 'es',
    required this.createdAt,
  });

  bool get isAdmin => role == UserRole.admin;

  // ── Firestore ────────────────────────────────────────────────────────────────

  factory UserModel.fromMap(Map<String, dynamic> map, String uid) {
    return UserModel(
      uid: uid,
      name: map['name'] as String,
      email: map['email'] as String,
      role: (map['role'] as String?) == 'admin' ? UserRole.admin : UserRole.user,
      photoUrl: map['photoUrl'] as String?,
      phone: map['phone'] as String?,
      darkMode: map['darkMode'] as bool? ?? false,
      language: map['language'] as String? ?? 'es',
      createdAt: (map['createdAt'] as Timestamp).toDate(),
    );
  }

  factory UserModel.fromDocumentSnapshot(DocumentSnapshot doc) {
    return UserModel.fromMap(doc.data() as Map<String, dynamic>, doc.id);
  }

  Map<String, dynamic> toMap() => {
        'name': name,
        'email': email,
        'role': role.name,
        'photoUrl': photoUrl,
        'phone': phone,
        'darkMode': darkMode,
        'language': language,
        'createdAt': Timestamp.fromDate(createdAt),
      };

  // ── Utilidades ───────────────────────────────────────────────────────────────

  UserModel copyWith({
    String? name,
    String? email,
    UserRole? role,
    String? photoUrl,
    String? phone,
    bool? darkMode,
    String? language,
  }) {
    return UserModel(
      uid: uid,
      name: name ?? this.name,
      email: email ?? this.email,
      role: role ?? this.role,
      photoUrl: photoUrl ?? this.photoUrl,
      phone: phone ?? this.phone,
      darkMode: darkMode ?? this.darkMode,
      language: language ?? this.language,
      createdAt: createdAt,
    );
  }

  @override
  List<Object?> get props =>
      [uid, name, email, role, photoUrl, phone, darkMode, language, createdAt];

  @override
  String toString() => 'UserModel(uid: $uid, name: $name, role: ${role.name})';
}
