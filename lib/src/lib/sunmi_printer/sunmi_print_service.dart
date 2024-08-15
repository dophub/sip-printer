import 'dart:async';

import 'package:sunmi_printer_plus/sunmi_printer_plus.dart';

class SunmiPrinterService {
  int paperSize = 0;
  bool printBinded = false;

  SunmiPrinterService() {
    Timer.run(() async {
      _bindingPrinter().then((bool? isBind) {
        SunmiPrinter.paperSize().then((int size) {
          paperSize = size;
        });

        printBinded = isBind!;
      });
    });
  }

  Future<bool?> _bindingPrinter() async {
    final bool? result = await SunmiPrinter.bindingPrinter();
    return result;
  }
}
