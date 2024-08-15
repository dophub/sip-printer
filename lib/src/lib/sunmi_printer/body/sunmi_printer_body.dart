import 'dart:async';
import 'package:sip_models/request.dart';
import 'package:sip_printer/src/extanstion/extension_string.dart';
import 'package:sunmi_printer_plus/column_maker.dart';
import 'package:sunmi_printer_plus/enums.dart';
import 'package:sunmi_printer_plus/sunmi_printer_plus.dart';

class SunmiPrinterBody {
  SunmiPrinterBody();

  Future<void> printBodyTABLE(List<OrderItem> orderList) async {
    await SunmiPrinter.initPrinter().then((var init) async {
      if (init!) {
        //AREA 3 - Titles
        for (OrderItem item in orderList) {
          await SunmiPrinter.printRow(cols: [
            ColumnMaker(
              text: '${item.count}x',
              width: 4,
            ),
            ColumnMaker(
              text: stringRowCreater(item.itemTitle!, 19),
              width: 19,
              align: SunmiPrintAlign.LEFT,
            ),
            ColumnMaker(text: '${item.totalPrice}TL', width: 8, align: SunmiPrintAlign.RIGHT),
          ]);
          await itemOptionBuilder(item);
        }
        //DIVIDER
        await SunmiPrinter.line();
        //TOTAL
      }
    });
  }

  Future<void> printBodyTAKEOUT(List<OrderItem> orderList) async {
    await SunmiPrinter.initPrinter().then((var init) async {
      if (init!) {
        //AREA 3 - Titles

        for (var item in orderList) {
          await SunmiPrinter.printRow(cols: [
            ColumnMaker(
              text: '${item.count}x',
              width: 4,
            ),
            ColumnMaker(
              text: stringRowCreater(item.itemTitle!, 20),
              width: 20,
              align: SunmiPrintAlign.LEFT,
            ),
            ColumnMaker(text: '${item.totalPrice}TL', width: 7, align: SunmiPrintAlign.RIGHT),
          ]);
          await itemOptionBuilder(item);
        }
        //DIVIDER
        await SunmiPrinter.line();
        //TOTAL
      }
    });
  }

  Future<void> printBodyGETIN(List<OrderItem> orderList) async {
    await SunmiPrinter.initPrinter().then((var init) async {
      if (init!) {
        //AREA 3 - Titles

        for (var item in orderList) {
          await SunmiPrinter.printRow(cols: [
            ColumnMaker(
              text: '${item.count}x',
              width: 4,
            ),
            ColumnMaker(
              text: stringRowCreater(item.itemTitle!, 20),
              width: 20,
              align: SunmiPrintAlign.LEFT,
            ),
            ColumnMaker(text: '${item.totalPrice}TL', width: 7, align: SunmiPrintAlign.RIGHT),
          ]);
          await itemOptionBuilder(item);
        }

        //DIVIDER
        await SunmiPrinter.line();
      }
    });
  }

  String stringRowCreater(String text, int textLength) {
    String sonText = '';
    if (text.length > textLength) {
      List<String> _tempList = text.split(' ');
      String satirText = '';
      for (var i = 0; i < _tempList.length; i++) {
        if (_tempList[i].length < textLength && (satirText.length + 1 + _tempList[i].length) < textLength) {
          satirText = '$satirText${_tempList[i]} ';
        } else {
          satirText = satirText.trim();
          int kalan = textLength - satirText.length;
          for (var i = 0; i < kalan; i++) {
            satirText = '$satirText ';
          }
          sonText = sonText + satirText;
          satirText = '${_tempList[i]} ';
        }
      }
      sonText = sonText + satirText;
    } else {
      return text;
    }
    //print(sonText);
    return sonText.trim().withoutDiacriticalMarks();
  }

  Future<void> itemOptionBuilder(OrderItem item) async {
    if (item.promotionMenuId == null) {
      for (OrderOption option in item.options!) {
        await SunmiPrinter.printRow(cols: [
          ColumnMaker(
            text: '',
            width: 4,
          ),
          ColumnMaker(
            text: stringRowCreater('${option.title!}:'.withoutDiacriticalMarks(), 27),
            width: 27,
            align: SunmiPrintAlign.LEFT,
          ),
        ]);
        for (OrderOptionItem optionItem in option.items!) {
          await SunmiPrinter.printRow(cols: [
            ColumnMaker(
              text: '',
              width: 4,
            ),
            ColumnMaker(
              text: stringRowCreater(optionItem.title!..withoutDiacriticalMarks, 27),
              width: 27,
              align: SunmiPrintAlign.LEFT,
            ),
          ]);
        }
      }
    }
    if (item.promotionMenuId != null) {
      for (OrderOption option in item.options!) {
        await SunmiPrinter.printRow(cols: [
          ColumnMaker(
            text: '',
            width: 4,
            align: SunmiPrintAlign.LEFT,
          ),
          ColumnMaker(
            text: stringRowCreater('${option.sectionTitle!}:'.withoutDiacriticalMarks(), 31),
            width: 27,
            align: SunmiPrintAlign.LEFT,
          ),
        ]);
        await SunmiPrinter.printRow(cols: [
          ColumnMaker(
            text: '',
            width: 4,
            align: SunmiPrintAlign.LEFT,
          ),
          ColumnMaker(
            text: stringRowCreater(option.sectionItem!.productName!.withoutDiacriticalMarks(), 31),
            width: 27,
            align: SunmiPrintAlign.LEFT,
          ),
        ]);
        for (var sectionOption in option.sectionItem!.options!) {
          await SunmiPrinter.printRow(cols: [
            ColumnMaker(
              text: '',
              width: 4,
              align: SunmiPrintAlign.LEFT,
            ),
            ColumnMaker(
              text: stringRowCreater('${sectionOption.title}:'.withoutDiacriticalMarks(), 31),
              width: 27,
              align: SunmiPrintAlign.LEFT,
            ),
          ]);
          for (var sectionOptionItem in sectionOption.items!) {
            await SunmiPrinter.printRow(cols: [
              ColumnMaker(
                text: '',
                width: 4,
                align: SunmiPrintAlign.LEFT,
              ),
              ColumnMaker(
                text: stringRowCreater(sectionOptionItem.title!.withoutDiacriticalMarks(), 31),
                width: 27,
                align: SunmiPrintAlign.LEFT,
              ),
            ]);
          }
        }
      }
    }
    if (!(item.itemNote == null || item.itemNote!.isEmpty)) {
      await SunmiPrinter.printRow(cols: [
        ColumnMaker(
          text: '',
          width: 4,
          align: SunmiPrintAlign.LEFT,
        ),
        ColumnMaker(
          text: stringRowCreater('Ürün Notu: ${item.itemNote!}'.withoutDiacriticalMarks(), 27),
          width: 27,
          align: SunmiPrintAlign.LEFT,
        ),
      ]);
    }
  }
}
