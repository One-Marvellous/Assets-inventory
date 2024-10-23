import 'package:assets_inventory_app_ghum/common/models/document_model.dart';
import 'package:assets_inventory_app_ghum/common/utils/constant/strings.dart';
import 'package:assets_inventory_app_ghum/common/widgets/box_text.dart';
import 'package:assets_inventory_app_ghum/common/widgets/textfield_description.dart';
import 'package:flutter/material.dart';
import 'package:intl/intl.dart';

class HistoryView extends StatefulWidget {
  const HistoryView({super.key, required this.document});
  final DocumentModel document;

  @override
  State<HistoryView> createState() => _HistoryViewState();
}

class _HistoryViewState extends State<HistoryView> {
  String get date =>
      DateFormat('yyyy-MM-dd').format(widget.document.timeStamp!.toDate());

  String get description => switch (widget.document.operation) {
        IStrings.add => "added",
        IStrings.transfer => "transferred",
        IStrings.maintain => "undergoing maintenance",
        String() => "",
      };

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: SafeArea(
        child: SingleChildScrollView(
          child: Padding(
            padding: const EdgeInsets.all(24.0),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Center(
                  child: TextFieldDescription(
                    text: widget.document.operation,
                    fontSize: 20,
                  ),
                ),
                const SizedBox(height: 20),
                TextFieldDescription(
                  text: "Quantity $description",
                ),
                const SizedBox(height: 5),
                BoxText(text: widget.document.quantity.toString()),

                Visibility(
                    visible: widget.document.supplier != null,
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        const TextFieldDescription(
                          text: "Supplied by",
                        ),
                        const SizedBox(height: 5),
                        BoxText(text: widget.document.supplier ?? ""),
                      ],
                    )),
                Visibility(
                    visible: widget.document.executor != null,
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        const TextFieldDescription(
                          text: "Task Executed by",
                        ),
                        const SizedBox(height: 5),
                        BoxText(text: widget.document.executor ?? ""),
                      ],
                    )),
                Visibility(
                    visible: widget.document.technician != null,
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        const TextFieldDescription(
                          text: "Technician conducting repairs",
                        ),
                        const SizedBox(height: 5),
                        BoxText(text: widget.document.technician ?? ""),
                      ],
                    )),
                const TextFieldDescription(
                  text: "Price (#)",
                ),
                const SizedBox(height: 5),
                BoxText(text: widget.document.price ?? 'Unknown'),
                const TextFieldDescription(
                  text: "Comments",
                ),
                const SizedBox(height: 5),
                BoxText(text: widget.document.report),
                const TextFieldDescription(
                  text: "Authenticated by",
                ),
                const SizedBox(height: 5),
                BoxText(text: widget.document.authenticator),

                // Space
                const SizedBox(height: 30),
                Center(
                  child: Text(
                    '${widget.document.officeName}, ${widget.document.subOfficeName} \n$date',
                    textAlign: TextAlign.center,
                  ),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}
