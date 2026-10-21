import 'package:flutter/services.dart' show rootBundle;
import 'package:pdf/widgets.dart' as pw;

class SipPrinter {
  static late SipPrinter instance;
  String headerTitle;
  String footerTitle;
  String languageCode;
  String priceUnit;
  pw.Font regularFont;
  pw.Font boldFont;

  SipPrinter({
    required this.languageCode,
    required this.priceUnit,
    required this.headerTitle,
    required this.footerTitle,
    required this.regularFont,
    required this.boldFont,
  });

  static Future<void> init({
    required String languageCode,
    required String priceUnit,
    required String headerTitle,
    required String footerTitle,
  }) async {
    final watch = Stopwatch()..start();
    final regularFont = pw.Font.ttf(await rootBundle.load('assets/fonts/Poppins-Medium.ttf'));
    print('load font: (${watch.elapsedMilliseconds} ms)');

    final boldFont = pw.Font.ttf(await rootBundle.load('assets/fonts/Poppins-Bold.ttf'));
    print('load font: (${watch.elapsedMilliseconds} ms)');

    instance = SipPrinter(
      languageCode: languageCode,
      priceUnit: priceUnit,
      headerTitle: headerTitle,
      footerTitle: footerTitle,
      regularFont: regularFont,
      boldFont: boldFont,
    );
  }
}
