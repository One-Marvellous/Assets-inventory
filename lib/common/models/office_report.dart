// ignore_for_file: public_member_api_docs, sort_constructors_first
import 'package:assets_inventory_app_ghum/common/models/items_model.dart';

class OfficeReport {
  String name;
  List<ItemModel> items;
  OfficeReport({
    required this.name,
    required this.items,
  });

  @override
  String toString() => 'OfficeReport(name: $name, items: $items)';
}
