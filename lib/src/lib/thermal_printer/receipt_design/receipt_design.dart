import 'dart:math';

import 'package:esc_pos_utils_plus/esc_pos_utils_plus.dart';
import 'package:sip_models/enum.dart';
import 'package:sip_models/ri_enum.dart';
import 'package:sip_printer/src/extanstion/date_time_extension.dart';
import 'package:sip_printer/src/extanstion/extension_string.dart';
import 'package:sip_printer/src/extanstion/general_extenstion.dart';
import 'design_functions.dart';
import 'package:sip_models/ri_models.dart';

class ReceiptDesign extends DesignFunctions {
  ReceiptDesign(super.generator, super._paperSize);

  Future<List<int>> createReceiptForTakeAway(PrinterQueueResponseModel printData) async {
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

  /// sipariş fişi
  Future<List<int>> createReceiptForTable(PrinterQueueResponseModel printData) async {
    try {
      List<int> byte = [];

      /// Title ------------------------------------------------------------------
      final String title;
      if (printData.isRevision == true) {
        title = "Revize Fiş";
      } else if (printData.paymentModelId == PaymentModelID.PRE.name) {
        title = "Self Servis Fişi";
      } else {
        title = 'Sipariş Fişi';
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
  List<int> printKitchenOrder(KitchenOrderModel activeOrderList) {
    try {
      List<int> byte = [];

      /// slip title ------------------------------------------------------------------
      addReceiptTitle(byte, "MUTFAK FİŞİ");
      addEmptyLines(byte);

      /// Table name ------------------------------------------------------------------
      addTowColumn(byte, 'Masa: ', activeOrderList.orderInfo?.tableName ?? '');

      /// sipariş numarasının son 4 hanesi random sayıdır
      final String id = '${activeOrderList.orderId!}${(Random().nextInt(10000) + 1000)}';
      addTowColumn(byte, 'Sipariş No: ', id);
      addSeparator(byte);

      /// customer name ------------------------------------------------------------------
      String customerName = '${activeOrderList.firstName ?? ''} ${activeOrderList.lastName ?? ''}';
      if (customerName.trim().isNotEmpty) {
        addTowColumn(byte, 'Müşteri: ', customerName);
        addSeparator(byte);
      }

      /// prdocut detail ------------------------------------------------------------------
      createColumnFromOrderDetail(
        byte,
        activeOrderList.products!.map((e) => e.toPrinterQueueResponseOrderOrderItemModel()).toList(),
      );

      cut(byte);
      return byte;
    } catch (e) {
      rethrow;
    }
  }

  Future<List<int>> testTicket() async {
    List<int> byte = [];
    await addQR(byte, 'https://siparisim.com.tr/');
    addEmptyLines(byte);
    await add3PartLogo(byte, ThirdPartClientPointId.GETIR.name);
    addEmptyLines(byte);
    await add3PartLogo(byte, ThirdPartClientPointId.MIGROSYEMEK.name);
    addEmptyLines(byte);
    await add3PartLogo(byte, ThirdPartClientPointId.YEMEKSEPETI.name);
    addEmptyLines(byte);
    await add3PartLogo(byte, ThirdPartClientPointId.TRENDYOL.name);
    addEmptyLines(byte);
    addFooter(byte, null);
    addEmptyLines(byte);
    cut(byte);
    return byte;
  }
}
