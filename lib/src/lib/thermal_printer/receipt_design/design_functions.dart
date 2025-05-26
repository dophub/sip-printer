import 'dart:math';
import 'package:collection/collection.dart';
import 'package:esc_pos_utils_plus/esc_pos_utils_plus.dart';
import 'package:flutter/services.dart';
import 'package:intl/intl.dart';
import 'package:qr_flutter/qr_flutter.dart';
import 'package:sip_models/enum.dart';
import 'package:sip_models/request.dart';
import 'package:sip_models/ri_enum.dart';
import 'package:sip_printer/src/extanstion/extension_string.dart';
import 'package:sip_printer/src/extanstion/general_extenstion.dart';
import 'package:sip_models/ri_models.dart';
import 'package:image/image.dart' as img;

import '../../../sip_printer.dart';

abstract class DesignFunctions {
  late final int maxLineCharacterCount;
  late final PaperSize paperSize;
  final Generator generator;

  DesignFunctions(this.generator, PaperSize? _paperSize) {
    paperSize = _paperSize ?? PaperSize.mm80;
    if (paperSize == PaperSize.mm80) {
      maxLineCharacterCount = 47;
    } else {
      maxLineCharacterCount = 31;
    }
  }

  void addReceiptTitle(List<int> byte, String title) {
    addCenterText(byte, title, width: PosTextSize.size2, height: PosTextSize.size2, bold: true);
  }

  void addHeader(
    List<int> byte,
    PrinterQueueResponsePrintDataModel printData, {
    bool printTableNo = true,
    bool printPayment = false,
  }) {
    if (printData.paymentModelId == PaymentModelID.PRE.name) {
      /// Sıra numarası ------------------------------------------------------------------
      if (printData.numberOfService != null) {
        byte.addAll(
          generator.row([
            PosColumn(
              width: 12,
              text: _createTowColumn('Sıra Numarası: ', printData.numberOfService.toString()),
              styles: const PosStyles(align: PosAlign.left, width: PosTextSize.size1),
            ),
          ]),
        );
      }

      /// service type ------------------------------------------------------------------
      final String txt = printData.serviceDeliveryType?.enumFromString(TableServiceType.values)?.title ?? 'null';
      byte.addAll(
        generator.row([
          PosColumn(
            width: 12,
            text: _createTowColumn('Servis Tipi: ', txt),
            styles: const PosStyles(align: PosAlign.left, width: PosTextSize.size1),
          ),
        ]),
      );
    }

    /// table no ------------------------------------------------------------------
    if (printTableNo) {
      byte.addAll(generator.row([
        PosColumn(
          width: 12,
          text: _createTowColumn('Masa: ', (printData.tableInfo?.tableName).toString()),
          styles: const PosStyles(align: PosAlign.left, width: PosTextSize.size1),
        ),
      ]));
    }

    /// payment type ------------------------------------------------------------------
    if (printPayment) {
      byte.addAll(
        generator.row([
          PosColumn(
            width: 12,
            text: _createTowColumn('Ödeme Yöntemi: ', "${printData.paymentType}".withoutDiacriticalMarks()),
            styles: const PosStyles(align: PosAlign.left, width: PosTextSize.size1),
          ),
        ]),
      );
    }
  }

  void addOrderHeader(
    List<int> byte,
    PrinterQuequeResponseOrderModel order, {
    bool printPayment = true,
    printCustomerPhoneNo = false,
    printCustomerAddress = false,
  }) {
    /// payment type ------------------------------------------------------------------
    if (printPayment) {
      byte.addAll(
        generator.row([
          PosColumn(
            width: 12,
            text: _createTowColumn('Ödeme Yöntemi: ', "${order.paymentInfo?.name}".withoutDiacriticalMarks()),
            styles: const PosStyles(align: PosAlign.left, width: PosTextSize.size1),
          ),
        ]),
      );
      final String isPayedStr = order.paymentInfo?.isOnlinePayment == null
          ? 'null'
          : order.paymentInfo!.isOnlinePayment == true
              ? 'Yapıldı'
              : 'Yapılmadı';
      byte.addAll(
        generator.row([
          PosColumn(
            width: 12,
            text: _createTowColumn('Ödeme Durumu: ', isPayedStr),
            styles: const PosStyles(align: PosAlign.left, width: PosTextSize.size1),
          ),
        ]),
      );
    }

    /// order no ------------------------------------------------------------------
    /// sipariş numarasının son 4 hanesi random sayıdır
    final String id = '${order.id!}${(Random().nextInt(10000) + 1000)}';
    byte.addAll(
      generator.row([
        PosColumn(
          width: 12,
          text: _createTowColumn('Sipariş No: ', id),
          styles: const PosStyles(align: PosAlign.left, width: PosTextSize.size1),
        ),
      ]),
    );

    /// order code ------------------------------------------------------------------
    /// sipariş numarasının son 4 hanesi random sayıdır
    final String code = order.orderNumber ?? '';
    if (code.trim().isNotEmpty) {
      byte.addAll(
        generator.row([
          PosColumn(
            width: 12,
            text: _createTowColumn('Sipariş kodu: ', code),
            styles: const PosStyles(align: PosAlign.left, width: PosTextSize.size1),
          ),
        ]),
      );
    }

    /// create date ------------------------------------------------------------------
    final date = DateFormat('dd.MM.yyyy HH:mm').format(order.recordDate ?? DateTime.now()).withoutDiacriticalMarks();
    byte.addAll(
      generator.row([
        PosColumn(
          width: 12,
          text: _createTowColumn('Tarih: ', date),
          styles: const PosStyles(align: PosAlign.left, width: PosTextSize.size1),
        ),
      ]),
    );
    addSeparator(byte);

    /// customer name ------------------------------------------------------------------
    final String customerName;
    if (order.orderPointId == OrderPoint.TABLE.name) {
      customerName = order.nickName.maskNullableSurname().withoutDiacriticalMarks();
    } else {
      customerName = order.customer!.nameSurname!.withoutDiacriticalMarks();
    }
    byte.addAll(
      generator.row([
        PosColumn(
          width: 12,
          text: _createTowColumn('Müşteri: ', customerName),
          styles: const PosStyles(align: PosAlign.left, width: PosTextSize.size1),
        ),
      ]),
    );

    /// Customer Phone no ------------------------------------------------------------------
    if (printCustomerPhoneNo) {
      byte.addAll(
        generator.row([
          PosColumn(
            width: 12,
            text: _createTowColumn('Telefon No: ', '${order.customer?.phoneNumber}'),
            styles: const PosStyles(align: PosAlign.left, width: PosTextSize.size1),
          ),
        ]),
      );
    }

    /// Customer Address ------------------------------------------------------------------
    if (printCustomerAddress) {
      addEmptyLines(byte);
      List<String> addressStrings = _orderDetailFitter(
        'Adres: ${order.customerAddress?.getFullAddress.withoutDiacriticalMarks() ?? 'null'}',
        maxLineCharacterCount,
      );
      for (var address in addressStrings) {
        byte.addAll(generator.text(address, styles: const PosStyles(align: PosAlign.left)));
      }
    }

    /// Customer Note ------------------------------------------------------------------
    if (order.orderNote?.isNotEmpty == true) {
      addEmptyLines(byte);
      List<String> orderNoteStrings = _orderDetailFitter(
        ('Müşteri Notu: ${order.orderNote!}').withoutDiacriticalMarks(),
        maxLineCharacterCount,
      );
      for (var orderNote in orderNoteStrings) {
        byte.addAll(generator.text(orderNote, styles: const PosStyles(align: PosAlign.left)));
      }
    }
  }

  void createColumnFromOrderDetail(List<int> byte, List<PrinterQueueResponseOrderOrderItemModel> items) {
    try {
      int leftColumnMaxChar = paperSize == PaperSize.mm58 ? 16 : 24;

      void _add(String col1, String col2, [String emptyStr = '', bool bold = false]) => byte.addAll(
            generator.row([
              PosColumn(
                text: emptyStr + col1.withoutDiacriticalMarks(),
                width: 7,
                styles: PosStyles(align: PosAlign.left, bold: bold),
              ),
              PosColumn(
                text: col2.withoutDiacriticalMarks(),
                width: 5,
                styles: PosStyles(align: PosAlign.left, bold: bold),
              )
            ]),
          );

      for (var i = 0; i < items.length; i++) {
        final countStr = '${items[i].count.toString()}x';
        String emptyStr = ' ' * countStr.length;

        /// Function -----------------------------------------------
        void _addOption(String title, List<OrderOptionItem>? items) {
          List<String> titleFitter = _orderDetailFitter('$title: ', leftColumnMaxChar);

          /// options item -----------------------------------------------
          String tempString = "";
          for (OrderOptionItem itemNames in items!) {
            tempString = "$tempString${itemNames.title!}, ";
          }

          tempString = tempString.substring(0, tempString.length - 2);
          List<String> optionsFitter = _orderDetailFitter(tempString, leftColumnMaxChar);
          titleFitter.addAll(optionsFitter);

          for (String orderString in titleFitter) {
            _add(orderString, '', emptyStr);
          }
        }

        /// item Title - Price -----------------------------------------------
        final List<String> itemsFitted = _orderDetailFitter(items[i].itemTitle!, leftColumnMaxChar);
        for (var element in itemsFitted) {
          if (element == itemsFitted.first) {
            if (items[i].status!.statusCode == OrderItemStatusId.CANCEL.name) {
              addCenterText(byte, 'Iptal Edildi', bold: true);
            }
            final String totalPrice;
            if (items[i].totalPrice != null) {
              totalPrice = "${items[i].totalPrice!.toStringAsFixed(2)} TL".withoutDiacriticalMarks();
            } else {
              totalPrice = '';
            }
            _add('$countStr$element', _createColumnAndAlignLeft(5, totalPrice), '', true);
          } else {
            _add(element, '', emptyStr);
          }
        }

        /// options -----------------------------------------------
        if (items[i].options != null) {
          /// PRODUCT -----------------------------------------------
          if (items[i].itemTypeId == ItemType.PRODUCT.name) {
            /// options -----------------------------------------------
            for (OrderOption option in items[i].options!) {
              if (option.items?.isNotEmpty == true) {
                /// options item -----------------------------------------------
                _addOption(option.title!, option.items);
              }
            }
          } else if (items[i].itemTypeId == ItemType.PROMOTION_MENU.name) {
            /// PROMOTION_MENU -----------------------------------------------

            for (OrderOption option in items[i].options!) {
              /// section title -----------------------------------------------
              List<String> sectionTitleFitter = _orderDetailFitter(
                '-${option.sectionTitle!}:',
                leftColumnMaxChar,
              );
              for (String str in sectionTitleFitter) {
                _add(str, '', emptyStr, true);
              }

              /// section product name -----------------------------------------------
              List<String> productNameFitter = _orderDetailFitter(option.sectionItem!.productName!, leftColumnMaxChar);
              for (String str in productNameFitter) {
                _add(str, '', emptyStr);
              }

              /// options -----------------------------------------------
              for (OrderSectionItemOption sectionOption in option.sectionItem!.options!) {
                /// options item -----------------------------------------------
                _addOption(sectionOption.title!, sectionOption.items);
              }
            }
          }
        }

        /// item Note -----------------------------------------------
        if (items[i].itemNote?.isNotEmpty == true) {
          List<String> orderNoteStrings = _orderDetailFitter(
            'Müşteri Notu: ${items[i].itemNote!}',
            leftColumnMaxChar,
          );
          for (var orderNote in orderNoteStrings) {
            _add(orderNote, '', emptyStr);
          }
        }

        addEmptyLines(byte);
      }
    } catch (e) {
      rethrow;
    }
  }

  void addPaymentDetail(List<int> byte, PrinterQueueResponsePrintDataModel printData) {
    /// tip amount ------------------------------------------------------------------
    if (printData.totalTipAmount != null && printData.totalTipAmount != 0) {
      final totalTipAmount = '${printData.totalTipAmount?.toStringAsFixed(2)} TL';
      byte.addAll(
        generator.row([
          PosColumn(
            width: 12,
            text: _createTowColumn('Bahşiş: ', totalTipAmount),
            styles: const PosStyles(align: PosAlign.left, width: PosTextSize.size1),
          ),
        ]),
      );
    }

    /// service to table amount ------------------------------------------------------------------
    if (printData.tableServiceAmount != null && printData.tableServiceAmount != 0) {
      final tableServiceAmount = '${printData.tableServiceAmount?.toStringAsFixed(2)} TL';
      byte.addAll(
        generator.row([
          PosColumn(
            width: 12,
            text: _createTowColumn('Masaya Servis: ', tableServiceAmount),
            styles: const PosStyles(align: PosAlign.left, width: PosTextSize.size1),
          ),
        ]),
      );
    }

    /// total amount ------------------------------------------------------------------
    final double totalAmount;
    if (printData.orders!.first.orderPointId == OrderPoint.TABLE.name) {
      totalAmount = printData.serviceTotalAmount!;
    } else {
      totalAmount = printData.orders!.first.totalAmount!;
    }
    byte.addAll(
      generator.row([
        PosColumn(
          width: 12,
          text: _createTowColumn('TOPLAM TUTAR: ', '${totalAmount.toStringAsFixed(2)} TL'),
          styles: const PosStyles(align: PosAlign.left, width: PosTextSize.size1),
        ),
      ]),
    );
  }

  void addFooter(List<int> byte, PrinterQueueDealerInfoModel? dealerIndo) {
    /// dealer name ------------------------------------------------------------------
    byte.addAll(
      generator.row([
        PosColumn(width: 1, text: '', styles: const PosStyles(align: PosAlign.left)),
        PosColumn(
          width: 10,
          text: (dealerIndo?.dealerName ?? SipPrinter.instance.headerTitle).toString().withoutDiacriticalMarks(),
          styles: const PosStyles(align: PosAlign.center, width: PosTextSize.size1),
        ),
        PosColumn(width: 1, text: '', styles: const PosStyles(align: PosAlign.left)),
      ]),
    );

    /// dealer address ------------------------------------------------------------------
    byte.addAll(
      generator.row([
        PosColumn(width: 1, text: '', styles: const PosStyles(align: PosAlign.left)),
        PosColumn(
          width: 10,
          text: (dealerIndo?.address ?? SipPrinter.instance.footerTitle).toString().withoutDiacriticalMarks(),
          styles: const PosStyles(align: PosAlign.center, width: PosTextSize.size1),
        ),
        PosColumn(width: 1, text: '', styles: const PosStyles(align: PosAlign.left)),
      ]),
    );
  }

  void addEmptyLines(List<int> byte) {
    byte.addAll(generator.emptyLines(1));
  }

  void addCenterText(
    List<int> byte,
    String title, {
    PosTextSize height = PosTextSize.size1,
    PosTextSize width = PosTextSize.size1,
    bool bold = false,
  }) {
    /// slip title ------------------------------------------------------------------
    byte.addAll(
      generator.row([
        PosColumn(width: 1, text: '', styles: const PosStyles(align: PosAlign.left)),
        PosColumn(
          width: 10,
          text: title.withoutDiacriticalMarks(),
          styles: PosStyles(
            align: PosAlign.center,
            bold: bold,
            width: width,
            height: height,
          ),
        ),
        PosColumn(width: 1, text: '', styles: const PosStyles(align: PosAlign.left)),
      ]),
    );
  }

  void cut(List<int> byte) {
    byte.addAll(generator.cut(mode: PosCutMode.partial));
  }

  PosTextSize getSize(String? size) {
    if (size == PrinterFontSizeEnum.XL.name) {
      return PosTextSize.size5;
    } else if (size == PrinterFontSizeEnum.LG.name) {
      return PosTextSize.size4;
    } else if (size == PrinterFontSizeEnum.MD.name) {
      return PosTextSize.size3;
    } else if (size == PrinterFontSizeEnum.SM.name) {
      return PosTextSize.size2;
    } else {
      return PosTextSize.size1;
    }
  }

  /// tek satırda iki sütün oluşturur
  String _createTowColumn(String col1, String col2) =>
      (col1 + (' ' * (maxLineCharacterCount - col2.length - col1.length)) + col2).withoutDiacriticalMarks();

  /// Sütün de kullanılmakta, verilen metini sola hizalar
  /// ratio: istenilen sütünün weghit i
  /// col2: sütünde gösterilen metin
  String _createColumnAndAlignLeft(int ratio, String col2) =>
      ((' ' * (((maxLineCharacterCount / 12) * ratio) - col2.length).truncate()) + col2).withoutDiacriticalMarks();

  void addSeparator(List<int> byte) {
    byte.addAll(
      generator.text(
        '-' * maxLineCharacterCount,
        styles: const PosStyles(align: PosAlign.left),
      ),
    );
  }

  List<String> _orderDetailFitter(String orderDetail, int maxLength) {
    List<String> tempList = [""];
    List<String> productWordsList = orderDetail.split(" ");
    for (int i = 0; i < productWordsList.length; i++) {
      final tempStr = "${tempList.last} ${productWordsList[i]}".trim();
      if (tempStr.length <= maxLength) {
        tempList.last = tempStr;
      } else {
        tempList.add(productWordsList[i]);
      }
    }
    return tempList;
  }

  void addTowColumn(List<int> byte, String col1, String col2) {
    byte.addAll(
      generator.row([
        PosColumn(
          width: 12,
          text: _createTowColumn(col1, col2),
          styles: const PosStyles(align: PosAlign.left, width: PosTextSize.size1),
        ),
      ]),
    );
  }

  Future<void> addInvoiceQRLink(List<int> byte, String link) async {
    await addQR(byte, link);
    byte.addAll(
      generator.text(
        'E-Belgeye erişmek için'.withoutDiacriticalMarks(),
        styles: const PosStyles(align: PosAlign.center),
      ),
    );
    byte.addAll(
      generator.text(
        'yukarıdaki QR kodu okutunuz.'.withoutDiacriticalMarks(),
        styles: const PosStyles(align: PosAlign.center),
      ),
    );
  }

  Future<void> addQR(List<int> byte, String link, {double size = 150}) async {
    try {
      /// ilk qr kodu düzgün çıkartmadığı için ilk önce küçük bir qr code basıyoruz
      final tempUiImg = await QrPainter(
        data: link,
        version: QrVersions.auto,
        gapless: true,
      ).toImageData(2);
      byte.addAll(generator.image(img.decodeImage(tempUiImg!.buffer.asUint8List())!));

      final uiImg = await QrPainter(
        data: link,
        version: QrVersions.auto,
        gapless: true,
      ).toImageData(size);
      final image = img.decodeImage(uiImg!.buffer.asUint8List());
      byte.addAll(generator.image(image!));
    } catch (e) {
      byte.addAll(
        generator.text(
          link.withoutDiacriticalMarks(),
          styles: const PosStyles(align: PosAlign.center),
        ),
      );
    }
  }

  Future<void> add3PartLogo(List<int> byte, String? clientPointId) async {
    final is3PartOrder = ThirdPartClientPointId.values.firstWhereOrNull((e) => e.name == clientPointId);
    try {
      final String assetsPath;
      switch (is3PartOrder) {
        case null:
          return;
        case ThirdPartClientPointId.MIGROSYEMEK:
          assetsPath = 'packages/sip_printer/assets/logo/migrosyemek_logo.jpg';
          break;
        case ThirdPartClientPointId.GETIR:
          assetsPath = 'packages/sip_printer/assets/logo/getiryemek_logo.jpg';
          break;
        case ThirdPartClientPointId.TRENDYOL:
          assetsPath = 'packages/sip_printer/assets/logo/trendyolyemek_logo.jpg';
          break;
        case ThirdPartClientPointId.YEMEKSEPETI:
          assetsPath = 'packages/sip_printer/assets/logo/yemeksepeti_logo.jpg';
          break;
      }

      final ByteData data = await rootBundle.load(assetsPath);
      final Uint8List imageBytes = data.buffer.asUint8List();
      final decodedImage = img.decodeImage(imageBytes)!;
      final grayscaleImage = img.grayscale(decodedImage);
      final _imageRaster = generator.imageRaster(grayscaleImage, align: PosAlign.center);
      byte.addAll(_imageRaster);
    } catch (e) {
      addReceiptTitle(byte, clientPointId!);
    }
  }
}
