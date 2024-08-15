import 'dart:async';

import 'package:intl/intl.dart';
import 'package:sip_models/enum.dart';
import 'package:sip_models/request.dart';
import 'package:sip_models/response.dart';
import 'package:sip_printer/src/extanstion/extension_string.dart';
import 'package:sunmi_printer_plus/column_maker.dart';
import 'package:sunmi_printer_plus/enums.dart';
import 'package:sunmi_printer_plus/sunmi_printer_plus.dart';
import 'package:sunmi_printer_plus/sunmi_style.dart';
import 'package:sip_models/ri_models.dart';

import '../../../sip_printer.dart';


/// [TABLE] => Masadan Ödeme
/// [TAKEOUT] => Adrese Teslim
/// [GETIN] => Gel Al

class SunmiPrinterHeader {
  SunmiPrinterHeader();

  Future<void> printHeaderTABLE({
    required String? tableName,
    required String orderNumber,
  }) async {
    String orderNumberTitle = 'Sipariş No';
    orderNumber = '#$orderNumber';
    String orderType = 'RESTORAN';

    await SunmiPrinter.initPrinter().then((var init) async {
      if (init!) {
        await SunmiPrinter.setAlignment(SunmiPrintAlign.CENTER);
        await SunmiPrinter.printText(
          '** SİPARİŞ FİŞİ **',
          style: SunmiStyle(
            fontSize: SunmiFontSize.MD,
            bold: true,
          ),
        );
        await SunmiPrinter.line();

        await SunmiPrinter.setAlignment(SunmiPrintAlign.CENTER);
        if (tableName != null) {
          await SunmiPrinter.printText(tableName,
              style: SunmiStyle(
                fontSize: SunmiFontSize.MD,
                bold: true,
              ));
        }

        //AREA 2 -> Sipariş No ve Restoran Kısmı
        await SunmiPrinter.printRow(cols: [
          ColumnMaker(
            text: orderNumberTitle,
            width: orderNumberTitle.length + 3,
          ),
          ColumnMaker(width: orderNumber.length + 5, align: SunmiPrintAlign.CENTER),
          ColumnMaker(text: orderType, width: orderType.length, align: SunmiPrintAlign.RIGHT),
        ]);

        //OrderNumber
        await SunmiPrinter.printText(orderNumber,
            style: SunmiStyle(
              fontSize: SunmiFontSize.MD,
            ));

        //DIVIDER
        await SunmiPrinter.line();
      }
    });
  }

  //********/TAKEOUT********//

  Future<void> printHeaderTAKEOUT({
    required String orderNumber,
    required String nameSurname,
    required CustomerAddressModel? customerAddress,
    required String? orderNote,
  }) async {
    await SunmiPrinter.initPrinter().then((var init) async {
      if (init!) {
        await SunmiPrinter.setAlignment(SunmiPrintAlign.CENTER);
        await SunmiPrinter.printText('** ${SipPrinter.instance.dealerInfo.dealerName} **',
            style: SunmiStyle(
              fontSize: SunmiFontSize.MD,
              bold: true,
            ));

        //DIVIDER
        await SunmiPrinter.line();
        await SunmiPrinter.setAlignment(SunmiPrintAlign.CENTER);

        //AREA 2 -> Sipariş No ve Restoran Kısmı
        await SunmiPrinter.printRow(cols: [
          ColumnMaker(
            text: 'SİPARİŞ NO:'.withoutDiacriticalMarks(),
            width: 11,
          ),
          ColumnMaker(width: 09, align: SunmiPrintAlign.CENTER),
          ColumnMaker(
            text: 'Tarih',
            width: 10,
            align: SunmiPrintAlign.RIGHT,
          ),
        ]);
        //OrderNumber

        await SunmiPrinter.printRow(cols: [
          ColumnMaker(
            text: '#$orderNumber',
            width: 10,
          ),
          ColumnMaker(
            text: DateFormat('dd.MM.yyyy, kk:mm').format(DateTime.now().toLocal()),
            align: SunmiPrintAlign.RIGHT,
            width: 20,
          ),
        ]);
        //DIVIDER
        await SunmiPrinter.line();
        await SunmiPrinter.printText('${nameSurname.withoutDiacriticalMarks}',
            style: SunmiStyle(
              fontSize: SunmiFontSize.MD,
              bold: true,
            ));
        if (customerAddress != null) {
          await SunmiPrinter.printText('${(customerAddress.address ?? '').withoutDiacriticalMarks}',
              style: SunmiStyle(
                fontSize: SunmiFontSize.MD,
              ));
        }

        //Adres tarifi boş ya da null değilse çağrılır.
        if (customerAddress != null &&
            customerAddress.addressRoute != null &&
            customerAddress.addressRoute!.trim().isNotEmpty) {
          await SunmiPrinter.printText('${customerAddress.addressRoute!.withoutDiacriticalMarks}',
              style: SunmiStyle(
                fontSize: SunmiFontSize.MD,
              ));
        }

        await SunmiPrinter.line();
        if (orderNote?.isNotEmpty == true) {
          await SunmiPrinter.printText('Müşteri Notu', style: SunmiStyle(fontSize: SunmiFontSize.MD, bold: true));

          await SunmiPrinter.printText('${orderNote!.withoutDiacriticalMarks}',
              style: SunmiStyle(
                fontSize: SunmiFontSize.MD,
              ));

          await SunmiPrinter.line();
        }
      }
    });
  }

  //********/GETIN********//

  Future<void> printHeaderGETIN({
    required String orderNumber,
    required String nameSurname,
    required String? callNumber,
    required String? orderNote,
  }) async {
    await SunmiPrinter.initPrinter().then((var init) async {
      if (init!) {
        await SunmiPrinter.setAlignment(SunmiPrintAlign.CENTER);
        await SunmiPrinter.printText('** GEL AL **',
            style: SunmiStyle(
              fontSize: SunmiFontSize.MD,
              bold: true,
            ));

        //DIVIDER
        await SunmiPrinter.line();
        await SunmiPrinter.setAlignment(SunmiPrintAlign.CENTER);

        //AREA 2 -> Sipariş No ve Restoran Kısmı
        await SunmiPrinter.printRow(cols: [
          ColumnMaker(
            text: 'SİPARİŞ NO:'.withoutDiacriticalMarks(),
            width: 11,
          ),
          ColumnMaker(width: 09, align: SunmiPrintAlign.CENTER),
          ColumnMaker(
            text: 'Tarih',
            width: 10,
            align: SunmiPrintAlign.RIGHT,
          ),
        ]);
        //OrderNumber

        await SunmiPrinter.printRow(cols: [
          ColumnMaker(
            text: '#$orderNumber',
            width: 10,
          ),
          ColumnMaker(
            text: DateFormat('dd.MM.yyyy, kk:mm').format(DateTime.now().toLocal()),
            align: SunmiPrintAlign.RIGHT,
            width: 20,
          ),
        ]);
        //DIVIDER
        await SunmiPrinter.line();
        await SunmiPrinter.printText('${nameSurname.withoutDiacriticalMarks}',
            style: SunmiStyle(
              fontSize: SunmiFontSize.MD,
              bold: true,
            ));

        if (callNumber != null && callNumber.trim().isNotEmpty) {
          await SunmiPrinter.printText('Telefon: ${callNumber.withoutDiacriticalMarks()}',
              style: SunmiStyle(
                fontSize: SunmiFontSize.MD,
              ));
        }
        await SunmiPrinter.line();
        if (orderNote?.isNotEmpty == true) {
          await SunmiPrinter.printText('Müşteri Notu', style: SunmiStyle(fontSize: SunmiFontSize.MD, bold: true));

          await SunmiPrinter.printText('${orderNote!.withoutDiacriticalMarks}',
              style: SunmiStyle(
                fontSize: SunmiFontSize.MD,
              ));
          await SunmiPrinter.line();
        }
      }
    });
  }

  Future<void> printTestReceipt() async {
    await SunmiPrinter.initPrinter().then((var init) async {
      if (init!) {
        await SunmiPrinter.setAlignment(SunmiPrintAlign.CENTER);
        await SunmiPrinter.printText('** TEST FİŞİ **',
            style: SunmiStyle(
              fontSize: SunmiFontSize.MD,
              bold: true,
            ));

        //DIVIDER
        await SunmiPrinter.line();
        await SunmiPrinter.setAlignment(SunmiPrintAlign.CENTER);

        //AREA 2 -> Sipariş No ve Restoran Kısmı
        await SunmiPrinter.printRow(cols: [
          ColumnMaker(
            text: 'TEST NO:'.withoutDiacriticalMarks(),
            width: 1,
          ),
          ColumnMaker(width: 09, align: SunmiPrintAlign.CENTER),
          ColumnMaker(
            text: 'Tarih',
            width: 10,
            align: SunmiPrintAlign.RIGHT,
          ),
        ]);
        //OrderNumber

        await SunmiPrinter.printRow(cols: [
          ColumnMaker(
            text: '0001',
            width: 10,
          ),
          ColumnMaker(
            text: DateFormat('dd.MM.yyyy, kk:mm').format(DateTime.now().toLocal()),
            align: SunmiPrintAlign.RIGHT,
            width: 20,
          ),
        ]);
        //DIVIDER
        await SunmiPrinter.line();
        await SunmiPrinter.printText("TEST FİRMASI",
            style: SunmiStyle(
              fontSize: SunmiFontSize.MD,
              bold: true,
            ));

        await SunmiPrinter.line();
        await SunmiPrinter.printText('Test Notu', style: SunmiStyle(fontSize: SunmiFontSize.MD, bold: true));

        await SunmiPrinter.printText('Bu Bir Test Fişidir',
            style: SunmiStyle(
              fontSize: SunmiFontSize.MD,
            ));
        await SunmiPrinter.line();
        await SunmiPrinter.lineWrap(3);
        await SunmiPrinter.exitTransactionPrint(true);
      }
    });
  }

  Future<void> printForBackgroundProcess({
    required PrinterQueueResponsePrintDataModel printData,
    required String paymentModelId,
    required bool isPayment,
    List<PrinterLineAndStyleModel>? headers,
    List<PrinterLineAndStyleModel>? footers,
  }) async {
    await SunmiPrinter.initPrinter().then((init) async {
      if (init == false) return;
      await SunmiPrinter.setAlignment(SunmiPrintAlign.CENTER);

      /// Dealer Name
      final dealerName = SipPrinter.instance.dealerInfo.dealerName!.withoutDiacriticalMarks();
      final dealerNameList = orderDetailFitter(dealerName, 31);
      for (String dealerStr in dealerNameList) {
        await SunmiPrinter.printText(
          dealerStr,
          style: SunmiStyle(
            fontSize: SunmiFontSize.LG,
            bold: true,
            align: SunmiPrintAlign.CENTER,
          ),
        );
      }

      /// Dealer addres
      final address = SipPrinter.instance.dealerInfo.address!.address!.withoutDiacriticalMarks();
      final addressList = orderDetailFitter(address, 31);
      for (String addressStr in addressList) {
        await SunmiPrinter.printText(
          addressStr,
          style: SunmiStyle(
            fontSize: SunmiFontSize.MD,
            bold: true,
            align: SunmiPrintAlign.CENTER,
          ),
        );
      }
      await SunmiPrinter.line();

      /// Header
      if (headers != null) {
        for (var element in headers) {
          await SunmiPrinter.printText(element.text!,
              style: SunmiStyle(
                fontSize: element.style?.enumFromString<SunmiFontSize>(SunmiFontSize.values),
                bold: true,
                align: SunmiPrintAlign.CENTER,
              ));
        }
        if (headers.isNotEmpty) await SunmiPrinter.line();
      }

      /// Receipt type
      await SunmiPrinter.printText(
          isPayment ? "KASA FİŞİ".withoutDiacriticalMarks() : "MASA ADİSYONU".withoutDiacriticalMarks(),
          style: SunmiStyle(
            fontSize: SunmiFontSize.MD,
            bold: true,
          ));

      /// Delivery type
      if (paymentModelId == PaymentModelID.PRE.name) {
        await SunmiPrinter.printText(
          (printData.serviceDeliveryType == TableServiceType.SS.name ? "Servis Tipi: Selfsevis" : "Servis Tipi: Masa")
              .withoutDiacriticalMarks(),
          style: SunmiStyle(
            fontSize: SunmiFontSize.MD,
            bold: true,
          ),
        );
      }
      await SunmiPrinter.line();

      /// Payment Status
      if (isPayment) {
        await SunmiPrinter.printText("Ödendi / ${printData.paymentType}".withoutDiacriticalMarks(),
            style: SunmiStyle(
              fontSize: SunmiFontSize.MD,
              bold: true,
            ));
        await SunmiPrinter.line();
      }

      /// Orders
      for (var order in printData.orders!) {
        await SunmiPrinter.printText(
          "${"Sipariş: ${order.id!.toString()}".withoutDiacriticalMarks()} - ${order.nickName.maskNullableSurname()}",
          style: SunmiStyle(
            fontSize: SunmiFontSize.MD,
            bold: true,
          ),
        );
        await SunmiPrinter.line();
        await _createColumnFromOrderDetail(order);
        await SunmiPrinter.line();
        if (order.orderNote?.isNotEmpty == true) {
          await SunmiPrinter.printText('Müşteri Notu', style: SunmiStyle(fontSize: SunmiFontSize.MD, bold: true));
          await SunmiPrinter.printText('${order.orderNote!.withoutDiacriticalMarks}',
              style: SunmiStyle(
                fontSize: SunmiFontSize.MD,
              ));
          await SunmiPrinter.line();
        }
      }

      /// Tip Amount
      if (printData.totalTipAmount != null && printData.totalTipAmount != 0) {
        await SunmiPrinter.printRow(cols: [
          ColumnMaker(
            text: 'Bahşiş:'.withoutDiacriticalMarks(),
            width: 4,
            align: SunmiPrintAlign.LEFT,
          ),
          ColumnMaker(
            text: '${printData.totalTipAmount} TL'.withoutDiacriticalMarks(),
            width: 19,
            align: SunmiPrintAlign.RIGHT,
          ),
        ]);
      }

      /// Table Service
      if (printData.tableServiceAmount != null && printData.tableServiceAmount != 0) {
        await SunmiPrinter.printRow(cols: [
          ColumnMaker(
            text: 'Masaya Servis:'.withoutDiacriticalMarks(),
            width: 4,
            align: SunmiPrintAlign.LEFT,
          ),
          ColumnMaker(
            text: '${printData.tableServiceAmount} TL'.withoutDiacriticalMarks(),
            width: 19,
            align: SunmiPrintAlign.RIGHT,
          ),
        ]);
      }

      /// Date
      await SunmiPrinter.printText(
        'TARİH: ${DateFormat('dd.MM.yyyy HH:mm').format(printData.orders?.firstOrNull?.recordDate ?? DateTime.now()).withoutDiacriticalMarks()}',
        style: SunmiStyle(
          fontSize: SunmiFontSize.MD,
          bold: true,
        ),
      );

      /// Total Amount
      await SunmiPrinter.printText(
        'TOPLAM TUTAR: ${printData.serviceTotalAmount!.toStringAsFixed(2)} TL',
        style: SunmiStyle(
          fontSize: SunmiFontSize.MD,
          bold: true,
        ),
      );

      /// Footer
      if (footers?.isNotEmpty == true) await SunmiPrinter.line();
      if (footers != null) {
        for (var element in footers) {
          await SunmiPrinter.printText(element.text!,
              style: SunmiStyle(
                fontSize: element.style?.enumFromString<SunmiFontSize>(SunmiFontSize.values),
                bold: true,
                align: SunmiPrintAlign.CENTER,
              ));
        }
      }

      await SunmiPrinter.lineWrap(4);
      await SunmiPrinter.exitTransactionPrint(true);
    });
  }

  Future<void> _createColumnFromOrderDetail(PrinterQuequeResponseOrderModel orderDetail) async {
    for (var i = 0; i < orderDetail.items!.length; i++) {
      final List<String> itemsFitted = orderDetailFitter(orderDetail.items![i].itemTitle!, 31);
      for (var element in itemsFitted) {
        if (element == itemsFitted.first) {
          if (orderDetail.items![i].status!.statusCode == OrderItemStatusId.CANCEL.name) {
            await SunmiPrinter.printRow(cols: [
              ColumnMaker(
                text: 'Iptal Edildi'.withoutDiacriticalMarks(),
                width: 4,
                align: SunmiPrintAlign.LEFT,
              ),
              ColumnMaker(
                text: '',
                width: 19,
                align: SunmiPrintAlign.CENTER,
              ),
              ColumnMaker(
                text: '',
                width: 8,
                align: SunmiPrintAlign.RIGHT,
              ),
            ]);
          }
          await SunmiPrinter.printRow(cols: [
            ColumnMaker(
              text: "${orderDetail.items![i].count.toString()}x".withoutDiacriticalMarks(),
              width: 4,
              align: SunmiPrintAlign.LEFT,
            ),
            ColumnMaker(
              text: element.withoutDiacriticalMarks(),
              width: 19,
              align: SunmiPrintAlign.LEFT,
            ),
            ColumnMaker(
              text: "${orderDetail.items![i].totalPrice!.toStringAsFixed(2)}TL".withoutDiacriticalMarks(),
              width: 8,
              align: SunmiPrintAlign.RIGHT,
            ),
          ]);
        } else {
          await SunmiPrinter.printRow(cols: [
            ColumnMaker(
              text: "".withoutDiacriticalMarks(),
              width: 4,
              align: SunmiPrintAlign.LEFT,
            ),
            ColumnMaker(
              text: element.withoutDiacriticalMarks(),
              width: 19,
              align: SunmiPrintAlign.LEFT,
            ),
            ColumnMaker(
              text: "".withoutDiacriticalMarks(),
              width: 9,
              align: SunmiPrintAlign.RIGHT,
            ),
          ]);
        }

        if (orderDetail.items![i].options != null) {
          if (orderDetail.items![i].itemTypeId == ItemType.PRODUCT.name) {
            for (OrderOption option in orderDetail.items![i].options!) {
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
          } else if (orderDetail.items![i].itemTypeId == ItemType.PROMOTION_MENU.name) {
            for (OrderOption option in orderDetail.items![i].options!) {
              await SunmiPrinter.printRow(cols: [
                ColumnMaker(
                  text: '',
                  width: 4,
                  align: SunmiPrintAlign.LEFT,
                ),
                ColumnMaker(
                  text: stringRowCreater('${option.sectionTitle!}:'.withoutDiacriticalMarks(), 27),
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
                  text: stringRowCreater(option.sectionItem!.productName!.withoutDiacriticalMarks(), 27),
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
                    text: stringRowCreater('${sectionOption.title}:'.withoutDiacriticalMarks(), 27),
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
        }
        if (orderDetail.items![i].itemNote?.isNotEmpty == true) {
          List<String> orderNoteStrings = orderDetailFitter(orderDetail.items![i].itemNote!, 20);
          orderNoteStrings.insert(0, "Müşteri Notu: ");
          for (var orderNote in orderNoteStrings) {
            await SunmiPrinter.printRow(cols: [
              ColumnMaker(
                text: "".withoutDiacriticalMarks(),
                width: 4,
                align: SunmiPrintAlign.LEFT,
              ),
              ColumnMaker(
                text: orderNote.withoutDiacriticalMarks(),
                width: 20,
                align: SunmiPrintAlign.LEFT,
              ),
              ColumnMaker(
                text: "".withoutDiacriticalMarks(),
                width: 7,
                align: SunmiPrintAlign.RIGHT,
              ),
            ]);
          }
        }
      }
    }
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

  List<String> orderDetailFitter(String orderDetail, int maxLenght) {
    List<String> tempList = [""];
    List<String> productWordsList = orderDetail.split(" ");
    for (int i = 0; i < productWordsList.length; i++) {
      final tempStr = "${tempList.last} ${productWordsList[i]}".trim();
      if (tempStr.length <= maxLenght) {
        tempList.last = tempStr;
      } else {
        tempList.add(productWordsList[i]);
      }
    }
    return tempList;
  }
}
