import 'package:assets_inventory_app_ghum/common/models/office.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

final officeListProvider = StateProvider<List<Office>>((ref) {
  return [];
});
