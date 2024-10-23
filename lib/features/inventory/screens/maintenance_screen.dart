import 'package:assets_inventory_app_ghum/common/models/action.dart';
import 'package:assets_inventory_app_ghum/common/models/document_model.dart';
import 'package:assets_inventory_app_ghum/common/utils.dart';
import 'package:assets_inventory_app_ghum/common/widgets/my_button.dart';
import 'package:assets_inventory_app_ghum/common/widgets/my_textfield.dart';
import 'package:assets_inventory_app_ghum/common/widgets/textfield_description.dart';
import 'package:assets_inventory_app_ghum/features/auth/provider/user_provider.dart';
import 'package:assets_inventory_app_ghum/features/inventory/widgets/maintenace_update_dialog.dart';
import 'package:assets_inventory_app_ghum/features/inventory/widgets/popup_menu.dart';
import 'package:assets_inventory_app_ghum/helpers/validator.dart';
import 'package:assets_inventory_app_ghum/services/controller/document_controller.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

class MaintenanceScreen extends ConsumerStatefulWidget {
  const MaintenanceScreen({super.key, required this.documentModel});
  final DocumentModel documentModel;

  @override
  ConsumerState<ConsumerStatefulWidget> createState() =>
      _MaintenanceScreenState();
}

class _MaintenanceScreenState extends ConsumerState<MaintenanceScreen> {
  late DocumentModel documentModel;
  late DateTime startDate;
  late DateTime dueDate;
  late int totalQuantity;
  late String price;
  late List<ActionItem> actions;

  final TextEditingController repairController = TextEditingController();
  final TextEditingController scrapController = TextEditingController();
  final TextEditingController auctionController = TextEditingController();
  final TextEditingController auctionPriceController = TextEditingController();
  final TextEditingController bidderController = TextEditingController();

  final formKey = GlobalKey<FormState>();

  PopupMenuItem<MenuItem> buildItem(MenuItem item) {
    return PopupMenuItem<MenuItem>(
      value: item,
      child: Text(item.text),
    );
  }

  @override
  void initState() {
    actions = List.from(widget.documentModel.action!);
    repairController.text = actions
        .where((element) => element.name == "Repair")
        .first
        .quantity
        .toString();

    scrapController.text = actions
        .where((element) => element.name == "Scrap")
        .first
        .quantity
        .toString();

    auctionController.text = actions
        .where((element) => element.name == "Auction")
        .first
        .quantity
        .toString();
    bidderController.text = actions
        .where((element) => element.name == "Auction")
        .first
        .bidder
        .toString();

    documentModel = widget.documentModel;
    startDate = widget.documentModel.timeStamp!.toDate();
    dueDate =
        startDate.add(Duration(days: widget.documentModel.duration ?? 30));
    totalQuantity = widget.documentModel.quantity;
    price = widget.documentModel.price ?? '';
    super.initState();
  }

  @override
  void dispose() {
    repairController.dispose();
    scrapController.dispose();
    auctionController.dispose();
    auctionPriceController.dispose();
    bidderController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Maintenance Details'),
        surfaceTintColor: Colors.transparent,
        centerTitle: true,
        actions: [
          PopupMenuButton<MenuItem>(
            color: Colors.white,
            surfaceTintColor: Colors.transparent,
            onSelected: (value) => onSelected(
              context,
              value,
              documentModel.copyWith(action: actions),
            ),
            itemBuilder: (context) =>
                [...MenuItems.maintenanceItems.map(buildItem)],
          )
        ],
      ),
      body: SingleChildScrollView(
        child: Padding(
          padding: const EdgeInsets.symmetric(horizontal: 24.0),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            mainAxisAlignment: MainAxisAlignment.start,
            children: [
              DetailsWidget(
                  title: "Inventory Name:",
                  text: documentModel.inventory!.name),
              const SizedBox(height: 5),
              DetailsWidget(title: "Total Quantity:", text: "$totalQuantity"),
              const SizedBox(height: 5),
              DetailsWidget(title: "Service Price:", text: "#$price"),
              const SizedBox(height: 5),
              _buildDateRow('Start Date:', startDate),
              const SizedBox(height: 5),
              _buildDateRow('Expected Due Date:', dueDate),
              const SizedBox(height: 20),

              // Service Report
              const Text(
                "Service Report",
                style: TextStyle(fontWeight: FontWeight.bold, fontSize: 24),
              ),
              const Divider(),
              const SizedBox(height: 20),
              Text(documentModel.report, style: const TextStyle(fontSize: 16)),
              const SizedBox(height: 20),
              const Divider(),
              const SizedBox(height: 20),

              // Actions
              const Text('Actions:',
                  style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold)),
              Form(
                  key: formKey,
                  child: Column(
                    children: List.generate(
                        3, (index) => _buildActionItem(actions[index], index)),
                  )),
              // const SizedBox(height: 20),
              // _buildSummary(),
              const SizedBox(height: 20),

              // TODO comparisim test
              MyButton(text: "Save Changes", onPressed: saveChanges),
              const SizedBox(height: kBottomNavigationBarHeight),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildDateRow(String label, DateTime date) {
    return Row(
      mainAxisAlignment: MainAxisAlignment.spaceBetween,
      children: [
        Text(label,
            style: const TextStyle(
              fontSize: 16,
            )),
        Text('${date.toLocal()}'.split(' ')[0],
            style: const TextStyle(fontSize: 16)),
      ],
    );
  }

  Widget _buildActionItem(ActionItem action, int index) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 5.0),
      child: Container(
        padding: const EdgeInsets.all(8.0),
        decoration: BoxDecoration(
            border: Border.all(color: Colors.grey, width: 0.2),
            borderRadius: BorderRadius.circular(5)),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Center(
              child: Text(action.name,
                  style: const TextStyle(
                      fontSize: 16, fontWeight: FontWeight.bold)),
            ),
            Row(
              children: [
                const TextFieldDescription(text: "Status"),
                const Spacer(),
                DropdownButton<String>(
                  underline: const SizedBox(),
                  value: action.status,
                  dropdownColor: Colors.white,
                  items: ['In Progress', 'Completed', 'N/A']
                      .map((status) => DropdownMenuItem<String>(
                            value: status,
                            child: Text(status),
                          ))
                      .toList(),
                  onChanged: (newValue) {
                    setState(() {
                      if (newValue == "N/A") {
                        actions[index] = action.copyWith(
                            quantity: 0, price: 0, status: newValue);
                        clearController(index);
                      } else {
                        actions[index] = action.copyWith(status: newValue!);
                      }
                    });
                  },
                ),
              ],
            ),
            if (action.name == 'Auction' && action.status == 'Completed')
              Padding(
                padding: const EdgeInsets.symmetric(vertical: 5.0),
                child: Column(
                  children: [
                    Row(
                      children: [
                        const TextFieldDescription(text: "Price"),
                        const Spacer(),
                        SizedBox(
                          width: MediaQuery.of(context).size.width / 2.5,
                          child: MyTextfield(
                            expands: false,
                            controller: auctionPriceController,
                            keyboardType: TextInputType.number,
                            validator: (value) =>
                                Validator.validateDouble(value, "Price"),
                            onChanged: (value) => setState(() {
                              actions[index] = action.copyWith(
                                  price: double.tryParse(value) ?? 0);
                            }),
                          ),
                        ),
                      ],
                    ),
                    const SizedBox(height: 5),
                    Row(
                      children: [
                        const TextFieldDescription(text: "Bidder"),
                        const Spacer(),
                        SizedBox(
                          width: MediaQuery.of(context).size.width / 2.5,
                          child: MyTextfield(
                            expands: false,
                            controller: bidderController,
                            validator: (value) => Validator.validateName(value),
                            hintText: "Enter a valid name",
                          ),
                        ),
                      ],
                    ),
                  ],
                ),
              ),
            Row(
              children: [
                const TextFieldDescription(text: "Quantity"),
                const Spacer(),
                SizedBox(
                  width: MediaQuery.of(context).size.width / 2.5,
                  child: MyTextfield(
                    hintText: "Not applicable",
                    enabled: action.status == "N/A" ? false : true,
                    expands: false,
                    controller: switch (index) {
                      0 => repairController,
                      1 => scrapController,
                      2 => auctionController,
                      int() => throw UnimplementedError(),
                    },
                    keyboardType: TextInputType.number,
                    validator: action.status == "N/A"
                        ? null
                        : (value) =>
                            Validator.validateInteger(value, "Quantity"),
                    onChanged: (value) {
                      setState(() {
                        actions[index] =
                            action.copyWith(quantity: int.tryParse(value) ?? 0);
                      });
                    },
                  ),
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }

  // Widget _buildSummary() {
  //   double totalPrice = actions
  //       .where((action) => action.name == 'Auction')
  //       .fold(0, (sum, action) => sum + action.price * action.quantity);

  //   return Text('Total Auction Price: #${totalPrice.toStringAsFixed(2)}',
  //       style: const TextStyle(fontSize: 16, fontWeight: FontWeight.bold));
  // }

  void saveChanges() {
    bool isValid = formKey.currentState!.validate();
    if (ref.read(userProvider)?.role != 'admin') {
      return showSnackbar(context, "Only Admin has access to this feature");
    }
    if (isValid) {
      // Submit logic
      int totalAssigned =
          actions.fold(0, (sum, action) => sum + action.quantity);
      if (totalAssigned > totalQuantity) {
        showSnackbar(
            context, 'Total quantity assigned exceeds available quantity.');
      } else if (totalAssigned != totalQuantity) {
        showSnackbar(context,
            'Total quantity assigned is not equal to available quantity.');
      } else if (documentModel.isCompleted == true) {
        showSnackbar(context, "Inventory has already been updated");
      } else {
        // Proceed with submission
        ref.watch(documentControllerProvider.notifier).editMaintenanceDetails(
            documentModel.copyWith(action: actions), context);
      }
    }
  }

  void clearController(int index) {
    switch (index) {
      case 0:
        repairController.text = '';
        break;
      case 1:
        scrapController.text = '';
        break;
      case 2:
        auctionController.text = '';
        auctionPriceController.text = '';
        bidderController.text = '';
        break;
      default:
    }
  }

  onSelected(BuildContext context, MenuItem value, DocumentModel document) {
    switch (value) {
      case MenuItems.updateInventory:
        bool isValid = formKey.currentState!.validate();

        var inProgress = document.action!
            .where((element) => element.status == 'In Progress')
            .toList()
            .isNotEmpty;
        if (ref.read(userProvider)?.role != 'admin') {
          return showSnackbar(context, "Only Admin has access to this feature");
        }

        if (isValid) {
          int totalAssigned =
              actions.fold(0, (sum, action) => sum + action.quantity);
          if (totalAssigned > totalQuantity) {
            showSnackbar(
                context, 'Total quantity assigned exceeds available quantity.');
          } else if (totalAssigned != totalQuantity) {
            showSnackbar(context,
                'Total quantity assigned is not equal to available quantity.');
          } else if (inProgress) {
            showSnackbar(context, "One or more status is In Progress");
          } else if (document.isCompleted == true) {
            showSnackbar(context, "Inventory has already been updated");
          } else {
            showDialog(
              context: context,
              builder: (context) => MaintenanceUpdateDialog(
                document: document,
              ),
            );
          }
        }
        break;
      case MenuItems.downloadReport:
        _downloadReport(document);
    }
  }

  void _showLoadingDialog() {
    showDialog(
      context: context,
      barrierDismissible: false,
      builder: (BuildContext context) {
        return const AlertDialog(
          surfaceTintColor: Colors.transparent,
          content: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              Text(
                "Downloading",
                style: TextStyle(fontWeight: FontWeight.bold, fontSize: 18),
              ),
              SizedBox(height: 20),
              CircularProgressIndicator(),
            ],
          ),
        );
      },
    );
  }

  Future<void> _downloadReport(DocumentModel document) async {
    // Show loading dialog
    _showLoadingDialog();

    // Fetch data
    await ref
        .watch(documentControllerProvider.notifier)
        .getMaintenanceReport(document.id, context);

    // Hide loading dialog
    if (!mounted) return;
    Navigator.of(context).pop();
  }
}

class DetailsWidget extends StatelessWidget {
  const DetailsWidget({
    super.key,
    required this.title,
    required this.text,
  });

  final String title;
  final String text;

  @override
  Widget build(BuildContext context) {
    return Row(
      mainAxisAlignment: MainAxisAlignment.spaceBetween,
      children: [
        Text(title, style: const TextStyle(fontSize: 16)),
        const SizedBox(width: 5),
        Expanded(
          child: Text(
            text,
            style: const TextStyle(fontSize: 16),
            textAlign: TextAlign.right,
          ),
        )
      ],
    );
  }
}
