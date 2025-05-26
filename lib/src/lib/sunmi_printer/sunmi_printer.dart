import 'dart:async';

import 'package:sip_models/enum.dart';
import 'package:sip_models/request.dart';
import 'package:sip_models/response.dart';
import 'package:sip_models/ri_models.dart';

import 'body/sunmi_printer_body.dart';
import 'footer/sunmi_printer_footer.dart';
import 'header/sunmi_printer_header.dart';
import 'sunmi_print_service.dart';

class SunmiPrinter extends SunmiPrinterService {
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
    required PaymentInfo paymentInfo,
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
      await SunmiPrinterHeader().printHeaderTABLE(tableName: tableName, orderNumber: orderNumber);
      await SunmiPrinterBody().printBodyTABLE(orderList);
      await SunmiPrinterFooter().printFooterTABLE(serviceTotalAmount);
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
    required PaymentInfo paymentInfo,
    required bool isCompleteOrder,
  }) {
    Timer.run(() async {
      await SunmiPrinterHeader().printHeaderTAKEOUT(
        orderNumber: orderNumber,
        nameSurname: nameSurname,
        customerAddress: customerAddress,
        orderNote: orderNote,
      );
      await SunmiPrinterBody().printBodyTAKEOUT(orderList);
      await SunmiPrinterFooter().printFooterTAKEOUT(
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
    required PaymentInfo paymentInfo,
    required bool isCompleteOrder,
  }) {
    Timer.run(() async {
      await SunmiPrinterHeader().printHeaderGETIN(
        orderNumber: orderNumber,
        nameSurname: nameSurname,
        callNumber: callNumber,
        orderNote: orderNote,
      );
      await SunmiPrinterBody().printBodyGETIN(orderList);
      await SunmiPrinterFooter().printFooterGETIN(
        totalAmount: totalAmount,
        paymentInfo: paymentInfo,
        isCompleteOrder: isCompleteOrder,
      );
    });
  }

  SunmiPrinter.testReceipt() {
    Timer.run(() async {
      await SunmiPrinterHeader().printTestReceipt();
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
      await SunmiPrinterHeader().printForBackgroundProcess(
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
