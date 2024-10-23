import 'package:assets_inventory_app_ghum/common/models/office.dart';
import 'package:assets_inventory_app_ghum/common/widgets/textfield_description.dart';
import 'package:assets_inventory_app_ghum/features/home/controllers/office_list_provider.dart';
import 'package:assets_inventory_app_ghum/services/controller/document_controller.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

class RoomReportSelectionDialog extends ConsumerStatefulWidget {
  const RoomReportSelectionDialog({super.key});

  @override
  ConsumerState<ConsumerStatefulWidget> createState() =>
      _RoomReportSelectionDialogState();
}

class _RoomReportSelectionDialogState
    extends ConsumerState<RoomReportSelectionDialog> {
  String selectedRoom = '';
  String selectedOffice = '';

  @override
  void initState() {
    selectedOffice = ref.read(officeListProvider).first.name;
    selectedRoom = ref.read(officeListProvider).first.rooms.first;
    super.initState();
  }

  @override
  Widget build(BuildContext context) {
    bool isLoading = ref.watch(documentControllerProvider);
    List<Office> office = ref.read(officeListProvider);
    return AlertDialog(
      surfaceTintColor: Colors.transparent,
      backgroundColor: Colors.white,
      shadowColor: Colors.transparent,
      title: const Text('Select a room'),
      content: isLoading
          ? const SizedBox(
              height: 100,
              width: 100,
              child: Center(
                child: CircularProgressIndicator(
                  color: Colors.green,
                ),
              ),
            )
          : SingleChildScrollView(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                mainAxisSize: MainAxisSize.min,
                children: <Widget>[
                  const TextFieldDescription(text: "Office Name:"),
                  DropdownButton<String>(
                    dropdownColor: Colors.white,
                    underline: const SizedBox(),
                    items: office
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
                    onChanged: (value) => officeChanged(value, office),
                    value: selectedOffice,
                  ),
                  const SizedBox(height: 10),
                  const TextFieldDescription(text: "Room:"),
                  DropdownButton<String>(
                    dropdownColor: Colors.white,
                    underline: const SizedBox(),
                    items: office
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
            ),
      actions: <Widget>[
        TextButton(
          onPressed: () async {
            await ref
                .watch(documentControllerProvider.notifier)
                .generateRoomReport(
                    officeLocation: selectedOffice,
                    roomLocation: selectedRoom,
                    context: context);
            if (!context.mounted) return;
            Navigator.pop(context);
          },
          child: const Text('OK'),
        ),
      ],
    );
  }

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
}
