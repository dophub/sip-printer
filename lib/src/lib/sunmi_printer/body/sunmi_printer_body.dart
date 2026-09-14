import 'dart:async';
import 'package:sip_models/request.dart';
import 'package:sip_printer/src/extanstion/extension_string.dart';
import 'package:sunmi_printer_plus/sunmi_printer_plus.dart';

class SunmiPrinterBody {
  final SunmiPrinterPlus sunmiPrinterPlus;

  SunmiPrinterBody({required this.sunmiPrinterPlus});

  Future<void> printBodyTABLE(List<OrderItem> orderList) async {
    //AREA 3 - Titles
    for (OrderItem item in orderList) {
      await sunmiPrinterPlus.printRow(
        cols: [
          SunmiColumn(
            text: '${item.count}x',
            width: 4,
          ),
          SunmiColumn(
            text: stringRowCreater(item.itemTitle!, 19),
            width: 19,
            style: SunmiTextStyle(align: SunmiPrintAlign.LEFT),
          ),
          SunmiColumn(
            text: '${item.totalPrice}TL',
            width: 8,
            style: SunmiTextStyle(align: SunmiPrintAlign.RIGHT),
          ),
        ],
      );
      await itemOptionBuilder(item);
    }
    //DIVIDER
    await addLine();
  }

  Future addLine([int time = 1]) async {
    for (var i = 0; i < time; i++) {
      await sunmiPrinterPlus.printText(text: ' ');
    }
  }


  Future<void> printBodyTAKEOUT(List<OrderItem> orderList) async {
    for (var item in orderList) {
      await sunmiPrinterPlus.printRow(cols: [
        SunmiColumn(
          text: '${item.count}x',
          width: 4,
        ),
        SunmiColumn(
          text: stringRowCreater(item.itemTitle!, 20),
          width: 20,
          style: SunmiTextStyle(align: SunmiPrintAlign.LEFT),
        ),
        SunmiColumn(
          text: '${item.totalPrice}TL',
          width: 7,
          style: SunmiTextStyle(align: SunmiPrintAlign.RIGHT),
        ),
      ]);
      await itemOptionBuilder(item);
    }
    //DIVIDER
    await addLine();
  }

  Future<void> printBodyGETIN(List<OrderItem> orderList) async {
    for (var item in orderList) {
      await sunmiPrinterPlus.printRow(cols: [
        SunmiColumn(
          text: '${item.count}x',
          width: 4,
        ),
        SunmiColumn(
          text: stringRowCreater(item.itemTitle!, 20),
          width: 20,
          style: SunmiTextStyle(align: SunmiPrintAlign.LEFT),
        ),
        SunmiColumn(
          text: '${item.totalPrice}TL',
          width: 7,
          style: SunmiTextStyle(align: SunmiPrintAlign.RIGHT),
        ),
      ]);
      await itemOptionBuilder(item);
    }

    //DIVIDER
    await addLine();
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
        await sunmiPrinterPlus.printRow(cols: [
          SunmiColumn(
            text: '',
            width: 4,
          ),
          SunmiColumn(
            text: stringRowCreater('${option.title!}:'.withoutDiacriticalMarks(), 27),
            width: 27,
            style: SunmiTextStyle(align: SunmiPrintAlign.LEFT),
          ),
        ]);
        for (OrderOptionItem optionItem in option.items!) {
          await sunmiPrinterPlus.printRow(cols: [
            SunmiColumn(
              text: '',
              width: 4,
            ),
            SunmiColumn(
              text: stringRowCreater(optionItem.title!..withoutDiacriticalMarks, 27),
              width: 27,
              style: SunmiTextStyle(align: SunmiPrintAlign.LEFT),
            ),
          ]);
        }
      }
    }
    if (item.promotionMenuId != null) {
      for (OrderOption option in item.options!) {
        await sunmiPrinterPlus.printRow(cols: [
          SunmiColumn(
            text: '',
            width: 4,
            style: SunmiTextStyle(align: SunmiPrintAlign.LEFT),
          ),
          SunmiColumn(
            text: stringRowCreater('${option.sectionTitle!}:'.withoutDiacriticalMarks(), 31),
            width: 27,
            style: SunmiTextStyle(align: SunmiPrintAlign.LEFT),
          ),
        ]);
        await sunmiPrinterPlus.printRow(cols: [
          SunmiColumn(
            text: '',
            width: 4,
            style: SunmiTextStyle(align: SunmiPrintAlign.LEFT),
          ),
          SunmiColumn(
            text: stringRowCreater(option.sectionItem!.productName!.withoutDiacriticalMarks(), 31),
            width: 27,
            style: SunmiTextStyle(align: SunmiPrintAlign.LEFT),
          ),
        ]);
        for (var sectionOption in option.sectionItem!.options!) {
          await sunmiPrinterPlus.printRow(cols: [
            SunmiColumn(
              text: '',
              width: 4,
              style: SunmiTextStyle(align: SunmiPrintAlign.LEFT),
            ),
            SunmiColumn(
              text: stringRowCreater('${sectionOption.title}:'.withoutDiacriticalMarks(), 31),
              width: 27,
              style: SunmiTextStyle(align: SunmiPrintAlign.LEFT),
            ),
          ]);
          for (var sectionOptionItem in sectionOption.items!) {
            await sunmiPrinterPlus.printRow(cols: [
              SunmiColumn(
                text: '',
                width: 4,
                style: SunmiTextStyle(align: SunmiPrintAlign.LEFT),
              ),
              SunmiColumn(
                text: stringRowCreater(sectionOptionItem.title!.withoutDiacriticalMarks(), 31),
                width: 27,
                style: SunmiTextStyle(align: SunmiPrintAlign.LEFT),
              ),
            ]);
          }
        }
      }
    }
    if (!(item.itemNote == null || item.itemNote!.isEmpty)) {
      await sunmiPrinterPlus.printRow(cols: [
        SunmiColumn(
          text: '',
          width: 4,
          style: SunmiTextStyle(align: SunmiPrintAlign.LEFT),
        ),
        SunmiColumn(
          text: stringRowCreater('Ürün Notu: ${item.itemNote!}'.withoutDiacriticalMarks(), 27),
          width: 27,
          style: SunmiTextStyle(align: SunmiPrintAlign.LEFT),
        ),
      ]);
    }
  }
}
