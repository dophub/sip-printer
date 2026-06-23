import 'package:intl/intl.dart';
import 'package:sip_models/response.dart';

import '../sip_printer.dart';

extension CustomerAddressModelExtension on CustomerAddressModel {
  String get getFullAddress {
    final parts = <String?>[
      if ((neighborhoodName ?? '').isNotEmpty) neighborhoodName,
      if ((districtName ?? '').isNotEmpty) districtName,
      if ((cityName ?? '').isNotEmpty) cityName,
      if ((buildingNumber ?? '').isNotEmpty) 'Bina: $buildingNumber',
      if ((floor ?? '').isNotEmpty) 'Kat: $floor',
      if ((flatNumber ?? '').isNotEmpty) 'Daire: $flatNumber',
      if ((address ?? '').isNotEmpty) 'Açık Adres: $address',
      if ((addressRoute ?? '').isNotEmpty) 'Adres Tarifi: $addressRoute',
    ];

    return parts.where((e) => e != null).join(' ');
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
