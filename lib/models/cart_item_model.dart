import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:equatable/equatable.dart';
import 'package:lifetours/models/firestore_constants.dart';

class CartItemModel extends Equatable {
  final String tourId;
  final String tourTitle;
  final String destinationName;
  final double pricePerPerson;
  final int participants;
  final String imageUrl;
  final DateTime? travelDate;

  double get totalPrice => pricePerPerson * participants;

  const CartItemModel({
    required this.tourId,
    required this.tourTitle,
    required this.destinationName,
    required this.pricePerPerson,
    required this.participants,
    required this.imageUrl,
    this.travelDate,
  });

  factory CartItemModel.fromMap(Map<String, dynamic> map, String tourId) {
    return CartItemModel(
      tourId: tourId,
      tourTitle: map[CartItemFields.tourTitle] as String,
      destinationName: map[CartItemFields.destinationName] as String,
      pricePerPerson: (map[CartItemFields.pricePerPerson] as num).toDouble(),
      participants: map[CartItemFields.participants] as int,
      imageUrl: map[CartItemFields.imageUrl] as String,
      travelDate: map[CartItemFields.travelDate] != null
          ? (map[CartItemFields.travelDate] as Timestamp).toDate()
          : null,
    );
  }

  factory CartItemModel.fromDocumentSnapshot(DocumentSnapshot doc) {
    return CartItemModel.fromMap(doc.data() as Map<String, dynamic>, doc.id);
  }

  Map<String, dynamic> toMap() {
    final map = <String, dynamic>{
      CartItemFields.tourId: tourId,
      CartItemFields.tourTitle: tourTitle,
      CartItemFields.destinationName: destinationName,
      CartItemFields.pricePerPerson: pricePerPerson,
      CartItemFields.participants: participants,
      CartItemFields.imageUrl: imageUrl,
    };
    if (travelDate != null) {
      map[CartItemFields.travelDate] = Timestamp.fromDate(travelDate!);
    }
    return map;
  }

  CartItemModel copyWith({int? participants, DateTime? travelDate}) {
    return CartItemModel(
      tourId: tourId,
      tourTitle: tourTitle,
      destinationName: destinationName,
      pricePerPerson: pricePerPerson,
      participants: participants ?? this.participants,
      imageUrl: imageUrl,
      travelDate: travelDate ?? this.travelDate,
    );
  }

  @override
  List<Object?> get props => [
        tourId,
        tourTitle,
        destinationName,
        pricePerPerson,
        participants,
        imageUrl,
        travelDate,
      ];

  @override
  String toString() =>
      'CartItemModel(tourId: $tourId, tourTitle: $tourTitle, participants: $participants, total: \$$totalPrice)';
}
