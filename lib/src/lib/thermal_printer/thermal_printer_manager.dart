import 'dart:async';

import 'package:esc_pos_utils_plus/esc_pos_utils_plus.dart';
import 'package:flutter/foundation.dart';
import 'package:sip_models/ri_enum.dart';
import 'package:sip_models/ri_models.dart';
import 'package:sip_printer/src/lib/thermal_printer/receipt_design/receipt_design.dart';
import 'package:usb_printer/usb_printer.dart';

import '../network/network_print_result.dart';
import '../network/network_printer.dart';

class ThermalPrinterManager {
  final CapabilityProfile _profile;

  static ThermalPrinterManager? _instance;

  ThermalPrinterManager._(this._profile);

  static FutureOr<ThermalPrinterManager> instance() async {
    return _instance ??= ThermalPrinterManager._(await CapabilityProfile.load());
  }

  /// Sipariş Fişi
  List<int> createReceiptForTable(PrinterPaperTypeEnum paperSize, PrinterQueueResponseModel printModel) {
    try {
      final type = _printerPaperTypeToPaperSize(paperSize);
      return ReceiptDesign(Generator(type, _profile), type).createReceiptForTable(printModel);
    } catch (e) {
      rethrow;
    }
  }

  /// Gel Al
  List<int> createReceiptForGetIn(PrinterPaperTypeEnum paperSize, PrinterQueueResponseModel printModel) {
    try {
      final type = _printerPaperTypeToPaperSize(paperSize);
      return ReceiptDesign(Generator(type, _profile), type).createReceiptForGetIn(printModel);
    } catch (e) {
      rethrow;
    }
  }

  /// Paket Siparisi
  Future<List<int>> createReceiptForTakeout(
    PrinterPaperTypeEnum paperSize,
    PrinterQueueResponseModel printModel,
  ) async {
    try {
      final type = _printerPaperTypeToPaperSize(paperSize);
      return ReceiptDesign(Generator(type, _profile), type).createReceiptForTakeAway(printModel);
    } catch (e) {
      rethrow;
    }
  }

  /// Kasa Fişi
  List<int> createReceiptForCashRegister(
    PrinterPaperTypeEnum paperSize,
    PrinterQueueResponseModel printModel,
  ) {
    try {
      final type = _printerPaperTypeToPaperSize(paperSize);
      return ReceiptDesign(Generator(type, _profile), type).createReceiptForCashRegister(printModel);
    } catch (e) {
      rethrow;
    }
  }

  /// Masa Adisyonu
  List<int> createReceiptForTableBill(
    PrinterPaperTypeEnum paperSize,
    PrinterQueueResponseModel printModel,
  ) {
    try {
      final type = _printerPaperTypeToPaperSize(paperSize);
      return ReceiptDesign(Generator(type, _profile), type).createReceiptForTableBill(printModel);
    } catch (e) {
      rethrow;
    }
  }

  /// print report
  List<int> createReceiptForReport(PrinterPaperTypeEnum paperSize, DailyReportModel printModel) {
    try {
      final type = _printerPaperTypeToPaperSize(paperSize);
      return ReceiptDesign(Generator(type, _profile), type).createReceiptForReport(printModel);
    } catch (e) {
      rethrow;
    }
  }

  /// print kitchen order
  List<int> createReceiptForKitchenOrder(PrinterPaperTypeEnum paperSize, KitchenOrderModel activeOrderList) {
    try {
      final type = _printerPaperTypeToPaperSize(paperSize);
      return ReceiptDesign(Generator(type, _profile), type).printKitchenOrder(activeOrderList);
    } catch (e) {
      rethrow;
    }
  }

  Future<List<int>> createReceiptForTest(PrinterPaperTypeEnum paperSize) {
    try {
      final type = _printerPaperTypeToPaperSize(paperSize);
      return ReceiptDesign(Generator(type, _profile), type).testTicket();
    } catch (e) {
      debugPrint(e.toString());
      rethrow;
    }
  }

  Future<void> print(IPrinterModel config, List<int> bytes) async {
    try {
      if (config is IPPrinterModel) {
        final service = FlutterThermalPrinterNetwork(config.ipAddress!, port: config.port!);
        final connectStatus = await service.connect();
        if (connectStatus != NetworkPrintResult.success) throw 'Yazıcı bağlantı hatası';

        final printStatus = await service.printTicket(bytes);
        await service.disconnect();
        if (printStatus != NetworkPrintResult.success) throw 'Yazıcıya çıktı gönderilemedi';
      } else if (config is USBPrinterModel) {
        final usbPrinter = UsbPrinter();
        final connectStatus = await usbPrinter.connect(
          vendorId: int.parse(config.vendorId!),
          productId: int.parse(config.productId!),
        );
        if (connectStatus != true) throw 'Yazıcı bağlantı hatası';

        // await Future.delayed(const Duration(milliseconds: 100));
        await usbPrinter.printBytes(bytes);
        // await usbPrinter.close();
      }
    } catch (e) {
      rethrow;
    }
  }

  Future<List<USBPrinterModel>> getConnectedUsbPrinters() async {
    final list = await UsbPrinter().getUSBDeviceList();
    return USBPrinterModel().jsonParserByMap(list);
  }

  PaperSize _printerPaperTypeToPaperSize(PrinterPaperTypeEnum type) {
    switch (type) {
      case PrinterPaperTypeEnum.mm58:
        return PaperSize.mm58;
      case PrinterPaperTypeEnum.mm80:
        return PaperSize.mm80;
    }
  }
}
