import 'dart:async';

import 'package:flutter/foundation.dart';
import 'package:sip_models/ri_enum.dart';
import 'package:sip_models/ri_models.dart';
import 'package:sip_printer/src/lib/thermal_printer/receipt_design/receipt_design.dart';
import 'package:thermal_printer/esc_pos_utils_platform/src/capability_profile.dart';
import 'package:thermal_printer/esc_pos_utils_platform/src/enums.dart';
import 'package:thermal_printer/esc_pos_utils_platform/src/generator.dart';
import 'package:thermal_printer/thermal_printer.dart';

class ThermalPrinterManager {
  final PrinterManager _printer = PrinterManager.instance;
  final CapabilityProfile _profile;

  static ThermalPrinterManager? _instance;

  ThermalPrinterManager._(this._profile);

  static FutureOr<ThermalPrinterManager> instance() async {
    return _instance ??= ThermalPrinterManager._(await CapabilityProfile.load());
  }

  /// Sipariş Fişi
  Future<void> printReceiptForTable(PrinterConfigModel config, PrinterQueueResponseModel printModel) async {
    try {
      final type = _printerPaperTypeToPaperSize(config.paperSize);
      List<int> bytes = ReceiptDesign(Generator(type, _profile), type).createReceiptForTable(printModel);
      await _print(config, bytes);
    } catch (e) {
      rethrow;
    }
  }

  /// Gel Al
  Future<void> printReceiptForGetIn(PrinterConfigModel config, PrinterQueueResponseModel printModel) async {
    try {
      final type = _printerPaperTypeToPaperSize(config.paperSize);
      List<int> bytes = ReceiptDesign(Generator(type, _profile), type).createReceiptForGetIn(printModel);
      await _print(config, bytes);
    } catch (e) {
      rethrow;
    }
  }

  /// Paket Siparisi
  Future<void> printReceiptForTakeout(PrinterConfigModel config, PrinterQueueResponseModel printModel) async {
    try {
      final type = _printerPaperTypeToPaperSize(config.paperSize);
      List<int> bytes = ReceiptDesign(Generator(type, _profile), type).createReceiptForTakeAway(printModel);
      await _print(config, bytes);
    } catch (e) {
      rethrow;
    }
  }

  /// Kasa Fişi
  Future<void> printReceiptForCashRegister(PrinterConfigModel config, PrinterQueueResponseModel printModel) async {
    try {
      final type = _printerPaperTypeToPaperSize(config.paperSize);
      List<int> bytes = ReceiptDesign(Generator(type, _profile), type).createReceiptForCashRegister(printModel);
      await _print(config, bytes);
    } catch (e) {
      rethrow;
    }
  }

  /// Masa Adisyonu
  Future<void> printReceiptForTableBill(PrinterConfigModel config, PrinterQueueResponseModel printModel) async {
    try {
      final type = _printerPaperTypeToPaperSize(config.paperSize);
      List<int> bytes = ReceiptDesign(Generator(type, _profile), type).createReceiptForTableBill(printModel);
      await _print(config, bytes);
    } catch (e) {
      rethrow;
    }
  }

  /// print report
  Future<void> printReport(PrinterConfigModel config, DailyReportModel printModel) async {
    try {
      final type = _printerPaperTypeToPaperSize(config.paperSize);
      List<int> bytes = ReceiptDesign(Generator(type, _profile), type).createReceiptForReport(printModel);
      await _print(config, bytes);
    } catch (e) {
      rethrow;
    }
  }

  /// print kitchen order
  Future<void> printKitchenOrder(PrinterConfigModel config, KitchenOrderModel activeOrderList) async {
    try {
      final type = _printerPaperTypeToPaperSize(config.paperSize);
      List<int> bytes = ReceiptDesign(Generator(type, _profile), type).printKitchenOrder(activeOrderList);
      await _print(config, bytes);
    } catch (e) {
      rethrow;
    }
  }

  Future<void> printTest(PrinterConfigModel config) async {
    try {
      final type = _printerPaperTypeToPaperSize(config.paperSize);
      List<int> bytes = ReceiptDesign(Generator(type, _profile), type).testTicket();
      await _print(config, bytes);
    } catch (e) {
      debugPrint(e.toString());
      rethrow;
    }
  }

  Future<void> _print(PrinterConfigModel config, List<int> bytes) async {
    try {
      final BasePrinterInput model;
      switch (config.typePrinter) {
        case PrinterTypeEnum.USB:
          model = UsbPrinterInput(
            name: config.name,
            productId: config.productId,
            vendorId: config.vendorId,
          );
          break;
        case PrinterTypeEnum.NETWORK || PrinterTypeEnum.LOCAL:
          model = TcpPrinterInput(
            ipAddress: config.ipAddress!,
            port: config.port!,
          );
          break;
        case PrinterTypeEnum.BLUETOOTH:
          model = BluetoothPrinterInput(
            name: config.name,
            address: config.ipAddress!,
            isBle: config.isBle ?? false,
            autoConnect: false,
          );
          break;
      }
      final type = _printerPaperTypeToPrinterType(config.typePrinter);
      bool result = await _printer.connect(type: type, model: model);
      if (result == false) throw 'Yazıcı bağlantı hatası';

      result = await _printer.send(type: type, bytes: bytes);
      if (result == false) {
        await _printer.disconnect(type: type);
        throw 'Yazıcıya çıktı gönderilemedi';
      }

      await _printer.disconnect(type: type);
    } catch (e) {
      rethrow;
    }
  }

  StreamController startScanPrinter({required PrinterType type, bool isBle = false}) {
    final _streamController = StreamController();
    final _subscription = _printer.discovery(type: type, isBle: isBle).listen((device) {
      _streamController.add(device);
    });
    _streamController.onCancel = () {
      _subscription.cancel();
    };
    return _streamController;
  }

  PaperSize _printerPaperTypeToPaperSize(PrinterPaperTypeEnum type) {
    switch (type) {
      case PrinterPaperTypeEnum.mm58:
        return PaperSize.mm58;
      case PrinterPaperTypeEnum.mm80:
        return PaperSize.mm80;
    }
  }

  PrinterType _printerPaperTypeToPrinterType(PrinterTypeEnum type) {
    switch (type) {
      case PrinterTypeEnum.NETWORK || PrinterTypeEnum.LOCAL:
        return PrinterType.network;
      case PrinterTypeEnum.USB:
        return PrinterType.usb;
      case PrinterTypeEnum.BLUETOOTH:
        return PrinterType.bluetooth;
    }
  }
}
