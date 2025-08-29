// lib/modules/expenses/models/expense_model.dart

import 'dart:isolate';
import 'dart:ui';
import 'package:argiot/src/app/modules/expense/expense_model.dart';

class ExpenseIsolate {
  static final ReceivePort _receivePort = ReceivePort();
  static SendPort? _sendPort;

  static void initialize() {
    IsolateNameServer.registerPortWithName(
      _receivePort.sendPort,
      'expense_isolate',
    );

    _receivePort.listen((dynamic data) {
      // Handle messages from isolate if needed
    });
  }

  static Future<List<ExpenseSummary>> calculateChartData(
    List<ExpenseSummary> data,
  ) async {
    if (_sendPort == null) {
      _sendPort = IsolateNameServer.lookupPortByName('expense_isolate');
      if (_sendPort == null) {
        // If isolate not running, calculate in main thread
        return _calculate(data);
      }
    }

    final response = ReceivePort();
    _sendPort?.send({
      'type': 'calculate',
      'data': data,
      'response': response.sendPort,
    });

    return await response.first;
  }

  static List<ExpenseSummary> _calculate(List<ExpenseSummary> data) {
    // Your calculation logic here
    return data;
  }
}

// Call this in main() before runApp
