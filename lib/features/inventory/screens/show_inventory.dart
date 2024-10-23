import 'package:assets_inventory_app_ghum/common/models/items_model.dart';
import 'package:assets_inventory_app_ghum/common/models/suboffice.dart';
import 'package:assets_inventory_app_ghum/common/utils.dart';
import 'package:assets_inventory_app_ghum/common/widgets/box_text.dart';
import 'package:assets_inventory_app_ghum/common/widgets/shimmer_loader.dart';
import 'package:assets_inventory_app_ghum/common/widgets/textfield_description.dart';
import 'package:assets_inventory_app_ghum/features/auth/provider/user_provider.dart';
import 'package:assets_inventory_app_ghum/features/inventory/screens/edit_inventory.dart';
import 'package:assets_inventory_app_ghum/features/inventory/screens/item_history.dart';
import 'package:assets_inventory_app_ghum/features/inventory/screens/pick_images.dart';
import 'package:assets_inventory_app_ghum/features/inventory/screens/show_full_image.dart';
import 'package:assets_inventory_app_ghum/features/inventory/widgets/delete_dialog.dart';
import 'package:assets_inventory_app_ghum/features/inventory/widgets/my_dialog.dart';
import 'package:assets_inventory_app_ghum/features/inventory/widgets/popup_menu.dart';
import 'package:assets_inventory_app_ghum/services/controller/item_controller.dart';
import 'package:cached_network_image/cached_network_image.dart';
import 'package:flutter/material.dart';
import 'package:flutter_cache_manager/flutter_cache_manager.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

class ShowInventory extends ConsumerStatefulWidget {
  const ShowInventory(
      {required this.inventoryId,
      required this.index,
      super.key,
      required this.subOffice});
  final String inventoryId;
  final int index;
  final SubOffice subOffice;
  @override
  ConsumerState<ConsumerStatefulWidget> createState() => _ShowInventoryState();
}

class _ShowInventoryState extends ConsumerState<ShowInventory> {
  late bool isAdmin;

  late int inventoryIndex;
  late SubOffice subOffice;

  PopupMenuItem<MenuItem> buildItem(MenuItem item) {
    return PopupMenuItem<MenuItem>(
      value: item,
      child: Text(item.text),
    );
  }

  void onSelected(BuildContext context, MenuItem item, SubOffice subOffice,
      ItemModel inventory) {
    switch (item) {
      case MenuItems.editItem:
        if (isAdmin) {
          Navigator.of(context).push(MaterialPageRoute(
            builder: (context) => EditInventory(
              index: inventoryIndex,
              subOffice: subOffice,
              inventory: inventory,
            ),
          ));
        } else {
          showSnackbar(context, "Only Admin has access to this feature");
        }
        break;
      case MenuItems.itemHistory:
        Navigator.of(context).push(MaterialPageRoute(
          builder: (context) => ItemHistory(id: inventory.sharedId),
        ));
        break;
      case MenuItems.deleteItem:
        if (isAdmin) {
          showDialog(
            context: context,
            builder: (context) => DeleteDialog(
              index: inventoryIndex,
              subOffice: subOffice,
              inventory: inventory,
            ),
          );
        } else {
          showSnackbar(context, "Only Admin has access to this feature");
        }
        break;
    }
  }

  @override
  void initState() {
    isAdmin = ref.read(userProvider)?.role == "admin";
    inventoryIndex = widget.index;
    subOffice = widget.subOffice;
    super.initState();
  }

  @override
  Widget build(BuildContext context) {
    return ref.watch(inventoryProvider(widget.inventoryId)).when(
        data: (data) {
          if (data.isEmpty) {
            return const Scaffold(
                body: Center(
              child: Text("Nothing to show"),
            ));
          } else {
            ItemModel item = data.first;

            return Scaffold(
              appBar: AppBar(
                title: const Text("Inventory Details"),
                centerTitle: true,
                surfaceTintColor: Colors.transparent,
                actions: [
                  PopupMenuButton<MenuItem>(
                    color: Colors.white,
                    surfaceTintColor: Colors.transparent,
                    onSelected: (value) =>
                        onSelected(context, value, subOffice, item),
                    itemBuilder: (context) =>
                        [...MenuItems.items.map(buildItem)],
                  )
                ],
              ),
              body: SafeArea(
                child: CustomScrollView(slivers: [
                  SliverPadding(
                    padding: const EdgeInsets.symmetric(horizontal: 24.0),
                    sliver: SliverToBoxAdapter(
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
                          BoxText(text: item.name),

                          const TextFieldDescription(text: "Id Tag"),
                          const SizedBox(height: 5),
                          BoxText(text: item.idTag ?? 'N/A'),

                          const TextFieldDescription(
                              text: "Inventory Description"),
                          const SizedBox(height: 5),
                          BoxText(text: item.description ?? "No description"),

                          const TextFieldDescription(text: "Category"),
                          const SizedBox(height: 5),
                          BoxText(text: item.category ?? 'N/A'),

                          const TextFieldDescription(
                              text: "Initial Purchased Price (#)"),
                          const SizedBox(height: 5),
                          BoxText(
                              text: item.price == ''
                                  ? "N/A"
                                  : item.price ?? "N/A"),

                          const TextFieldDescription(
                              text: "Date of Purchase/Acquisition"),
                          const SizedBox(height: 5),
                          BoxText(text: item.acquisitionDate ?? "Unknown"),

                          const TextFieldDescription(
                              text: "Warranty Expiration Date"),
                          const SizedBox(height: 5),
                          BoxText(text: item.warrantyExpiration ?? 'N/A'),

                          const TextFieldDescription(
                              text: "Inventory Condition"),
                          const SizedBox(height: 5),
                          BoxText(text: item.condition),

                          const SizedBox(height: 20),

                          // Quantity
                          const Center(
                            child: TextFieldDescription(
                              text: "Quantity and Ownership Status",
                              fontSize: 18,
                            ),
                          ),
                          const SizedBox(height: 10),

                          const TextFieldDescription(text: "Quantity"),
                          const SizedBox(height: 5),
                          BoxText(text: item.quantity.toString()),

                          const TextFieldDescription(text: "OwnerShip Status"),
                          const SizedBox(height: 5),
                          BoxText(text: item.status),

                          const TextFieldDescription(
                              text: "Inventory Location"),
                          const SizedBox(height: 5),
                          BoxText(
                              text:
                                  "@ ${item.officeLocation} --> ${item.roomLocation}"),

                          // Images
                          if ((item.imagePath.isNotEmpty) || isAdmin)
                            Column(
                              children: [
                                const Center(
                                  child: TextFieldDescription(
                                    text: "Images",
                                    fontSize: 18,
                                  ),
                                ),
                                Padding(
                                  padding: const EdgeInsets.only(
                                      top: 10, bottom: 20),
                                  child: Text(
                                    isAdmin
                                        ? "Click on the image to expand the image, tap the plus icon to add more images, long press on an image to delete"
                                        : "Click on the image to expand the image",
                                    style: const TextStyle(
                                      fontStyle: FontStyle.italic,
                                      fontSize: 14,
                                      color: Colors.black,
                                      fontWeight: FontWeight.w300,
                                    ),
                                  ),
                                ),
                              ],
                            ),
                        ],
                      ),
                    ),
                  ),

                  // is not Admin
                  if (item.imagePath.isNotEmpty && !isAdmin)
                    SliverPadding(
                      padding: const EdgeInsets.symmetric(horizontal: 24.0),
                      sliver: SliverGrid.builder(
                        itemCount: item.imagePath.length,
                        gridDelegate:
                            const SliverGridDelegateWithFixedCrossAxisCount(
                                crossAxisCount: 3),
                        itemBuilder: (context, index) {
                          var imageLink = item.imagePath[index];
                          return Padding(
                            padding: const EdgeInsets.only(right: 4),
                            child: CachedNetworkImage(
                              imageUrl: imageLink,
                              placeholder: (context, url) => const Loader(
                                height: double.infinity,
                                width: double.infinity,
                              ),
                              cacheManager: CacheManager(Config(
                                  'customCacheKey',
                                  stalePeriod: const Duration(days: 7))),
                              errorWidget: (context, url, error) => const Icon(
                                Icons.error,
                                color: Colors.red,
                              ),
                              imageBuilder: (context, imageProvider) =>
                                  GestureDetector(
                                onTap: () {
                                  Navigator.push(
                                      context,
                                      MaterialPageRoute(
                                        builder: (context) => ShowFullImage(
                                          imageLink: imageLink,
                                        ),
                                      ));
                                },
                                child: Container(
                                  decoration: BoxDecoration(
                                    image: DecorationImage(
                                      image: imageProvider,
                                      fit: BoxFit.cover,
                                    ),
                                  ),
                                ),
                              ),
                            ),
                          );
                        },
                      ),
                    ),

                  // isAdmin
                  if (isAdmin)
                    SliverPadding(
                      padding: const EdgeInsets.symmetric(horizontal: 24.0),
                      sliver: SliverGrid.builder(
                        itemCount: item.imagePath.length + 1,
                        gridDelegate:
                            const SliverGridDelegateWithFixedCrossAxisCount(
                                crossAxisCount: 3),
                        itemBuilder: (context, index) {
                          return index == (item.imagePath.length)
                              ? Center(
                                  child: IconButton(
                                      onPressed: () => Navigator.push(
                                          context,
                                          MaterialPageRoute(
                                            builder: (context) => PickImages(
                                                inventory: item,
                                                subOffice: subOffice,
                                                index: inventoryIndex),
                                          )),
                                      icon: const Icon(Icons.add)))
                              : Padding(
                                  padding: const EdgeInsets.only(right: 4),
                                  child: CachedNetworkImage(
                                    imageUrl: item.imagePath[index],
                                    placeholder: (context, url) => const Loader(
                                      height: double.infinity,
                                      width: double.infinity,
                                    ),
                                    cacheManager: CacheManager(Config(
                                        'customCacheKey',
                                        stalePeriod: const Duration(days: 7))),
                                    errorWidget: (context, url, error) =>
                                        const Icon(
                                      Icons.error,
                                      color: Colors.red,
                                    ),
                                    imageBuilder: (context, imageProvider) =>
                                        GestureDetector(
                                      onLongPress: () => deleteImage(
                                          item.imagePath[index],
                                          item,
                                          subOffice,
                                          inventoryIndex),
                                      onTap: () {
                                        Navigator.push(
                                            context,
                                            MaterialPageRoute(
                                              builder: (context) =>
                                                  ShowFullImage(
                                                imageLink:
                                                    item.imagePath[index],
                                              ),
                                            ));
                                      },
                                      child: Container(
                                        decoration: BoxDecoration(
                                          image: DecorationImage(
                                            image: imageProvider,
                                            fit: BoxFit.cover,
                                          ),
                                        ),
                                      ),
                                    ),
                                  ),
                                );
                        },
                      ),
                    ),
                  const SliverToBoxAdapter(
                    child: SizedBox(height: kBottomNavigationBarHeight),
                  ),
                ]),
              ),
            );
          }
        },
        error: (error, stackTrace) {
          return Scaffold(
            body: Center(
              child: Text(
                "There is a problem loading this page, try again later\n$stackTrace}",
                textAlign: TextAlign.center,
              ),
            ),
          );
        },
        loading: () => const Scaffold(
              body: Center(
                child: CircularProgressIndicator(),
              ),
            ));
  }

  void deleteImage(String imageUrl, ItemModel inventoryItem,
      SubOffice subOffice, int index) {
    showDialog(
      barrierDismissible: false,
      context: context,
      builder: (context) {
        return MyDialog(
            imageUrl: imageUrl,
            inventory: inventoryItem,
            subOffice: subOffice,
            index: inventoryIndex);
      },
    );
  }
}
