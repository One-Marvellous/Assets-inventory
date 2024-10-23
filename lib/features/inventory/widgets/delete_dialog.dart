import 'dart:math';

import 'package:assets_inventory_app_ghum/common/models/item_prev.dart';
import 'package:assets_inventory_app_ghum/common/models/items_model.dart';
import 'package:assets_inventory_app_ghum/common/models/suboffice.dart';
import 'package:assets_inventory_app_ghum/common/widgets/my_textfield.dart';
import 'package:assets_inventory_app_ghum/helpers/validator.dart';
import 'package:assets_inventory_app_ghum/services/controller/document_controller.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

class DeleteDialog extends ConsumerStatefulWidget {
  const DeleteDialog(
      {super.key,
      required this.index,
      required this.subOffice,
      required this.inventory});

  final int index;
  final SubOffice subOffice;
  final ItemModel inventory;

  @override
  ConsumerState<ConsumerStatefulWidget> createState() => _DeleteDialogState();
}

class _DeleteDialogState extends ConsumerState<DeleteDialog> {
  final TextEditingController codeController = TextEditingController();
  final formKey = GlobalKey<FormState>();
  late String generatedCode;
  late SubOffice subOffice;
  late ItemModel inventory;
  late int index;

  String _generateCode(int length) {
    const chars = 'ABCDEFGHIJKLMNOPQRSTUVWXYZ';
    final rnd = Random();
    return String.fromCharCodes(Iterable.generate(
        length, (_) => chars.codeUnitAt(rnd.nextInt(chars.length))));
  }

  @override
  void initState() {
    generatedCode = _generateCode(8);
    subOffice = widget.subOffice;
    index = widget.index;
    inventory = widget.inventory;
    super.initState();
  }

  @override
  void dispose() {
    codeController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    bool isLoading = ref.watch(documentControllerProvider);
    return AlertDialog(
      surfaceTintColor: Colors.transparent,
      backgroundColor: Colors.white,
      shadowColor: Colors.transparent,
      title: const Text('Delete this Inventory?'),
      content: SingleChildScrollView(
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            const Text(
                'Doing so will permanently delete the data at this inventory, including all nested documents.'),
            const SizedBox(height: 10),
            const Text('Please enter the following code to confirm:'),
            const SizedBox(height: 10),
            Text(
              generatedCode,
              style: const TextStyle(
                  fontWeight: FontWeight.bold, letterSpacing: 2, fontSize: 20),
            ),
            const SizedBox(height: 5),
            Form(
              key: formKey,
              child: MyTextfield(
                autovalidateMode: AutovalidateMode.onUserInteraction,
                controller: codeController,
                hintText: "Enter code",
                validator: (value) =>
                    Validator.validateCode(value, generatedCode),
              ),
            ),
          ],
        ),
      ),
      actions: [
        TextButton(
          onPressed: () {
            Navigator.of(context).pop();
          },
          child: const Text('Cancel'),
        ),
        TextButton(
          onPressed: isLoading ? null : deleteDocument,
          child: Text(isLoading ? 'Deleting...' : 'Delete'),
        ),
      ],
    );
  }

  void deleteDocument() {
    if (formKey.currentState!.validate()) {
      List<ItemPrev> items = subOffice.items;

      // Update the ItemPrev
      items.removeAt(index);
      var resultingSubOffice = subOffice.copyWith(items: items);

      // Perform deletion
      ref.watch(documentControllerProvider.notifier).deleteDocuments(
          subOffice: resultingSubOffice,
          inventory: inventory,
          context: context);
    }
  }
}
