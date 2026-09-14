import 'dart:async';

import 'package:flutter/cupertino.dart';
import 'package:intl/intl.dart';
import 'package:sip_models/request.dart';
import 'package:sip_printer/src/extanstion/extension_string.dart';
import 'package:sunmi_printer_plus/sunmi_printer_plus.dart';

import '../../../sip_printer.dart';

class SunmiPrinterFooter {
  final SunmiPrinterPlus sunmiPrinterPlus;

  SunmiPrinterFooter({required this.sunmiPrinterPlus});

  Future<void> printFooterTABLE(double serviceTotalAmount) async {
    await sunmiPrinterPlus.printRow(
      cols: [
        SunmiColumn(
          text: DateFormat('dd.MM.yyyy, kk:mm').format(DateTime.now().toLocal()),
          width: 20,
          style: SunmiTextStyle(align: SunmiPrintAlign.LEFT),
        ),
        SunmiColumn(
          text: '${serviceTotalAmount.toStringAsFixed(2)}TL',
          width: 11,
          style: SunmiTextStyle(align: SunmiPrintAlign.RIGHT),
        ),
      ],
    );
    await addLine(5);
  }

  Future<void> printFooterTAKEOUT({
    required double totalAmount,
    required PaymentInfo? paymentInfo,
    required bool isCompleteOrder,
  }) async {
    debugPrint('TAKEOUT FOOTER');
    //TOTAL

    await sunmiPrinterPlus.printText(
      text: 'TOPLAM TUTAR:  ${totalAmount.toStringAsFixed(2)} TL',
      style: SunmiTextStyle(
        bold: true,
        align: SunmiPrintAlign.CENTER,
      ),
    );
    //SPACE
    await _childTopFooter(paymentInfo: paymentInfo, isCompleteOrder: isCompleteOrder);
  }

  ///GEL-Al Footer kısmını yazdırır.
  Future<void> printFooterGETIN({
    required double totalAmount,
    required PaymentInfo? paymentInfo,
    required bool isCompleteOrder,
  }) async {
    debugPrint('GETIN FOOTER');
    //TOTAL

    await sunmiPrinterPlus.printText(
      text: 'TOPLAM TUTAR:  ${totalAmount.toStringAsFixed(2)} TL',
      style: SunmiTextStyle(
        bold: true,
        align: SunmiPrintAlign.CENTER,
      ),
    );
    //SPACE

    await _childTopFooter(paymentInfo: paymentInfo, isCompleteOrder: isCompleteOrder);
  }

  ///Adress ve Ödeme bilgilerini gösterir
  Future<void> _childTopFooter({
    required PaymentInfo? paymentInfo,
    required bool isCompleteOrder,
  }) async {
    await addLine();

    if (paymentInfo != null) {
      if (paymentInfo.isOnlinePayment! && isCompleteOrder) {
        await sunmiPrinterPlus.printText(
          text: 'ÖDEME ALINDI',
          style: SunmiTextStyle(
            fontSize: 32,
            bold: true,
            align: SunmiPrintAlign.CENTER,
          ),
        );
      } else {
        await sunmiPrinterPlus.printText(
          text: "ÖDEME ALINMADI",
          style: SunmiTextStyle(
            fontSize: 32,
            bold: true,
            align: SunmiPrintAlign.CENTER,
          ),
        );
      }

      await sunmiPrinterPlus.printText(
        text: '${paymentInfo.name.toString().withoutDiacriticalMarks}',
        style: SunmiTextStyle(
          align: SunmiPrintAlign.CENTER,
        ),
      );
    }
    await _childBottomFooter();
  }

  ///Adress bilgilerini gösterir
  Future<void> _childBottomFooter() async {
    await addLine();
    await sunmiPrinterPlus.printText(
      text: SipPrinter.instance.headerTitle.withoutDiacriticalMarks(),
      style: SunmiTextStyle(
        bold: true,
        align: SunmiPrintAlign.CENTER,
      ),
    );
    await sunmiPrinterPlus.printText(
      text: SipPrinter.instance.footerTitle.withoutDiacriticalMarks(),
      style: SunmiTextStyle(
        align: SunmiPrintAlign.CENTER,
      ),
    );
    await sunmiPrinterPlus.printText(
      text: 'Telefon: ',
      style: SunmiTextStyle(
        align: SunmiPrintAlign.CENTER,
      ),
    );
    await addLine(3);
  }

  Future addLine([int time = 1]) async {
    for (var i = 0; i < time; i++) {
      await sunmiPrinterPlus.printText(text: ' ');
    }
  }
}
