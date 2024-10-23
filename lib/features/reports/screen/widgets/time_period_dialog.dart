import 'package:assets_inventory_app_ghum/services/controller/document_controller.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

class TimePeriodDialog extends ConsumerStatefulWidget {
  const TimePeriodDialog({super.key});

  @override
  ConsumerState<ConsumerStatefulWidget> createState() =>
      _TimePeriodDialogState();
}

class _TimePeriodDialogState extends ConsumerState<TimePeriodDialog> {
  String _selectedPeriod = 'Current month';
  DateTime startDate = DateTime.now();
  DateTime endDate = DateTime.now();

  void setDateRange(String range) {
    DateTime now = DateTime.now();
    switch (range) {
      case 'Current month':
        startDate = DateTime(now.year, now.month, 1);
        endDate = DateTime(now.year, now.month + 1, 0);
        break;
      case 'Last 30 days':
        endDate = now;
        startDate = now.subtract(const Duration(days: 30));
        break;
      case 'Last 90 days':
        endDate = now;
        startDate = now.subtract(const Duration(days: 90));
        break;
      case 'Current year':
        startDate = DateTime(now.year, 1, 1);
        endDate = DateTime(now.year, 12, 31);
        break;
      default:
        throw ArgumentError('Invalid range');
    }
  }

  @override
  Widget build(BuildContext context) {
    bool isLoading = ref.watch(documentControllerProvider);
    return AlertDialog(
      surfaceTintColor: Colors.transparent,
      backgroundColor: Colors.white,
      shadowColor: Colors.transparent,
      title: const Text('Select date range'),
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
                mainAxisSize: MainAxisSize.min,
                children: <Widget>[
                  RadioListTile<String>(
                    title: const Text('Current month'),
                    value: 'Current month',
                    groupValue: _selectedPeriod,
                    onChanged: (String? value) {
                      setState(() {
                        _selectedPeriod = value!;
                      });
                    },
                  ),
                  RadioListTile<String>(
                    title: const Text('Last 30 days'),
                    value: 'Last 30 days',
                    groupValue: _selectedPeriod,
                    onChanged: (String? value) {
                      setState(() {
                        _selectedPeriod = value!;
                      });
                    },
                  ),
                  RadioListTile<String>(
                    title: const Text('Last 90 days'),
                    value: 'Last 90 days',
                    groupValue: _selectedPeriod,
                    onChanged: (String? value) {
                      setState(() {
                        _selectedPeriod = value!;
                      });
                    },
                  ),
                  RadioListTile<String>(
                    title: const Text('Current year'),
                    value: 'Current year',
                    groupValue: _selectedPeriod,
                    onChanged: (String? value) {
                      setState(() {
                        _selectedPeriod = value!;
                      });
                    },
                  ),
                ],
              ),
            ),
      actions: <Widget>[
        TextButton(
          onPressed: () async {
            setDateRange(_selectedPeriod);
            await ref
                .watch(documentControllerProvider.notifier)
                .getRecentReport(
                    startDate: startDate, endDate: endDate, context: context);

            if (!context.mounted) return;
            Navigator.of(context).pop();
          },
          child: const Text('OK'),
        ),
      ],
    );
  }
}
