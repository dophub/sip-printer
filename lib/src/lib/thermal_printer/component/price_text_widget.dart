import 'package:flutter/material.dart';

import '../../../extanstion/general_extenstion.dart';

/// Bir ürün fiyatını gösterir.
///
/// Üç durumu destekler:
/// * Normal: yalnızca [price] gösterilir.
/// * İndirimli: [discountPrice] verilirse, asıl fiyat üstü çizili ve
///   kırmızı, indirimli fiyat ise yanında/üstünde gösterilir.
/// * İkram: [isComplimentary] true ise indirimli fiyat yerine
class PriceTextWidget extends StatelessWidget {
  const PriceTextWidget({
    super.key,
    required this.price,
    this.discountPrice,
    this.textStyle,
    this.discountTextStyle,
    this.discountTextColor,
    this.withOutDigitNumber = false,
    this.maxLines,
    this.direction = Axis.vertical,
    this.textDirection,
    this.discountPricePadding = const EdgeInsets.only(right: 6),
    this.textHeight,
    this.isComplimentary = false,
    this.fontFamily,
  });

  static const String _complimentaryLabel = 'İkram';

  final double price;
  final double? discountPrice;
  final TextStyle? textStyle;
  final TextStyle? discountTextStyle;
  final Color? discountTextColor;
  final bool withOutDigitNumber;
  final int? maxLines;
  final String? fontFamily;
  final Axis direction;
  final TextDirection? textDirection;
  final EdgeInsetsGeometry discountPricePadding;
  final double? textHeight;
  final bool isComplimentary;

  bool get _hasDiscount => isComplimentary || discountPrice != null;

  String _format(double value) => value.getPrice(withOutDigitNumber: withOutDigitNumber);

  @override
  Widget build(BuildContext context) {
    return Flex(
      direction: direction,
      textDirection: textDirection,
      mainAxisSize: MainAxisSize.min,
      children: [
        if (_hasDiscount) _buildDiscountText(),
        _buildOriginalPrice(),
      ],
    );
  }

  Widget _buildDiscountText() {
    final String label = isComplimentary ? _complimentaryLabel : _format(discountPrice!);

    return Padding(
      padding: discountPricePadding,
      child: Text(
        label,
        maxLines: maxLines,
        style: discountTextStyle ??
            TextStyle(
              fontSize: 30,
              fontFamily: fontFamily,
              fontWeight: FontWeight.w500,
              height: 1.2,
            ),
      ),
    );
  }

  Widget _buildOriginalPrice() {
    final style = textStyle ??
        TextStyle(
          fontSize: 34,
          fontFamily: fontFamily,
          fontWeight: FontWeight.w500,
          height: 1.2,
        );
    return Text(
      _format(price),
      maxLines: maxLines,
      style: style.copyWith(
        decoration: _hasDiscount ? TextDecoration.lineThrough : TextDecoration.none,
        height: textHeight,
      ),
    );
  }
}
