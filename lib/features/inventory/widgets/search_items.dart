import 'package:assets_inventory_app_ghum/common/widgets/custom_circular_avatar.dart';
import 'package:flutter/material.dart';

class SearchInventoryItem extends StatelessWidget {
  const SearchInventoryItem(
      {super.key,
      required this.count,
      required this.name,
      required this.officeName,
      required this.roomName,
      this.imageUrl,
      this.onTap});
  final String name;
  final int count;
  final String? imageUrl;
  final String officeName;
  final String roomName;
  final void Function()? onTap;

  @override
  Widget build(BuildContext context) {
    return ListTile(
      onTap: onTap,
      leading: CustomCircularAvatar(imageUrl: imageUrl),
      subtitle: Row(
        children: [
          Expanded(
              child: Container(
            padding: const EdgeInsets.all(8),
            decoration: BoxDecoration(
                borderRadius: BorderRadius.circular(50),
                border: Border.all(width: 0.2, color: Colors.green)),
            child: Center(
              child: Text(
                officeName,
                maxLines: 1,
                overflow: TextOverflow.ellipsis,
              ),
            ),
          )),
          const SizedBox(width: 5),
          Expanded(
            child: Container(
              padding: const EdgeInsets.all(8),
              decoration: BoxDecoration(
                  borderRadius: BorderRadius.circular(50),
                  border: Border.all(width: 0.2, color: Colors.green)),
              child: Center(
                child: Text(
                  roomName,
                  maxLines: 1,
                  overflow: TextOverflow.ellipsis,
                ),
              ),
            ),
          ),
        ],
      ),
      title: Text(
        name,
        style: const TextStyle(fontWeight: FontWeight.bold),
      ),
      trailing: Text(
        "$count",
        style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 14),
      ),
    );
  }
}
