import 'dart:async';

import 'package:sip_models/enum.dart';
import 'package:sip_models/request.dart';
import 'package:sip_models/response.dart';
import 'package:sip_models/ri_models.dart';
import 'package:sunmi_printer_plus/sunmi_printer_plus.dart';

import 'body/sunmi_printer_body.dart';
import 'footer/sunmi_printer_footer.dart';
import 'header/sunmi_printer_header.dart';

class SunmiPrinter {
  SunmiPrinter._() : super();

  //OrderPoint in tipine göre nesne üretilir.
  factory SunmiPrinter.fromOrderPoint(
    String orderPoint, {
    required String? tableName,
    required List<OrderItem> orderList,
    required double totalAmount,
    required String orderNumber,
    required String nameSurname,
    required String callNumber,
    required CustomerAddressModel? customerAddress,
    required String? orderNote,
    required PaymentInfo? paymentInfo,
    required bool isCompleteOrder,
  }) {
    if (orderPoint == DeliveryType.TABLE.name) {
      return SunmiPrinter.table(
        tableName: tableName,
        orderList: orderList,
        serviceTotalAmount: totalAmount,
        orderNumber: orderNumber,
      );
    } else if (orderPoint == DeliveryType.TAKEOUT.name) {
      return SunmiPrinter.takeOut(
        orderList: orderList,
        orderNumber: orderNumber,
        nameSurname: nameSurname,
        customerAddress: customerAddress,
        orderNote: orderNote,
        totalAmount: totalAmount,
        paymentInfo: paymentInfo,
        isCompleteOrder: isCompleteOrder,
      );
    } else if (orderPoint == DeliveryType.GETIN.name) {
      return SunmiPrinter.getIn(
        orderList: orderList,
        orderNumber: orderNumber,
        nameSurname: nameSurname,
        callNumber: callNumber,
        orderNote: orderNote,
        totalAmount: totalAmount,
        paymentInfo: paymentInfo,
        isCompleteOrder: isCompleteOrder,
      );
    }
    throw '$orderPoint  not recognized.';
  }

  //Masadan ödemede üretilen nesne
  SunmiPrinter.table({
    required String? tableName,
    required List<OrderItem> orderList,
    required double serviceTotalAmount,
    required String orderNumber,
  }) {
    Timer.run(() async {
      final SunmiPrinterPlus sunmiPrinterPlus = SunmiPrinterPlus();
      await SunmiPrinterHeader(sunmiPrinterPlus: sunmiPrinterPlus).printHeaderTABLE(tableName: tableName, orderNumber: orderNumber);
      await SunmiPrinterBody(sunmiPrinterPlus: sunmiPrinterPlus).printBodyTABLE(orderList);
      await SunmiPrinterFooter(sunmiPrinterPlus: sunmiPrinterPlus).printFooterTABLE(serviceTotalAmount);
    });
  }

  //Adrese teslimde üretilen nesne
  SunmiPrinter.takeOut({
    required List<OrderItem> orderList,
    required String orderNumber,
    required String nameSurname,
    required CustomerAddressModel? customerAddress,
    required String? orderNote,
    required double totalAmount,
    required PaymentInfo? paymentInfo,
    required bool isCompleteOrder,
  }) {
    Timer.run(() async {
      final SunmiPrinterPlus sunmiPrinterPlus = SunmiPrinterPlus();
      await SunmiPrinterHeader(sunmiPrinterPlus: sunmiPrinterPlus).printHeaderTAKEOUT(
        orderNumber: orderNumber,
        nameSurname: nameSurname,
        customerAddress: customerAddress,
        orderNote: orderNote,
      );
      await SunmiPrinterBody(sunmiPrinterPlus: sunmiPrinterPlus).printBodyTAKEOUT(orderList);
      await SunmiPrinterFooter(sunmiPrinterPlus: sunmiPrinterPlus).printFooterTAKEOUT(
        totalAmount: totalAmount,
        paymentInfo: paymentInfo,
        isCompleteOrder: isCompleteOrder,
      );
    });
  }

  //Gel Al da üretilen nesne
  SunmiPrinter.getIn({
    required List<OrderItem> orderList,
    required String orderNumber,
    required String nameSurname,
    required String? callNumber,
    required String? orderNote,
    required double totalAmount,
    required PaymentInfo? paymentInfo,
    required bool isCompleteOrder,
  }) {
    Timer.run(() async {
      final SunmiPrinterPlus sunmiPrinterPlus = SunmiPrinterPlus();
      await SunmiPrinterHeader(sunmiPrinterPlus: sunmiPrinterPlus).printHeaderGETIN(
        orderNumber: orderNumber,
        nameSurname: nameSurname,
        callNumber: callNumber,
        orderNote: orderNote,
      );
      await SunmiPrinterBody(sunmiPrinterPlus: sunmiPrinterPlus).printBodyGETIN(orderList);
      await SunmiPrinterFooter(sunmiPrinterPlus: sunmiPrinterPlus).printFooterGETIN(
        totalAmount: totalAmount,
        paymentInfo: paymentInfo,
        isCompleteOrder: isCompleteOrder,
      );
    });
  }

  SunmiPrinter.testReceipt() {
    Timer.run(() async {
      final SunmiPrinterPlus sunmiPrinterPlus = SunmiPrinterPlus();
      await SunmiPrinterHeader(sunmiPrinterPlus: sunmiPrinterPlus).printTestReceipt();
    });
  }

  SunmiPrinter.printForBackground({
    required PrinterQueueResponsePrintDataModel printData,
    required bool isPayment,
    required String paymentModelId,
    List<PrinterLineAndStyleModel>? headers,
    List<PrinterLineAndStyleModel>? footers,
    String? invoiceLink,
  }) {
    Timer.run(() async {
      final SunmiPrinterPlus sunmiPrinterPlus = SunmiPrinterPlus();
      await SunmiPrinterHeader(sunmiPrinterPlus: sunmiPrinterPlus).printForBackgroundProcess(
        printData: printData,
        isPayment: isPayment,
        paymentModelId: paymentModelId,
        headers: headers,
        footers: footers,
        invoiceLink: invoiceLink,
      );
    });
  }
}
