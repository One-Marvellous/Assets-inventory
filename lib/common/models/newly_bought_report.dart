// ignore_for_file: public_member_api_docs, sort_constructors_first
class NewReport {
  final String name;
  final String acqDate;
  final String expDate;
  final String quantity;
  final String price;
  final String officeName;
  final String room;
  final String supplier;
  final String authenticator;
  final String description;

  NewReport(
      {required this.name,
      required this.acqDate,
      required this.expDate,
      required this.quantity,
      required this.price,
      required this.officeName,
      required this.room,
      required this.supplier,
      required this.authenticator,
      required this.description});

  @override
  String toString() {
    return 'NewReport(name: $name, acqDate: $acqDate, expDate:$expDate quantity: $quantity, price: $price, officeName: $officeName, room: $room, supplier: $supplier, authenticator: $authenticator, description: $description)';
  }
}
