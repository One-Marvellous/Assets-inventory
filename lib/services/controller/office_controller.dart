import 'package:assets_inventory_app_ghum/common/models/document_model.dart';
import 'package:assets_inventory_app_ghum/common/models/item_prev.dart';
import 'package:assets_inventory_app_ghum/common/models/items_model.dart';
import 'package:assets_inventory_app_ghum/common/models/office.dart';
import 'package:assets_inventory_app_ghum/common/models/suboffice.dart';
import 'package:assets_inventory_app_ghum/common/utils.dart';
import 'package:assets_inventory_app_ghum/features/home/controllers/office_list_provider.dart';
import 'package:assets_inventory_app_ghum/services/repository/office_repository.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

final officeControllerProvider =
    StateNotifierProvider<OfficeController, bool>((ref) {
  return OfficeController(
      officeRepository: ref.watch(officeRepositoryProvider), ref: ref);
});

class OfficeController extends StateNotifier<bool> {
  OfficeController(
      {required OfficeRepository officeRepository, required Ref ref})
      : _officeRepository = officeRepository,
        _ref = ref,
        super(false);

  final OfficeRepository _officeRepository;
  final Ref _ref;

  Future<void> upload(
      {required BuildContext context,
      required List<Office> offices,
      required List<SubOffice> subOffices}) async {
    state = true;
    final res = await _officeRepository.upload(offices, subOffices);
    state = false;
    res.fold((l) => showSnackbar(context, l.message),
        (r) => showSnackbar(context, 'Finished uploading'));
  }

  Future<List<Office>> getOfficeList() async {
    var res = await _officeRepository.getOfficeList();
    List<Office> officeList = [];
    res.fold((l) => throw l.message, (r) {
      _ref.read(officeListProvider.notifier).state = r;
      officeList = r;
    });
    return officeList;
  }

  Future<void> uploadForEach(
      {required BuildContext context,
      required List<DocumentModel> documentList,
      required List<ItemModel> itemList}) async {
    state = true;
    final res = await _officeRepository.uploadForEach(documentList, itemList);
    state = false;
    res.fold((l) => showSnackbar(context, l.message),
        (r) => showSnackbar(context, 'Finished ${itemList[0].officeLocation}'));
  }

  Future<void> updateSubOfficeData({
    required BuildContext context,
    required List<ItemPrev> previewList,
    required SubOffice subOffice,
  }) async {
    state = true;
    final res = await _officeRepository.updateSubOfficeData(
      previewList,
      subOffice,
    );
    state = false;
    res.fold((l) => showSnackbar(context, l.message), (r) => null);
  }
}
