// ignore_for_file: public_member_api_docs, sort_constructors_first
class ActionItem {
  final String name;
  final String status;
  final double price;
  final int quantity;
  final String? bidder;

  ActionItem(
      {required this.name,
      required this.status,
      required this.price,
      required this.quantity,
      this.bidder});

  @override
  String toString() {
    return "ActionItem {name: $name, status: $status, price: $price, quantity: $quantity, bidder: $bidder}";
  }

  Map<String, dynamic> toMap() {
    return <String, dynamic>{
      'name': name,
      'status': status,
      'price': price,
      'quantity': quantity,
      'bidder': bidder,
    };
  }

  factory ActionItem.fromMap(Map<String, dynamic> map) {
    return ActionItem(
      name: map['name'] as String,
      status: map['status'] as String,
      price: double.parse(map['price'].toString()),
      quantity: map['quantity'] as int,
      bidder: map['bidder'],
    );
  }

  ActionItem copyWith({
    String? name,
    String? status,
    double? price,
    int? quantity,
    String? bidder,
  }) {
    return ActionItem(
      name: name ?? this.name,
      status: status ?? this.status,
      price: price ?? this.price,
      quantity: quantity ?? this.quantity,
      bidder: bidder ?? this.bidder,
    );
  }
}
