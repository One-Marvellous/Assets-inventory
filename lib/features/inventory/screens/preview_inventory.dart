import 'dart:developer';

import 'package:assets_inventory_app_ghum/common/models/suboffice.dart';
import 'package:assets_inventory_app_ghum/features/inventory/screens/show_inventory.dart';
import 'package:assets_inventory_app_ghum/features/inventory/widgets/items.dart';
import 'package:assets_inventory_app_ghum/services/controller/suboffice_controller.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

class PreviewInventory extends ConsumerStatefulWidget {
  const PreviewInventory({super.key, required this.uid, required this.name});
  final String uid;
  final String name;

  @override
  ConsumerState<ConsumerStatefulWidget> createState() =>
      _PreviewInventoryState();
}

class _PreviewInventoryState extends ConsumerState<PreviewInventory> {
  Map<String, String> data = {};

  @override
  void initState() {
    data = {"uid": widget.uid, "name": widget.name};
    super.initState();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
        appBar: AppBar(
          title: const Text("Inventory"),
          centerTitle: true,
          surfaceTintColor: Colors.transparent,
        ),
        body: ref.watch(subOfficeInventoriesProvider(data)).when(
            data: (data) {
              var suboffice = data.first;
              var inventoryItems = suboffice.items;
              return inventoryItems.isNotEmpty
                  ? ListView.builder(
                      itemCount: inventoryItems.length,
                      itemBuilder: (context, index) {
                        var inventory = inventoryItems.reversed.toList()[index];
                        return Padding(
                          padding: const EdgeInsets.only(bottom: 5),
                          child: InventoryItem(
                            onTap: () {
                              editInventory(context, inventory.inventoryId,
                                  inventoryItems.length - 1 - index, suboffice);
                            },
                            count: inventory.quantity,
                            serialNumber: inventory.serialNumber ?? '',
                            name: inventory.name,
                            imageUrl: inventory.imagePath != ''
                                ? inventory.imagePath
                                : null,
                          ),
                        );
                      },
                    )
                  : const Center(child: Text("No Inventory"));
            },
            error: (error, stackTrace) {
              return const Center(
                child: Text(
                    "There is a problem loading this page, try again later"),
              );
            },
            loading: () => const Center(
                  child: CircularProgressIndicator(),
                )));
  }

  void editInventory(BuildContext context, String inventoryId, int index,
      SubOffice suboffice) {
    Navigator.of(context).push(MaterialPageRoute(
      builder: (context) {
        log(inventoryId);
        return ShowInventory(
            inventoryId: inventoryId, index: index, subOffice: suboffice);
      },
    ));
  }
}
