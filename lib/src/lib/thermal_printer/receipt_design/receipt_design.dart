import 'package:flutter/material.dart';
import 'package:sip_models/enum.dart';
import 'package:sip_models/ri_enum.dart';
import 'package:sip_printer/src/extanstion/date_time_extension.dart';
import 'package:sip_printer/src/extanstion/extension_string.dart';
import 'package:sip_printer/src/extanstion/general_extenstion.dart';
import 'design_functions.dart';
import 'package:sip_models/ri_models.dart';

class ReceiptDesign extends DesignFunctions {
  ReceiptDesign(super.generator, super._paperSize);

  Future<List<int>> createReceiptForTakeout(PrinterQueueResponseModel printData) async {
    try {
      List<int> byte = [];

      final order = printData.printData!.orders!.first;

      /// MarketPlace logo ------------------------------------------------------------------
      await add3PartLogo(byte, order.clientPointId);
      addEmptyLines(byte);

      /// title ------------------------------------------------------------------
      addReceiptTitle(byte, 'PAKET');
      addEmptyLines(byte);

      /// header ------------------------------------------------------------------
      addOrderHeader(byte, order, printCustomerPhoneNo: true, printCustomerAddress: true);

      /// Order Item ------------------------------------------------------------------
      addSeparator(byte);
      createColumnFromOrderDetail(byte, order.items!);
      addSeparator(byte);

      /// total amount ------------------------------------------------------------------
      addPaymentDetail(byte, printData.printData!);
      addEmptyLines(byte);

      /// dealer name ------------------------------------------------------------------
      addFooter(byte, printData.printData!.dealerInfo);

      cut(byte);
      return byte;
    } catch (e) {
      rethrow;
    }
  }

  Future<List<int>> createReceiptForTakeoutWidget(PrinterQueueResponseModel printData) async {
    try {
      final List<Widget> widgetList = [];

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

      final image = await createImageFromWidget(
        Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: widgetList,
        ),
      );

      return convertImageToByteAndCut(image);
    } catch (e) {
      rethrow;
    }
  }

  List<int> createReceiptForGetIn(PrinterQueueResponseModel printData) {
    try {
      List<int> byte = [];

      /// title ------------------------------------------------------------------
      addReceiptTitle(byte, 'GEL AL');
      addEmptyLines(byte);

      final order = printData.printData!.orders!.first;

      /// header ------------------------------------------------------------------
      addOrderHeader(byte, order);

      /// Order Item ------------------------------------------------------------------
      addSeparator(byte);
      createColumnFromOrderDetail(byte, order.items!);
      addSeparator(byte);

      /// total amount ------------------------------------------------------------------
      addPaymentDetail(byte, printData.printData!);
      addEmptyLines(byte);

      /// footer ------------------------------------------------------------------
      addFooter(byte, printData.printData!.dealerInfo);

      cut(byte);
      return byte;
    } catch (e) {
      rethrow;
    }
  }

  Future<List<int>> createReceiptForGetInWidget(PrinterQueueResponseModel printData) async {
    try {
      final List<Widget> widgetList = [];

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

      final image = await createImageFromWidget(
        Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: widgetList,
        ),
      );

      return convertImageToByteAndCut(image);
    } catch (e) {
      rethrow;
    }
  }

  /// sipariş fişi
  Future<List<int>> createReceiptForTable(PrinterQueueResponseModel printData) async {
    try {
      List<int> byte = [];

      /// Title ------------------------------------------------------------------
      final String title;
      if (printData.isRevision == true) {
        title = "REVİZE FİŞ";
      } else if (printData.paymentModelId == PaymentModelID.PRE.name) {
        title = "SELF SERVİS FİŞİ";
      } else {
        title = "SİPARİŞ FİŞİ";
      }
      addReceiptTitle(byte, title);
      addEmptyLines(byte);

      /// Header ------------------------------------------------------------------
      if (printData.headers!.isNotEmpty) {
        for (var element in printData.headers!) {
          final size = getSize(element.style);
          addCenterText(byte, element.text ?? '', width: size, height: size);
        }
        addEmptyLines(byte);
      }

      /// order header ------------------------------------------------------------------
      addHeader(byte, printData.printData!);

      /// Orders ------------------------------------------------------------------
      for (var order in printData.printData!.orders!) {
        /// order header ------------------------------------------------------------------
        addOrderHeader(byte, order, printPayment: false);
        addSeparator(byte);

        /// order item ------------------------------------------------------------------
        createColumnFromOrderDetail(byte, order.items!);
        addSeparator(byte);

        /// Invoice QR Link
        /// birden fazla order varsa her order için ayrı ayrı qr basar bitane order varsa fişin sonunda bitane qr basar
        if (printData.printData!.orders!.length > 1 && order.invoiceSuccessLink != null) {
          await addInvoiceQRLink(byte, order.invoiceSuccessLink!);
          addSeparator(byte);
        }
      }

      /// payment ------------------------------------------------------------------
      addPaymentDetail(byte, printData.printData!);
      addEmptyLines(byte);

      /// Invoice QR Link ------------------------------------------------------------------
      /// birden fazla order varsa her order için ayrı ayrı qr basar bitane order varsa fişin sonunda bitane qr basar
      if (printData.printData!.orders!.length == 1 && printData.printData!.orders!.first.invoiceSuccessLink != null) {
        addSeparator(byte);
        await addInvoiceQRLink(byte, printData.printData!.orders!.first.invoiceSuccessLink!);
        addSeparator(byte);
      }

      /// api footer ------------------------------------------------------------------
      for (var element in printData.footers!) {
        final size = getSize(element.style);
        addCenterText(byte, element.text ?? '', width: size, height: size);
      }
      if (printData.footers!.isNotEmpty) addEmptyLines(byte);

      /// footer ------------------------------------------------------------------
      addFooter(byte, printData.printData!.dealerInfo);
      cut(byte);
      return byte;
    } catch (e) {
      rethrow;
    }
  }

  /// sipariş fişi
  Future<List<int>> createReceiptForTableWidget(PrinterQueueResponseModel printData) async {
    try {
      final List<Widget> widgetList = [];

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
          await addInvoiceQRLinkWidget(widgetList, order.invoiceSuccessLink!);
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
        await addInvoiceQRLinkWidget(widgetList, printData.printData!.orders!.first.invoiceSuccessLink!);
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

      final image = await createImageFromWidget(
        Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: widgetList,
        ),
      );

      return convertImageToByteAndCut(image);
    } catch (e) {
      rethrow;
    }
  }

  /// kasa fişi
  List<int> createReceiptForCashRegister(PrinterQueueResponseModel printData) {
    try {
      List<int> byte = [];

      /// slip title ------------------------------------------------------------------
      addReceiptTitle(byte, "KASA FİŞİ");
      addEmptyLines(byte);

      /// header ------------------------------------------------------------------
      addHeader(
        byte,
        printData.printData!,
        printTableNo: printData.printData!.paymentModelId == PaymentModelID.POST.name ||
            printData.printData!.serviceDeliveryType == TableServiceType.TABLE.name,
        printPayment: true,
      );

      for (var order in printData.printData!.orders!) {
        /// order header ------------------------------------------------------------------
        addOrderHeader(byte, order, printPayment: false);
        addSeparator(byte);

        /// order detail ------------------------------------------------------------------
        createColumnFromOrderDetail(byte, order.items!);
        addSeparator(byte);
      }

      /// payment detail ------------------------------------------------------------------
      addPaymentDetail(byte, printData.printData!);
      addEmptyLines(byte);

      /// footer ------------------------------------------------------------------
      addFooter(byte, printData.printData!.dealerInfo);
      cut(byte);
      return byte;
    } catch (e) {
      rethrow;
    }
  }

  /// kasa fişi
  Future<List<int>> createReceiptForCashRegisterWidget(PrinterQueueResponseModel printData) async {
    try {
      final List<Widget> widgetList = [];

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

      final image = await createImageFromWidget(
        Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: widgetList,
        ),
      );

      return convertImageToByteAndCut(image);
    } catch (e) {
      rethrow;
    }
  }

  /// masa adisyonu
  List<int> createReceiptForTableBill(PrinterQueueResponseModel printData) {
    try {
      List<int> byte = [];

      /// slip title ------------------------------------------------------------------
      addReceiptTitle(byte, "MASA ADİSYONU");
      addEmptyLines(byte);

      /// header ------------------------------------------------------------------
      addHeader(byte, printData.printData!);

      for (var order in printData.printData!.orders!) {
        /// order header ------------------------------------------------------------------
        addOrderHeader(byte, order, printPayment: false);
        addSeparator(byte);

        /// order detail ------------------------------------------------------------------
        createColumnFromOrderDetail(byte, order.items!);
        addSeparator(byte);
      }

      /// payment detail ------------------------------------------------------------------
      addPaymentDetail(byte, printData.printData!);
      addEmptyLines(byte);

      /// footer ------------------------------------------------------------------
      addFooter(byte, printData.printData!.dealerInfo);
      cut(byte);
      return byte;
    } catch (e) {
      rethrow;
    }
  }

  /// masa adisyonu
  Future<List<int>> createReceiptForTableBillWidget(PrinterQueueResponseModel printData) async {
    try {
      final List<Widget> widgetList = [];

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

      final image = await createImageFromWidget(
        Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: widgetList,
        ),
      );

      return convertImageToByteAndCut(image);
    } catch (e) {
      rethrow;
    }
  }

  /// print Report
  List<int> createReceiptForReport(DailyReportModel printModel) {
    try {
      List<int> byte = [];

      /// slip title ------------------------------------------------------------------
      addReceiptTitle(byte, "GÜN SONU");
      addEmptyLines(byte);

      /// startDate ------------------------------------------------------------------
      final startDate = DateTime.parse(printModel.startDate!).formatDateTimeForTipListView();
      final endDate = DateTime.parse(printModel.endDate!).formatDateTimeForTipListView();
      if (startDate == endDate) {
        addTowColumn(byte, 'Tarih: ', startDate);
      } else {
        addTowColumn(byte, 'Başlangıç Tarihi: ', startDate);
        addTowColumn(byte, 'Bitiş Tarihi: ', endDate);
      }
      addEmptyLines(byte);

      /// Ödeme Tipi ------------------------------------------------------------------
      addTowColumn(byte, 'AdetXÖdeme Tipi', 'Tutar');
      addSeparator(byte);
      for (var model in printModel.paymentTypes!) {
        final title =
            model.paymentType!.enumFromString<PaymentTypeEnum>(PaymentTypeEnum.values)?.title ?? model.paymentType!;
        addTowColumn(byte, '${model.count}X$title', '${model.turnover?.getPrice()}');
      }
      addEmptyLines(byte);

      /// Sipariş Durum ------------------------------------------------------------------
      addTowColumn(byte, 'AdetXSipariş Durum', 'Tutar');
      addSeparator(byte);
      for (var model in printModel.statusTypes!) {
        final title = model.statusType!.enumFromString<AllOrderTypeStatusEnum>(AllOrderTypeStatusEnum.values)?.title ??
            model.statusType!;
        addTowColumn(byte, '${model.count}X$title', '${model.turnover?.getPrice()}');
      }
      addEmptyLines(byte);

      /// Ürünler ------------------------------------------------------------------
      addTowColumn(byte, 'AdetXÜrün Adı', 'Tutar');
      addSeparator(byte);
      for (var model in printModel.orderItems!) {
        addTowColumn(byte, '${model.count}X${model.title}', '${model.turnover?.getPrice()}');
      }
      addEmptyLines(byte);

      /// Footer ------------------------------------------------------------------
      addFooter(byte, null);
      cut(byte);
      return byte;
    } catch (e) {
      rethrow;
    }
  }

  /// print Report
  Future<List<int>> createReceiptForReportWidget(DailyReportModel printModel) async {
    try {
      final List<Widget> widgetList = [];

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

      final image = await createImageFromWidget(
        Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: widgetList,
        ),
      );

      return convertImageToByteAndCut(image);
    } catch (e) {
      rethrow;
    }
  }

  Future<List<int>> printKitchenOrderByWidget(PrinterQueueResponseModel printData) async {
    final List<Widget> widgetList = [];

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
      widgetList.add(createColumnFromOrderDetailWidget(order.items!, isPriceVisible: false));

      if (i < printData.printData!.orders!.length - 1) addSeparatorWidget(widgetList);
    }

    final image = await createImageFromWidget(
      Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: widgetList,
      ),
    );

    return convertImageToByteAndCut(image);
  }

  Future<List<int>> testTicket() async {
    List<int> byte = [];
    await addQR(byte, 'https://siparisim.com.tr/');
    addEmptyLines(byte);
    addFooter(byte, null);
    addEmptyLines(byte);
    cut(byte);
    return byte;
  }

  Future<List<int>> testTicketWidget() async {
    try {
      final List<Widget> widgetList = [];

      /// QR ------------------------------------------------------------------
      await addInvoiceQRLinkWidget(
        widgetList,
        'https://siparisim.com.tr/',
      );

      addEmptyLinesWidget(widgetList);

      /// 3. parti logo ------------------------------------------------------------------
      // await add3PartLogoWidget(
      //   widgetList,
      //   ThirdPartClientPointId.GETIR.name,
      // );
      // addEmptyLinesWidget(widgetList);

      // await add3PartLogoWidget(
      //   widgetList,
      //   ThirdPartClientPointId.MIGROSYEMEK.name,
      // );
      // addEmptyLinesWidget(widgetList);

      // await add3PartLogoWidget(
      //   widgetList,
      //   ThirdPartClientPointId.YEMEKSEPETI.name,
      // );
      // addEmptyLinesWidget(widgetList);

      // await add3PartLogoWidget(
      //   widgetList,
      //   ThirdPartClientPointId.TRENDYOL.name,
      // );
      // addEmptyLinesWidget(widgetList);

      /// Footer ------------------------------------------------------------------
      addFooterWidget(widgetList, null);
      addEmptyLinesWidget(widgetList);

      final image = await createImageFromWidget(
        Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: widgetList,
        ),
      );

      return convertImageToByteAndCut(image);
    } catch (e) {
      rethrow;
    }
  }
}
