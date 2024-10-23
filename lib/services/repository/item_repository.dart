import 'dart:developer';

import 'package:assets_inventory_app_ghum/common/models/items_model.dart';
import 'package:assets_inventory_app_ghum/common/utils/failure.dart';
import 'package:assets_inventory_app_ghum/common/utils/type_def.dart';
import 'package:assets_inventory_app_ghum/services/firebase/firebase_constants.dart';
import 'package:assets_inventory_app_ghum/services/firebase/firebase_providers.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:fpdart/fpdart.dart';

final itemRepositoryProvider = Provider<ItemRepository>((ref) {
  return ItemRepository(firestore: ref.watch(firestoreProvider));
});

class ItemRepository {
  final FirebaseFirestore _firestore;

  ItemRepository({required FirebaseFirestore firestore})
      : _firestore = firestore;

  Stream<List<ItemModel>> getItemById(String id) {
    return _items.where("id", isEqualTo: id).snapshots().map((event) {
      List<ItemModel> items = [];
      for (var doc in event.docs) {
        items.add(ItemModel.fromMap(doc.data() as Map<String, dynamic>));
      }
      return items;
    });
  }

  // TODO delete this later.

  Stream<List<ItemModel>> getItemByName(String query) {
    return _items
        .where("searchList", arrayContains: query)
        .limit(100)
        .snapshots()
        .map((event) {
      List<ItemModel> items = [];
      for (var doc in event.docs) {
        items.add(ItemModel.fromMap(doc.data() as Map<String, dynamic>));
      }
      log(items.toString());
      return items;
    });
  }

  FutureEither<QuerySnapshot> fetchItems(
      {required String query,
      DocumentSnapshot? lastDocument,
      required int limit}) async {
    try {
      Query queryRef =
          _items.where("searchList", arrayContains: query).limit(25);
      if (lastDocument != null) {
        queryRef = queryRef.startAfterDocument(lastDocument);
      }

      QuerySnapshot snapshot =
          await queryRef.get(const GetOptions(source: Source.server));

      return Right(snapshot);
    } catch (e) {
      return left(Failure(e.toString()));
    }
  }

  CollectionReference get _items =>
      _firestore.collection(FirebaseConstants.itemCollection);
}
