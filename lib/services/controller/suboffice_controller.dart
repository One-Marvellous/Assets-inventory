import 'dart:io';

import 'package:assets_inventory_app_ghum/common/models/items_model.dart';
import 'package:assets_inventory_app_ghum/common/models/suboffice.dart';
import 'package:assets_inventory_app_ghum/common/utils.dart';
import 'package:assets_inventory_app_ghum/common/utils/failure.dart';
import 'package:assets_inventory_app_ghum/services/firebase/storage_repository_provider.dart';
import 'package:assets_inventory_app_ghum/services/repository/suboffice_repository.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:flutter/widgets.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

final subOfficeInventoriesProvider =
    StreamProvider.family((ref, Map<String, String> data) {
  var subOfficeControllerProvider =
      ref.watch(subofficeControllerProvider.notifier);
  return subOfficeControllerProvider.getAllSubofficeInventories(
      uid: data["uid"]!, name: data["name"]!);
});

final subofficeControllerProvider =
    StateNotifierProvider<SubofficeController, bool>((ref) {
  return SubofficeController(
      subofficeRepository: ref.watch(subofficeRepositoryProvider),
      storageRepository: ref.watch(storageRepositoryProvider));
});

class SubofficeController extends StateNotifier<bool> {
  SubofficeController(
      {required SubofficeRepository subofficeRepository,
      required StorageRepository storageRepository})
      : _subofficeRepository = subofficeRepository,
        _storageRepository = storageRepository,
        super(false);

  final SubofficeRepository _subofficeRepository;
  final StorageRepository _storageRepository;

  void createInventory({
    required BuildContext context,
    required String subofficeName,
    required String uid,
    required ItemModel item,
    required File? file,
  }) async {
    state = true;

    if (file != null) {
      final res = await _storageRepository.storeFile(
          path: "office/inventory", id: item.id, file: file);
      res.fold((l) => showSnackbar(context, l.message), (r) {
        // item = item.copyWith(imagePath: r);
      });
    }
    final res = await _subofficeRepository.createInventory(
        subofficeName: subofficeName, uid: uid, item: item);
    state = false;
    res.fold(
        (l) => showSnackbar(context, l.message), (r) => Navigator.pop(context));
  }

  // void updateInventory(
  //     {required BuildContext context,
  //     required SubOffice suboffice,
  //     required List<ItemModel> items,
  //     required File? file,
  //     required int index}) async {
  //   state = true;

  //   if (file != null) {
  //     ItemModel item = items[index];
  //     final res = await _storageRepository.storeFile(
  //         path: "office/inventory", id: item.id, file: file);
  //     res.fold((l) => showSnackbar(context, l.message), (r) {
  //       item = item.copyWith(imagePath: r);
  //     });
  //   }

  //   suboffice = suboffice.copyWith(items: items);

  //   final res = await _subofficeRepository.updateInventory(suboffice);
  //   state = false;

  //   res.fold(
  //       (l) => showSnackbar(context, l.message), (r) => Navigator.pop(context));
  // }

  Future<List<SubOffice>> getSubOfficeInventories(
      {required String uid,
      required String name,
      required BuildContext context}) async {
    var res = await _subofficeRepository.getSubofficeInventories(
        uid: uid, name: name);

    List<SubOffice> inventoryList = [];
    res.fold((l) => Failure(l.message), (r) => inventoryList = r);
    return inventoryList;
  }

  Stream<List<SubOffice>> getAllSubofficeInventories(
      {required String uid, required String name}) {
    return _subofficeRepository.getAllSubofficeInventories(
        uid: uid, name: name);
  }
}
