import 'package:assets_inventory_app_ghum/common/models/office.dart';
import 'package:assets_inventory_app_ghum/features/home/controllers/office_list_provider.dart';
import 'package:assets_inventory_app_ghum/services/controller/document_controller.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

class OfficeReportSelectionDialog extends ConsumerStatefulWidget {
  const OfficeReportSelectionDialog({super.key});

  @override
  ConsumerState<ConsumerStatefulWidget> createState() =>
      _OfficeReportSelectionDialogState();
}

class _OfficeReportSelectionDialogState
    extends ConsumerState<OfficeReportSelectionDialog> {
  String selectedOffice = '';
  @override
  void initState() {
    selectedOffice = ref.read(officeListProvider).first.name;

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
      title: const Text('Select an office'),
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
                ],
              ),
            ),
      actions: <Widget>[
        TextButton(
          onPressed: () async {
            await ref
                .watch(documentControllerProvider.notifier)
                .generateOfficeReport(
                    officeLocation: selectedOffice, context: context);

            if (!context.mounted) return;
            Navigator.of(context).pop();
          },
          child: const Text('OK'),
        ),
      ],
    );
  }

  void officeChanged(String? value, List<Office> office) {
    setState(() {
      selectedOffice = value!;
    });
  }
}
