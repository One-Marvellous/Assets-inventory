import 'package:assets_inventory_app_ghum/common/models/items_model.dart';
import 'package:assets_inventory_app_ghum/common/models/office.dart';
import 'package:assets_inventory_app_ghum/common/widgets/box_text.dart';
import 'package:assets_inventory_app_ghum/common/widgets/link_text.dart';
import 'package:assets_inventory_app_ghum/common/widgets/shimmer_loader.dart';
import 'package:assets_inventory_app_ghum/common/widgets/textfield_description.dart';
import 'package:assets_inventory_app_ghum/features/home/controllers/office_list_provider.dart';
import 'package:assets_inventory_app_ghum/features/home/widgets/sub_office_widget.dart';
import 'package:assets_inventory_app_ghum/features/inventory/screens/preview_inventory.dart';
import 'package:assets_inventory_app_ghum/features/inventory/screens/show_full_image.dart';
import 'package:cached_network_image/cached_network_image.dart';
import 'package:flutter/material.dart';
import 'package:flutter_cache_manager/flutter_cache_manager.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

class ShowSearchInventory extends ConsumerStatefulWidget {
  const ShowSearchInventory({super.key, required this.inventory});
  final ItemModel inventory;

  @override
  ConsumerState<ConsumerStatefulWidget> createState() =>
      _ShowSearchInventoryState();
}

class _ShowSearchInventoryState extends ConsumerState<ShowSearchInventory> {
  late List<Office> office;
  late ItemModel item;

  @override
  void initState() {
    item = widget.inventory;
    office = ref.read(officeListProvider);
    super.initState();
  }

  @override
  Widget build(BuildContext context) {
    var selectedOffice = office
        .firstWhere((office) => office.name == widget.inventory.officeLocation);
    var index = selectedOffice.rooms.indexOf(widget.inventory.roomLocation);

    return Scaffold(
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

                  const TextFieldDescription(text: "Inventory Description"),
                  const SizedBox(height: 5),
                  BoxText(text: item.description ?? "No description"),

                  const TextFieldDescription(text: "Category"),
                  const SizedBox(height: 5),
                  BoxText(text: item.category ?? 'N/A'),

                  const TextFieldDescription(text: "Price (#)"),
                  const SizedBox(height: 5),
                  BoxText(text: item.price == '' ? "N/A" : item.price ?? "N/A"),

                  const TextFieldDescription(
                      text: "Date of Purchase/Acquisition"),
                  const SizedBox(height: 5),
                  BoxText(text: item.acquisitionDate ?? "Unknown"),

                  const TextFieldDescription(text: "Warranty Expiration Date"),
                  const SizedBox(height: 5),
                  BoxText(text: item.warrantyExpiration ?? 'N/A'),

                  const TextFieldDescription(text: "Inventory Condition"),
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

                  const Text(
                    "To edit click on the text to navigate to office or room location",
                    style: TextStyle(
                      fontStyle: FontStyle.italic,
                      fontSize: 14,
                      color: Colors.black,
                      fontWeight: FontWeight.w300,
                    ),
                  ),
                  const SizedBox(height: 20),
                  Row(
                    crossAxisAlignment: CrossAxisAlignment.center,
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      Expanded(
                        child: LinkText(
                            linkText: widget.inventory.officeLocation,
                            onTap: () => goToOffice(selectedOffice)),
                      ),
                      const Expanded(
                        child: Center(
                          child: Padding(
                            padding: EdgeInsets.symmetric(horizontal: 10.0),
                            child: Text("-->"),
                          ),
                        ),
                      ),
                      Expanded(
                        child: LinkText(
                            linkText: widget.inventory.roomLocation,
                            onTap: () => goToRoom(selectedOffice.uid,
                                selectedOffice.rooms[index])),
                      ),
                    ],
                  ),

                  // Images
                  if (widget.inventory.imagePath.isNotEmpty)
                    const Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        SizedBox(height: 20),
                        Center(
                          child: TextFieldDescription(
                            text: "Images",
                            fontSize: 18,
                          ),
                        ),
                        SizedBox(height: 10),
                        Text(
                          "Click on the image to expand the image",
                          style: TextStyle(
                            fontStyle: FontStyle.italic,
                            fontSize: 14,
                            color: Colors.black,
                            fontWeight: FontWeight.w300,
                          ),
                        ),
                        SizedBox(height: 20),
                      ],
                    )
                ],
              ),
            ),
          ),
          SliverPadding(
            padding: const EdgeInsets.symmetric(horizontal: 24.0),
            sliver: SliverGrid.builder(
              itemCount: widget.inventory.imagePath.length,
              gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
                  crossAxisCount: 3),
              itemBuilder: (context, index) {
                var imageLink = widget.inventory.imagePath[index];
                return Padding(
                  padding: const EdgeInsets.only(right: 4),
                  child: CachedNetworkImage(
                    imageUrl: imageLink,
                    placeholder: (context, url) => const Loader(
                      height: double.infinity,
                      width: double.infinity,
                    ),
                    cacheManager: CacheManager(Config('customCacheKey',
                        stalePeriod: const Duration(days: 7))),
                    errorWidget: (context, url, error) => const Icon(
                      Icons.error,
                      color: Colors.red,
                    ),
                    imageBuilder: (context, imageProvider) => GestureDetector(
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
          const SliverToBoxAdapter(
            child: SizedBox(height: kBottomNavigationBarHeight),
          ),
        ]),
      ),
    );
  }

  goToOffice(Office selectedOffice) {
    Navigator.push(
        context,
        MaterialPageRoute(
          builder: (context) => SubOfficeWidget(office: selectedOffice),
        ));
  }

  goToRoom(String uid, String name) {
    Navigator.push(
        context,
        MaterialPageRoute(
          settings: const RouteSettings(name: "PreviewInventory"),
          builder: (context) => PreviewInventory(uid: uid, name: name),
        ));
  }
}
