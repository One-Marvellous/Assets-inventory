import 'package:assets_inventory_app_ghum/common/models/items_model.dart';
import 'package:assets_inventory_app_ghum/common/models/suboffice.dart';
import 'package:assets_inventory_app_ghum/common/utils/failure.dart';
import 'package:assets_inventory_app_ghum/common/utils/type_def.dart';
import 'package:assets_inventory_app_ghum/services/firebase/firebase_constants.dart';
import 'package:assets_inventory_app_ghum/services/firebase/firebase_providers.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:fpdart/fpdart.dart';

final subofficeRepositoryProvider = Provider<SubofficeRepository>((ref) {
  return SubofficeRepository(firestore: ref.watch(firestoreProvider));
});

class SubofficeRepository {
  final FirebaseFirestore _firestore;

  SubofficeRepository({required FirebaseFirestore firestore})
      : _firestore = firestore;

  FutureVoid createInventory({
    required String subofficeName,
    required String uid,
    required ItemModel item,
  }) async {
    try {
      var querySnapshot = await _subOffice
          .where("uid", isEqualTo: uid)
          .where("name", isEqualTo: subofficeName)
          .get();
      List<SubOffice> selectedSuboffice = [];
      for (var doc in querySnapshot.docs) {
        selectedSuboffice
            .add(SubOffice.fromMap(doc.data() as Map<String, dynamic>));
      }

      return Right(_subOffice.doc(selectedSuboffice.first.id).update({
        "items": FieldValue.arrayUnion([item.toMap()])
      }));
    } on FirebaseException catch (e) {
      throw e.message!;
    } catch (e) {
      return left(Failure(e.toString()));
    }
  }

  FutureVoid updateInventory(SubOffice suboffice) async {
    try {
      return right(_subOffice.doc(suboffice.id).update(suboffice.toMap()));
    } on FirebaseException catch (e) {
      throw e.message!;
    } catch (e) {
      return left(Failure(e.toString()));
    }
  }

  FutureEither<List<SubOffice>> getSubofficeInventories(
      {required String uid, required String name}) async {
    try {
      var querySnapshot = await _subOffice
          .where("uid", isEqualTo: uid)
          .where("name", isEqualTo: name)
          .get();
      List<SubOffice> selectedSuboffice = [];
      for (var doc in querySnapshot.docs) {
        selectedSuboffice
            .add(SubOffice.fromMap(doc.data() as Map<String, dynamic>));
      }

      return Right(selectedSuboffice);
    } on FirebaseException catch (e) {
      throw e.message!;
    } catch (e) {
      return left(Failure(e.toString()));
    }
  }

  Stream<List<SubOffice>> getAllSubofficeInventories(
      {required String uid, required String name}) {
    return _subOffice
        .where("uid", isEqualTo: uid)
        .where("name", isEqualTo: name)
        .snapshots()
        .map((event) {
      List<SubOffice> suboffice = [];
      for (var doc in event.docs) {
        suboffice.add(SubOffice.fromMap(doc.data() as Map<String, dynamic>));
      }
      return suboffice;
    });
  }

  CollectionReference get _subOffice =>
      _firestore.collection(FirebaseConstants.subOfficeCollection);
}
