import 'dart:async';
import 'dart:developer';

import 'package:assets_inventory_app_ghum/common/models/document_model.dart';
import 'package:assets_inventory_app_ghum/common/models/item_prev.dart';
import 'package:assets_inventory_app_ghum/common/models/items_model.dart';
import 'package:assets_inventory_app_ghum/common/models/newly_bought_report.dart';
import 'package:assets_inventory_app_ghum/common/models/office_report.dart';
import 'package:assets_inventory_app_ghum/common/models/suboffice.dart';
import 'package:assets_inventory_app_ghum/common/utils/constant/strings.dart';
import 'package:assets_inventory_app_ghum/common/utils/failure.dart';
import 'package:assets_inventory_app_ghum/common/utils/type_def.dart';
import 'package:assets_inventory_app_ghum/services/firebase/firebase_constants.dart';
import 'package:assets_inventory_app_ghum/services/firebase/firebase_providers.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_storage/firebase_storage.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:fpdart/fpdart.dart';

final documentRepositoryProvider = Provider<DocumentRepository>((ref) {
  return DocumentRepository(
      firestore: ref.watch(firestoreProvider),
      firebaseStorage: ref.watch(storageProvider));
});

class DocumentRepository {
  final FirebaseFirestore _firestore;
  final FirebaseStorage _firebaseStorage;

  DocumentRepository(
      {required FirebaseFirestore firestore,
      required FirebaseStorage firebaseStorage})
      : _firestore = firestore,
        _firebaseStorage = firebaseStorage;

  FutureVoid createAddDocument(
      {required SubOffice subOffice,
      required DocumentModel document,
      required ItemModel inventoryItem}) async {
    try {
      WriteBatch batch = _firestore.batch();
      batch.update(_subOffice.doc(subOffice.id), subOffice.toMap());
      batch.update(_items.doc(inventoryItem.id), inventoryItem.toMap());
      batch.set(_document.doc(document.id), document.toMap());
      batch.commit();

      // Future.wait([
      //   _subOffice.doc(subOffice.id).update(subOffice.toMap()),
      //   _items.doc(inventoryItem.id).update(inventoryItem.toMap()),
      //   _document.doc(document.id).set(document.toMap()),
      // ]);
      return right(null);
    } catch (e) {
      return left(Failure(e.toString()));
    }
  }

  FutureVoid createTransferDocument(
      {required SubOffice subOffice,
      required DocumentModel document,
      required ItemModel item,
      required String transferSubOfficeName,
      required String transferSubOfficeUid,
      required ItemModel inventoryItem,
      required bool deleteInventory}) async {
    try {
      var querySnapshot = await _subOffice
          .where("uid", isEqualTo: transferSubOfficeUid)
          .where("name", isEqualTo: transferSubOfficeName)
          .get();
      List<SubOffice> selectedSuboffice = [];
      for (var doc in querySnapshot.docs) {
        selectedSuboffice
            .add(SubOffice.fromMap(doc.data() as Map<String, dynamic>));
      }
      ItemPrev itemPrev = ItemPrev(
          inventoryId: item.id,
          name: item.name,
          quantity: item.quantity,
          serialNumber: item.idTag);
      if (!deleteInventory) {
        WriteBatch batch = _firestore.batch();
        batch.update(_subOffice.doc(selectedSuboffice.first.id), {
          "items": FieldValue.arrayUnion([itemPrev.toMap()])
        });
        batch.set(_items.doc(item.id),
            item.copyWith(imagePath: [], documentIds: [document.id]).toMap());
        batch.update(_subOffice.doc(subOffice.id), subOffice.toMap());
        batch.update(_items.doc(inventoryItem.id), inventoryItem.toMap());
        batch.set(_document.doc(document.id), document.toMap());
        batch.commit();
        // Future.wait([
        //   _subOffice.doc(selectedSuboffice.first.id).update({
        //     "items": FieldValue.arrayUnion([itemPrev.toMap()])
        //   }),
        //   _items.doc(item.id).set(item.copyWith(
        //       documentIds: [...item.documentIds, document.id]).toMap()),
        //   _subOffice.doc(subOffice.id).update(subOffice.toMap()),
        //   _items.doc(inventoryItem.id).update(inventoryItem.toMap()),
        //   _document.doc(document.id).set(document.toMap()),
        // ]);
      } else {
        WriteBatch batch = _firestore.batch();
        batch.update(_subOffice.doc(selectedSuboffice.first.id), {
          "items": FieldValue.arrayUnion([itemPrev.toMap()])
        });
        batch.set(
            _items.doc(item.id),
            item.copyWith(
                documentIds: [...item.documentIds, document.id]).toMap());
        batch.update(_subOffice.doc(subOffice.id), subOffice.toMap());
        batch.delete(_items.doc(inventoryItem.id));
        batch.set(_document.doc(document.id), document.toMap());
        batch.commit();

        // Future.wait([
        //   _subOffice.doc(selectedSuboffice.first.id).update({
        //     "items": FieldValue.arrayUnion([itemPrev.toMap()])
        //   }),
        //   _items
        //       .doc(item.id)
        //       .set(item.copyWith(documentIds: [document.id]).toMap()),
        //   _subOffice.doc(subOffice.id).update(subOffice.toMap()),
        //   _items.doc(inventoryItem.id).delete(),
        //   _document.doc(document.id).set(document.toMap()),
        // ]);
      }
      return right(null);
    } catch (e) {
      return left(Failure(e.toString()));
    }
  }

  FutureVoid createNewDocument(
      {required DocumentModel document,
      required ItemModel item,
      required String transferSubOfficeName,
      required String transferSubOfficeUid}) async {
    try {
      var querySnapshot = await _subOffice
          .where("uid", isEqualTo: transferSubOfficeUid)
          .where("name", isEqualTo: transferSubOfficeName)
          .get();
      List<SubOffice> selectedSuboffice = [];
      for (var doc in querySnapshot.docs) {
        selectedSuboffice
            .add(SubOffice.fromMap(doc.data() as Map<String, dynamic>));
      }
      ItemPrev itemPrev = ItemPrev(
        inventoryId: item.id,
        name: item.name,
        quantity: item.quantity,
        serialNumber: item.idTag,
        imagePath: (item.imagePath.isNotEmpty) ? item.imagePath.first : null,
      );
      WriteBatch batch = _firestore.batch();
      batch.set(_items.doc(item.id), item.toMap());
      batch.update(_subOffice.doc(selectedSuboffice.first.id), {
        "items": FieldValue.arrayUnion([itemPrev.toMap()])
      });
      batch.set(_document.doc(document.id), document.toMap());
      batch.commit();

      // Future.wait([
      //   _items.doc(item.id).set(item.toMap()),
      //   _subOffice.doc(selectedSuboffice.first.id).update({
      //     "items": FieldValue.arrayUnion([itemPrev.toMap()])
      //   }),
      //   _document.doc(document.id).set(document.toMap()),
      // ]);
      return right(null);
    } catch (e) {
      return left(Failure(e.toString()));
    }
  }

  FutureVoid createMaintenanceDocument({
    required SubOffice subOffice,
    required DocumentModel document,
    required ItemModel inventoryItem,
  }) async {
    try {
      WriteBatch batch = _firestore.batch();
      batch.update(_subOffice.doc(subOffice.id), subOffice.toMap());
      batch.update(_items.doc(inventoryItem.id), inventoryItem.toMap());
      batch.set(_document.doc(document.id), document.toMap());
      batch.commit();

      // Future.wait([
      //   _subOffice.doc(subOffice.id).update(subOffice.toMap()),
      //   _items.doc(inventoryItem.id).update(inventoryItem.toMap()),
      //   _document.doc(document.id).set(document.toMap()),
      // ]);

      return right(null);
    } catch (e) {
      return left(Failure(e.toString()));
    }
  }

  FutureVoid updateImages({
    required ItemModel inventoryItem,
    required SubOffice subOffice,
  }) async {
    try {
      WriteBatch batch = _firestore.batch();
      batch.update(_subOffice.doc(subOffice.id), subOffice.toMap());
      batch.update(_items.doc(inventoryItem.id), inventoryItem.toMap());
      batch.commit();

      // Future.wait([
      //   _subOffice.doc(subOffice.id).update(subOffice.toMap()),
      //   _items.doc(inventoryItem.id).update(inventoryItem.toMap()),
      // ]);
      return right(null);
    } catch (e) {
      return left(Failure(e.toString()));
    }
  }

  Stream<List<DocumentModel>> getDocumentById(String id) {
    return _document
        .where("uid", isEqualTo: id)
        .orderBy("timeStamp")
        .snapshots()
        .map((event) {
      List<DocumentModel> documents = [];
      for (var doc in event.docs) {
        documents
            .add(DocumentModel.fromMap(doc.data() as Map<String, dynamic>));
      }
      return documents;
    });
  }

  FutureVoid editMaintenanceDetails(DocumentModel document) async {
    try {
      _document
          .doc(document.id)
          .update({'action': document.action?.map((x) => x.toMap()).toList()});
      return right(null);
    } catch (e) {
      return left(Failure(e.toString()));
    }
  }

  FutureVoid completeMaintenance(
      {required DocumentModel document,
      required SubOffice subOffice,
      required ItemModel inventoryItem,
      required DocumentModel newDocument}) async {
    try {
      WriteBatch batch = _firestore.batch();
      batch.set(_document.doc(newDocument.id), newDocument.toMap());
      batch.update(
          _subOffice.doc(document.inventory!.subOfficeId), subOffice.toMap());
      batch.update(
          _items.doc(document.inventory!.inventoryId),
          inventoryItem.copyWith(documentIds: [
            ...inventoryItem.documentIds,
            newDocument.id
          ]).toMap());
      batch.update(_document.doc(document.id), {
        'action': document.action?.map((x) => x.toMap()).toList(),
        'isCompleted': true
      });
      batch.commit();

      // Future.wait([
      //   _subOffice
      //       .doc(document.inventory!.subOfficeId)
      //       .update(subOffice.toMap()),
      //   _items
      //       .doc(document.inventory!.inventoryId)
      //       .update(inventoryItem.toMap()),
      //   _document.doc(document.id).update(
      //       {'action': document.action?.map((x) => x.toMap()).toList()}),
      // ]);
      return right(null);
    } catch (e) {
      return left(Failure(e.toString()));
    }
  }

  FutureEither<List<DocumentSnapshot<Object?>>> getAllNeccesaryData(
      String inventoryId, String subOfficeId) async {
    try {
      var dk = await _subOffice.doc(subOfficeId).get();
      log(dk.data().toString());
      var neccessaryData = await Future.wait([
        _subOffice.doc(subOfficeId).get(),
        _items.doc(inventoryId).get(),
      ]);
      return right(neccessaryData);
    } catch (e) {
      return left(Failure(e.toString()));
    }
  }

  FutureVoid deleteDocuments(SubOffice subOffice, ItemModel inventory) async {
    try {
      WriteBatch batch = _firestore.batch();
      for (String id in inventory.documentIds) {
        log(id);
        DocumentReference docRef = _document.doc(id);
        batch.delete(docRef);
      }

      batch.update(_subOffice.doc(subOffice.id), subOffice.toMap());
      batch.delete(_items.doc(inventory.id));
      await batch.commit();
      for (String imageUrl in inventory.imagePath) {
        final ref = _firebaseStorage.refFromURL(imageUrl);
        await ref.delete();
      }
      return right(null);
    } catch (e) {
      log(e.toString());
      return left(Failure(e.toString()));
    }
  }

  Stream<List<DocumentModel>> getMaintenanceDocument() {
    return _document
        .where("operation", isEqualTo: IStrings.maintain)
        .orderBy("timeStamp", descending: true)
        .snapshots()
        .map((event) {
      List<DocumentModel> documents = [];
      for (var doc in event.docs) {
        documents
            .add(DocumentModel.fromMap(doc.data() as Map<String, dynamic>));
      }
      return documents;
    });
  }

  FutureEither<DocumentModel> getMaintenanceReport(String id) async {
    try {
      DocumentSnapshot documentSnapshot = await _document.doc(id).get();
      DocumentModel report = DocumentModel.fromMap(
          documentSnapshot.data() as Map<String, dynamic>);
      return right(report);
    } catch (e) {
      return left(Failure(e.toString()));
    }
  }

  FutureEither<List<NewReport>> getRecentReport(
      DateTime startDate, DateTime endDate) async {
    try {
      List<ItemModel> items = [];
      List<DocumentModel> itemsDocuments = [];

      // get all inventory items that are new
      var data = await _items
          .where('timeStamp',
              isGreaterThanOrEqualTo: Timestamp.fromDate(startDate))
          .where('timeStamp', isLessThan: endDate)
          .get();

      for (var doc in data.docs) {
        items.add(ItemModel.fromMap(doc.data() as Map<String, dynamic>));
      }
      for (var item in items) {
        // get shared id
        String sharedId = item.sharedId;

        var documentData = await _document
            .where("uid", isEqualTo: sharedId)
            .orderBy("timeStamp", descending: true)
            .get();
        List<DocumentModel> documents = [];

        for (var doc in documentData.docs) {
          documents
              .add(DocumentModel.fromMap(doc.data() as Map<String, dynamic>));
        }
        var documentHistory = documents.firstWhere(
            (document) => document.operation == IStrings.add,
            orElse: () => documents.last);
        itemsDocuments.add(documentHistory);
      }
      if (items.length == itemsDocuments.length) {
        log("${items.length}");
        return right(List.generate(items.length, (index) {
          String recentlyAdded = itemsDocuments[index].operation == IStrings.add
              ? '${itemsDocuments[index].quantity}'
              : '';
          String name = items[index].name;
          String acqDate = items[index].acquisitionDate ?? '';
          String expDate = items[index].warrantyExpiration ?? '';
          String quantity = recentlyAdded.isEmpty
              ? '${items[index].quantity}'
              : '${items[index].quantity}, $recentlyAdded recently Added';
          String price = itemsDocuments[index].operation == IStrings.add
              ? '${itemsDocuments[index].price}'
              : '${items[index].price}';
          String officeName = items[index].officeLocation;
          String room = items[index].roomLocation;
          String supplier = itemsDocuments[index].supplier ?? '';
          String authenticator = itemsDocuments[index].authenticator;
          String description = itemsDocuments[index].operation == IStrings.add
              ? itemsDocuments[index].report
              : items[index].description ?? '';

          var newReport = NewReport(
              name: name,
              acqDate: acqDate,
              expDate: expDate,
              quantity: quantity,
              price: price,
              officeName: officeName,
              room: room,
              supplier: supplier,
              authenticator: authenticator,
              description: description);
          log(newReport.toString());
          return newReport;
        }));
      } else {
        return left(Failure("An unexpected error occured"));
      }
    } catch (e) {
      return left(Failure(e.toString()));
    }
  }

  FutureEither<List<OfficeReport>> generateOfficeReport(
      {required String officeLocation}) async {
    try {
      List<ItemModel> items = [];
      var querySnapshot =
          await _items.where("officeLocation", isEqualTo: officeLocation).get();

      for (var doc in querySnapshot.docs) {
        log(doc.data().toString());
        items.add(ItemModel.fromMap(doc.data() as Map<String, dynamic>));
      }

      Map<String, List<ItemModel>> groupedData = {};

      for (var item in items) {
        if (!groupedData.containsKey(item.roomLocation)) {
          groupedData[item.roomLocation] = [];
        }
        groupedData[item.roomLocation]!.add(item);
      }

      // Creating the NewData list
      List<OfficeReport> officeReports = groupedData.entries.map((entry) {
        return OfficeReport(name: entry.key, items: entry.value);
      }).toList();
      log("message: $officeReports");
      return right(officeReports);
    } catch (e) {
      return left(Failure(e.toString()));
    }
  }

  FutureEither<List<ItemModel>> generateRoomReport(
      {required String roomLocation, required String officeLocation}) async {
    try {
      List<ItemModel> items = [];

      var querySnapshot = await _items
          .where("officeLocation", isEqualTo: officeLocation)
          .where("roomLocation", isEqualTo: roomLocation)
          .get();
      for (var doc in querySnapshot.docs) {
        log(doc.data().toString());
        items.add(ItemModel.fromMap(doc.data() as Map<String, dynamic>));
      }

      return right(items);
    } catch (e) {
      return left(Failure(e.toString()));
    }
  }

  CollectionReference get _subOffice =>
      _firestore.collection(FirebaseConstants.subOfficeCollection);

  CollectionReference get _document =>
      _firestore.collection(FirebaseConstants.documentCollection);

  CollectionReference get _items =>
      _firestore.collection(FirebaseConstants.itemCollection);
}
