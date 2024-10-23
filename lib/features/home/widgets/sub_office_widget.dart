import 'package:assets_inventory_app_ghum/common/models/office.dart';
import 'package:assets_inventory_app_ghum/common/widgets/office_tile.dart';
import 'package:assets_inventory_app_ghum/features/inventory/screens/preview_inventory.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

class SubOfficeWidget extends ConsumerWidget {
  const SubOfficeWidget({super.key, required this.office});
  final Office office;

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    String uid = office.uid;
    return Scaffold(
      appBar: AppBar(
        title: Text(office.name),
        surfaceTintColor: Colors.transparent,
      ),
      body: ListView.builder(
        itemCount: office.rooms.length,
        itemBuilder: (context, index) {
          var name = office.rooms[index];
          return Padding(
            padding: const EdgeInsets.only(bottom: 8.0),
            child: OfficeTile(
              name: name,
              onTap: () {
                Navigator.push(
                    context,
                    MaterialPageRoute(
                      settings: const RouteSettings(name: "PreviewInventory"),
                      builder: (context) =>
                          PreviewInventory(uid: uid, name: name),
                    ));
              },
            ),
          );
        },
      ),
    );
  }
}
