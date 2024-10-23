import 'package:assets_inventory_app_ghum/common/models/document_model.dart';
import 'package:assets_inventory_app_ghum/common/utils/constant/strings.dart';
import 'package:assets_inventory_app_ghum/features/inventory/screens/item_history_view.dart';
import 'package:assets_inventory_app_ghum/services/controller/document_controller.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:intl/intl.dart';

class ItemHistory extends ConsumerWidget {
  const ItemHistory({super.key, required this.id});
  final String id;

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    return Scaffold(
      appBar: AppBar(
        title: const Text("Item History"),
        surfaceTintColor: Colors.transparent,
        centerTitle: true,
      ),
      body: ref.watch(documentsProvider(id)).when(
          data: (data) {
            return ListView.builder(
              itemCount: data.length,
              itemBuilder: (context, index) {
                DocumentModel document = data[index];
                Color color = pickColor(document.operation);
                String sign = pickSign(document.operation);
                return ListTile(
                  onTap: () => onTap(document, context),
                  trailing: Text(
                    "$sign${document.quantity}",
                    style: const TextStyle(fontWeight: FontWeight.bold),
                  ),
                  leading: Container(
                    width: 8,
                    height: 60,
                    color: color,
                  ),
                  title: Text(
                    document.operation,
                    style: const TextStyle(
                        fontWeight: FontWeight.bold, fontSize: 18),
                  ),
                  subtitle: Text(DateFormat('yyyy-MM-dd')
                      .format(document.timeStamp!.toDate())),
                );
              },
            );
          },
          error: (error, stackTrace) {
            return const Center(
              child: Text(
                  "There is a problem loading this page, try again later."),
            );
          },
          loading: () => const Center(
                child: CircularProgressIndicator(),
              )),
    );
  }

  Color pickColor(String operation) {
    switch (operation) {
      case IStrings.add:
        return Colors.green;
      case IStrings.transfer:
        return Colors.blue;
      case IStrings.maintain:
        return Colors.amber;
      case IStrings.create:
        return Colors.yellow;
      case IStrings.delete:
        return Colors.red;
      default:
        return Colors.black;
    }
  }

  String pickSign(String operation) {
    switch (operation) {
      case (IStrings.add):
        return '+';
      case (IStrings.create):
        return '+';
      case (IStrings.maintain):
        return '-';
      case (IStrings.transfer):
        return '-';
      default:
        return "";
    }
  }

  void onTap(DocumentModel document, BuildContext context) {
    Navigator.push(
        context,
        MaterialPageRoute(
          builder: (context) => HistoryView(document: document),
        ));
  }
}
