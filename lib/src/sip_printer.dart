import 'package:sip_models/ri_models.dart';

class SipPrinter {
  static late SipPrinter instance;
  String headerTitle;
  String footerTitle;
  String languageCode;
  String priceUnit;

  SipPrinter({
    required this.languageCode,
    required this.priceUnit,
    required this.headerTitle,
    required this.footerTitle,
  });

  static init({
    required String languageCode,
    required String priceUnit,
    required String headerTitle,
    required String footerTitle,
  }) {
    instance = SipPrinter(
      languageCode: languageCode,
      priceUnit: priceUnit,
      headerTitle: headerTitle,
      footerTitle: footerTitle,
    );
  }
}
