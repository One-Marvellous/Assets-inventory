import 'package:assets_inventory_app_ghum/common/models/document_model.dart';
import 'package:assets_inventory_app_ghum/services/controller/document_controller.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

class MaintenanceUpdateDialog extends ConsumerStatefulWidget {
  const MaintenanceUpdateDialog({super.key, required this.document});
  final DocumentModel document;

  @override
  ConsumerState<ConsumerStatefulWidget> createState() =>
      _MaintenanceUpdateDialogState();
}

class _MaintenanceUpdateDialogState
    extends ConsumerState<MaintenanceUpdateDialog> {
  @override
  Widget build(BuildContext context) {
    return AlertDialog(
      surfaceTintColor: Colors.transparent,
      title: const Text('Update Inventory'),
      content: const Text(
          'Note this action is irreversible, make sure you confirm the details.\n\nDo you wish to continue?'),
      actions: <Widget>[
        TextButton(
          onPressed: () {
            Navigator.of(context).pop(); // Close the dialog
          },
          child: const Text('No'),
        ),
        TextButton(
          onPressed: () {
            ref.watch(documentControllerProvider.notifier).completeMaintenance(
                document: widget.document, context: context);
            // Perform Update operation
          },
          child: const Text('Yes'),
        ),
      ],
    );
  }
}
