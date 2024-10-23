// ignore_for_file: use_build_context_synchronously

import 'dart:developer';

import 'package:assets_inventory_app_ghum/common/constant.dart';
import 'package:assets_inventory_app_ghum/common/models/document_model.dart';
import 'package:assets_inventory_app_ghum/common/models/item_prev.dart';
import 'package:assets_inventory_app_ghum/common/models/items_model.dart';
import 'package:assets_inventory_app_ghum/common/models/office.dart';
import 'package:assets_inventory_app_ghum/common/models/suboffice.dart';
import 'package:assets_inventory_app_ghum/common/sub_office_constant.dart';
import 'package:assets_inventory_app_ghum/common/utils.dart';
import 'package:assets_inventory_app_ghum/common/utils/constant/strings.dart';
import 'package:assets_inventory_app_ghum/common/widgets/my_button.dart';
import 'package:assets_inventory_app_ghum/services/controller/office_controller.dart';
import 'package:csv/csv.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:uuid/uuid.dart';

class UploadData extends ConsumerWidget {
  const UploadData({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    bool isLoading = ref.watch(officeControllerProvider);
    return Scaffold(
      appBar: AppBar(),
      body: Center(
        child: Column(
          children: [
            MyButton(
              onPressed: () {
                log(iSubOffice.length.toString());
                // uploadData(ref, context);
              },
              text: "Upload Data",
              isLoading: isLoading,
            ),
            MyButton(
              onPressed: () {
                uploadInventory(ref, context);
              },
              text: "Upload Inventory",
              isLoading: isLoading,
            ),
          ],
        ),
      ),
    );
  }

  void uploadData(WidgetRef ref, BuildContext context) {
    List<Office> offices = [];
    List<SubOffice> subOffices = [];
    for (var e in iOffices) {
      String uuid = const Uuid().v4();
      offices.add(Office(name: e.name, uid: uuid, rooms: e.rooms));
      for (var i in e.rooms) {
        subOffices.add(
            SubOffice(name: i, uid: uuid, id: const Uuid().v4(), items: []));
      }
    }
    log(subOffices.toString());
    ref
        .watch(officeControllerProvider.notifier)
        .upload(context: context, offices: offices, subOffices: subOffices);
  }
}

void uploadInventory(WidgetRef ref, BuildContext context) async {
  int count = 0;
  int subCount = 0;
  int maxRoom = 0;

  for (var dummyData in iOffices) {
    // log(dummyData.name);
    for (var room in dummyData.rooms) {
      List<DocumentModel> documentList = [];
      List<ItemModel> itemList = [];

      List<List<dynamic>> loadCsvData =
          await loadCsv(csvFolderName: dummyData.name, csvName: room);
      List<ItemPrev> myPrevList = [];
      // Get total count of rooms
      int lines = loadCsvData.length;
      if (lines > maxRoom) {
        // log(lines.toString());
        maxRoom = lines;
        // log("${dummyData.name}, $room");
      }
      for (var e in loadCsvData) {
        var documentId = const Uuid().v4();

        List<String> searchList =
            indexName(e.first.toString().trim().toLowerCase());

        DocumentModel document = DocumentModel(
          id: const Uuid().v4(),
          uid: documentId,
          officeName: dummyData.name,
          subOfficeName: room,
          report: e[2].toString().trim(),
          operation: IStrings.create,
          authenticator: "",
          quantity: int.parse(e[1].toString().trim()),
        );

        ItemModel item = ItemModel(
          id: const Uuid().v4(),
          name: e.first.toString().trim(),
          quantity: int.parse(e[1].toString().trim()),
          status: "Office-owned",
          condition: "Existing",
          sharedId: documentId,
          searchList: searchList,
          officeLocation: dummyData.name,
          roomLocation: room,
          imagePath: [],
          documentIds: [document.id],
          description: e[2].toString().trim(),
        );

        ItemPrev itemPrev = ItemPrev(
          inventoryId: item.id,
          name: item.name,
          quantity: item.quantity,
        );

        documentList.add(document);
        itemList.add(item);
        myPrevList.add(itemPrev);
      }

      SubOffice subOffice = iSubOffice[subCount];
      // log(subOffice.name);

      await ref.watch(officeControllerProvider.notifier).updateSubOfficeData(
          context: context, previewList: myPrevList, subOffice: subOffice);

      await ref.watch(officeControllerProvider.notifier).uploadForEach(
            context: context,
            documentList: documentList,
            itemList: itemList,
          );

      // log(documentList.toString());
      // log(itemList.toString());

      subCount++;
    }
    count++;
  }
  // log("count: $count");
  // // log(maxRoom.toString());
  log("subCount: $subCount");

  log("All done");
}

Future<List<List<dynamic>>> loadCsv(
    {required String csvFolderName, required String csvName}) async {
  final rawData =
      await rootBundle.loadString("assets/upload/$csvFolderName/$csvName.csv");
  List<List<dynamic>> listData = const CsvToListConverter().convert(rawData);
  return listData;
}
