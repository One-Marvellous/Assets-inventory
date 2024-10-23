import 'dart:developer';
import 'dart:io';

import 'package:assets_inventory_app_ghum/common/models/action.dart';
import 'package:assets_inventory_app_ghum/common/models/document_model.dart';
import 'package:assets_inventory_app_ghum/common/models/items_model.dart';
import 'package:assets_inventory_app_ghum/common/models/newly_bought_report.dart';
import 'package:assets_inventory_app_ghum/common/models/office_report.dart';
import 'package:assets_inventory_app_ghum/common/utils.dart';
import 'package:assets_inventory_app_ghum/features/reports/screen/pdf/save_and_open_pdf.dart';
import 'package:pdf/pdf.dart';
import 'package:pdf/widgets.dart';

class CreatePdf {
  static Future<File> generateNewlyBoughtReport(
      List<NewReport> newReport) async {
    List<String> headers = [
      "Name",
      "Acq. Date",
      "Warranty Exp.",
      "Qty",
      "Price",
      'Office Name',
      'Room Name',
      "Supplier",
      "Certifier",
      "Description"
    ];
    final data = newReport
        .map((report) => [
              report.name,
              report.acqDate,
              report.expDate,
              report.quantity,
              '#${report.price}',
              report.officeName,
              report.room,
              report.supplier,
              report.authenticator,
              report.description,
            ])
        .toList();
    final pdf = Document();
    pdf.addPage(MultiPage(
      pageFormat: PdfPageFormat.a4,
      orientation: PageOrientation.landscape,
      build: (context) => [
        Center(
            child: Text("Abia State Inventory Record",
                style: TextStyle(fontWeight: FontWeight.bold))),
        Row(children: [
          Text('State:'),
          SizedBox(width: 0.5 * PdfPageFormat.cm),
          Text('Abia')
        ]),
        Row(children: [
          Text('Date:'),
          SizedBox(width: 0.5 * PdfPageFormat.cm),
          Text(formatDateTime(DateTime.now()))
        ]),
        SizedBox(height: 24),
        Center(child: Text("Newly Bought Inventory")),
        Divider(),
        SizedBox(height: 10),
        TableHelper.fromTextArray(
          columnWidths: const {
            0: FixedColumnWidth(150),
            1: FixedColumnWidth(90),
            2: FixedColumnWidth(90),
            3: FixedColumnWidth(40),
            4: FixedColumnWidth(90),
            5: FixedColumnWidth(100),
            6: FixedColumnWidth(100),
            7: FixedColumnWidth(100),
            8: FixedColumnWidth(100),
            9: FixedColumnWidth(150),
            10: FixedColumnWidth(150),
          },
          cellAlignments: {
            0: Alignment.centerLeft,
            1: Alignment.centerLeft,
            2: Alignment.centerLeft,
            3: Alignment.centerLeft,
            4: Alignment.centerLeft,
            5: Alignment.centerLeft,
            6: Alignment.centerLeft,
            7: Alignment.centerLeft,
            8: Alignment.centerLeft,
            9: Alignment.centerLeft,
            10: Alignment.centerLeft,
          },
          headerStyle: TextStyle(
            fontSize: 10,
            fontWeight: FontWeight.bold,
          ),
          cellStyle: const TextStyle(
            fontSize: 10,
          ),
          data: data,
          headers: headers,
          cellAlignment: Alignment.centerLeft,
          tableWidth: TableWidth.max,
          headerHeight: 50,
          border: TableBorder.all(width: 1),
        )
      ],
    ));
    return SaveAndOpenDocument.savePdf(
        name: "${formatDateTime2(DateTime.now())}-Inventory Report", pdf: pdf);
  }

  static Future<File> generateMaintenanceReport(DocumentModel document) async {
    String startDate =
        document.timeStamp!.toDate().toLocal().toString().split(' ')[0];
    String dueDate = document.timeStamp!
        .toDate()
        .add(Duration(days: document.duration ?? 30))
        .toLocal()
        .toString()
        .split(' ')[0];
    final pdf = Document();
    pdf.addPage(MultiPage(
        pageFormat: PdfPageFormat.a4,
        build: (context) => [
              Center(
                  child: Text("Abia State Inventory Record",
                      style: TextStyle(
                          fontWeight: FontWeight.bold, fontSize: 16))),

              SizedBox(height: 10),
              Row(children: [
                Text('State:', style: const TextStyle(fontSize: 16)),
                SizedBox(width: 0.5 * PdfPageFormat.cm),
                Text('Abia', style: const TextStyle(fontSize: 16))
              ]),
              SizedBox(height: 5),
              Row(children: [
                Text('Date:', style: const TextStyle(fontSize: 16)),
                SizedBox(width: 0.5 * PdfPageFormat.cm),
                Text(formatDateTime(DateTime.now()),
                    style: const TextStyle(fontSize: 16))
              ]),
              SizedBox(height: 24),
              Center(
                  child: Text(
                "Maintenance Details Report",
                style: TextStyle(fontWeight: FontWeight.bold, fontSize: 16),
              )),
              Divider(),

              // Details
              SizedBox(height: 10),
              _topDetails("Inventory Name:", document.inventory!.name),
              _topDetails("Total Quantity:", document.quantity.toString()),
              _topDetails("Service Price:", '#${document.price}'),
              _topDetails("Start Date:", startDate),
              _topDetails("Expected Due Date", dueDate),
              SizedBox(height: 20),

              // Service Report
              Text(
                "Service Report",
                style: TextStyle(fontWeight: FontWeight.bold, fontSize: 16),
              ),
              Divider(),
              SizedBox(height: 20),
              Text(document.report, style: const TextStyle(fontSize: 16)),
              SizedBox(height: 20),
              Divider(),
              SizedBox(height: 20),
              ...List.generate(document.action!.length,
                  (index) => _buildAction(document.action![index])),
              SizedBox(height: 20),
              _topDetails('Overall Inventory Status',
                  document.isCompleted ? "Completed" : 'Not yet completed'),
              Divider()
            ]));

    return SaveAndOpenDocument.savePdf(
        name:
            "${formatDateTime2(DateTime.now())}-${document.inventory?.name ?? ''}-Maintenance Report",
        pdf: pdf);
  }

  static _topDetails(String title, String text) {
    return Padding(
        padding: const EdgeInsets.only(bottom: 5),
        child: Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            Text(title, style: const TextStyle(fontSize: 16)),
            SizedBox(width: 5),
            Expanded(
              child: Text(
                text,
                style: const TextStyle(fontSize: 16),
                textAlign: TextAlign.right,
              ),
            )
          ],
        ));
  }

  static _buildAction(ActionItem action) {
    if (action.status == 'Completed' || action.status == 'In Progress') {
      return Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
        Center(
            child: Text(action.name,
                style: TextStyle(
                    decoration: TextDecoration.underline,
                    fontWeight: FontWeight.bold,
                    fontSize: 16))),
        SizedBox(height: 10),
        _topDetails('Quantity', action.quantity.toString()),
        _topDetails("Status", action.status),
        if (action.name == 'Auction' && action.status == 'Completed')
          _topDetails('Price', action.price.toString())
      ]);
    }

    return SizedBox();
  }

  static Future<File> generateOfficeReport(
      List<OfficeReport> reports, String officeName) async {
    log('report: $reports');
    List<String> headers = [
      "Name",
      "Qty",
      "Description",
      "ID Tag",
      "Category",
      "Office Location",
      "Room Location",
      "Acq. Date",
      "Warranty Exp",
      "Supplier",
      "Price",
      "Status"
    ];
    final pdf = Document();
    pdf.addPage(MultiPage(
        pageFormat: PdfPageFormat.a4,
        orientation: PageOrientation.landscape,
        build: (context) => [
              Center(
                  child: Text("Abia State Inventory Record",
                      style: TextStyle(fontWeight: FontWeight.bold))),
              Row(children: [
                Text('State:'),
                SizedBox(width: 0.5 * PdfPageFormat.cm),
                Text('Abia')
              ]),
              Row(children: [
                Text('Date:'),
                SizedBox(width: 0.5 * PdfPageFormat.cm),
                Text(formatDateTime(DateTime.now()))
              ]),
              SizedBox(height: 24),
              ...List.generate(reports.length, (index) {
                var report = reports[index];
                final data = report.items
                    .map((item) => [
                          item.name,
                          item.quantity,
                          item.description ?? '',
                          item.idTag ?? '',
                          item.category ?? '',
                          item.officeLocation,
                          item.roomLocation,
                          item.acquisitionDate ?? '',
                          item.warrantyExpiration ?? '',
                          item.supplier ?? '',
                          item.price != null ? '#${item.price}' : '',
                          item.status
                        ])
                    .toList();

                return Padding(
                    padding: index == reports.length - 1
                        ? const EdgeInsets.all(0)
                        : const EdgeInsets.only(bottom: 24),
                    child: Column(children: [
                      Center(child: Text('$officeName, ${report.name}')),
                      Divider(),
                      SizedBox(height: 10),
                      TableHelper.fromTextArray(
                        columnWidths: const {
                          0: FixedColumnWidth(150),
                          1: FixedColumnWidth(60),
                          2: FixedColumnWidth(150),
                          3: FixedColumnWidth(80),
                          4: FixedColumnWidth(120),
                          5: FixedColumnWidth(120),
                          6: FixedColumnWidth(120),
                          7: FixedColumnWidth(130),
                          8: FixedColumnWidth(130),
                          9: FixedColumnWidth(150),
                          10: FixedColumnWidth(100),
                          11: FixedColumnWidth(150),
                        },
                        cellAlignments: {
                          0: Alignment.centerLeft,
                          1: Alignment.centerLeft,
                          2: Alignment.centerLeft,
                          3: Alignment.centerLeft,
                          4: Alignment.centerLeft,
                          5: Alignment.centerLeft,
                          6: Alignment.centerLeft,
                          7: Alignment.centerLeft,
                          8: Alignment.centerLeft,
                          9: Alignment.centerLeft,
                          10: Alignment.centerLeft,
                          11: Alignment.centerLeft,
                        },
                        headerStyle: TextStyle(
                          fontSize: 10,
                          fontWeight: FontWeight.bold,
                        ),
                        cellStyle: const TextStyle(
                          fontSize: 10,
                        ),
                        data: data,
                        headers: headers,
                        cellAlignment: Alignment.centerLeft,
                        tableWidth: TableWidth.max,
                        headerHeight: 50,
                        border: TableBorder.all(width: 1),
                      )
                    ]));
              })
            ]));

    return SaveAndOpenDocument.savePdf(
        name: "${formatDateTime2(DateTime.now())}-$officeName-Report",
        pdf: pdf);
  }

  static Future<File> generateRoomReport(
      List<ItemModel> items, String roomName, String officeName) async {
    List<String> headers = [
      "Name",
      "Qty",
      "Description",
      "ID Tag",
      "Category",
      "Office Location",
      "Room Location",
      "Acq. Date",
      "Warranty Exp",
      "Supplier",
      "Price",
      "Status"
    ];
    final data = items
        .map((item) => [
              item.name,
              item.quantity,
              item.description ?? '',
              item.idTag ?? '',
              item.category ?? '',
              item.officeLocation,
              item.roomLocation,
              item.acquisitionDate ?? '',
              item.warrantyExpiration ?? '',
              item.supplier ?? '',
              item.price != null ? '#${item.price}' : '',
              item.status
            ])
        .toList();
    final pdf = Document();
    pdf.addPage(MultiPage(
        pageFormat: PdfPageFormat.a4,
        orientation: PageOrientation.landscape,
        build: (context) => [
              Center(
                  child: Text("Abia State Inventory Record",
                      style: TextStyle(fontWeight: FontWeight.bold))),
              Row(children: [
                Text('State:'),
                SizedBox(width: 0.5 * PdfPageFormat.cm),
                Text('Abia')
              ]),
              Row(children: [
                Text('Date:'),
                SizedBox(width: 0.5 * PdfPageFormat.cm),
                Text(formatDateTime(DateTime.now()))
              ]),
              SizedBox(height: 24),
              Center(
                  child: Text(
                '$officeName, $roomName',
              )),
              Divider(),
              SizedBox(height: 10),
              TableHelper.fromTextArray(
                columnWidths: const {
                  0: FixedColumnWidth(150),
                  1: FixedColumnWidth(60),
                  2: FixedColumnWidth(150),
                  3: FixedColumnWidth(80),
                  4: FixedColumnWidth(120),
                  5: FixedColumnWidth(120),
                  6: FixedColumnWidth(120),
                  7: FixedColumnWidth(130),
                  8: FixedColumnWidth(130),
                  9: FixedColumnWidth(150),
                  10: FixedColumnWidth(100),
                  11: FixedColumnWidth(150),
                },
                cellAlignments: {
                  0: Alignment.centerLeft,
                  1: Alignment.centerLeft,
                  2: Alignment.centerLeft,
                  3: Alignment.centerLeft,
                  4: Alignment.centerLeft,
                  5: Alignment.centerLeft,
                  6: Alignment.centerLeft,
                  7: Alignment.centerLeft,
                  8: Alignment.centerLeft,
                  9: Alignment.centerLeft,
                  10: Alignment.centerLeft,
                  11: Alignment.centerLeft,
                },
                headerStyle: TextStyle(
                  fontSize: 10,
                  fontWeight: FontWeight.bold,
                ),
                cellStyle: const TextStyle(
                  fontSize: 10,
                ),
                data: data,
                headers: headers,
                cellAlignment: Alignment.centerLeft,
                tableWidth: TableWidth.max,
                headerHeight: 50,
                border: TableBorder.all(width: 1),
              )
            ]));

    return SaveAndOpenDocument.savePdf(
        name: "${formatDateTime2(DateTime.now())}-$roomName-Report", pdf: pdf);
  }
}
