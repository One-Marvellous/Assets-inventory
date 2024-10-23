// ignore_for_file: public_member_api_docs, sort_constructors_first, unnecessary_this
import 'dart:convert';

class ItemPrev {
  final String inventoryId;
  final String name;
  final int quantity;
  final String? serialNumber;
  final String? imagePath;

  ItemPrev(
      {required this.inventoryId,
      required this.name,
      required this.quantity,
      this.serialNumber,
      this.imagePath});

  Map<String, dynamic> toMap() {
    return <String, dynamic>{
      'inventoryId': inventoryId,
      'name': name,
      'quantity': quantity,
      'serialNumber': serialNumber,
      'imagePath': imagePath,
    };
  }

  factory ItemPrev.fromMap(Map<String, dynamic> map) {
    return ItemPrev(
      inventoryId: map['inventoryId'] as String,
      name: map['name'] as String,
      quantity: map['quantity'] as int,
      serialNumber:
          map['serialNumber'] != null ? map['serialNumber'] as String : null,
      imagePath: map['imagePath'] != null ? map['imagePath'] as String : null,
    );
  }

  String toJson() => json.encode(toMap());

  factory ItemPrev.fromJson(String source) =>
      ItemPrev.fromMap(json.decode(source) as Map<String, dynamic>);

  ItemPrev copyWith({
    String? inventoryId,
    String? name,
    int? quantity,
    String? serialNumber,
    String? imagePath,
  }) {
    return ItemPrev(
      inventoryId: inventoryId ?? this.inventoryId,
      name: name ?? this.name,
      quantity: quantity ?? this.quantity,
      serialNumber: serialNumber ?? this.serialNumber,
      imagePath: imagePath ?? this.imagePath,
    );
  }

  @override
  String toString() {
    return 'ItemPrev(inventoryId: "$inventoryId", name: "$name", quantity: $quantity)';
  }
}
