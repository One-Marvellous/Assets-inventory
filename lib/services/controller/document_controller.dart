import 'dart:developer';
import 'dart:io';

import 'package:assets_inventory_app_ghum/common/models/document_model.dart';
import 'package:assets_inventory_app_ghum/common/models/item_prev.dart';
import 'package:assets_inventory_app_ghum/common/models/items_model.dart';
import 'package:assets_inventory_app_ghum/common/models/suboffice.dart';
import 'package:assets_inventory_app_ghum/common/utils.dart';
import 'package:assets_inventory_app_ghum/common/utils/constant/strings.dart';
import 'package:assets_inventory_app_ghum/features/auth/provider/user_provider.dart';
import 'package:assets_inventory_app_ghum/features/reports/screen/pdf/create_pdf.dart';
import 'package:assets_inventory_app_ghum/features/reports/screen/pdf/save_and_open_pdf.dart';
import 'package:assets_inventory_app_ghum/services/firebase/storage_repository_provider.dart';
import 'package:assets_inventory_app_ghum/services/repository/document_repository.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:flutter/widgets.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:uuid/uuid.dart';

final documentsProvider = StreamProvider.family((ref, String id) {
  return ref.watch(documentControllerProvider.notifier).getDocumentById(id);
});

final maintenanceDocumentProvider = StreamProvider((ref) {
  return ref
      .watch(documentControllerProvider.notifier)
      .getMaintenanceDocument();
});

final documentControllerProvider =
    StateNotifierProvider<DocumentController, bool>((ref) {
  return DocumentController(ref.watch(documentRepositoryProvider),
      ref.watch(storageRepositoryProvider), ref);
});

class DocumentController extends StateNotifier<bool> {
  DocumentController(DocumentRepository documentRepository,
      StorageRepository storageRepository, Ref ref)
      : _documentRepository = documentRepository,
        _storageRepository = storageRepository,
        _ref = ref,
        super(false);
  final DocumentRepository _documentRepository;
  final StorageRepository _storageRepository;
  final Ref _ref;

  void createAddDocument(
      {required SubOffice subOffice,
      required DocumentModel document,
      required ItemModel inventoryItem,
      required BuildContext context}) async {
    state = true;
    final res = await _documentRepository.createAddDocument(
        subOffice: subOffice, document: document, inventoryItem: inventoryItem);
    state = false;
    res.fold((l) => showSnackbar(context, l.message), (r) {
      showSnackbar(context, "More inventory quantity added");
      Navigator.pop(context);
    });
  }

  void createTransferDocument({
    required SubOffice subOffice,
    required DocumentModel document,
    required ItemModel item,
    required String transferOfficeName,
    required String transferSubOfficeName,
    required String transferSubOfficeUid,
    required BuildContext context,
    required ItemModel inventoryItems,
    required bool deleteInventory,
  }) async {
    state = true;
    final res = await _documentRepository.createTransferDocument(
        subOffice: subOffice,
        document: document,
        item: item,
        transferSubOfficeName: transferSubOfficeName,
        transferSubOfficeUid: transferSubOfficeUid,
        inventoryItem: inventoryItems,
        deleteInventory: deleteInventory);
    state = false;
    res.fold((l) => showSnackbar(context, l.message), (r) {
      showSnackbar(context,
          "Inventory Transferred to $transferOfficeName, $transferSubOfficeName");
      deleteInventory
          ? Navigator.popUntil(context, ModalRoute.withName('PreviewInventory'))
          : Navigator.pop(context);
    });
  }

  void createNewDocument(
      {required DocumentModel document,
      required ItemModel item,
      required String transferSubOfficeName,
      required String transferSubOfficeUid,
      required BuildContext context,
      required List<File> images}) async {
    state = true;
    var newItem = item;

    if (images.isNotEmpty) {
      List<String> imagePath = [];
      log("images count: ${images.length}");
      for (var img in images) {
        final res = await _storageRepository.storeFile(
            path: "office/inventory", id: const Uuid().v4(), file: img);
        res.fold((l) => showSnackbar(context, l.message), (r) {
          imagePath.add(r);
        });
      }
      log("imageList: $imagePath");
      newItem = item.copyWith(imagePath: imagePath);
    }

    log(newItem.toString());

    final res = await _documentRepository.createNewDocument(
        document: document,
        item: newItem,
        transferSubOfficeName: transferSubOfficeName,
        transferSubOfficeUid: transferSubOfficeUid);
    state = false;
    res.fold((l) => showSnackbar(context, l.message), (r) {
      showSnackbar(context, "Inventory added");
      Navigator.pop(context);
    });
  }

  void createMaintenanceDocument({
    required SubOffice subOffice,
    required DocumentModel document,
    required BuildContext context,
    required ItemModel inventoryItem,
  }) async {
    state = true;
    final res = await _documentRepository.createMaintenanceDocument(
      subOffice: subOffice,
      document: document,
      inventoryItem: inventoryItem,
    );
    state = false;
    res.fold((l) => showSnackbar(context, l.message), (r) {
      showSnackbar(context, "Inventory has been submitted for maintenance");
      Navigator.pop(context);
    });
  }

  void saveImages(
      {required ItemModel inventoryItem,
      required int index,
      required SubOffice subOffice,
      required List<File> images,
      required BuildContext context}) async {
    state = true;
    var newItem = inventoryItem;

    // Update inventory image
    if (images.isNotEmpty) {
      List<String> imagePath = inventoryItem.imagePath;
      log("images count: ${images.length}");
      for (var img in images) {
        final res = await _storageRepository.storeFile(
            path: "office/inventory", id: const Uuid().v4(), file: img);
        res.fold((l) => showSnackbar(context, l.message), (r) {
          imagePath.add(r);
        });
      }
      log("imageList: $imagePath");
      newItem = inventoryItem.copyWith(imagePath: imagePath);
    } else {
      return Navigator.pop(context);
    }

    // update ItemPrev image
    List<ItemPrev> items = subOffice.items;
    items[index] = items[index].copyWith(
        imagePath:
            (newItem.imagePath.isNotEmpty) ? newItem.imagePath.first : null);
    var newSubOffice = subOffice.copyWith(items: items);

    final res = await _documentRepository.updateImages(
        inventoryItem: newItem, subOffice: newSubOffice);

    state = false;
    res.fold((l) => showSnackbar(context, l.message), (r) {
      showSnackbar(context, "Images added");
      Navigator.pop(context);
    });
  }

  Future<void> deleteImages(
      {required String imageUrl,
      required ItemModel inventoryItem,
      required int index,
      required SubOffice subOffice,
      required BuildContext context}) async {
    state = true;
    var newItem = inventoryItem;
    bool success = false;

    // delete the image
    final storageRes = await _storageRepository.deleteFile(imageUrl: imageUrl);
    storageRes.fold(
        (l) => showSnackbar(context, l.message), (r) => success = r);
    if (!success) {
      return;
    } else {
      // update inventory image
      List<String> imagePath = inventoryItem.imagePath;
      imagePath.removeWhere((element) => element == imageUrl);
      newItem = inventoryItem.copyWith(imagePath: imagePath);
      log("message: ${newItem.imagePath}");
      log("bool: ${(newItem.imagePath.isNotEmpty) ? newItem.imagePath.first : null}");

      // update ItemPrev image
      List<ItemPrev> items = subOffice.items;
      items[index] = items[index].copyWith(
          imagePath:
              (newItem.imagePath.isNotEmpty) ? newItem.imagePath.first : '');
      log("items: ${items.toString()}");
      var newSubOffice = subOffice.copyWith(items: items);
      log("newSubOffice: $newSubOffice");

      final res = await _documentRepository.updateImages(
          inventoryItem: newItem, subOffice: newSubOffice);

      state = false;
      res.fold((l) => showSnackbar(context, l.message), (r) {
        showSnackbar(context, "Selected image has been removed");
      });
    }
  }

  Future<void> editMaintenanceDetails(DocumentModel document, context) async {
    final res = await _documentRepository.editMaintenanceDetails(document);
    res.fold(
        (l) => showSnackbar(context, l.message), (r) => Navigator.pop(context));
  }

  Future<void> completeMaintenance(
      {required DocumentModel document, required BuildContext context}) async {
    state = true;
    // Get the Suboffice and inventory item...
    final data = await getAllNeccessaryData(document.inventory!.inventoryId,
        document.inventory!.subOfficeId, context);

    if (data.isNotEmpty) {
      SubOffice subOffice =
          SubOffice.fromMap(data[0].data() as Map<String, dynamic>);
      log("SubOffice: ${subOffice.toString()}");

      // Edit the Suboffice and inventory item...
      List<ItemPrev> items = subOffice.items;
      int index = items
          .indexWhere((element) => element.name == document.inventory!.name);
      items[index] = items[index].copyWith(
          quantity: (document.action!
                  .firstWhere((action) => action.name == "Repair")
                  .quantity) +
              (subOffice.items[0].quantity));
      subOffice = subOffice.copyWith(items: items);
      log("newSubOffice: ${subOffice.toString()}");

      ItemModel inventoryItem =
          ItemModel.fromMap(data[1].data() as Map<String, dynamic>);
      log("InventoryItem: ${inventoryItem.toString()}");

      inventoryItem = inventoryItem.copyWith(
          quantity: (document.action!
                  .firstWhere((action) => action.name == "Repair")
                  .quantity) +
              inventoryItem.quantity);

      log("newInventoryItem: ${inventoryItem.toString()}");

      // Edit document
      document = document.copyWith(isCompleted: true);

      double totalPrice = document.action!
          .where((action) => action.name == 'Auction')
          .fold(0, (total, action) => total + action.price * action.quantity);
      int quantityRepaired = document.action!
          .firstWhere((action) => action.name == 'Repair')
          .quantity;
      int quantityAuction = document.action!
          .firstWhere((action) => action.name == 'Auction')
          .quantity;
      int quantityScrapped = document.action!
          .firstWhere((action) => action.name == 'Scrap')
          .quantity;

      DocumentModel newDocument = DocumentModel(
          id: const Uuid().v4(),
          uid: document.uid,
          officeName: document.officeName,
          subOfficeName: document.subOfficeName,
          report:
              "$quantityRepaired repaired\n$quantityScrapped scrapped\n$quantityAuction auctioned at #$totalPrice",
          operation: IStrings.maintenanceCompleted,
          authenticator: _ref.read(userProvider)?.name ?? 'Unknown',
          quantity: document.quantity);

      final res = await _documentRepository.completeMaintenance(
        document: document,
        subOffice: subOffice,
        inventoryItem: inventoryItem,
        newDocument: newDocument,
      );

      state = false;

      res.fold((l) {
        showSnackbar(context, l.message);
        Navigator.pop(context);
      }, (r) {
        showSnackbar(context, "Inventory Updated");

        Navigator.pop(context);
        Navigator.pop(context);
      });
    }
  }

  Future<List<DocumentSnapshot<Object?>>> getAllNeccessaryData(
      String inventoryId, String subOfficeId, BuildContext context) async {
    List<DocumentSnapshot<Object?>> dataList = [];
    final res =
        await _documentRepository.getAllNeccesaryData(inventoryId, subOfficeId);
    res.fold((l) => showSnackbar(context, l.message), (r) => dataList = r);
    return dataList;
  }

  Future<void> deleteDocuments(
      {required SubOffice subOffice,
      required ItemModel inventory,
      required BuildContext context}) async {
    state = true;
    final res = await _documentRepository.deleteDocuments(subOffice, inventory);
    state = false;
    res.fold((l) {
      showSnackbar(context, l.message);
      Navigator.pop(context);
    }, (r) {
      showSnackbar(context, "Inventory successfully deleted");
      // TODO check...
      Navigator.popUntil(context, ModalRoute.withName('PreviewInventory'));
    });
  }

  Future<void> getMaintenanceReport(String id, BuildContext context) async {
    state = true;
    final res = await _documentRepository.getMaintenanceReport(id);
    state = false;
    res.fold(
        (l) => showSnackbar(context, l.message),
        (r) => CreatePdf.generateMaintenanceReport(r)
            .then((file) => SaveAndOpenDocument.openPdf(file)));
  }

  Future<void> getRecentReport(
      {required DateTime startDate,
      required DateTime endDate,
      required BuildContext context}) async {
    state = true;
    final res = await _documentRepository.getRecentReport(startDate, endDate);
    state = false;
    res.fold((l) => showSnackbar(context, l.message), (r) {
      r.isEmpty
          ? showSnackbar(context, 'Report is empty')
          : CreatePdf.generateNewlyBoughtReport(r)
              .then((file) => SaveAndOpenDocument.openPdf(file));
    });
  }

  Future<void> generateOfficeReport(
      {required String officeLocation, required BuildContext context}) async {
    state = true;
    final res = await _documentRepository.generateOfficeReport(
        officeLocation: officeLocation);
    state = false;
    res.fold((l) => showSnackbar(context, l.message), (r) {
      r.isEmpty
          ? showSnackbar(context, 'Report is empty')
          : CreatePdf.generateOfficeReport(r, officeLocation)
              .then((file) => SaveAndOpenDocument.openPdf(file));
    });
  }

  Future<void> generateRoomReport(
      {required String roomLocation,
      required String officeLocation,
      required BuildContext context}) async {
    state = true;
    final res = await _documentRepository.generateRoomReport(
        roomLocation: roomLocation, officeLocation: officeLocation);
    state = false;
    res.fold((l) => showSnackbar(context, l.message), (r) {
      r.isEmpty
          ? showSnackbar(context, 'Report is empty')
          : CreatePdf.generateRoomReport(r, roomLocation, officeLocation)
              .then((file) => SaveAndOpenDocument.openPdf(file));
    });
  }

  Stream<List<DocumentModel>> getDocumentById(String id) {
    return _documentRepository.getDocumentById(id);
  }

  Stream<List<DocumentModel>> getMaintenanceDocument() {
    return _documentRepository.getMaintenanceDocument();
  }
}
