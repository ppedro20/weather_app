import 'dart:async';
import 'package:intl/intl.dart';

class DateHelper {
  static String getCurrentDateTime() {
    final now = DateTime.now();
    final formatter = DateFormat('dd-MM-yy HH:mm:ss');
    return formatter.format(now);
  }

  static Timer startTimer(Function(String) onTimeUpdate) {
    return Timer.periodic(const Duration(seconds: 1), (Timer t) {
      onTimeUpdate(getCurrentDateTime());
    });
  }
}
