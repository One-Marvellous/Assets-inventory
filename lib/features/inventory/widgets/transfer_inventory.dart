import 'package:assets_inventory_app_ghum/common/models/document_model.dart';
import 'package:assets_inventory_app_ghum/common/models/item_prev.dart';
import 'package:assets_inventory_app_ghum/common/models/items_model.dart';
import 'package:assets_inventory_app_ghum/common/models/office.dart';
import 'package:assets_inventory_app_ghum/common/models/suboffice.dart';
import 'package:assets_inventory_app_ghum/common/utils.dart';
import 'package:assets_inventory_app_ghum/common/utils/constant/strings.dart';
import 'package:assets_inventory_app_ghum/common/widgets/my_button.dart';
import 'package:assets_inventory_app_ghum/common/widgets/my_textfield.dart';
import 'package:assets_inventory_app_ghum/common/widgets/textfield_description.dart';
import 'package:assets_inventory_app_ghum/features/home/controllers/office_list_provider.dart';
import 'package:assets_inventory_app_ghum/helpers/validator.dart';
import 'package:assets_inventory_app_ghum/services/controller/document_controller.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:uuid/uuid.dart';

class TransferInventory extends ConsumerStatefulWidget {
  const TransferInventory(
      {super.key,
      required this.subOffice,
      required this.index,
      required this.inventoryItem});
  final SubOffice subOffice;
  final int index;
  final ItemModel inventoryItem;

  @override
  ConsumerState<ConsumerStatefulWidget> createState() =>
      _TransferInventoryState();
}

class _TransferInventoryState extends ConsumerState<TransferInventory> {
  final formKey = GlobalKey<FormState>();

  final TextEditingController executorController = TextEditingController();
  final TextEditingController quantityController = TextEditingController();
  final TextEditingController authenticatorController = TextEditingController();
  final TextEditingController commentController = TextEditingController();

  String selectedOffice = "";
  String selectedRoom = "";

  void officeChanged(String? value, List<Office> office) {
    setState(() {
      selectedOffice = value!;
      selectedRoom =
          office.firstWhere((office) => office.name == selectedOffice).rooms[0];
    });
  }

  void roomChanged(String? value) {
    setState(() {
      selectedRoom = value!;
    });
  }

  late ItemModel inventoryItem;
  late SubOffice subOffice;
  late int initialQuantity;
  late int index;
  late List<Office> office;

  @override
  void initState() {
    inventoryItem = widget.inventoryItem;
    initialQuantity = widget.inventoryItem.quantity;
    selectedOffice = ref.read(officeListProvider).first.name;
    selectedRoom = ref.read(officeListProvider).first.rooms.first;
    office = ref.read(officeListProvider);

    subOffice = widget.subOffice;
    index = widget.index;
    super.initState();
  }

  @override
  void dispose() {
    executorController.dispose();
    quantityController.dispose();
    authenticatorController.dispose();
    commentController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    List<Office> offices = ref.read(officeListProvider);
    String uid =
        offices.firstWhere((office) => office.name == selectedOffice).uid;
    return Column(
      mainAxisSize: MainAxisSize.min,
      children: [
        Form(
          key: formKey,
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              // Space
              const SizedBox(
                height: 20,
              ),
              TextFieldDescription(
                  text:
                      "Quantity of items transfered (initial quantity: $initialQuantity)"),
              const SizedBox(height: 5),
              MyTextfield(
                controller: quantityController,
                keyboardType: TextInputType.number,
                hintText: "Quantity",
                validator: (value) =>
                    Validator.validateQuantity(value, initialQuantity),
              ),

              // Space
              const SizedBox(
                height: 20,
              ),
              const TextFieldDescription(text: "Task Executed by"),
              const SizedBox(height: 5),
              MyTextfield(
                controller: executorController,
                hintText: "Mr John Doe",
                validator: (value) =>
                    Validator.validateItem(value, "executor name"),
              ),

              // Space
              const SizedBox(
                height: 20,
              ),
              const TextFieldDescription(
                  text: "Details and Reason(s) for transfer"),
              const SizedBox(height: 5),
              MyTextfield(
                maxLines: 3,
                controller: commentController,
                hintText: "Reason",
                validator: (value) => Validator.validateWithMessage(
                    value, "Comment must not be empty"),
              ),

              const SizedBox(height: 40),
              const TextFieldDescription(
                  text: "Where should the item be attached to?"),
              const SizedBox(height: 5),
              Row(
                children: [
                  const TextFieldDescription(text: "Main Office:"),
                  const Spacer(),
                  DropdownButton<String>(
                    underline: const SizedBox(),
                    items: offices
                        .map((office) => DropdownMenuItem(
                              value: office.name,
                              child: SizedBox(
                                  width: MediaQuery.of(context).size.width / 2,
                                  child: Text(
                                    office.name,
                                    maxLines: 2,
                                    overflow: TextOverflow.ellipsis,
                                  )),
                            ))
                        .toList(),
                    onChanged: (value) => officeChanged(value, offices),
                    value: selectedOffice,
                  ),
                ],
              ),
              const SizedBox(height: 20),
              Row(
                children: [
                  const TextFieldDescription(text: "Room:"),
                  const Spacer(),
                  DropdownButton<String>(
                    underline: const SizedBox(),
                    items: offices
                        .firstWhere((office) => office.name == selectedOffice)
                        .rooms
                        .map<DropdownMenuItem<String>>((String room) {
                      return DropdownMenuItem<String>(
                        value: room,
                        child: SizedBox(
                          width: MediaQuery.of(context).size.width / 2,
                          child: Text(
                            room,
                            maxLines: 2,
                            overflow: TextOverflow.ellipsis,
                          ),
                        ),
                      );
                    }).toList(),
                    onChanged: (value) => roomChanged(value),
                    value: selectedRoom,
                  ),
                ],
              ),

              // Space
              const SizedBox(
                height: 20,
              ),
              const TextFieldDescription(text: "Authenticated by"),
              const SizedBox(height: 5),
              MyTextfield(
                controller: authenticatorController,
                hintText: "Admin",
                validator: (value) => Validator.validateWithMessage(
                    value, "Enter a valid authorization name"),
              ),
              const SizedBox(height: kBottomNavigationBarHeight),
              MyButton(
                  onPressed: () => doTransfer(
                      transferOfficeName: selectedOffice,
                      transferSubOfficeName: selectedRoom,
                      transferSubOfficeUid: uid),
                  text: "Transfer"),

              const SizedBox(height: 30),
            ],
          ),
        ),
        const SizedBox(height: kBottomNavigationBarHeight)
      ],
    );
  }

  void doTransfer(
      {required String transferOfficeName,
      required String transferSubOfficeName,
      required String transferSubOfficeUid}) {
    FocusScope.of(context).unfocus();

    if (formKey.currentState!.validate()) {
      var newQuantity =
          initialQuantity - int.parse(quantityController.text.trim());
      List<ItemPrev> items = List.from(subOffice.items);
      items[index] = items[index].copyWith(quantity: newQuantity);

      List<ItemPrev> remainingItems = List.from(subOffice.items);
      remainingItems.removeAt(index);

      var resultingSubOffice = subOffice.copyWith(
        items: newQuantity < 1 ? remainingItems : items,
      );

      var updatedInventoryItem = inventoryItem.copyWith(quantity: newQuantity);

      var officeName =
          office.firstWhere((office) => office.uid == subOffice.uid).name;

      var comment = commentController.text.trim();

      var transferItem = inventoryItem.copyWith(
        id: const Uuid().v4(),
        quantity: int.parse(quantityController.text.trim()),
        description:
            "${inventoryItem.description}\n\n$comment\n\nTransfer from $officeName, ${subOffice.name}",
        officeLocation: selectedOffice,
        roomLocation: selectedRoom,
        status: "Non-office-owned",
      );

      DocumentModel document = DocumentModel(
        id: const Uuid().v4(),
        uid: inventoryItem.sharedId,
        officeName: officeName,
        subOfficeName: subOffice.name,
        executor: executorController.text.trim(),
        report: "$comment\n\nTransfer from $officeName, ${subOffice.name}",
        operation: IStrings.transfer,
        authenticator: authenticatorController.text.trim(),
        quantity: int.parse(quantityController.text.trim()),
      );

      ref.watch(documentControllerProvider.notifier).createTransferDocument(
          subOffice: resultingSubOffice,
          document: document,
          item: transferItem,
          transferOfficeName: transferOfficeName,
          transferSubOfficeName: transferSubOfficeName,
          transferSubOfficeUid: transferSubOfficeUid,
          inventoryItems: updatedInventoryItem,
          deleteInventory: newQuantity < 1,
          context: context);
    } else {
      showSnackbar(context, "Please check for errors filling this form");
    }
  }
}
