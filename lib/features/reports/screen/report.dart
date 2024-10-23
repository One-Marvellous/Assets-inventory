import 'package:assets_inventory_app_ghum/features/reports/screen/widgets/office_report_selection_dialog.dart';
import 'package:assets_inventory_app_ghum/features/reports/screen/widgets/room_report_selection_dialog.dart';
import 'package:assets_inventory_app_ghum/features/reports/screen/widgets/time_period_dialog.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

class Reports extends ConsumerStatefulWidget {
  const Reports({super.key});

  @override
  ConsumerState<ConsumerStatefulWidget> createState() => _ReportsState();
}

class _ReportsState extends ConsumerState<Reports> {
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text("Reports"),
        surfaceTintColor: Colors.transparent,
      ),
      body: SingleChildScrollView(
        child: Column(
          children: [
            ListTile(
              title: const Text("Generate report on recently bought item's"),
              onTap: pickTimeFrame,
            ),
            ListTile(
              title: const Text("Generate report on a particular office"),
              onTap: officeReport,
            ),
            ListTile(
              title: const Text("Generate report on a particular room"),
              onTap: roomReport,
            )
          ],
        ),
      ),
    );
  }

  void pickTimeFrame() {
    showDialog(
        context: context, builder: (context) => const TimePeriodDialog());
  }

  void officeReport() {
    showDialog(
        context: context,
        builder: (context) => const OfficeReportSelectionDialog());
  }

  void roomReport() {
    showDialog(
        context: context,
        builder: (context) => const RoomReportSelectionDialog());
  }
}
