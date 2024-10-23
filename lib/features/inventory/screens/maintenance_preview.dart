import 'package:assets_inventory_app_ghum/common/models/document_model.dart';
import 'package:assets_inventory_app_ghum/features/inventory/screens/maintenance_screen.dart';
import 'package:assets_inventory_app_ghum/services/controller/document_controller.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

class MaintenancePreviewScreen extends ConsumerStatefulWidget {
  const MaintenancePreviewScreen({super.key});

  @override
  ConsumerState<ConsumerStatefulWidget> createState() =>
      _MaintenancePreviewScreenState();
}

class _MaintenancePreviewScreenState
    extends ConsumerState<MaintenancePreviewScreen> {
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text("Maintenance"),
        centerTitle: true,
      ),
      body: ref.watch(maintenanceDocumentProvider).when(
            data: (data) {
              return data.isEmpty
                  ? const Center(
                      child: Text(
                      "No Inventory item undergoing maintenance",
                      textAlign: TextAlign.center,
                    ))
                  : ListView.builder(
                      itemCount: data.length,
                      itemBuilder: (context, index) {
                        var document = data[index];
                        return Container(
                          margin: const EdgeInsets.symmetric(horizontal: 24)
                              .copyWith(bottom: 10),
                          decoration: BoxDecoration(
                              border:
                                  Border.all(color: Colors.grey, width: 0.2)),
                          child: ListTile(
                            onTap: () => onTap(document, context),
                            trailing: Text("${document.quantity}"),
                            title: Row(
                              children: [
                                Text(document.inventory!.name,
                                    style: const TextStyle(
                                        fontWeight: FontWeight.bold,
                                        fontSize: 18)),
                              ],
                            ),
                            subtitle: Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                Text(
                                  '(${document.officeName}, ${document.subOfficeName})',
                                  maxLines: 1,
                                  textAlign: TextAlign.center,
                                  overflow: TextOverflow.ellipsis,
                                ),
                                Text(
                                  document.isCompleted
                                      ? "Completed"
                                      : 'Not yet completed',
                                  style: TextStyle(
                                      fontWeight: FontWeight.bold,
                                      color: document.isCompleted
                                          ? Colors.green
                                          : Colors.red),
                                ),
                              ],
                            ),
                          ),
                        );
                      },
                    );
            },
            error: (error, stackTrace) => const Center(
              child: Text("An unexpected error occurred"),
            ),
            loading: () => const Center(
              child: CircularProgressIndicator(),
            ),
          ),
    );
  }

  onTap(DocumentModel document, BuildContext context) {
    Navigator.push(
        context,
        MaterialPageRoute(
          builder: (context) => MaintenanceScreen(documentModel: document),
        ));
  }
}
