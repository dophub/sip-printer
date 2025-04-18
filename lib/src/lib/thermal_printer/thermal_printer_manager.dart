import 'dart:async';

import 'package:flutter/foundation.dart';
import 'package:flutter_thermal_printer/flutter_thermal_printer.dart';
import 'package:flutter_thermal_printer/network/network_print_result.dart';
import 'package:flutter_thermal_printer/utils/printer.dart';
import 'package:sip_models/ri_enum.dart';
import 'package:sip_models/ri_models.dart';
import 'package:sip_printer/src/lib/thermal_printer/receipt_design/receipt_design.dart';

class ThermalPrinterManager {
  // final PrinterManager _printer = PrinterManager.instance;
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
      List<int> bytes = await ReceiptDesign(Generator(type, _profile), type).createReceiptForTakeAway(printModel);
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

  Future<List<int>> printTestByte(PrinterConfigModel config) async {
    try {
      final type = _printerPaperTypeToPaperSize(config.paperSize);
      List<int> bytes = ReceiptDesign(Generator(type, _profile), type).testTicket();
      return bytes;
    } catch (e) {
      debugPrint(e.toString());
      rethrow;
    }
  }

  Future<void> _print(PrinterConfigModel config, List<int> bytes) async {
    try {
      switch (config.typePrinter) {
        case PrinterTypeEnum.NETWORK || PrinterTypeEnum.LOCAL:
          final service = FlutterThermalPrinterNetwork(config.ipAddress!, port: config.port!);
          final connectStatus = await service.connect();
          if (connectStatus != NetworkPrintResult.success) throw 'Yazıcı bağlantı hatası';

          final printStatus = await service.printTicket(bytes);
          await service.disconnect();
          if (printStatus != NetworkPrintResult.success) throw 'Yazıcıya çıktı gönderilemedi';

          break;
        case PrinterTypeEnum.USB || PrinterTypeEnum.BLUETOOTH:
/*          model = UsbPrinterInput(
            name: config.name,
            productId: config.productId,
            vendorId: config.vendorId,
          );

          model = BluetoothPrinterInput(
            name: config.name,
            address: config.ipAddress!,
            isBle: config.isBle ?? false,
            autoConnect: false,
          );*/

          final flutterThermalPrinterPlugin = FlutterThermalPrinter.instance;
          final printer = Printer(
            connectionType: config.typePrinter == PrinterTypeEnum.USB ? ConnectionType.USB : ConnectionType.BLE,
            address: config.ipAddress!,
            name: config.name,
            // isConnected: false,
            vendorId: config.vendorId,
            productId: config.productId,
          );

          final connectStatus = await flutterThermalPrinterPlugin.connect(printer);
          if (connectStatus != true) throw 'Yazıcı bağlantı hatası';

          await flutterThermalPrinterPlugin.printData(printer, bytes);
          await flutterThermalPrinterPlugin.disconnect(printer);
          break;
      }

/*      final type = _printerPaperTypeToPrinterType(config.typePrinter);
      bool result = await _printer.connect(type: type, model: model);
      if (result == false) throw 'Yazıcı bağlantı hatası';

      result = await _printer.send(type: type, bytes: bytes);
      if (result == false) {
        await _printer.disconnect(type: type);
        throw 'Yazıcıya çıktı gönderilemedi';
      }

      await _printer.disconnect(type: type);*/
    } catch (e) {
      rethrow;
    }
  }

  Future<StreamController<List<Printer>>> startScanPrinter({
    List<ConnectionType> connectionTypes = const [ConnectionType.USB],
    // bool isBle = false,
  }) async {
    final flutterThermalPrinterPlugin = FlutterThermalPrinter.instance;
    final streamController = StreamController<List<Printer>>();
    await flutterThermalPrinterPlugin.getPrinters(connectionTypes: connectionTypes);
    final StreamSubscription<List<Printer>> devicesStreamSubscription =
        flutterThermalPrinterPlugin.devicesStream.listen((List<Printer> printers) {
      streamController.add(printers);
    });
    streamController.onCancel = () {
      devicesStreamSubscription.cancel();
    };
    return streamController;

/*    final streamController = StreamController<SipPrinterDevice>();
    final subscription = _printer.discovery(type: _printerPaperTypeToPrinterType(type), isBle: isBle).listen((device) {
      streamController.add(SipPrinterDevice.fromPrinterDevice(device));
    });
    streamController.onCancel = () {
      subscription.cancel();
    };
    return streamController;*/
  }

  PaperSize _printerPaperTypeToPaperSize(PrinterPaperTypeEnum type) {
    switch (type) {
      case PrinterPaperTypeEnum.mm58:
        return PaperSize.mm58;
      case PrinterPaperTypeEnum.mm80:
        return PaperSize.mm80;
    }
  }

/*  PrinterType _printerPaperTypeToPrinterType(PrinterTypeEnum type) {
    switch (type) {
      case PrinterTypeEnum.NETWORK || PrinterTypeEnum.LOCAL:
        return PrinterType.network;
      case PrinterTypeEnum.USB:
        return PrinterType.usb;
      case PrinterTypeEnum.BLUETOOTH:
        return PrinterType.bluetooth;
    }
  }*/
}
