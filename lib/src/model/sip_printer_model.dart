import 'package:thermal_printer/thermal_printer.dart';

class SipPrinterDevice {
  String name;
  String operatingSystem;
  String? vendorId;
  String? productId;
  String? address;

  SipPrinterDevice({
    required this.name,
    required this.operatingSystem,
    this.address,
    this.vendorId,
    this.productId,
  });

  factory SipPrinterDevice.fromPrinterDevice(PrinterDevice device) {
    return SipPrinterDevice(
      name: device.name,
      operatingSystem: device.operatingSystem,
      address: device.address,
      vendorId: device.vendorId,
      productId: device.productId,
    );
  }
}
