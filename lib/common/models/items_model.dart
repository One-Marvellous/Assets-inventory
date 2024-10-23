// ignore_for_file: public_member_api_docs, sort_constructors_first
import 'package:cloud_firestore/cloud_firestore.dart';

class ItemModel {
  final String id;
  final String name;
  final String? idTag;
  final String? price;
  final String? description;
  final int quantity;
  final List<String> imagePath;
  final String status;
  final String condition;
  final String? acquisitionDate;
  final String sharedId;
  final List<String> searchList;
  final String officeLocation;
  final String roomLocation;
  final String? warrantyExpiration;
  final String? category;
  final List<String> documentIds;
  final Timestamp? timeStamp;
  final bool isUpdated;
  final String? supplier;

  ItemModel(
      {required this.id,
      required this.name,
      required this.quantity,
      required this.status,
      required this.condition,
      required this.sharedId,
      required this.searchList,
      required this.officeLocation,
      required this.roomLocation,
      required this.imagePath,
      required this.documentIds,
      this.supplier,
      this.idTag,
      this.acquisitionDate,
      this.description,
      this.price,
      this.category,
      this.warrantyExpiration,
      this.timeStamp,
      this.isUpdated = false});

  ItemModel copyWith(
      {String? name,
      String? id,
      String? idTag,
      int? quantity,
      List<String>? imagePath,
      String? status,
      String? price,
      String? description,
      String? acquisitionDate,
      String? condition,
      String? sharedId,
      List<String>? searchList,
      String? officeLocation,
      String? roomLocation,
      String? warrantyExpiration,
      String? category,
      String? conditionDescription,
      List<String>? documentIds,
      bool? isUpdated,
      String? supplier}) {
    return ItemModel(
      id: id ?? this.id,
      name: name ?? this.name,
      idTag: idTag ?? this.idTag,
      quantity: quantity ?? this.quantity,
      imagePath: imagePath ?? this.imagePath,
      status: status ?? this.status,
      price: price ?? this.price,
      description: description ?? this.description,
      condition: condition ?? this.condition,
      acquisitionDate: acquisitionDate ?? this.acquisitionDate,
      sharedId: sharedId ?? this.sharedId,
      searchList: searchList ?? this.searchList,
      officeLocation: officeLocation ?? this.officeLocation,
      roomLocation: roomLocation ?? this.roomLocation,
      warrantyExpiration: warrantyExpiration ?? this.warrantyExpiration,
      category: category ?? this.category,
      documentIds: documentIds ?? this.documentIds,
      isUpdated: isUpdated ?? this.isUpdated,
      supplier: supplier ?? this.supplier,
    );
  }

  Map<String, dynamic> toMap() {
    return <String, dynamic>{
      'id': id,
      'name': name,
      'idTag': idTag,
      'quantity': quantity,
      'imagePath': imagePath,
      'status': status,
      'price': price,
      'description': description,
      'acquisitionDate': acquisitionDate,
      'condition': condition,
      'sharedId': sharedId,
      'searchList': searchList,
      'officeLocation': officeLocation,
      'roomLocation': roomLocation,
      'warrantyExpiration': warrantyExpiration,
      'category': category,
      'documentIds': documentIds,
      'supplier': supplier,
      'timeStamp': isUpdated ? FieldValue.serverTimestamp() : null
    };
  }

  factory ItemModel.fromMap(Map<String, dynamic> map) {
    return ItemModel(
      id: map['id'] as String,
      name: map['name'] as String,
      quantity: map['quantity'] as int,
      imagePath: map['imagePath']?.cast<String>(),
      price: map['price'] != null ? map['price'] as String : null,
      description:
          map['description'] != null ? map['description'] as String : null,
      status: map['status'] as String,
      acquisitionDate: map['acquisitionDate'] != null
          ? map['acquisitionDate'] as String
          : null,
      condition: map['condition'] as String,
      sharedId: map['sharedId'] as String,
      searchList: map['searchList'].cast<String>(),
      officeLocation: map['officeLocation'] as String,
      roomLocation: map['roomLocation'] as String,
      warrantyExpiration: map['warrantyExpiration'] != null
          ? map['warrantyExpiration'] as String
          : null,
      category: map['category'] != null ? map['category'] as String : null,
      idTag: map['idTag'] != null ? map['idTag'] as String : null,
      supplier: map['supplier'],
      documentIds: map['documentIds'].cast<String>(),
      timeStamp: map['timeStamp'],
    );
  }

  @override
  String toString() {
    return 'ItemModel(id: $id, name: $name, serialNumber: $idTag, quantity: $quantity, imagePath: $imagePath, status: $status, price: $price, description: $description, date: $acquisitionDate, condition: $condition, sharedId: $sharedId, officeLocation: $officeLocation, roomLocation: $roomLocation, warrantyExpiration: $warrantyExpiration documentIds: $documentIds, supplier: $supplier}';
  }
}
