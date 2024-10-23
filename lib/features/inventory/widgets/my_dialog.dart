import 'package:assets_inventory_app_ghum/common/models/items_model.dart';
import 'package:assets_inventory_app_ghum/common/models/suboffice.dart';
import 'package:assets_inventory_app_ghum/services/controller/document_controller.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

class MyDialog extends ConsumerStatefulWidget {
  const MyDialog(
      {super.key,
      required this.imageUrl,
      required this.inventory,
      required this.subOffice,
      required this.index});

  final String imageUrl;
  final ItemModel inventory;
  final SubOffice subOffice;
  final int index;

  @override
  ConsumerState<ConsumerStatefulWidget> createState() => _MyDialogState();
}

class _MyDialogState extends ConsumerState<MyDialog> {
  late String imageUrl;
  late ItemModel inventoryItem;
  late SubOffice subOffice;
  late int index;
  @override
  void initState() {
    imageUrl = widget.imageUrl;
    inventoryItem = widget.inventory;
    subOffice = widget.subOffice;
    index = widget.index;
    super.initState();
  }

  @override
  Widget build(BuildContext context) {
    return AlertDialog(
      surfaceTintColor: Colors.transparent,
      title: const Text('Confirm Delete'),
      content: const Text('You are going to delete this image. Are you sure?'),
      actions: <Widget>[
        TextButton(
          onPressed: () {
            Navigator.of(context).pop(); // Close the dialog
          },
          child: const Text('Cancel'),
        ),
        TextButton(
          onPressed: () {
            // Handle delete action
            ref.watch(documentControllerProvider.notifier).deleteImages(
                imageUrl: imageUrl,
                inventoryItem: inventoryItem,
                index: index,
                subOffice: subOffice,
                context: context);
            Navigator.of(context).pop(); // Close the dialog
            // Perform delete operation
          },
          child: const Text('Yes'),
        ),
      ],
    );
  }
}
