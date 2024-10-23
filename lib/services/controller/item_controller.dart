import 'package:assets_inventory_app_ghum/common/models/items_model.dart';
import 'package:assets_inventory_app_ghum/services/repository/item_repository.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

final inventoryProvider = StreamProvider.family((ref, String id) {
  return ref.watch(itemControllerProvider.notifier).getItemById(id);
});
final inventorySearchProvider = StreamProvider.family((ref, String query) {
  return ref.watch(itemControllerProvider.notifier).getItemByName(query);
});

final itemControllerProvider =
    StateNotifierProvider<ItemController, bool>((ref) {
  return ItemController(ref.watch(itemRepositoryProvider), ref);
});

class ItemController extends StateNotifier<bool> {
  ItemController(ItemRepository itemRepository, Ref ref)
      : _itemRepository = itemRepository,
        super(false);
  final ItemRepository _itemRepository;

  Stream<List<ItemModel>> getItemById(String id) {
    return _itemRepository.getItemById(id);
  }

  Stream<List<ItemModel>> getItemByName(String query) {
    return _itemRepository.getItemByName(query);
  }

  Future<QuerySnapshot> fetchItems(
      {required String query,
      DocumentSnapshot? lastDocument,
      required int limit,
      required BuildContext context}) async {
    final res = await _itemRepository.fetchItems(
        query: query, limit: limit, lastDocument: lastDocument);
    QuerySnapshot? querySnapshot;
    res.fold((l) => throw l.message, (r) => querySnapshot = r);
    return querySnapshot!;
  }
}
