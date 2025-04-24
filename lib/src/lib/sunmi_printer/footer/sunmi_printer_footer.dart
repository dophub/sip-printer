import 'dart:async';

import 'package:flutter/cupertino.dart';
import 'package:intl/intl.dart';
import 'package:sip_models/request.dart';
import 'package:sip_printer/src/extanstion/extension_string.dart';
import 'package:sunmi_printer_plus/column_maker.dart';
import 'package:sunmi_printer_plus/enums.dart';
import 'package:sunmi_printer_plus/sunmi_printer_plus.dart';
import 'package:sunmi_printer_plus/sunmi_style.dart';

import '../../../sip_printer.dart';

class SunmiPrinterFooter {
  SunmiPrinterFooter();

  Future<void> printFooterTABLE(double serviceTotalAmount) async {
    await SunmiPrinter.printRow(cols: [
      ColumnMaker(
        text: DateFormat('dd.MM.yyyy, kk:mm').format(DateTime.now().toLocal()),
        align: SunmiPrintAlign.LEFT,
        width: 20,
      ),
      ColumnMaker(text: '${serviceTotalAmount.toStringAsFixed(2)}TL', width: 11, align: SunmiPrintAlign.RIGHT),
    ]);
    await SunmiPrinter.lineWrap(5);
    await SunmiPrinter.exitTransactionPrint(true);
  }

  Future<void> printFooterTAKEOUT({
    required double totalAmount,
    required PaymentInfo paymentInfo,
    required bool isCompleteOrder,
  }) async {
    debugPrint('TAKEOUT FOOTER');
    await SunmiPrinter.initPrinter().then((var init) async {
      if (init!) {
        //TOTAL

        await SunmiPrinter.setAlignment(SunmiPrintAlign.RIGHT);
        await SunmiPrinter.printText('TOPLAM TUTAR:  ${totalAmount.toStringAsFixed(2)} TL',
            style: SunmiStyle(
              fontSize: SunmiFontSize.MD,
              bold: true,
            ));
        //SPACE
        await _childTopFooter(paymentInfo: paymentInfo, isCompleteOrder: isCompleteOrder);
      }
    });
  }

  ///GEL-Al Footer kısmını yazdırır.
  Future<void> printFooterGETIN({
    required double totalAmount,
    required PaymentInfo paymentInfo,
    required bool isCompleteOrder,
  }) async {
    debugPrint('GETIN FOOTER');
    await SunmiPrinter.initPrinter().then((var init) async {
      if (init!) {
        //TOTAL

        await SunmiPrinter.setAlignment(SunmiPrintAlign.RIGHT);
        await SunmiPrinter.printText('TOPLAM TUTAR:  ${totalAmount.toStringAsFixed(2)} TL',
            style: SunmiStyle(
              fontSize: SunmiFontSize.MD,
              bold: true,
            ));
        //SPACE

        await _childTopFooter(paymentInfo: paymentInfo, isCompleteOrder: isCompleteOrder);
      }
    });
  }

  ///Adress ve Ödeme bilgilerini gösterir
  Future<void> _childTopFooter({
    required PaymentInfo paymentInfo,
    required bool isCompleteOrder,
  }) async {
    await SunmiPrinter.line();
    await SunmiPrinter.setAlignment(SunmiPrintAlign.CENTER);

    if (paymentInfo.isOnlinePayment! && isCompleteOrder) {
      await SunmiPrinter.printText('ÖDEME ALINDI',
          style: SunmiStyle(
            fontSize: SunmiFontSize.LG,
            bold: true,
          ));
    } else {
      await SunmiPrinter.printText('ÖDEME ALINMADI',
          style: SunmiStyle(
            fontSize: SunmiFontSize.LG,
            bold: true,
          ));
    }

    await SunmiPrinter.setAlignment(SunmiPrintAlign.CENTER);
    await SunmiPrinter.printText('${paymentInfo.name.toString().withoutDiacriticalMarks}',
        style: SunmiStyle(
          fontSize: SunmiFontSize.MD,
        ));
    await _childBottomFooter();
  }

  ///Adress bilgilerini gösterir
  Future<void> _childBottomFooter() async {
    await SunmiPrinter.line();
    await SunmiPrinter.setAlignment(SunmiPrintAlign.CENTER);
    await SunmiPrinter.printText(SipPrinter.instance.headerTitle.withoutDiacriticalMarks(),
        style: SunmiStyle(
          fontSize: SunmiFontSize.MD,
          bold: true,
        ));
    await SunmiPrinter.setAlignment(SunmiPrintAlign.CENTER);
    await SunmiPrinter.printText(SipPrinter.instance.footerTitle.withoutDiacriticalMarks(),
        style: SunmiStyle(
          fontSize: SunmiFontSize.MD,
        ));
    await SunmiPrinter.setAlignment(SunmiPrintAlign.CENTER);
    await SunmiPrinter.printText('Telefon: ',
        style: SunmiStyle(
          fontSize: SunmiFontSize.MD,
        ));
    await SunmiPrinter.lineWrap(3);
    await SunmiPrinter.exitTransactionPrint(true);
  }
}
