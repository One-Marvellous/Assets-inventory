import 'package:assets_inventory_app_ghum/common/models/item_prev.dart';

class SubOffice {
  final String name;
  final String uid;
  final String id;
  final List<ItemPrev> items;
  SubOffice({
    required this.name,
    required this.uid,
    required this.id,
    required this.items,
  });

  SubOffice copyWith({
    String? name,
    String? uid,
    String? id,
    String? status,
    List<ItemPrev>? items,
  }) {
    return SubOffice(
      name: name ?? this.name,
      uid: uid ?? this.uid,
      id: id ?? this.id,
      items: items ?? this.items,
    );
  }

  Map<String, dynamic> toMap() {
    return <String, dynamic>{
      'name': name,
      'uid': uid,
      'id': id,
      'items': items.map((x) => x.toMap()).toList(),
    };
  }

  factory SubOffice.fromMap(Map<String, dynamic> map) {
    return SubOffice(
      name: map['name'] as String,
      uid: map['uid'] as String,
      id: map['id'] as String,
      items: List<ItemPrev>.from(
        (map['items'] as List<dynamic>).map<ItemPrev>(
          (x) => ItemPrev.fromMap(x as Map<String, dynamic>),
        ),
      ),
    );
  }

  @override
  String toString() {
    return 'SubOffice(name: "$name", uid: "$uid", id: "$id", items: $items)';
  }
}

