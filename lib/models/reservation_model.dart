import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:equatable/equatable.dart';

/// Estado posible de una reserva.
enum ReservationStatus { pending, confirmed, cancelled, completed }

extension ReservationStatusExtension on ReservationStatus {
  String get label {
    switch (this) {
      case ReservationStatus.pending:
        return 'Pendiente';
      case ReservationStatus.confirmed:
        return 'Confirmada';
      case ReservationStatus.cancelled:
        return 'Cancelada';
      case ReservationStatus.completed:
        return 'Completada';
    }
  }

  static ReservationStatus fromString(String value) {
    return ReservationStatus.values.firstWhere(
      (e) => e.name == value,
      orElse: () => ReservationStatus.pending,
    );
  }
}

/// Modelo que representa un documento de la colección [reservations] en Firestore.
///
/// Estructura en Firestore:
/// ```
/// reservations/{reservationId}
///   ├── userId:          String        (referencia a users/{uid})
///   ├── userName:        String        (desnormalizado)
///   ├── tourId:          String        (referencia a tours/{id})
///   ├── tourTitle:       String        (desnormalizado)
///   ├── tourImageUrl:    String        (desnormalizado)
///   ├── destinationName: String        (desnormalizado)
///   ├── pricePerPerson:  double
///   ├── participants:    int
///   ├── totalPrice:      double
///   ├── travelDate:      Timestamp
///   ├── status:          "pending" | "confirmed" | "cancelled" | "completed"
///   ├── notes:           String?       (notas del usuario)
///   └── createdAt:       Timestamp
/// ```
class ReservationModel extends Equatable {
  final String id;
  final String userId;
  final String userName;
  final String tourId;
  final String tourTitle;
  final String tourImageUrl;
  final String destinationName;
  final double pricePerPerson;
  final int participants;
  final double totalPrice;
  final DateTime travelDate;
  final ReservationStatus status;
  final String? notes;
  final DateTime createdAt;

  const ReservationModel({
    required this.id,
    required this.userId,
    required this.userName,
    required this.tourId,
    required this.tourTitle,
    required this.tourImageUrl,
    required this.destinationName,
    required this.pricePerPerson,
    required this.participants,
    required this.totalPrice,
    required this.travelDate,
    this.status = ReservationStatus.pending,
    this.notes,
    required this.createdAt,
  });

  bool get isCancellable =>
      status == ReservationStatus.pending || status == ReservationStatus.confirmed;

  // ── Firestore ────────────────────────────────────────────────────────────────

  factory ReservationModel.fromMap(Map<String, dynamic> map, String id) {
    return ReservationModel(
      id: id,
      userId: map['userId'] as String,
      userName: map['userName'] as String,
      tourId: map['tourId'] as String,
      tourTitle: map['tourTitle'] as String,
      tourImageUrl: map['tourImageUrl'] as String,
      destinationName: map['destinationName'] as String,
      pricePerPerson: (map['pricePerPerson'] as num).toDouble(),
      participants: map['participants'] as int,
      totalPrice: (map['totalPrice'] as num).toDouble(),
      travelDate: (map['travelDate'] as Timestamp).toDate(),
      status: ReservationStatusExtension.fromString(map['status'] as String? ?? 'pending'),
      notes: map['notes'] as String?,
      createdAt: (map['createdAt'] as Timestamp).toDate(),
    );
  }

  factory ReservationModel.fromDocumentSnapshot(DocumentSnapshot doc) {
    return ReservationModel.fromMap(doc.data() as Map<String, dynamic>, doc.id);
  }

  Map<String, dynamic> toMap() => {
        'userId': userId,
        'userName': userName,
        'tourId': tourId,
        'tourTitle': tourTitle,
        'tourImageUrl': tourImageUrl,
        'destinationName': destinationName,
        'pricePerPerson': pricePerPerson,
        'participants': participants,
        'totalPrice': totalPrice,
        'travelDate': Timestamp.fromDate(travelDate),
        'status': status.name,
        'notes': notes,
        'createdAt': Timestamp.fromDate(createdAt),
      };

  // ── Utilidades ───────────────────────────────────────────────────────────────

  ReservationModel copyWith({
    ReservationStatus? status,
    String? notes,
  }) {
    return ReservationModel(
      id: id,
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
      status: status ?? this.status,
      notes: notes ?? this.notes,
      createdAt: createdAt,
    );
  }

  @override
  List<Object?> get props => [
        id, userId, tourId, participants, totalPrice,
        travelDate, status, notes, createdAt,
      ];

  @override
  String toString() =>
      'ReservationModel(id: $id, tourTitle: $tourTitle, status: ${status.name})';
}
