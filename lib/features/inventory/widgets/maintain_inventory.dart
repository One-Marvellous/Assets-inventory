import 'package:assets_inventory_app_ghum/common/models/action.dart';
import 'package:assets_inventory_app_ghum/common/models/document_model.dart';
import 'package:assets_inventory_app_ghum/common/models/item_prev.dart';
import 'package:assets_inventory_app_ghum/common/models/items_model.dart';
import 'package:assets_inventory_app_ghum/common/models/maintenance_details.dart';
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
import 'package:flutter/services.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:uuid/uuid.dart';

class MaintainInventory extends ConsumerStatefulWidget {
  const MaintainInventory(
      {super.key,
      required this.subOffice,
      required this.index,
      required this.inventoryItem});
  final SubOffice subOffice;
  final int index;
  final ItemModel inventoryItem;

  @override
  ConsumerState<ConsumerStatefulWidget> createState() =>
      _MaintainInventoryState();
}

class _MaintainInventoryState extends ConsumerState<MaintainInventory> {
  final formKey = GlobalKey<FormState>();
  final TextEditingController technicianController = TextEditingController();
  final TextEditingController quantityController = TextEditingController();
  final TextEditingController authenticatorController = TextEditingController();
  final TextEditingController reportController = TextEditingController();
  final TextEditingController durationController = TextEditingController();
  final TextEditingController priceController = TextEditingController();

  late ItemModel inventoryItem;
  late int initialQuantity;
  late SubOffice subOffice;
  late int index;
  late List<Office> office;

  @override
  void initState() {
    inventoryItem = widget.inventoryItem;
    initialQuantity = widget.inventoryItem.quantity;
    subOffice = widget.subOffice;
    index = widget.index;
    office = ref.read(officeListProvider);
    super.initState();
  }

  @override
  void dispose() {
    technicianController.dispose();
    quantityController.dispose();
    authenticatorController.dispose();
    reportController.dispose();
    durationController.dispose();
    priceController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Column(
      children: [
        Form(
          key: formKey,
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              const SizedBox(
                height: 20,
              ),
              TextFieldDescription(
                  text:
                      "Quantity of item undergoing maintenance (initial quantity: $initialQuantity)"),
              const SizedBox(height: 5),
              MyTextfield(
                controller: quantityController,
                hintText: "Quantity",
                keyboardType: TextInputType.number,
                validator: (value) =>
                    Validator.validateQuantity(value, initialQuantity),
              ),

              // Space
              const SizedBox(
                height: 20,
              ),
              const TextFieldDescription(
                  text: "Duration for Maintenance (days)"),
              const SizedBox(height: 5),
              MyTextfield(
                keyboardType: TextInputType.number,
                controller: durationController,
                hintText: "30",
                validator: (value) =>
                    Validator.validateInteger(value, "Duration"),
              ),

              // Space
              const SizedBox(
                height: 20,
              ),
              const TextFieldDescription(text: "Technician Name"),
              const SizedBox(height: 5),
              MyTextfield(
                controller: technicianController,
                hintText: "Mr John Doe",
                validator: (value) =>
                    Validator.validateItem(value, "technician name"),
              ),

              // Space
              const SizedBox(
                height: 20,
              ),
              const TextFieldDescription(text: "Service report"),
              const SizedBox(height: 5),
              MyTextfield(
                controller: reportController,
                hintText: "Report on what was serviced",
                maxLines: 3,
                validator: (value) => Validator.validateWithMessage(
                    value, "Service report cannot be empty"),
              ),

              // Space
              const SizedBox(
                height: 20,
              ),
              const TextFieldDescription(text: "Repair cost in #"),
              const SizedBox(height: 5),
              MyTextfield(
                controller: priceController,
                hintText: "Repair cost in #",
                validator: (value) => Validator.validateItem(value, "price"),
                keyboardType:
                    const TextInputType.numberWithOptions(decimal: true),
                inputFormatters: [
                  TextInputFormatter.withFunction(priceFormatFunction),
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
                  onPressed: doMaintenance, text: "Continue with Maintenance")
            ],
          ),
        ),
        const SizedBox(height: kBottomNavigationBarHeight)
      ],
    );
  }

  void doMaintenance() {
    FocusScope.of(context).unfocus();
    if (formKey.currentState!.validate()) {
      var newQuantity =
          initialQuantity - int.parse(quantityController.text.trim());
      String id = const Uuid().v4();

      // update ItemPrev
      List<ItemPrev> items = subOffice.items;
      items[index] = items[index].copyWith(quantity: newQuantity);
      var resultingSubOffice = subOffice.copyWith(items: items);

      // update ItemModel
      var updatedInventoryItem = inventoryItem.copyWith(
          quantity: newQuantity,
          documentIds: [...inventoryItem.documentIds, id]);

      // create Document

      DocumentModel document = DocumentModel(
        id: id,
        uid: inventoryItem.sharedId,
        officeName:
            office.firstWhere((office) => office.uid == subOffice.uid).name,
        subOfficeName: subOffice.name,
        report: reportController.text.trim(),
        operation: IStrings.maintain,
        authenticator: authenticatorController.text.trim(),
        technician: technicianController.text.trim(),
        quantity: int.parse(quantityController.text.trim()),
        price: priceController.text.trim(),
        inventory: MaintenanceDetails(
          name: inventoryItem.name,
          inventoryId: inventoryItem.id,
          subOfficeId: subOffice.id,
        ),
        action: [
          ActionItem(
              name: 'Repair',
              status: 'In Progress',
              price:
                  double.parse(priceController.text.trim().replaceAll(',', '')),
              quantity: int.parse(quantityController.text.trim())),
          ActionItem(name: 'Scrap', status: 'N/A', price: 0.00, quantity: 0),
          ActionItem(name: 'Auction', status: 'N/A', price: 0.00, quantity: 0),
        ],
        duration: int.parse(durationController.text.trim()),
      );

      ref.watch(documentControllerProvider.notifier).createMaintenanceDocument(
            subOffice: resultingSubOffice,
            document: document,
            inventoryItem: updatedInventoryItem,
            context: context,
          );
    } else {
      showSnackbar(context, "Please check for errors filling this form");
    }
  }
}
