import 'dart:async';

import 'package:intl/intl.dart';
import 'package:sip_models/enum.dart';
import 'package:sip_models/request.dart';
import 'package:sip_models/response.dart';
import 'package:sip_printer/src/extanstion/extension_string.dart';
import 'package:sunmi_printer_plus/sunmi_printer_plus.dart';
import 'package:sip_models/ri_models.dart';

import '../../../sip_printer.dart';

/// [TABLE] => Masadan Ödeme
/// [TAKEOUT] => Adrese Teslim
/// [GETIN] => Gel Al

class SunmiPrinterHeader {
  final SunmiPrinterPlus sunmiPrinterPlus;

  SunmiPrinterHeader({required this.sunmiPrinterPlus});

  Future<void> printHeaderTABLE({
    required String? tableName,
    required String orderNumber,
  }) async {
    String orderNumberTitle = 'Sipariş No';
    orderNumber = '#$orderNumber';
    String orderType = 'RESTORAN';

    await sunmiPrinterPlus.printText(
      text: '** SİPARİŞ FİŞİ **',
      style: SunmiTextStyle(
        bold: true,
        align: SunmiPrintAlign.CENTER,
      ),
    );
    await addLine();

    if (tableName != null) {
      await sunmiPrinterPlus.printText(
        text: tableName,
        style: SunmiTextStyle(
          bold: true,
          align: SunmiPrintAlign.CENTER,
        ),
      );
    }

    //AREA 2 -> Sipariş No ve Restoran Kısmı
    await sunmiPrinterPlus.printRow(
      cols: [
        SunmiColumn(
          text: orderNumberTitle,
          width: orderNumberTitle.length + 3,
          style: SunmiTextStyle(align: SunmiPrintAlign.LEFT),
        ),
        SunmiColumn(
          text: orderType,
          width: orderType.length,
          style: SunmiTextStyle(align: SunmiPrintAlign.RIGHT),
        ),
      ],
    );

    //OrderNumber
    await sunmiPrinterPlus.printText(
      text: orderNumber,
      style: SunmiTextStyle(
        align: SunmiPrintAlign.CENTER,
      ),
    );

    //DIVIDER
    await addLine();
  }

  //********/TAKEOUT********//

  Future<void> printHeaderTAKEOUT({
    required String orderNumber,
    required String nameSurname,
    required CustomerAddressModel? customerAddress,
    required String? orderNote,
  }) async {
    await sunmiPrinterPlus.printText(
      text: '** ${SipPrinter.instance.headerTitle.withoutDiacriticalMarks()} **',
      style: SunmiTextStyle(
        bold: true,
        align: SunmiPrintAlign.CENTER,
      ),
    );

    //DIVIDER
    await addLine();

    //AREA 2 -> Sipariş No ve Restoran Kısmı
    await sunmiPrinterPlus.printRow(
      cols: [
        SunmiColumn(
          text: 'SİPARİŞ NO:'.withoutDiacriticalMarks(),
          width: 11,
        ),
        SunmiColumn(
          width: 09,
          style: SunmiTextStyle(align: SunmiPrintAlign.CENTER),
          text: '',
        ),
        SunmiColumn(
          text: 'Tarih',
          width: 10,
          style: SunmiTextStyle(align: SunmiPrintAlign.RIGHT),
        ),
      ],
    );
    //OrderNumber

    await sunmiPrinterPlus.printRow(
      cols: [
        SunmiColumn(
          text: '#$orderNumber',
          width: 10,
        ),
        SunmiColumn(
          text: DateFormat('dd.MM.yyyy, kk:mm').format(DateTime.now().toLocal()),
          style: SunmiTextStyle(align: SunmiPrintAlign.RIGHT),
          width: 20,
        ),
      ],
    );
    //DIVIDER
    await addLine();
    await sunmiPrinterPlus.printText(
      text: '${nameSurname.withoutDiacriticalMarks}',
      style: SunmiTextStyle(
        bold: true,
      ),
    );
    if (customerAddress != null) {
      await sunmiPrinterPlus.printText(
        text: '${(customerAddress.address ?? '').withoutDiacriticalMarks}',
        style: SunmiTextStyle(),
      );
    }

    //Adres tarifi boş ya da null değilse çağrılır.
    if (customerAddress != null &&
        customerAddress.addressRoute != null &&
        customerAddress.addressRoute!.trim().isNotEmpty) {
      await sunmiPrinterPlus.printText(
        text: '${customerAddress.addressRoute!.withoutDiacriticalMarks}',
        style: SunmiTextStyle(),
      );
    }

    await addLine();
    if (orderNote?.isNotEmpty == true) {
      await sunmiPrinterPlus.printText(
        text: 'Müşteri Notu',
        style: SunmiTextStyle(bold: true),
      );

      await sunmiPrinterPlus.printText(
        text: '${orderNote!.withoutDiacriticalMarks}',
        style: SunmiTextStyle(),
      );

      await addLine();
    }
  }

  //********/GETIN********//

  Future<void> printHeaderGETIN({
    required String orderNumber,
    required String nameSurname,
    required String? callNumber,
    required String? orderNote,
  }) async {
    await sunmiPrinterPlus.printText(
      text: '** GEL AL **',
      style: SunmiTextStyle(
        bold: true,
        align: SunmiPrintAlign.CENTER,
      ),
    );

    //DIVIDER
    await addLine();

    //AREA 2 -> Sipariş No ve Restoran Kısmı
    await sunmiPrinterPlus.printRow(cols: [
      SunmiColumn(
        text: 'SİPARİŞ NO:'.withoutDiacriticalMarks(),
        width: 11,
      ),
      SunmiColumn(
        width: 09,
        style: SunmiTextStyle(align: SunmiPrintAlign.CENTER),
        text: '',
      ),
      SunmiColumn(
        text: 'Tarih',
        width: 10,
        style: SunmiTextStyle(align: SunmiPrintAlign.RIGHT),
      ),
    ]);
    //OrderNumber

    await sunmiPrinterPlus.printRow(cols: [
      SunmiColumn(
        text: '#$orderNumber',
        width: 10,
      ),
      SunmiColumn(
        text: DateFormat('dd.MM.yyyy, kk:mm').format(DateTime.now().toLocal()),
        style: SunmiTextStyle(align: SunmiPrintAlign.RIGHT),
        width: 20,
      ),
    ]);
    //DIVIDER
    await addLine();
    await sunmiPrinterPlus.printText(
      text: '${nameSurname.withoutDiacriticalMarks}',
      style: SunmiTextStyle(
        bold: true,
        align: SunmiPrintAlign.CENTER,
      ),
    );

    if (callNumber != null && callNumber.trim().isNotEmpty) {
      await sunmiPrinterPlus.printText(
        text: 'Telefon: ${callNumber.withoutDiacriticalMarks()}',
        style: SunmiTextStyle(
          align: SunmiPrintAlign.LEFT,
        ),
      );
    }
    await addLine();
    if (orderNote?.isNotEmpty == true) {
      await sunmiPrinterPlus.printText(
        text: 'Müşteri Notu',
        style: SunmiTextStyle(
          bold: true,
          align: SunmiPrintAlign.LEFT,
        ),
      );

      await sunmiPrinterPlus.printText(
        text: '${orderNote!.withoutDiacriticalMarks}',
        style: SunmiTextStyle(),
      );
      await addLine();
    }
  }

  Future<void> printTestReceipt() async {
    await sunmiPrinterPlus.printText(
      text: '** TEST FİŞİ **',
      style: SunmiTextStyle(
        bold: true,
        align: SunmiPrintAlign.CENTER,
      ),
    );

    //DIVIDER
    await addLine();

    //AREA 2 -> Sipariş No ve Restoran Kısmı
    await sunmiPrinterPlus.printRow(
      cols: [
        SunmiColumn(
          text: 'TEST NO:'.withoutDiacriticalMarks(),
          width: 1,
        ),
        SunmiColumn(
          text: 'Tarih',
          width: 1,
          style: SunmiTextStyle(align: SunmiPrintAlign.RIGHT),
        ),
      ],
    );
    //OrderNumber

    await sunmiPrinterPlus.printRow(cols: [
      SunmiColumn(
        text: '0001',
        width: 10,
      ),
      SunmiColumn(
        text: DateFormat('dd.MM.yyyy, kk:mm').format(DateTime.now().toLocal()),
        style: SunmiTextStyle(align: SunmiPrintAlign.RIGHT),
        width: 20,
      ),
    ]);
    //DIVIDER
    await addLine();
    await sunmiPrinterPlus.printQrcode(
      text: 'https://sorgula.turkcellesirket.com/earsiv/7710617226/SAS2025000035290/1,00',
      style: SunmiQrcodeStyle(
        qrcodeSize: 4,
        align: SunmiPrintAlign.CENTER,
      ),
    );
    await sunmiPrinterPlus.printText(
      text: 'E-Belgeye erişmek için'.withoutDiacriticalMarks(),
      style: SunmiTextStyle(
        bold: false,
        align: SunmiPrintAlign.CENTER,
      ),
    );
    await sunmiPrinterPlus.printText(
      text: 'yukarıdaki QR kodu okutunuz.'.withoutDiacriticalMarks(),
      style: SunmiTextStyle(
        bold: false,
        align: SunmiPrintAlign.CENTER,
      ),
    );

    await addLine(6);
  }

  Future addLine([int time = 1]) async {
    for (var i = 0; i < time; i++) {
      await sunmiPrinterPlus.printText(text: ' ');
    }
  }

  Future<void> printForBackgroundProcess({
    required PrinterQueueResponsePrintDataModel printData,
    required String paymentModelId,
    required bool isPayment,
    List<PrinterLineAndStyleModel>? headers,
    List<PrinterLineAndStyleModel>? footers,
    String? invoiceLink,
  }) async {
    /// Dealer Name
    final dealerName = SipPrinter.instance.headerTitle.withoutDiacriticalMarks();
    final dealerNameList = orderDetailFitter(dealerName, 31);
    for (String dealerStr in dealerNameList) {
      await sunmiPrinterPlus.printText(
        text: dealerStr,
        style: SunmiTextStyle(
          fontSize: 32,
          bold: true,
          align: SunmiPrintAlign.CENTER,
        ),
      );
    }

    /// Dealer addres
    final address = SipPrinter.instance.footerTitle.withoutDiacriticalMarks();
    final addressList = orderDetailFitter(address, 31);
    for (String addressStr in addressList) {
      await sunmiPrinterPlus.printText(
        text: addressStr,
        style: SunmiTextStyle(
          bold: true,
          align: SunmiPrintAlign.CENTER,
        ),
      );
    }
    await addLine();

    /// Header
    if (headers != null) {
      for (var element in headers) {
        await sunmiPrinterPlus.printText(
          text: element.text!,
          style: SunmiTextStyle(
            fontSize: getSizeFromFontSize(element.style),
            bold: true,
            align: SunmiPrintAlign.CENTER,
          ),
        );
      }
      if (headers.isNotEmpty) await addLine();
    }

    /// Receipt type
    await sunmiPrinterPlus.printText(
      text: isPayment ? "KASA FİŞİ".withoutDiacriticalMarks() : "MASA ADİSYONU".withoutDiacriticalMarks(),
      style: SunmiTextStyle(
        bold: true,
        align: SunmiPrintAlign.CENTER,
      ),
    );

    /// Delivery type
    if (paymentModelId == PaymentModelID.PRE.name) {
      await sunmiPrinterPlus.printText(
        text:
            (printData.serviceDeliveryType == TableServiceType.SS.name ? "Servis Tipi: Selfsevis" : "Servis Tipi: Masa")
                .withoutDiacriticalMarks(),
        style: SunmiTextStyle(
          bold: true,
          align: SunmiPrintAlign.CENTER,
        ),
      );
    }
    await addLine();

    /// Payment Status
    if (isPayment) {
      await sunmiPrinterPlus.printText(
        text: "Ödendi / ${printData.paymentType}".withoutDiacriticalMarks(),
        style: SunmiTextStyle(
          bold: true,
          align: SunmiPrintAlign.CENTER,
        ),
      );
      await addLine();
    }

    /// Orders
    for (var order in printData.orders!) {
      await sunmiPrinterPlus.printText(
        text:
            "${"Sipariş: ${order.id!.toString()}".withoutDiacriticalMarks()} - ${order.nickName.maskNullableSurname()}",
        style: SunmiTextStyle(
          bold: true,
          align: SunmiPrintAlign.CENTER,
        ),
      );
      await addLine();
      await _createColumnFromOrderDetail(order);
      await addLine();
      if (order.orderNote?.isNotEmpty == true) {
        await sunmiPrinterPlus.printText(
          text: 'Sipariş Notu',
          style: SunmiTextStyle(
            bold: true,
            align: SunmiPrintAlign.CENTER,
          ),
        );
        await sunmiPrinterPlus.printText(
          text: '${order.orderNote!.withoutDiacriticalMarks}',
          style: SunmiTextStyle(
            align: SunmiPrintAlign.CENTER,
          ),
        );
        await addLine();
      }
    }

    /// Tip Amount
    if (printData.totalTipAmount != null && printData.totalTipAmount != 0) {
      await sunmiPrinterPlus.printRow(cols: [
        SunmiColumn(
          text: 'Bahşiş:'.withoutDiacriticalMarks(),
          width: 4,
          style: SunmiTextStyle(align: SunmiPrintAlign.LEFT),
        ),
        SunmiColumn(
          text: '${printData.totalTipAmount} TL'.withoutDiacriticalMarks(),
          width: 19,
          style: SunmiTextStyle(align: SunmiPrintAlign.RIGHT),
        ),
      ]);
    }

    /// Table Service
    if (printData.tableServiceAmount != null && printData.tableServiceAmount != 0) {
      await sunmiPrinterPlus.printRow(cols: [
        SunmiColumn(
          text: 'Masaya Servis:'.withoutDiacriticalMarks(),
          width: 4,
          style: SunmiTextStyle(align: SunmiPrintAlign.LEFT),
        ),
        SunmiColumn(
          text: '${printData.tableServiceAmount} TL'.withoutDiacriticalMarks(),
          width: 19,
          style: SunmiTextStyle(align: SunmiPrintAlign.RIGHT),
        ),
      ]);
    }

    /// Date
    await sunmiPrinterPlus.printText(
      text:
          'TARİH: ${DateFormat('dd.MM.yyyy HH:mm').format(printData.orders?.firstOrNull?.recordDate ?? DateTime.now()).withoutDiacriticalMarks()}',
      style: SunmiTextStyle(
        bold: true,
        align: SunmiPrintAlign.CENTER,
      ),
    );

    /// Total Amount
    await sunmiPrinterPlus.printText(
      text: 'TOPLAM TUTAR: ${printData.serviceTotalAmount!.toStringAsFixed(2)} TL',
      style: SunmiTextStyle(
        bold: true,
        align: SunmiPrintAlign.CENTER,
      ),
    );

    /// invoice QR
    if (invoiceLink != null) {
      await addLine(2);
      await sunmiPrinterPlus.printQrcode(
        text: invoiceLink,
        style: SunmiQrcodeStyle(
          qrcodeSize: 4,
          align: SunmiPrintAlign.CENTER,
        ),
      );
      await sunmiPrinterPlus.printText(
        text: 'E-Belgeye erişmek için'.withoutDiacriticalMarks(),
        style: SunmiTextStyle(
          bold: false,
          align: SunmiPrintAlign.CENTER,
        ),
      );
      await sunmiPrinterPlus.printText(
        text: 'yukarıdaki QR kodu okutunuz.'.withoutDiacriticalMarks(),
        style: SunmiTextStyle(
          bold: false,
          align: SunmiPrintAlign.CENTER,
        ),
      );
    }

    /// Footer
    if (footers?.isNotEmpty == true) await addLine();
    if (footers != null) {
      for (var element in footers) {
        await sunmiPrinterPlus.printText(
          text: element.text!,
          style: SunmiTextStyle(
            fontSize: getSizeFromFontSize(element.style),
            bold: true,
            align: SunmiPrintAlign.CENTER,
          ),
        );
      }
    }

    await addLine(4);
  }

  Future<void> _createColumnFromOrderDetail(PrinterQuequeResponseOrderModel orderDetail) async {
    for (var i = 0; i < orderDetail.items!.length; i++) {
      final List<String> itemsFitted = orderDetailFitter(orderDetail.items![i].itemTitle!, 31);
      for (var element in itemsFitted) {
        if (element == itemsFitted.first) {
          if (orderDetail.items![i].status!.statusCode == OrderItemStatusId.CANCEL.name) {
            await sunmiPrinterPlus.printRow(cols: [
              SunmiColumn(
                text: 'Iptal Edildi'.withoutDiacriticalMarks(),
                width: 4,
                style: SunmiTextStyle(align: SunmiPrintAlign.LEFT),
              ),
              SunmiColumn(
                text: '',
                width: 19,
                style: SunmiTextStyle(align: SunmiPrintAlign.CENTER),
              ),
              SunmiColumn(
                text: '',
                width: 8,
                style: SunmiTextStyle(align: SunmiPrintAlign.RIGHT),
              ),
            ]);
          }
          await sunmiPrinterPlus.printRow(cols: [
            SunmiColumn(
              text: "${orderDetail.items![i].count.toString()}x".withoutDiacriticalMarks(),
              width: 4,
              style: SunmiTextStyle(align: SunmiPrintAlign.LEFT),
            ),
            SunmiColumn(
              text: element.withoutDiacriticalMarks(),
              width: 19,
              style: SunmiTextStyle(align: SunmiPrintAlign.LEFT),
            ),
            SunmiColumn(
              text: "${orderDetail.items![i].totalPrice!.toStringAsFixed(2)}TL".withoutDiacriticalMarks(),
              width: 8,
              style: SunmiTextStyle(align: SunmiPrintAlign.RIGHT),
            ),
          ]);
        } else {
          await sunmiPrinterPlus.printRow(cols: [
            SunmiColumn(
              text: "".withoutDiacriticalMarks(),
              width: 4,
              style: SunmiTextStyle(align: SunmiPrintAlign.LEFT),
            ),
            SunmiColumn(
              text: element.withoutDiacriticalMarks(),
              width: 19,
              style: SunmiTextStyle(align: SunmiPrintAlign.LEFT),
            ),
            SunmiColumn(
              text: "".withoutDiacriticalMarks(),
              width: 9,
              style: SunmiTextStyle(align: SunmiPrintAlign.RIGHT),
            ),
          ]);
        }

        if (orderDetail.items![i].options != null) {
          if (orderDetail.items![i].itemTypeId == ItemType.PRODUCT.name) {
            for (OrderOption option in orderDetail.items![i].options!) {
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
          } else if (orderDetail.items![i].itemTypeId == ItemType.PROMOTION_MENU.name) {
            for (OrderOption option in orderDetail.items![i].options!) {
              await sunmiPrinterPlus.printRow(cols: [
                SunmiColumn(
                  text: '',
                  width: 4,
                  style: SunmiTextStyle(align: SunmiPrintAlign.LEFT),
                ),
                SunmiColumn(
                  text: stringRowCreater('${option.sectionTitle!}:'.withoutDiacriticalMarks(), 27),
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
                  text: stringRowCreater(option.sectionItem!.productName!.withoutDiacriticalMarks(), 27),
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
                    text: stringRowCreater('${sectionOption.title}:'.withoutDiacriticalMarks(), 27),
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
        }
        if (orderDetail.items![i].itemNote?.isNotEmpty == true) {
          List<String> orderNoteStrings = orderDetailFitter(orderDetail.items![i].itemNote!, 20);
          orderNoteStrings.insert(0, "Müşteri Notu: ");
          for (var orderNote in orderNoteStrings) {
            await sunmiPrinterPlus.printRow(cols: [
              SunmiColumn(
                text: "".withoutDiacriticalMarks(),
                width: 4,
                style: SunmiTextStyle(align: SunmiPrintAlign.LEFT),
              ),
              SunmiColumn(
                text: orderNote.withoutDiacriticalMarks(),
                width: 20,
                style: SunmiTextStyle(align: SunmiPrintAlign.LEFT),
              ),
              SunmiColumn(
                text: "".withoutDiacriticalMarks(),
                width: 7,
                style: SunmiTextStyle(align: SunmiPrintAlign.RIGHT),
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

  int getSizeFromFontSize(String? size) {
    switch (size) {
      case 'XS':
        return 14;
      case 'SM':
        return 20;
      case 'MD':
        return 24;
      case 'LG':
        return 32;
      case "XL":
        return 48;
      default:
        return 24;
    }
  }
}
