import 'package:intl/intl.dart';

extension DateTimeExtension on DateTime {
  String formatDateTimeForTurkishDate() {
    return DateFormat('yyyy.MM.dd HH:mm').format(this);
  }

  String formatDateTime() {
    return DateFormat('yyyy-MM-dd').format(this);
  }

  String formatDateTimeForTipListView() {
    return DateFormat('dd.MM.yyyy').format(this);
  }
}
