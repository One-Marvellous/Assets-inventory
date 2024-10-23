import 'package:assets_inventory_app_ghum/common/models/document_model.dart';
import 'package:assets_inventory_app_ghum/common/models/item_prev.dart';
import 'package:assets_inventory_app_ghum/common/models/items_model.dart';
import 'package:assets_inventory_app_ghum/common/models/office.dart';
import 'package:assets_inventory_app_ghum/common/models/suboffice.dart';
import 'package:assets_inventory_app_ghum/common/utils/failure.dart';
import 'package:assets_inventory_app_ghum/common/utils/type_def.dart';
import 'package:assets_inventory_app_ghum/services/firebase/firebase_constants.dart';
import 'package:assets_inventory_app_ghum/services/firebase/firebase_providers.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:fpdart/fpdart.dart';

final officeRepositoryProvider = Provider<OfficeRepository>((ref) {
  return OfficeRepository(firestore: ref.watch(firestoreProvider));
});

class OfficeRepository {
  final FirebaseFirestore _firestore;
  OfficeRepository({required FirebaseFirestore firestore})
      : _firestore = firestore;

  FutureVoid upload(List<Office> offices, List<SubOffice> subOffices) async {
    try {
      WriteBatch batch = _firestore.batch();
      for (var office in offices) {
        batch.set(_office.doc(office.uid), office.toMap());
      }

      for (var subOffice in subOffices) {
        batch.set(_subOffice.doc(subOffice.id), subOffice.toMap());
      }

      batch.commit();

      return right(null);
    } catch (e) {
      return left(Failure(e.toString()));
    }
  }

  FutureEither<List<Office>> getOfficeList() async {
    try {
      var querySnapshot =
          await _office.get(const GetOptions(source: Source.server));
      List<Office> office = [];
      for (var doc in querySnapshot.docs) {
        office.add(Office.fromMap(doc.data() as Map<String, dynamic>));
      }

      return right(office);
    } on FirebaseException catch (e) {
      throw e.message!;
    } catch (e) {
      return left(Failure(e.toString()));
    }
  }

  FutureVoid uploadForEach(
      List<DocumentModel> documentList, List<ItemModel> itemList) async {
    try {
      WriteBatch batch = _firestore.batch();
      for (var item in itemList) {
        batch.set(_items.doc(item.id), item.toMap());
      }

      for (var document in documentList) {
        batch.set(_document.doc(document.id), document.toMap());
      }

      batch.commit();

      return right(null);
    } catch (e) {
      return left(Failure(e.toString()));
    }
  }

  FutureVoid updateSubOfficeData(
    List<ItemPrev> previewList,
    SubOffice subOffice,
  ) async {
    try {
      _subOffice
          .doc(subOffice.id)
          .update(subOffice.copyWith(items: previewList).toMap());
      return right(null);
    } catch (e) {
      return left(Failure(e.toString()));
    }
  }

  CollectionReference get _office =>
      _firestore.collection(FirebaseConstants.officeCollection);

  CollectionReference get _subOffice =>
      _firestore.collection(FirebaseConstants.subOfficeCollection);

  CollectionReference get _document =>
      _firestore.collection(FirebaseConstants.documentCollection);

  CollectionReference get _items =>
      _firestore.collection(FirebaseConstants.itemCollection);
}
