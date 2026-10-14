import 'package:sip_models/enum.dart';
import 'package:sip_models/ri_enum.dart';
import 'package:sip_printer/src/extanstion/date_time_extension.dart';
import 'package:sip_printer/src/extanstion/extension_string.dart';
import 'package:sip_printer/src/extanstion/general_extenstion.dart';
import 'design_functions.dart';
import 'package:sip_models/ri_models.dart';
import 'package:image/image.dart' as img show Image;
import 'package:pdf/widgets.dart' as pw;

class ReceiptDesign extends DesignFunctions {
  ReceiptDesign(super._paperSize);

  Future<(List<int>, img.Image)> createReceiptForTakeout(PrinterQueueResponseModel printData) async {
    try {
      final List<pw.Widget> widgetList = [];

      final order = printData.printData!.orders!.first;

      /// MarketPlace logo ------------------------------------------------------------------
      await add3PartLogoWidget(widgetList, order.clientPointId);
      addEmptyLinesWidget(widgetList);

      /// title ------------------------------------------------------------------
      addReceiptTitleWidget(widgetList, 'PAKET');
      addEmptyLinesWidget(widgetList);

      /// header ------------------------------------------------------------------
      addOrderHeaderWidget(widgetList, order, printCustomerPhoneNo: true, printCustomerAddress: true);

      /// Order Item ------------------------------------------------------------------
      addSeparatorWidget(widgetList);
      widgetList.add(createColumnFromOrderDetailWidget(order.items!));
      addSeparatorWidget(widgetList);

      /// total amount ------------------------------------------------------------------
      addPaymentDetailWidget(widgetList, printData.printData!);
      addEmptyLinesWidget(widgetList, count: 2);

      /// dealer name ------------------------------------------------------------------
      addFooterWidget(widgetList, printData.printData!.dealerInfo);

      return await createImageAndConvert(widgetList);
    } catch (e) {
      rethrow;
    }
  }

  Future<(List<int>, img.Image)> createReceiptForGetIn(PrinterQueueResponseModel printData) async {
    try {
      final List<pw.Widget> widgetList = [];

      /// title ------------------------------------------------------------------
      addReceiptTitleWidget(widgetList, 'GEL AL');
      addEmptyLinesWidget(widgetList);

      final order = printData.printData!.orders!.first;

      /// header ------------------------------------------------------------------
      addOrderHeaderWidget(widgetList, order);

      /// Order Item ------------------------------------------------------------------
      addSeparatorWidget(widgetList);
      widgetList.add(createColumnFromOrderDetailWidget(order.items!));
      addSeparatorWidget(widgetList);

      /// total amount ------------------------------------------------------------------
      addPaymentDetailWidget(widgetList, printData.printData!);
      addEmptyLinesWidget(widgetList, count: 2);

      /// footer ------------------------------------------------------------------
      addFooterWidget(widgetList, printData.printData!.dealerInfo);

      return await createImageAndConvert(widgetList);
    } catch (e) {
      rethrow;
    }
  }

  /// sipariş fişi
  Future<(List<int>, img.Image)> createReceiptForTable(PrinterQueueResponseModel printData) async {
    try {
      final List<pw.Widget> widgetList = [];

      /// Title ------------------------------------------------------------------
      final String title;
      if (printData.isRevision == true) {
        title = "REVİZE FİŞ";
      } else if (printData.paymentModelId == PaymentModelID.PRE.name) {
        title = "SELF SERVİS FİŞİ";
      } else {
        title = "SİPARİŞ FİŞİ";
      }
      addReceiptTitleWidget(widgetList, title);
      addEmptyLinesWidget(widgetList);

      /// Header ------------------------------------------------------------------
      if (printData.headers!.isNotEmpty) {
        for (var element in printData.headers!) {
          final size = getSizeWidget(element.style);
          addTextWidget(widgetList, element.text ?? '', fontSize: size);
        }
        addEmptyLinesWidget(widgetList);
      }

      /// Order Header ------------------------------------------------------------------
      addHeaderWidget(widgetList, printData.printData!);

      /// Orders ------------------------------------------------------------------
      for (var order in printData.printData!.orders!) {
        /// Order Header ------------------------------------------------------------------
        addOrderHeaderWidget(widgetList, order, printPayment: false);
        addSeparatorWidget(widgetList);

        /// Order Item ------------------------------------------------------------------
        widgetList.add(createColumnFromOrderDetailWidget(order.items!));
        addSeparatorWidget(widgetList);

        /// Invoice QR Link
        /// birden fazla order varsa her order için ayrı ayrı qr basar
        if (printData.printData!.orders!.length > 1 && order.invoiceSuccessLink != null) {
          addInvoiceQRLinkWidget(widgetList, order.invoiceSuccessLink!);
          addSeparatorWidget(widgetList);
        }
      }

      /// Payment ------------------------------------------------------------------
      addPaymentDetailWidget(widgetList, printData.printData!);
      addEmptyLinesWidget(widgetList);

      /// Invoice QR Link ------------------------------------------------------------------
      /// birden fazla order varsa her order için ayrı ayrı qr basar
      /// bitane order varsa fişin sonunda bitane qr basar
      if (printData.printData!.orders!.length == 1 && printData.printData!.orders!.first.invoiceSuccessLink != null) {
        addSeparatorWidget(widgetList);
        addInvoiceQRLinkWidget(widgetList, printData.printData!.orders!.first.invoiceSuccessLink!);
        addSeparatorWidget(widgetList);
      }

      /// API Footer ------------------------------------------------------------------
      for (var element in printData.footers!) {
        final size = getSizeWidget(element.style);
        addTextWidget(widgetList, element.text ?? '', fontSize: size);
      }

      addEmptyLinesWidget(widgetList, count: 2);

      /// Footer ------------------------------------------------------------------
      addFooterWidget(widgetList, printData.printData!.dealerInfo);

      return await createImageAndConvert(widgetList);
    } catch (e) {
      rethrow;
    }
  }

  /// kasa fişi
  Future<(List<int>, img.Image)> createReceiptForCashRegister(PrinterQueueResponseModel printData) async {
    try {
      final List<pw.Widget> widgetList = [];

      /// slip title ------------------------------------------------------------------
      addReceiptTitleWidget(widgetList, "KASA FİŞİ");
      addEmptyLinesWidget(widgetList);

      /// header ------------------------------------------------------------------
      addHeaderWidget(
        widgetList,
        printData.printData!,
        printTableNo: printData.printData!.paymentModelId == PaymentModelID.POST.name ||
            printData.printData!.serviceDeliveryType == TableServiceType.TABLE.name,
        printPayment: true,
      );

      /// Orders ------------------------------------------------------------------
      for (var order in printData.printData!.orders!) {
        /// order header ------------------------------------------------------------------
        addOrderHeaderWidget(widgetList, order, printPayment: false);
        addSeparatorWidget(widgetList);

        /// order detail ------------------------------------------------------------------
        widgetList.add(createColumnFromOrderDetailWidget(order.items!));
        addSeparatorWidget(widgetList);
      }

      /// payment detail ------------------------------------------------------------------
      addPaymentDetailWidget(widgetList, printData.printData!);
      addEmptyLinesWidget(widgetList, count: 2);

      /// footer ------------------------------------------------------------------
      addFooterWidget(widgetList, printData.printData!.dealerInfo);

      return await createImageAndConvert(widgetList);
    } catch (e) {
      rethrow;
    }
  }

  /// masa adisyonu
  Future<(List<int>, img.Image)> createReceiptForTableBill(PrinterQueueResponseModel printData) async {
    try {
      final List<pw.Widget> widgetList = [];

      /// slip title ------------------------------------------------------------------
      addReceiptTitleWidget(widgetList, "MASA ADİSYONU");
      addEmptyLinesWidget(widgetList);

      /// header ------------------------------------------------------------------
      addHeaderWidget(widgetList, printData.printData!);

      /// Orders ------------------------------------------------------------------
      for (var order in printData.printData!.orders!) {
        /// order header ------------------------------------------------------------------
        addOrderHeaderWidget(widgetList, order, printPayment: false);
        addSeparatorWidget(widgetList);

        /// order detail ------------------------------------------------------------------
        widgetList.add(createColumnFromOrderDetailWidget(order.items!));
        addSeparatorWidget(widgetList);
      }

      /// payment detail ------------------------------------------------------------------
      addPaymentDetailWidget(widgetList, printData.printData!);
      addEmptyLinesWidget(widgetList, count: 2);

      /// footer ------------------------------------------------------------------
      addFooterWidget(widgetList, printData.printData!.dealerInfo);

      return await createImageAndConvert(widgetList);
    } catch (e) {
      rethrow;
    }
  }

  /// print Report
  Future<(List<int>, img.Image)> createReceiptForReport(DailyReportModel printModel) async {
    try {
      final List<pw.Widget> widgetList = [];

      /// slip title ------------------------------------------------------------------
      addReceiptTitleWidget(widgetList, "GÜN SONU");
      addEmptyLinesWidget(widgetList);

      /// startDate ------------------------------------------------------------------
      final startDate = DateTime.parse(printModel.startDate!).formatDateTimeForTipListView();
      final endDate = DateTime.parse(printModel.endDate!).formatDateTimeForTipListView();

      if (startDate == endDate) {
        addTowColumnWidget(widgetList, 'Tarih: ', startDate);
      } else {
        addTowColumnWidget(
          widgetList,
          'Başlangıç Tarihi: ',
          startDate,
        );
        addTowColumnWidget(
          widgetList,
          'Bitiş Tarihi: ',
          endDate,
        );
      }

      addEmptyLinesWidget(widgetList);

      /// Ödeme Tipi ------------------------------------------------------------------
      addTowColumnWidget(widgetList, 'AdetXÖdeme Tipi', 'Tutar');
      addSeparatorWidget(widgetList);

      for (var model in printModel.paymentTypes!) {
        final title =
            model.paymentType!.enumFromString<PaymentTypeEnum>(PaymentTypeEnum.values)?.title ?? model.paymentType!;

        addTowColumnWidget(
          widgetList,
          '${model.count}X$title',
          '${model.turnover?.getPrice()}',
        );
      }

      addEmptyLinesWidget(widgetList);

      /// Sipariş Durum ------------------------------------------------------------------
      addTowColumnWidget(widgetList, 'AdetXSipariş Durum', 'Tutar');
      addSeparatorWidget(widgetList);

      for (var model in printModel.statusTypes!) {
        final title = model.statusType!.enumFromString<AllOrderTypeStatusEnum>(AllOrderTypeStatusEnum.values)?.title ??
            model.statusType!;

        addTowColumnWidget(
          widgetList,
          '${model.count}X$title',
          '${model.turnover?.getPrice()}',
        );
      }

      addEmptyLinesWidget(widgetList);

      /// Ürünler ------------------------------------------------------------------
      addTowColumnWidget(widgetList, 'AdetXÜrün Adı', 'Tutar');
      addSeparatorWidget(widgetList);

      for (var model in printModel.orderItems!) {
        addTowColumnWidget(
          widgetList,
          '${model.count}X${model.title}',
          '${model.turnover?.getPrice()}',
        );
      }

      addEmptyLinesWidget(widgetList, count: 2);

      /// Footer ------------------------------------------------------------------
      addFooterWidget(widgetList, null);

      return await createImageAndConvert(widgetList);
    } catch (e) {
      rethrow;
    }
  }

  Future<(List<int>, img.Image)> createReceiptForKitchenOrder(PrinterQueueResponseModel printData) async {
    final List<pw.Widget> widgetList = [];

    /// slip title ------------------------------------------------------------------
    addReceiptTitleWidget(widgetList, 'MUTFAK FİŞİ');
    addEmptyLinesWidget(widgetList);

    /// order header ------------------------------------------------------------------
    addHeaderWidget(widgetList, printData.printData!);

    /// Orders ------------------------------------------------------------------
    for (int i = 0; i < printData.printData!.orders!.length; i++) {
      final order = printData.printData!.orders![i];

      /// order header ------------------------------------------------------------------
      addOrderHeaderWidget(widgetList, order, printPayment: false);
      addSeparatorWidget(widgetList);

      /// order item ------------------------------------------------------------------
      widgetList.add(createColumnFromOrderDetailWidget(
        order.items!,
        isPriceVisible: false,
        printCancelItem: true,
        orderStatusGroupId: order.orderStatus?.orderStatusGroupId,
      ));

      if (i < printData.printData!.orders!.length - 1) addSeparatorWidget(widgetList);
    }

    return await createImageAndConvert(widgetList);
  }

  Future<(List<int>, img.Image)> createReceiptForTest() async {
    try {
      final List<pw.Widget> widgetList = [];

      /// QR ------------------------------------------------------------------
      addInvoiceQRLinkWidget(
        widgetList,
        'https://siparisim.com.tr/',
      );

      addEmptyLinesWidget(widgetList);
      addTextWidget(widgetList, 'Siparisim', fontWeight: pw.FontWeight.bold);

      /// 3. parti logo ------------------------------------------------------------------
      await add3PartLogoWidget(
        widgetList,
        ThirdPartClientPointId.GETIR.name,
      );
      addEmptyLinesWidget(widgetList);
      addTextWidget(widgetList, 'Siparisim', fontWeight: pw.FontWeight.bold);

      await add3PartLogoWidget(
        widgetList,
        ThirdPartClientPointId.MIGROSYEMEK.name,
      );
      addEmptyLinesWidget(widgetList);
      addTextWidget(widgetList, 'Siparisim', fontWeight: pw.FontWeight.bold);

      await add3PartLogoWidget(
        widgetList,
        ThirdPartClientPointId.YEMEKSEPETI.name,
      );
      addEmptyLinesWidget(widgetList);
      addTextWidget(widgetList, 'Siparisim', fontWeight: pw.FontWeight.bold);

      await add3PartLogoWidget(
        widgetList,
        ThirdPartClientPointId.TRENDYOL.name,
      );
      addEmptyLinesWidget(widgetList);

      /// Footer ------------------------------------------------------------------
      addFooterWidget(widgetList, null);
      addEmptyLinesWidget(widgetList);

      return await createImageAndConvert(widgetList);
    } catch (e) {
      rethrow;
    }
  }
}
