import 'dart:async';
import 'dart:io';
import 'package:print_usb/model/usb_device.dart';
import 'package:print_usb/print_usb.dart';
import 'package:sip_models/ri_models.dart';
import 'package:usb_printer/usb_printer.dart';
import '../network/network_print_result.dart';
import '../network/network_printer.dart';

class ThermalPrinterManager {
  static ThermalPrinterManager? _instance;

  ThermalPrinterManager._();

  factory ThermalPrinterManager.instance() {
    return _instance ??= ThermalPrinterManager._();
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
        if (Platform.isWindows) {
          bool connected = await PrintUsb.connect(name: config.name!);

          if (connected) {
            bool success = await PrintUsb.printBytes(
              bytes: bytes,
              device: UsbDevice(name: config.name!, model: '', isDefault: true, available: true),
            );

            if (!success) throw 'Print failed.';
          }
        } else {
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
      }
    } catch (e) {
      rethrow;
    }
  }

  Future<List<USBPrinterModel>> getConnectedUsbPrinters() async {
    if (Platform.isWindows) {
      final list = await PrintUsb.getList();
      return list
          .map<USBPrinterModel>((e) => USBPrinterModel(name: e.name, vendorId: e.name, productId: e.name))
          .toList();
    } else {
      final list = await UsbPrinter().getUSBDeviceList();
      return USBPrinterModel().jsonParserByMap(list);
    }
  }
}
