import 'dart:io';

import 'package:assets_inventory_app_ghum/common/models/document_model.dart';
import 'package:assets_inventory_app_ghum/common/models/items_model.dart';
import 'package:assets_inventory_app_ghum/common/models/office.dart';
import 'package:assets_inventory_app_ghum/common/utils.dart';
import 'package:assets_inventory_app_ghum/common/utils/constant/strings.dart';
import 'package:assets_inventory_app_ghum/common/widgets/my_button.dart';
import 'package:assets_inventory_app_ghum/common/widgets/my_textfield.dart';
import 'package:assets_inventory_app_ghum/common/widgets/text_with_description.dart';
import 'package:assets_inventory_app_ghum/common/widgets/textfield_description.dart';
import 'package:assets_inventory_app_ghum/features/home/controllers/office_list_provider.dart';
import 'package:assets_inventory_app_ghum/features/inventory/screens/show_full_image.dart';
import 'package:assets_inventory_app_ghum/helpers/validator.dart';
import 'package:assets_inventory_app_ghum/services/controller/document_controller.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:image_picker/image_picker.dart';
import 'package:uuid/uuid.dart';

class NewInventory extends ConsumerStatefulWidget {
  const NewInventory({super.key});

  @override
  ConsumerState<ConsumerStatefulWidget> createState() => _NewInventoryState();
}

class _NewInventoryState extends ConsumerState<NewInventory> {
  final formKey = GlobalKey<FormState>();

  TextEditingController nameController = TextEditingController();
  TextEditingController idTagController = TextEditingController();
  TextEditingController quantityController = TextEditingController();
  TextEditingController priceController = TextEditingController();
  TextEditingController descriptionController = TextEditingController();
  TextEditingController authenticatorController = TextEditingController();
  TextEditingController supplierController = TextEditingController();
  TextEditingController dateController = TextEditingController();
  TextEditingController categoryController = TextEditingController();
  TextEditingController warrantyExpirationDateController =
      TextEditingController();

  List<File> images = [];

  String selectedOffice = "";
  String selectedRoom = "";

  List radioOption = ["Office-owned", "Non-office-owned"];
  List conditionOption = ["New", "Old", "Existing"];
  String radioKey = "";
  String conditionKey = "";

  List imageOptions = ["Camera", "Gallery"];
  String imageKey = "Camera";

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

  void increment() {
    try {
      quantityController.text =
          (int.parse(quantityController.text) + 1).toString();
    } catch (e) {
      showSnackbar(context, "Quantity not a number");
    }
  }

  void decrement() {
    try {
      if (int.parse(quantityController.text) > 1) {
        quantityController.text =
            (int.parse(quantityController.text) - 1).toString();
      }
    } catch (e) {
      showSnackbar(context, "Quantity not a number");
    }
  }

  Future<void> pickAndResizeImage() async {
    var selectedImage = imageKey == "Camera"
        ? await pickImageFromCamera()
        : await pickImageFromGallery();
    if (selectedImage != null) {
      XFile compressedImage = await resizeImage(selectedImage);
      setState(() {
        images.add(File(compressedImage.path));
      });
    }
  }

  void createInventory(
      {required String subofficeName,
      required String uid,
      required List<File> images}) {
    FocusScope.of(context).unfocus();
    if (radioKey.isEmpty) {
      return showSnackbar(context, "Select a valid inventory ownership");
    }
    if (conditionKey.isEmpty) {
      return showSnackbar(context, "Select a valid inventory condition");
    }
    if (formKey.currentState!.validate()) {
      List<String> searchList =
          indexName(nameController.text.trim().toLowerCase());

      var documentId = const Uuid().v4();

      DocumentModel document = DocumentModel(
        id: const Uuid().v4(),
        uid: documentId,
        officeName: selectedOffice,
        subOfficeName: selectedRoom,
        supplier: supplierController.text.trim(),
        report: descriptionController.text.trim(),
        operation: IStrings.create,
        authenticator: authenticatorController.text.trim(),
        quantity: int.parse(quantityController.text.trim()),
        price: priceController.text.isNotEmpty
            ? priceController.text.trim()
            : null,
      );

      ItemModel item = ItemModel(
        supplier: supplierController.text.trim(),
        isUpdated: true,
        documentIds: [document.id],
        officeLocation: selectedOffice,
        roomLocation: selectedRoom,
        searchList: searchList,
        condition: conditionKey,
        category: categoryController.text.trim().isNotEmpty
            ? categoryController.text.trim()
            : null,
        warrantyExpiration:
            warrantyExpirationDateController.text.trim().isNotEmpty
                ? warrantyExpirationDateController.text.trim()
                : null,
        acquisitionDate: dateController.text.trim() == ""
            ? null
            : dateController.text.trim(),
        id: const Uuid().v4(),
        name: nameController.text.trim(),
        idTag: idTagController.text.trim().isNotEmpty
            ? idTagController.text.trim()
            : null,
        quantity: int.parse(quantityController.text.trim()),
        status: radioKey,
        price: priceController.text.isNotEmpty
            ? priceController.text.trim()
            : null,
        description: descriptionController.text.trim(),
        sharedId: documentId,
        imagePath: [],
      );

      ref.watch(documentControllerProvider.notifier).createNewDocument(
          document: document,
          item: item,
          transferSubOfficeName: subofficeName,
          transferSubOfficeUid: uid,
          images: images,
          context: context);
    } else {
      showSnackbar(context, "Please check for errors filling this form");
    }
  }

  @override
  void initState() {
    selectedOffice = ref.read(officeListProvider).first.name;
    selectedRoom = ref.read(officeListProvider).first.rooms.first;
    quantityController.text = "1";
    super.initState();
  }

  @override
  void dispose() {
    nameController.dispose();
    quantityController.dispose();
    idTagController.dispose();
    descriptionController.dispose();
    priceController.dispose();
    authenticatorController.dispose();
    supplierController.dispose();
    dateController.dispose();
    categoryController.dispose();
    warrantyExpirationDateController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    List<Office> office = ref.read(officeListProvider);
    bool isLoading = ref.watch(documentControllerProvider);
    String uid =
        office.firstWhere((office) => office.name == selectedOffice).uid;
    return Scaffold(
      body: isLoading
          ? const Center(
              child: Row(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                Text("Saving ..."),
                SizedBox(width: 10),
                CircularProgressIndicator(),
              ],
            ))
          : SafeArea(
              child: CustomScrollView(slivers: [
                SliverPadding(
                  padding: const EdgeInsets.symmetric(horizontal: 24.0),
                  sliver: SliverToBoxAdapter(
                    child: Form(
                      key: formKey,
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          // Basic Details
                          const Center(
                            child: TextFieldDescription(
                              text: "Basic Details",
                              fontSize: 18,
                            ),
                          ),
                          const SizedBox(height: 10),

                          const TextFieldDescription(text: "Inventory Name"),
                          const SizedBox(height: 5),
                          MyTextfield(
                            controller: nameController,
                            hintText: "Table",
                            validator: (value) =>
                                Validator.validateItem(value, "name"),
                          ),

                          const SizedBox(height: 20),
                          const TextFieldDescription(
                              text: "Inventory Description (optional)"),
                          const SizedBox(height: 5),
                          MyTextfield(
                            maxLines: 3,
                            controller: descriptionController,
                            hintText: "Inventory description (optional)",
                          ),
                          const SizedBox(height: 40),

                          // Identification
                          const Center(
                            child: TextFieldDescription(
                              text: "Identification",
                              fontSize: 18,
                            ),
                          ),
                          const SizedBox(height: 10),

                          const TextFieldDescription(text: "ID Tag"),
                          const SizedBox(height: 5),
                          MyTextfield(
                            keyboardType: TextInputType.number,
                            controller: idTagController,
                            hintText: "123456789",
                          ),

                          const SizedBox(height: 20),

                          const TextWithDescription(
                              startText: "Category",
                              descriptionText: "Please leave blank if unknown"),

                          const SizedBox(height: 5),
                          MyTextfield(
                            controller: categoryController,
                            hintText: "Electronics",
                          ),

                          const SizedBox(
                            height: 40,
                          ),

                          // Quantity and Location
                          const Center(
                            child: TextFieldDescription(
                              text: "Quantity and Location",
                              fontSize: 18,
                            ),
                          ),
                          const SizedBox(height: 10),

                          const TextFieldDescription(text: "Quantity"),
                          const SizedBox(height: 5),
                          Row(
                            children: [
                              Expanded(
                                child: MyTextfield(
                                  expands: false,
                                  controller: quantityController,
                                  hintText: "Quantity",
                                  keyboardType: TextInputType.number,
                                  validator: (value) =>
                                      Validator.validateQuantity(value, null),
                                ),
                              ),
                              const SizedBox(width: 20),
                              Row(
                                children: [
                                  IconButton(
                                      onPressed: increment,
                                      icon: const Icon(Icons.add)),
                                  const SizedBox(
                                    width: 20,
                                  ),
                                  IconButton(
                                      onPressed: decrement,
                                      icon: const Icon(Icons.remove)),
                                ],
                              )
                            ],
                          ),
                          const SizedBox(height: 20),
                          const TextFieldDescription(
                              text: "Where is this inventory Located?"),
                          const SizedBox(height: 5),
                          Row(
                            children: [
                              const TextFieldDescription(text: "Main Office:"),
                              const Spacer(),
                              DropdownButton<String>(
                                dropdownColor: Colors.white,
                                underline: const SizedBox(),
                                items: office
                                    .map((office) => DropdownMenuItem(
                                          value: office.name,
                                          child: SizedBox(
                                              width: MediaQuery.of(context)
                                                      .size
                                                      .width /
                                                  2,
                                              child: Text(
                                                office.name,
                                                maxLines: 2,
                                                overflow: TextOverflow.ellipsis,
                                              )),
                                        ))
                                    .toList(),
                                onChanged: (value) =>
                                    officeChanged(value, office),
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
                                dropdownColor: Colors.white,
                                underline: const SizedBox(),
                                items: office
                                    .firstWhere((office) =>
                                        office.name == selectedOffice)
                                    .rooms
                                    .map<DropdownMenuItem<String>>(
                                        (String room) {
                                  return DropdownMenuItem<String>(
                                    value: room,
                                    child: SizedBox(
                                      width:
                                          MediaQuery.of(context).size.width / 2,
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
                          const SizedBox(height: 40),

                          // Supplier and Ownership
                          const Center(
                            child: TextFieldDescription(
                              text: "Supplier and Ownership",
                              fontSize: 18,
                            ),
                          ),
                          const SizedBox(height: 10),

                          const TextFieldDescription(text: "Supplier Name"),
                          const SizedBox(height: 5),
                          MyTextfield(
                            controller: supplierController,
                            hintText: "Mr John Doe",
                            validator: (value) =>
                                Validator.validateItem(value, "supplier name"),
                          ),
                          const SizedBox(height: 20),
                          const TextFieldDescription(
                              text:
                                  "Which of these best describe this item ownership"),
                          const SizedBox(height: 5),
                          Column(
                            mainAxisAlignment: MainAxisAlignment.start,
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: List.generate(
                                radioOption.length,
                                (index) => Row(
                                      mainAxisAlignment:
                                          MainAxisAlignment.start,
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
                          const SizedBox(height: 40),

                          // Authentication and Tracking
                          const Center(
                            child: TextFieldDescription(
                              text: "Authentication and Tracking",
                              fontSize: 18,
                            ),
                          ),
                          const SizedBox(height: 10),

                          const TextFieldDescription(text: "Authenticated By"),
                          const SizedBox(height: 5),
                          MyTextfield(
                            controller: authenticatorController,
                            hintText: "Admin",
                            validator: (value) => Validator.validateItem(
                                value, "authorization name"),
                          ),
                          const SizedBox(height: 20),

                          const TextWithDescription(
                              startText:
                                  "Date of Purchase/Acquisition (dd/mm/yyyy)",
                              descriptionText: "Please leave blank if unknown"),

                          const SizedBox(height: 5),
                          MyTextfield(
                            controller: dateController,
                            hintText: "dd/mm/yyyy",
                            keyboardType: TextInputType.datetime,
                            inputFormatters: [
                              LengthLimitingTextInputFormatter(10),
                              FilteringTextInputFormatter.allow(
                                  RegExp(r'^[0-9\/]*$')),
                              TextInputFormatter.withFunction(
                                  dateFormatFunction)
                            ],
                            validator: (conditionKey == "Old" ||
                                    conditionKey == "Existing")
                                ? (value) => Validator.validateEmptyDate(value)
                                : (value) => Validator.validateDate(value),
                          ),

                          const SizedBox(height: 20),

                          const TextFieldDescription(
                              text: "Inventory Condition"),
                          const SizedBox(height: 5),
                          Column(
                            mainAxisAlignment: MainAxisAlignment.start,
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: List.generate(
                                conditionOption.length,
                                (index) => Row(
                                      mainAxisAlignment:
                                          MainAxisAlignment.start,
                                      mainAxisSize: MainAxisSize.min,
                                      children: [
                                        Radio<String>(
                                            value: conditionOption[index],
                                            groupValue: conditionKey,
                                            onChanged: (val) {
                                              setState(() {
                                                conditionKey = val!;
                                              });
                                            }),
                                        Expanded(
                                          child: Text(conditionOption[index],
                                              style: const TextStyle(
                                                  fontSize: 14,
                                                  fontWeight: FontWeight.w400,
                                                  color: Color(0xff666666))),
                                        ),
                                      ],
                                    )),
                          ),

                          const SizedBox(height: 40),

                          // Financial
                          const Center(
                            child: TextFieldDescription(
                              text: "Purchase Information",
                              fontSize: 18,
                            ),
                          ),
                          const SizedBox(height: 10),

                          const TextWithDescription(
                              startText: "Price in #",
                              descriptionText: "Please leave blank if unknown"),

                          const SizedBox(height: 5),
                          MyTextfield(
                            keyboardType: const TextInputType.numberWithOptions(
                                decimal: true),
                            controller: priceController,
                            inputFormatters: [
                              TextInputFormatter.withFunction(
                                  priceFormatFunction),
                            ],
                            hintText: "Price in #",
                            validator: conditionKey == "Old" ||
                                    conditionKey == "Existing"
                                ? null
                                : (value) =>
                                    Validator.validateItem(value, "price"),
                          ),
                          const SizedBox(height: 20),

                          const TextWithDescription(
                            startText: "Warranty Expiration Date (dd/mm/yyyy)",
                            descriptionText: "Please leave blank if unknown",
                          ),

                          const SizedBox(height: 5),
                          MyTextfield(
                            keyboardType: TextInputType.datetime,
                            inputFormatters: [
                              LengthLimitingTextInputFormatter(10),
                              FilteringTextInputFormatter.allow(
                                  RegExp(r'^[0-9\/]*$')),
                              TextInputFormatter.withFunction(
                                  dateFormatFunction)
                            ],
                            controller: warrantyExpirationDateController,
                            hintText: "dd/mm/yyyy",
                            validator: (value) =>
                                Validator.validateEmptyDate(value),
                          ),
                          const SizedBox(height: 20),
                          // Images
                          const Center(
                            child: TextFieldDescription(
                              text: "Images",
                              fontSize: 18,
                            ),
                          ),
                          const SizedBox(height: 10),

                          const Text(
                            "Tap on the add icon to add an image, tap on an image to view, long press on an image to remove Image",
                            style: TextStyle(
                              fontStyle: FontStyle.italic,
                              fontSize: 14,
                              color: Colors.black,
                              fontWeight: FontWeight.w300,
                            ),
                          ),

                          const SizedBox(height: 20),
                        ],
                      ),
                    ),
                  ),
                ),
                SliverPadding(
                  padding: const EdgeInsets.symmetric(horizontal: 24),
                  sliver: SliverToBoxAdapter(
                    child: Column(
                      mainAxisAlignment: MainAxisAlignment.start,
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: List.generate(
                          imageOptions.length,
                          (index) => Row(
                                mainAxisAlignment: MainAxisAlignment.start,
                                mainAxisSize: MainAxisSize.min,
                                children: [
                                  Radio<String>(
                                      value: imageOptions[index],
                                      groupValue: imageKey,
                                      onChanged: (val) {
                                        setState(() {
                                          imageKey = val!;
                                        });
                                      }),
                                  Expanded(
                                    child: Text(
                                        'Select image from ${imageOptions[index]}',
                                        style: const TextStyle(
                                            fontSize: 14,
                                            fontWeight: FontWeight.w400,
                                            color: Color(0xff666666))),
                                  ),
                                ],
                              )),
                    ),
                  ),
                ),
                SliverPadding(
                  padding: const EdgeInsets.symmetric(horizontal: 24.0),
                  sliver: SliverGrid.builder(
                    itemCount: images.length + 1,
                    gridDelegate:
                        const SliverGridDelegateWithFixedCrossAxisCount(
                            crossAxisCount: 3),
                    itemBuilder: (context, index) {
                      return index == images.length
                          ? Center(
                              child: IconButton(
                                  onPressed: () => pickAndResizeImage(),
                                  icon: const Icon(Icons.add)))
                          : GestureDetector(
                              onTap: () {
                                Navigator.push(
                                    context,
                                    MaterialPageRoute(
                                      builder: (context) => ShowFullImage(
                                        isNetworkImage: false,
                                        imageFile: images[index],
                                      ),
                                    ));
                              },
                              onLongPress: () {
                                setState(() {
                                  images.removeAt(index);
                                });
                              },
                              child: Container(
                                margin: const EdgeInsets.all(4),
                                decoration: BoxDecoration(
                                    image: DecorationImage(
                                        image: FileImage(images[index]),
                                        fit: BoxFit.cover)),
                              ),
                            );
                    },
                  ),
                ),
                SliverPadding(
                  padding: const EdgeInsets.symmetric(horizontal: 24.0),
                  sliver: SliverToBoxAdapter(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        const SizedBox(height: kBottomNavigationBarHeight),
                        MyButton(
                            onPressed: () => createInventory(
                                  subofficeName: selectedRoom,
                                  uid: uid,
                                  images: images,
                                ),
                            text: "SAVE"),
                        const SizedBox(height: 30),
                        const SizedBox(height: kBottomNavigationBarHeight)
                      ],
                    ),
                  ),
                )
              ]),
            ),
    );
  }
}
