import 'package:sip_models/ri_models.dart';

class SipPrinter {
  static late SipPrinter instance;
  ParametersResponseDealerInfoModel dealerInfo;
  String languageCode;
  String priceUnit;

  SipPrinter({
    required this.dealerInfo,
    required this.languageCode,
    required this.priceUnit,
  });

  static init({
    required ParametersResponseDealerInfoModel dealerInfo,
    required String languageCode,
    required String priceUnit,
  }) {
    instance = SipPrinter(
      dealerInfo: dealerInfo,
      languageCode: languageCode,
      priceUnit: priceUnit,
    );
  }
}
