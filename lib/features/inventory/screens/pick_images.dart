import 'dart:io';

import 'package:assets_inventory_app_ghum/common/models/items_model.dart';
import 'package:assets_inventory_app_ghum/common/models/suboffice.dart';
import 'package:assets_inventory_app_ghum/common/utils.dart';
import 'package:assets_inventory_app_ghum/common/widgets/my_button.dart';
import 'package:assets_inventory_app_ghum/features/inventory/screens/show_full_image.dart';
import 'package:assets_inventory_app_ghum/services/controller/document_controller.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:image_picker/image_picker.dart';

class PickImages extends ConsumerStatefulWidget {
  const PickImages(
      {super.key,
      required this.inventory,
      required this.subOffice,
      required this.index});
  final ItemModel inventory;
  final int index;
  final SubOffice subOffice;
  @override
  ConsumerState<ConsumerStatefulWidget> createState() => _PickImagesState();
}

class _PickImagesState extends ConsumerState<PickImages> {
  List<File> images = [];
  List imageOptions = ["Camera", "Gallery"];
  String imageKey = "Camera";

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

  @override
  Widget build(BuildContext context) {
    bool isLoading = ref.watch(documentControllerProvider);
    return Scaffold(
      appBar: AppBar(
        title: const Text("Pick Images"),
        centerTitle: true,
      ),
      body: isLoading
          ? const Center(
              child: Row(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                Text("Saving..."),
                SizedBox(width: 10),
                CircularProgressIndicator(),
              ],
            ))
          : CustomScrollView(
              slivers: [
                const SliverPadding(
                  padding: EdgeInsets.symmetric(horizontal: 24),
                  sliver: SliverToBoxAdapter(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          "Click on the add button to add an image, tap an image to view, long press on an image to remove Image",
                          style: TextStyle(
                            fontStyle: FontStyle.italic,
                            fontSize: 14,
                            color: Colors.black,
                            fontWeight: FontWeight.w300,
                          ),
                        ),
                        SizedBox(height: 20),
                      ],
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
                            onPressed: () {
                              saveImages(
                                inventoryItem: widget.inventory,
                                index: widget.index,
                                subOffice: widget.subOffice,
                                images: images,
                              );
                            },
                            text: "SAVE"),
                        const SizedBox(height: 30),
                        const SizedBox(height: kBottomNavigationBarHeight)
                      ],
                    ),
                  ),
                )
              ],
            ),
    );
  }

  void saveImages(
      {required ItemModel inventoryItem,
      required int index,
      required SubOffice subOffice,
      required List<File> images}) {
    ref.watch(documentControllerProvider.notifier).saveImages(
        inventoryItem: inventoryItem,
        index: index,
        subOffice: subOffice,
        images: images,
        context: context);
  }
}
