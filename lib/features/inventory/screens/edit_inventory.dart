import 'package:assets_inventory_app_ghum/common/models/items_model.dart';
import 'package:assets_inventory_app_ghum/common/models/suboffice.dart';
import 'package:assets_inventory_app_ghum/common/widgets/textfield_description.dart';
import 'package:assets_inventory_app_ghum/features/inventory/widgets/add_more.dart';
import 'package:assets_inventory_app_ghum/features/inventory/widgets/maintain_inventory.dart';
import 'package:assets_inventory_app_ghum/features/inventory/widgets/transfer_inventory.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

class EditInventory extends ConsumerStatefulWidget {
  const EditInventory(
      {super.key,
      required this.subOffice,
      required this.index,
      required this.inventory});
  final SubOffice subOffice;
  final int index;
  final ItemModel inventory;

  @override
  ConsumerState<ConsumerStatefulWidget> createState() => _EditInventoryState();
}

class _EditInventoryState extends ConsumerState<EditInventory> {
  List radioOption = [
    "Add more quantity to existing inventory",
    "Transfer inventory to another office",
    "Maintenance and repairs"
  ];
  String radioKey = "";

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: SafeArea(
        child: Padding(
          padding: const EdgeInsets.symmetric(horizontal: 24),
          child: SingleChildScrollView(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                const SizedBox(height: 24),
                const TextFieldDescription(
                    fontSize: 18,
                    text:
                        "Which of these best describe the purpose of editing this Inventory?"),
                const SizedBox(height: 5),
                Column(
                  mainAxisAlignment: MainAxisAlignment.start,
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: List.generate(
                      radioOption.length,
                      (index) => Row(
                            mainAxisAlignment: MainAxisAlignment.start,
                            mainAxisSize: MainAxisSize.min,
                            children: [
                              Radio<String>(
                                  value: radioOption[index],
                                  groupValue: radioKey,
                                  onChanged: (val) {
                                    setState(() {
                                      radioKey = val!;
                                    });
                                  }),
                              Expanded(
                                child: Text(radioOption[index],
                                    style: const TextStyle(
                                        fontSize: 14,
                                        fontWeight: FontWeight.w400,
                                        color: Color(0xff666666))),
                              ),
                            ],
                          )),
                ),
                Visibility(
                    visible: radioKey == radioOption[0],
                    child: AddMoreToInventoryScreen(
                      index: widget.index,
                      subOffice: widget.subOffice,
                      inventoryItem: widget.inventory,
                    )),
                Visibility(
                    visible: radioKey == radioOption[1],
                    child: TransferInventory(
                      index: widget.index,
                      subOffice: widget.subOffice,
                      inventoryItem: widget.inventory,
                    )),
                Visibility(
                    visible: radioKey == radioOption[2],
                    child: MaintainInventory(
                      index: widget.index,
                      subOffice: widget.subOffice,
                      inventoryItem: widget.inventory,
                    )),
              ],
            ),
          ),
        ),
      ),
    );
  }
}
