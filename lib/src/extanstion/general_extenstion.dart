import 'package:intl/intl.dart';
import 'package:sip_models/response.dart';

import '../sip_printer.dart';

extension CustomerAddressModelExtension on CustomerAddressModel {
  String get getFullAddress {
    try {
      return '${neighborhoodName!} ${districtName!} ${cityName!} Bina:${buildingNumber!} Kat:${floor!} Daire:${flatNumber!} Açık Adres: ${address!} Adres Tarifi: ${addressRoute!}';
    } catch (e) {
      return address ?? '';
    }
  }
}

extension PriceFormat on double {
  String getPrice({
    bool withOutDigitNumber = false,
  }) {
    final int decimalDigits;
    final String customPattern;
    if (withOutDigitNumber) {
      decimalDigits = 0;
      customPattern = '#,##0.00\u00A4';
    } else {
      decimalDigits = 2;
      customPattern = '#,##0.00\u00A4';
    }
    var percent = NumberFormat.currency(
      locale: SipPrinter.instance.languageCode,
      symbol: SipPrinter.instance.priceUnit,
      decimalDigits: decimalDigits,
      customPattern: customPattern,
    );
    return percent.format(this);
  }
}
