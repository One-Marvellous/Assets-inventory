import 'package:assets_inventory_app_ghum/common/models/office.dart';
import 'package:assets_inventory_app_ghum/common/models/document_model.dart';
import 'package:assets_inventory_app_ghum/common/models/item_prev.dart';
import 'package:assets_inventory_app_ghum/common/models/items_model.dart';
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

class AddMoreToInventoryScreen extends ConsumerStatefulWidget {
  const AddMoreToInventoryScreen(
      {super.key,
      required this.subOffice,
      required this.index,
      required this.inventoryItem});
  final SubOffice subOffice;
  final int index;
  final ItemModel inventoryItem;

  @override
  ConsumerState<ConsumerStatefulWidget> createState() =>
      _AddMoreToInventoryScreenState();
}

class _AddMoreToInventoryScreenState
    extends ConsumerState<AddMoreToInventoryScreen> {
  final formKey = GlobalKey<FormState>();

  final TextEditingController supplierController = TextEditingController();
  final TextEditingController quantityController = TextEditingController();
  final TextEditingController authenticatorController = TextEditingController();
  final TextEditingController commentController = TextEditingController();
  final TextEditingController priceController = TextEditingController();

  late ItemModel inventoryItem;
  late SubOffice subOffice;
  late int index;
  late List<Office> office;
  late int initialQuantity;

  @override
  void initState() {
    inventoryItem = widget.inventoryItem;
    index = widget.index;
    subOffice = widget.subOffice;
    office = ref.read(officeListProvider);
    initialQuantity = widget.inventoryItem.quantity;
    super.initState();
  }

  @override
  void dispose() {
    supplierController.dispose();
    quantityController.dispose();
    authenticatorController.dispose();
    commentController.dispose();
    priceController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Column(
      mainAxisSize: MainAxisSize.min,
      children: [
        Form(
          key: formKey,
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              const SizedBox(
                height: 20,
              ),
              const TextFieldDescription(text: "Quantity"),
              const SizedBox(height: 5),
              MyTextfield(
                keyboardType: TextInputType.number,
                controller: quantityController,
                hintText: "Quantity",
                validator: (value) => Validator.validateAddQuantity(value),
              ),

              // Space
              const SizedBox(
                height: 20,
              ),
              const TextFieldDescription(text: "Supplier Name"),
              const SizedBox(height: 5),
              MyTextfield(
                controller: supplierController,
                hintText: "Supplier name",
                validator: (value) =>
                    Validator.validateItem(value, "supplier name"),
              ),

              // Space
              const SizedBox(
                height: 20,
              ),
              const TextFieldDescription(text: "Product details"),
              const SizedBox(height: 5),
              MyTextfield(
                maxLines: 3,
                controller: commentController,
                hintText: "Newly bought",
                validator: (value) => Validator.validateWithMessage(
                    value, "Comment must not be empty"),
              ),

              // Space
              const SizedBox(
                height: 20,
              ),
              const TextFieldDescription(text: "Price in #"),
              const SizedBox(height: 5),
              MyTextfield(
                controller: priceController,
                hintText: "Price in #",
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
              MyButton(onPressed: addMore, text: "Add"),
            ],
          ),
        ),
        const SizedBox(height: kBottomNavigationBarHeight)
      ],
    );
  }

  void addMore() {
    FocusScope.of(context).unfocus();

    if (formKey.currentState!.validate()) {
      List<ItemPrev> items = subOffice.items;
      String id = const Uuid().v4();

      // Update the ItemPrev
      items[index] = items[index].copyWith(
          quantity:
              initialQuantity + int.parse(quantityController.text.trim()));
      var resultingSubOffice = subOffice.copyWith(items: items);

      // Update the ItemModel
      var updatedInventoryItem = inventoryItem.copyWith(
          documentIds: [...inventoryItem.documentIds, id],
          quantity: initialQuantity + int.parse(quantityController.text.trim()),
          isUpdated: true);

      // Create Document

      DocumentModel document = DocumentModel(
        id: id,
        uid: inventoryItem.sharedId,
        officeName:
            office.firstWhere((office) => office.uid == subOffice.uid).name,
        subOfficeName: subOffice.name,
        report: commentController.text.trim(),
        supplier: supplierController.text.trim(),
        operation: IStrings.add,
        authenticator: authenticatorController.text.trim(),
        quantity: int.parse(quantityController.text.trim()),
        price: priceController.text.trim(),
      );

      ref.watch(documentControllerProvider.notifier).createAddDocument(
          subOffice: resultingSubOffice,
          document: document,
          inventoryItem: updatedInventoryItem,
          context: context);
    } else {
      showSnackbar(context, "Please check for errors filling this form");
    }
  }
}
