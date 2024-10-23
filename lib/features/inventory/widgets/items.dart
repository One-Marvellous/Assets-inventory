import 'package:assets_inventory_app_ghum/common/widgets/custom_circular_avatar.dart';
import 'package:flutter/material.dart';
import 'package:flutter_svg/svg.dart';

class InventoryItem extends StatelessWidget {
  const InventoryItem(
      {super.key,
      required this.count,
      required this.serialNumber,
      required this.name,
      this.imageUrl,
      this.onTap});
  final String name;
  final String serialNumber;
  final int count;
  final String? imageUrl;
  final void Function()? onTap;

  @override
  Widget build(BuildContext context) {
    return ListTile(
      onTap: onTap,
      leading: CustomCircularAvatar(imageUrl: imageUrl),
      subtitle: serialNumber.isEmpty
          ? const SizedBox()
          : Row(
              children: [
                SvgPicture.asset('assets/svg/barcode.svg',
                    height: 14, width: 50),
                SvgPicture.asset('assets/svg/barcode.svg',
                    height: 14, width: 50),
                const SizedBox(width: 5),
                Text(
                  serialNumber,
                ),
              ],
            ),
      title: Text(
        name,
        style: const TextStyle(fontWeight: FontWeight.bold),
        maxLines: 1,
        overflow: TextOverflow.ellipsis,
      ),
      trailing: Text(
        "$count",
        style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 14),
      ),
    );
  }
}
