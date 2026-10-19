import 'dart:async';
import 'package:esc_pos_utils_plus/esc_pos_utils_plus.dart';
import 'package:printing/printing.dart' show Printing;
import 'package:image/image.dart' as img;
import '../../../sip_printer.dart';
import 'package:htmltopdfwidgets/htmltopdfwidgets.dart' as htmltopdfwidgets;
import 'package:pdf/widgets.dart' as pw;
import 'dart:typed_data';

class ThermalPrinterUtils {
  static ThermalPrinterUtils? _instance;

  ThermalPrinterUtils._();

  static get instance => _instance ??= ThermalPrinterUtils._();

  Future<Uint8List> createHtmlToPdf(final String html, PaperSize paperSize) async {
    final List<pw.Widget> widgets = await htmltopdfwidgets.HTMLToPdf().convert(html, useNewEngine: true);
    return _buildPdf(widgets, paperSize);
  }

  Future<Uint8List> _buildPdf(List<pw.Widget> widgets, PaperSize paperSize) async {
    final doc = pw.Document(
      theme: pw.ThemeData.withFont(
        base: SipPrinter.instance.regularFont,
        bold: SipPrinter.instance.boldFont,
      ),
    );

    doc.addPage(
      pw.Page(
        pageFormat: htmltopdfwidgets.PdfPageFormat(
          paperSize.width.toDouble(),
          double.infinity,
          marginAll: 0,
        ),
        margin: const pw.EdgeInsets.symmetric(horizontal: 8, vertical: 8),
        build: (_) => pw.Column(
          crossAxisAlignment: pw.CrossAxisAlignment.start,
          children: widgets,
        ),
      ),
    );

    return doc.save();
  }

  Future<List<int>> convertPdfToEscPosAndCut(Uint8List pdfBytes, PaperSize paperSize) async {
    final watch = Stopwatch()..start();

    img.Image image = await _pdfToImage(pdfBytes, paperSize);
    print('pdfToImage: ${watch.elapsedMilliseconds} ms');

    watch
      ..reset()
      ..start();

    final List<int> list = _imageToEscPosRaster(image);
    print('generator.image: ${watch.elapsedMilliseconds} ms');

    final bytes = <int>[];
    bytes.addAll(list);

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

  Future<img.Image> _pdfToImage(Uint8List pdfBytes, PaperSize paperSize) async {
    final watch = Stopwatch()..start();

    const double rasterDpi = 72;
    final raster = await Printing.raster(pdfBytes, dpi: rasterDpi).first;
    print('pdfToImage: 1 (${watch.elapsedMilliseconds} ms)');

    watch.reset();
    final pngBytes = await raster.toPng();
    print('pdfToImage: 2 (${watch.elapsedMilliseconds} ms)');

    watch.reset();
    var image = img.decodeImage(pngBytes)!;
    print('pdfToImage: 3 ${image.width}x${image.height} (${watch.elapsedMilliseconds} ms)');

    final paperWidth = paperSize == PaperSize.mm80 ? 576 : 384;

    watch.reset();
    if (image.width != paperWidth) {
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
  List<int> _imageToEscPosRaster(
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
