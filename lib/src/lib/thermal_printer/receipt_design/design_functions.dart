import 'dart:async';
import 'dart:typed_data';

import 'package:collection/collection.dart';
import 'package:flutter/services.dart' show rootBundle;
import 'package:image/image.dart' as img;
import 'package:intl/intl.dart' show DateFormat;
import 'package:pdf/pdf.dart';
import 'package:pdf/widgets.dart' as pw;
import 'package:printing/printing.dart' show Printing;
import 'package:sip_models/enum.dart';
import 'package:sip_models/request.dart';
import 'package:sip_models/ri_enum.dart';
import 'package:sip_models/ri_models.dart';
import 'package:sip_printer/src/extanstion/extension_string.dart';
import 'package:sip_printer/src/extanstion/general_extenstion.dart';

import '../../../sip_printer.dart';

abstract class DesignFunctions {
  late final PrinterPaperTypeEnum paperSize;

  /// Piksel genişliği (203 dpi'da 80mm = 576, 58mm = 384)
  late final double paperWidth;

  /// Kağıt kenar boşluğu (PDF birimi)
  static const double _horizontalPadding = 8;

  /// PDF -> image çözünürlüğü. 72 dpi = 1 pt = 1 px.
  /// Yüksek dpi ile render edilip sonra yazıcı genişliğine küçültülür (daha net çıktı).
  static const double _rasterDpi = 72;

  /// Font asset yolları (Türkçe karakter desteği için TTF şart)

  DesignFunctions(this.paperSize) {
    paperWidth = paperSize == PrinterPaperTypeEnum.mm80 ? 576 : 384;
  }

  pw.FontWeight _w(bool bold) => bold ? pw.FontWeight.bold : pw.FontWeight.normal;

  void addTextWidget(
    List<pw.Widget> list,
    String title, {
    double? fontSize = 32,
    pw.FontWeight? fontWeight,
    pw.TextAlign textAlign = pw.TextAlign.center,
  }) {
    list.add(
      pw.SizedBox(
        width: paperWidth - _horizontalPadding * 2,
        child: pw.Text(
          title,
          style: pw.TextStyle(fontSize: fontSize, fontWeight: fontWeight, height: 1.2),
          textAlign: textAlign,
        ),
      ),
    );
  }

  void addEmptyLinesWidget(List<pw.Widget> list, {int count = 1}) {
    list.addAll(List.generate(count, (_) => pw.SizedBox(height: 38)));
  }

  void addReceiptTitleWidget(List<pw.Widget> list, String title) {
    addTextWidget(list, title, fontWeight: pw.FontWeight.bold, fontSize: 50);
  }

  /// Kesik çizgili ayraç
  void addSeparatorWidget(List<pw.Widget> list) {
    final w = paperWidth - _horizontalPadding * 2;
    list.add(
      pw.SizedBox(
        width: w,
        height: 12,
        child: pw.CustomPaint(
          size: PdfPoint(w, 12),
          painter: (PdfGraphics canvas, PdfPoint size) {
            canvas
              ..setStrokeColor(PdfColors.black)
              ..setLineWidth(1.6)
              ..setLineDashPattern([6, 4])
              ..drawLine(0, size.y / 2, size.x, size.y / 2)
              ..strokePath();
          },
        ),
      ),
    );
  }

  pw.Widget addRowWidget(
    String col1,
    String col2, {
    int flex1 = 5,
    int flex2 = 6,
    int? col1MaxLines,
  }) {
    return pw.SizedBox(
      width: paperWidth - _horizontalPadding * 2,
      child: pw.Row(
        crossAxisAlignment: pw.CrossAxisAlignment.start,
        children: [
          pw.Expanded(
            flex: flex1,
            child: pw.Text(
              col1,
              style: const pw.TextStyle(fontSize: 32, height: 1.2),
              maxLines: col1MaxLines,
            ),
          ),
          pw.Expanded(
            flex: flex2,
            child: pw.Text(
              col2,
              style: const pw.TextStyle(fontSize: 32, height: 1.2),
              textAlign: pw.TextAlign.right,
            ),
          ),
        ],
      ),
    );
  }

  void addTowColumnWidget(List<pw.Widget> widgetList, String col1, String col2) =>
      widgetList.add(addRowWidget(col1, col2));

  void addHeaderWidget(
    List<pw.Widget> widgetList,
    PrinterQueueResponsePrintDataModel printData, {
    bool printTableNo = true,
    bool printPayment = false,
  }) {
    if (printData.paymentModelId == PaymentModelID.PRE.name) {
      /// Sıra numarası
      if (printData.numberOfService != null) {
        addReceiptTitleWidget(widgetList, 'Sıra Numarası');
        addReceiptTitleWidget(widgetList, printData.numberOfService.toString());
        addEmptyLinesWidget(widgetList);
      }

      /// Pleksi numarası
      if (printData.pleksiNumber != null) {
        addReceiptTitleWidget(widgetList, 'Pleksi Numarası');
        addReceiptTitleWidget(widgetList, printData.pleksiNumber.toString());
        addEmptyLinesWidget(widgetList);
      }

      /// service type
      final String? txt = printData.serviceDeliveryType?.enumFromString(TableServiceType.values)?.title;
      if (txt != null) {
        widgetList.add(addRowWidget('Servis Tipi: ', txt));
      }
    }

    /// table no
    if (printTableNo) {
      widgetList.add(addRowWidget('Masa: ', printData.tableInfo?.tableName ?? '-'));
    }

    /// payment type
    if (printPayment) {
      widgetList.add(addRowWidget('Ödeme Tipi: ', printData.paymentType ?? '-'));
    }
  }

  void addOrderHeaderWidget(
    List<pw.Widget> widgetList,
    PrinterQuequeResponseOrderModel order, {
    bool printPayment = true,
    bool printCustomerPhoneNo = false,
    bool printCustomerAddress = false,
  }) {
    if (order.orderStatus?.orderStatusGroupId == OrderStatusGroup.CANCEL.name) {
      addSeparatorWidget(widgetList);
      addTextWidget(widgetList, 'Iptal Edildi', fontWeight: pw.FontWeight.bold, fontSize: 50);
      addSeparatorWidget(widgetList);
    }

    /// payment type
    if (printPayment && order.paymentInfo != null) {
      widgetList.add(addRowWidget('Ödeme Tipi: ', '${order.paymentInfo?.name}'));

      final String isPayedStr = order.paymentInfo?.isOnlinePayment == null
          ? 'null'
          : order.paymentInfo!.isOnlinePayment == true
              ? 'Yapıldı'
              : 'Yapılmadı';
      widgetList.add(addRowWidget('Ödeme Durumu: ', isPayedStr, flex1: 1, flex2: 1));
    }

    /// order no
    widgetList.add(addRowWidget('Sipariş No: ', order.id.toString()));

    /// create date
    final date = DateFormat('dd.MM.yyyy HH:mm').format(order.recordDate ?? DateTime.now());
    widgetList.add(addRowWidget('Tarih: ', date));

    /// işlem no
    if ((order.prefixedOrderNumber ?? '').isNotEmpty) {
      widgetList.add(addRowWidget('İşlem No: ', order.prefixedOrderNumber!));
    }

    final List<pw.Widget> customerInfoList = [];
    addSeparatorWidget(customerInfoList);

    /// customer name
    if ((order.customer?.nameSurname?.trim() ?? '').isNotEmpty) {
      customerInfoList.add(addRowWidget('Müşteri: ', order.customer!.nameSurname!));
    }

    /// Customer Phone no
    if (printCustomerPhoneNo && order.customer?.phoneNumber != null) {
      customerInfoList.add(addRowWidget('Telefon No: ', '${order.customer?.phoneNumber}'));
    }

    /// Customer Address
    if (printCustomerAddress) {
      addEmptyLinesWidget(customerInfoList);
      addTextWidget(
        customerInfoList,
        'Adres: ${order.customerAddress?.getFullAddress ?? '-'}',
        textAlign: pw.TextAlign.left,
        fontWeight: pw.FontWeight.bold,
      );
    }

    /// Customer Note
    if (order.orderNote?.isNotEmpty == true) {
      addEmptyLinesWidget(customerInfoList);
      addTextWidget(
        customerInfoList,
        'Sipariş Notu: ${order.orderNote}',
        textAlign: pw.TextAlign.left,
        fontWeight: pw.FontWeight.bold,
      );
    }

    if (customerInfoList.length > 1) widgetList.addAll(customerInfoList);
  }

  /// Fiyat widget'ı (eski PriceTextWidget'ın PDF karşılığı).
  /// - ikram:    üstü çizili fiyat + "İkram"
  /// - indirim:  üstü çizili eski fiyat + güncel fiyat
  /// - normal:   sadece fiyat
  pw.Widget _priceWidget({
    required double price,
    double? discountPrice,
    bool isComplimentary = false,
  }) {
    const double size = 32;
    pw.Widget text(String s, {bool strike = false, bool bold = true, double fs = size}) => pw.Text(
          s,
          textAlign: pw.TextAlign.right,
          style: pw.TextStyle(
            fontSize: fs,
            height: 1,
            fontWeight: _w(bold),
            decoration: strike ? pw.TextDecoration.lineThrough : null,
          ),
        );

    final children = <pw.Widget>[];
    if (isComplimentary) {
      children.add(text('İkram'));
      children.add(text(price.getPrice(), strike: true, bold: false));
    } else if (discountPrice != null && discountPrice != price) {
      children.add(text(discountPrice.getPrice(), strike: true, bold: false));
      children.add(text(price.getPrice()));
    } else {
      children.add(text(price.getPrice()));
    }

    return pw.Column(crossAxisAlignment: pw.CrossAxisAlignment.end, children: children);
  }

  pw.Widget createColumnFromOrderDetailWidget(
    List<PrinterQueueResponseOrderOrderItemModel> items, {
    String? orderStatusGroupId,
    bool isPriceVisible = true,
    bool printCancelItem = false,
  }) {
    final List<pw.Widget> children = [];

    pw.Widget row(
      String col1, {
      pw.Widget? col2Widget,
      pw.FontWeight fontWeight = pw.FontWeight.normal,
      double leftPadding = 0,
    }) {
      return pw.Padding(
        padding: pw.EdgeInsets.only(left: leftPadding),
        child: pw.Row(
          crossAxisAlignment: pw.CrossAxisAlignment.start,
          children: [
            pw.Expanded(
              flex: 8,
              child: pw.Text(
                col1,
                style: pw.TextStyle(fontSize: 34, fontWeight: fontWeight, height: 1.2),
              ),
            ),
            col2Widget != null
                ? pw.Expanded(
                    flex: 5,
                    child: pw.Align(alignment: pw.Alignment.centerRight, child: col2Widget),
                  )
                : pw.SizedBox(),
          ],
        ),
      );
    }

    List<pw.Widget> addOption(String title, List<OrderOptionItem>? items, double leftPadding) {
      if (items?.isNotEmpty != true) return [];
      final optionWidgets = <pw.Widget>[];
      optionWidgets.add(row('$title: ', leftPadding: leftPadding));

      final joined = items!.map((e) => e.title).join(', ');
      if (joined.isNotEmpty) {
        optionWidgets.add(row(joined, leftPadding: leftPadding));
      }
      return optionWidgets;
    }

    for (int i = 0; i < items.length; i++) {
      final item = items[i];
      final countStr = '${item.count}x';

      /// ITEM TITLE
      final isItemCancelled = item.status?.statusCode == OrderItemStatusId.CANCEL.name;
      final isOrderCancelled = orderStatusGroupId == OrderStatusGroup.CANCEL.name;

      if (isItemCancelled || isOrderCancelled) {
        // Mutfak fişi hariç diğer fiş türlerinde iptal edilen ürünler basılmaz.
        if (isItemCancelled && !printCancelItem) continue;

        children.add(
          pw.SizedBox(
            width: paperWidth - _horizontalPadding * 2,
            child: pw.Text(
              'İptal Edildi',
              textAlign: pw.TextAlign.center,
              style: const pw.TextStyle(fontSize: 34, fontWeight: pw.FontWeight.bold, height: 1.2),
            ),
          ),
        );
      }

      /// item Title - Price
      pw.Widget? price;
      if (isPriceVisible == true && item.totalPrice != null) {
        price = _priceWidget(
          price: item.totalPrice!,
          discountPrice:
              item.afterManualDiscountItemPrice ?? (item.isUseCampaign == true ? item.beforeCampaignItemPrice : null),
          isComplimentary: item.manualDiscountTypeId == ManuelDiscountType.giveaway.discountType,
        );
      }

      children.add(row('$countStr${item.itemTitle!}', col2Widget: price, fontWeight: pw.FontWeight.bold));
      children.add(pw.SizedBox(height: 10));

      /// options
      if (item.options != null) {
        if (item.itemTypeId == ItemType.PRODUCT.name) {
          for (final option in item.options!) {
            if (option.items?.isNotEmpty == true) {
              children.addAll(addOption(option.title!, option.items, countStr.length * 8));
              children.add(pw.SizedBox(height: 10));
            }
          }
        } else if (item.itemTypeId == ItemType.PROMOTION_MENU.name) {
          for (final option in item.options!) {
            /// section title
            children.add(row('-${option.sectionTitle!}:', leftPadding: countStr.length * 8));

            /// section product name
            children.add(row(option.sectionItem!.productName!, leftPadding: (countStr.length + 3) * 8));

            /// options
            for (final sectionOption in option.sectionItem!.options!) {
              children.addAll(addOption(sectionOption.title!, sectionOption.items, (countStr.length + 3) * 8));
            }
            children.add(pw.SizedBox(height: 10));
          }
        }
      }

      /// item Note
      if (item.itemNote?.isNotEmpty == true) {
        children.add(row(
          'Ürün Notu: ${item.itemNote!}',
          fontWeight: pw.FontWeight.bold,
          leftPadding: countStr.length * 8,
        ));
      }

      if (i != items.length - 1) children.add(pw.SizedBox(height: 18));
    }

    return pw.SizedBox(
      width: paperWidth - _horizontalPadding * 2,
      child: pw.Column(
        crossAxisAlignment: pw.CrossAxisAlignment.start,
        children: children,
      ),
    );
  }

  void addPaymentDetailWidget(
    List<pw.Widget> widgetList,
    PrinterQueueResponsePrintDataModel printData,
  ) {
    /// tip amount
    if (printData.totalTipAmount != null && printData.totalTipAmount != 0) {
      widgetList.add(
        addRowWidget(flex1: 3, flex2: 2, 'BAHŞİŞ:', '${printData.totalTipAmount?.toStringAsFixed(2)}TL'),
      );
    }

    /// service to table amount
    if (printData.tableServiceAmount != null && printData.tableServiceAmount != 0) {
      widgetList.add(
        addRowWidget(flex1: 3, flex2: 2, 'MASAYA SERVİS:', '${printData.tableServiceAmount?.toStringAsFixed(2)}TL'),
      );
    }

    /// indirim
    final List<pw.Widget> discounts = [];
    for (int i = 0; i < printData.orders!.length; i++) {
      final order = printData.orders![i];
      final campaign = order.campaigns!.firstOrNull;
      if (campaign != null) {
        discounts.add(
          addRowWidget(
            flex1: 3,
            flex2: 2,
            campaign.spotTitle!,
            '-${campaign.campaignAmount!.getPrice()} ',
            col1MaxLines: 1,
          ),
        );
      }

      if ([ManuelDiscountType.noDiscount.discountType, null].contains(order.manualDiscountTypeId) == false) {
        discounts.add(
          addRowWidget(flex1: 3, flex2: 2, 'İNDİRİM TUTARI:', '-${order.totalManualDiscount?.getPrice()}'),
        );
      }
    }

    if (discounts.isNotEmpty) {
      widgetList.add(
        addRowWidget(
          flex1: 3,
          flex2: 2,
          'TOPLAM TUTAR:',
          (printData.orders!.first.beforeCampaignTotal ?? 0).getPrice(),
        ),
      );
      widgetList.addAll(discounts);
    }

    /// total amount
    widgetList.add(
      addRowWidget(
        flex1: 3,
        flex2: 2,
        'ÖDENECEK TUTAR:',
        (printData.orders!.first.orderPointId == OrderPoint.TABLE.name
                ? printData.serviceTotalAmount ?? 0
                : printData.orders!.first.totalAmount ?? 0)
            .getPrice(),
      ),
    );
  }

  void addFooterWidget(
    List<pw.Widget> widgetList,
    PrinterQueueDealerInfoModel? dealerInfo,
  ) {
    /// dealer name
    addTextWidget(
      widgetList,
      (dealerInfo?.dealerName ?? SipPrinter.instance.headerTitle).toString(),
      fontSize: 34,
      fontWeight: pw.FontWeight.bold,
    );

    /// dealer address
    addTextWidget(
      widgetList,
      (dealerInfo?.address ?? SipPrinter.instance.footerTitle).toString(),
      fontSize: 34,
      fontWeight: pw.FontWeight.bold,
    );
  }

  void addInvoiceQRLinkWidget(List<pw.Widget> widgetList, String link) {
    try {
      widgetList.add(
        pw.Center(
          child: pw.Padding(
            padding: const pw.EdgeInsets.all(15),
            child: pw.BarcodeWidget(
              barcode: pw.Barcode.qrCode(),
              data: link,
              width: 300,
              height: 300,
              drawText: false,
            ),
          ),
        ),
      );

      addTextWidget(widgetList, 'E-Belgeye erişmek için', fontSize: 34, fontWeight: pw.FontWeight.bold);
      addTextWidget(widgetList, 'yukarıdaki QR kodu okutunuz.', fontSize: 34, fontWeight: pw.FontWeight.bold);
    } catch (e) {
      addTextWidget(widgetList, link, fontSize: 34, fontWeight: pw.FontWeight.bold);
    }
  }

  Future<void> add3PartLogoWidget(
    List<pw.Widget> widgetList,
    String? clientPointId,
  ) async {
    try {
      final is3PartOrder = ThirdPartClientPointId.values.firstWhereOrNull((e) => e.name == clientPointId);

      final String assetsPath;
      switch (is3PartOrder) {
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
        default:
          return;
      }

      final data = await rootBundle.load(assetsPath).timeout(const Duration(seconds: 3));
      final logo = pw.MemoryImage(data.buffer.asUint8List());

      widgetList.add(
        pw.Center(
          child: pw.Image(logo, width: 100, fit: pw.BoxFit.scaleDown),
        ),
      );
    } catch (e) {
      if (clientPointId != null) {
        addReceiptTitleWidget(widgetList, clientPointId);
      }
    }
  }

  double getSizeWidget(String? size) {
    if (size == PrinterFontSizeEnum.XL.name) {
      return 20;
    } else if (size == PrinterFontSizeEnum.LG.name) {
      return 18;
    } else if (size == PrinterFontSizeEnum.MD.name) {
      return 16;
    } else if (size == PrinterFontSizeEnum.SM.name) {
      return 14;
    } else {
      return 12;
    }
  }

  Future<(List<int>, img.Image)> createImageAndConvert(List<pw.Widget> widgets) async {
    final watch = Stopwatch()..start();
    print('createImageAndConvert: START');

    final pdfBytes = await buildPdf(widgets);
    print('createImageAndConvert: buildPdf = ${watch.elapsedMilliseconds} ms');

    watch.reset();
    final image = await pdfToImage(pdfBytes);
    print('createImageAndConvert: pdfToImage = ${watch.elapsedMilliseconds} ms');

    watch.reset();
    final bytes = _convertImageToByteAndCut(image);
    print('createImageAndConvert: ${watch.elapsedMilliseconds} ms | bytes=${bytes.length}');

    return (bytes, image);
  }

  Future<Uint8List> buildPdf(List<pw.Widget> widgets) async {
    final doc = pw.Document(
      theme: pw.ThemeData.withFont(
        base: SipPrinter.instance.regularFont,
        bold: SipPrinter.instance.boldFont,
      ),
    );

    doc.addPage(
      pw.Page(
        // height: infinity => sayfa içeriğin yüksekliğine göre uzar (rulo kağıt)
        pageFormat: PdfPageFormat(paperWidth, double.infinity, marginAll: 0),
        margin: const pw.EdgeInsets.symmetric(horizontal: _horizontalPadding, vertical: 8),
        build: (_) => pw.Column(
          crossAxisAlignment: pw.CrossAxisAlignment.start,
          children: widgets,
        ),
      ),
    );

    return doc.save();
  }

  List<int> _convertImageToByteAndCut(img.Image image) {
    final watch = Stopwatch()..start();

    final bytes = <int>[];
    bytes.addAll(imageToEscPosRaster(image));

    print(
      'generator.image: ${watch.elapsedMilliseconds} ms',
    );

    watch
      ..reset()
      ..start();

    // bytes.addAll(generator.cut());
    /*
    bytes.addAll(
      generator.beep(
        n: 1,
        duration: PosBeepDuration.beep300ms,
      ),
    );
*/

    // cut
    bytes.addAll([
      0x1D, // GS
      0x56, // V
      0x30, // 0 = Full cut
    ]);

    // beep
    bytes.addAll([0x1B, 0x42, 0x01, 0x06]);

    print('cut + beep: ${watch.elapsedMilliseconds} ms');

    return bytes;
  }

  Future<img.Image> pdfToImage(Uint8List pdfBytes) async {
    final watch = Stopwatch()..start();

    final raster = await Printing.raster(pdfBytes, dpi: _rasterDpi).first;
    print('pdfToImage: 1 (${watch.elapsedMilliseconds} ms)');

    watch.reset();
    final pngBytes = await raster.toPng();
    print('pdfToImage: 2 (${watch.elapsedMilliseconds} ms)');

    watch.reset();
    var image = img.decodeImage(pngBytes)!;
    print('pdfToImage: 3 ${image.width}x${image.height} (${watch.elapsedMilliseconds} ms)');

    watch.reset();
    if (image.width != paperWidth.toInt()) {
      image = img.copyResize(
        image,
        width: paperWidth.toInt(),
        interpolation: img.Interpolation.cubic,
      );
    }
    print('pdfToImage: 4 ${image.width}x${image.height} (${watch.elapsedMilliseconds} ms)');

    return image;
  }

  /// [threshold]   : 0-255, bu değerden koyu pikseller siyah basılır.
  /// [chunkHeight] : Bazı yazıcılar tek blokta çok yüksek resmi kabul etmez, bu yüzden parçalanır.
  List<int> imageToEscPosRaster(
    img.Image source, {
    int threshold = 160,
    int chunkHeight = 256,
  }) {
    final image = source.numChannels == 4 ? source : source.convert(numChannels: 4);

    final width = image.width;
    final height = image.height;
    final widthBytes = (width + 7) >> 3;
    final rgba = image.getBytes(order: img.ChannelOrder.rgba);

    final out = BytesBuilder(copy: false);

    for (int startY = 0; startY < height; startY += chunkHeight) {
      final h = (startY + chunkHeight > height) ? height - startY : chunkHeight;

      // GS v 0 m xL xH yL yH
      out.add([
        0x1D, 0x76, 0x30, 0x00, //
        widthBytes & 0xFF, (widthBytes >> 8) & 0xFF,
        h & 0xFF, (h >> 8) & 0xFF,
      ]);

      final block = Uint8List(widthBytes * h);

      for (int y = 0; y < h; y++) {
        final rowStart = (startY + y) * width * 4;
        final blockRow = y * widthBytes;

        for (int x = 0; x < width; x++) {
          final i = rowStart + x * 4;
          final a = rgba[i + 3];
          if (a < 128) continue; // şeffaf = beyaz

          final lum = (rgba[i] * 299 + rgba[i + 1] * 587 + rgba[i + 2] * 114) ~/ 1000;
          if (lum < threshold) {
            block[blockRow + (x >> 3)] |= 0x80 >> (x & 7);
          }
        }
      }

      out.add(block);
    }

    return out.takeBytes();
  }
}
