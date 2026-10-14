import 'dart:typed_data';
import 'package:flutter/material.dart';
import 'package:sip_models/ri_enum.dart';
import 'package:sip_models/ri_models.dart';
import 'package:sip_printer/sip_printer.dart';
import 'package:image/image.dart' as img show encodePng;

void main() {
  runApp(const MyApp());
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'Flutter Demo',
      theme: ThemeData(colorScheme: .fromSeed(seedColor: Colors.deepPurple)),
      home: const MyHomePage(title: 'Flutter Demo Home Page'),
    );
  }
}

class MyHomePage extends StatefulWidget {
  const MyHomePage({super.key, required this.title});

  final String title;

  @override
  State<MyHomePage> createState() => _MyHomePageState();
}

class _MyHomePageState extends State<MyHomePage> {
  Future<Uint8List>? _future;
  bool _isLoading = false;
  final printerManager = ThermalPrinterManager.instance();
  final receiptDesign = ReceiptDesign(PrinterPaperTypeEnum.mm80);

  @override
  void initState() {
    super.initState();

    WidgetsBinding.instance.addPostFrameCallback((_) async {
      await SipPrinter.init(
        languageCode: 'tr',
        priceUnit: 'TL',
        headerTitle: 'Deneme İşletme',
        footerTitle: 'Deneme İşletme Adres',
      );
      _future = _createReceipt('cashRegister');
      setState(() {});
    });
  }

  Future<Uint8List> _createReceipt(String type) async {
    final order = PrinterQueueResponseModel().jsonParserByMap(orderMap);

    switch (type) {
      case 'table':
        final result = await receiptDesign.createReceiptForTable(order);
        return Uint8List.fromList(img.encodePng(result.$2));

      case 'getIn':
        final result = await receiptDesign.createReceiptForGetIn(order);
        return Uint8List.fromList(img.encodePng(result.$2));

      case 'takeout':
        final result = await receiptDesign.createReceiptForTakeout(order);
        return Uint8List.fromList(img.encodePng(result.$2));

      case 'cashRegister':
        final result = await receiptDesign.createReceiptForCashRegister(order);
        return Uint8List.fromList(img.encodePng(result.$2));

      case 'tableBill':
        final result = await receiptDesign.createReceiptForTableBill(order);
        return Uint8List.fromList(img.encodePng(result.$2));

      case 'kitchen':
        final result = await receiptDesign.createReceiptForKitchenOrder(order);
        return Uint8List.fromList(img.encodePng(result.$2));

      case 'test':
        final result = await receiptDesign.createReceiptForTest();
        return Uint8List.fromList(img.encodePng(result.$2));

      default:
        throw Exception('Bilinmeyen fiş türü: $type');
    }
  }

  Future<void> _refreshReceipt(String type) async {
    setState(() {
      _isLoading = true;
      _future = _createReceipt(type);
    });

    try {
      await _future;
    } catch (_) {
    } finally {
      if (mounted) {
        setState(() {
          _isLoading = false;
        });
      }
    }
  }

  Widget _receiptButton(String title, String type) {
    return ElevatedButton(onPressed: _isLoading ? null : () => _refreshReceipt(type), child: Text(title));
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: Text(widget.title)),
      body: Column(
        children: [
          Wrap(
            spacing: 8,
            runSpacing: 8,
            alignment: WrapAlignment.center,
            children: [
              _receiptButton('Sipariş Fişi', 'table'),
              _receiptButton('Gel Al', 'getIn'),
              _receiptButton('Paket Siparişi', 'takeout'),
              _receiptButton('Kasa Fişi', 'cashRegister'),
              _receiptButton('Masa Adisyonu', 'tableBill'),
              _receiptButton('Mutfak Siparişi', 'kitchen'),
              _receiptButton('Test Fişi', 'test'),
            ],
          ),

          const SizedBox(height: 16),

          Expanded(
            child: SingleChildScrollView(
              child: _future == null
                  ? const SizedBox()
                  : FutureBuilder<Uint8List>(
                      future: _future,
                      builder: (context, snapshot) {
                        if (snapshot.connectionState == ConnectionState.waiting) {
                          return const CircularProgressIndicator();
                        }

                        if (snapshot.hasError) {
                          return Text('Hata: ${snapshot.error}');
                        }

                        if (!snapshot.hasData) {
                          return const Text('Resim oluşturulamadı');
                        }

                        return Image.memory(snapshot.data!, fit: BoxFit.contain);
                      },
                    ),
            ),
          ),
        ],
      ),
    );
  }
}

const orderMap = {
  "id": 15541,
  "trackid": "b8483b98-c9ec-449b-a73c-cbf84557b543",
  "print_data": {
    "orders": [
      {
        "id": 18912,
        "items": [
          {
            "id": 27735,
            "unit": {
              "id": "1c2168e9-8aa8-429d-945b-7a9e1b9cd1e9",
              "code": "ADET",
              "name": "Adet",
              "has_decimal": false,
            },
            "count": 2,
            "status": {"status_code": "INKITCHEN", "status_name": "Hazırlanıyor"},
            "is_gift": null,
            "options": [],
            "discounts": [
              {
                "id": 763,
                "source": "ITEM",
                "is_active": true,
                "locked_at": null,
                "created_at": "2026-10-13T06:54:26.842089",
                "order_item_id": 27735,
                "deactivated_at": null,
                "manual_discount_value": 0.0,
                "manual_discount_amount": 890.0,
                "manual_discount_type_id": 3,
              },
            ],
            "item_code": "P-IK-7248",
            "item_note": "",
            "status_id": "INKITCHEN",
            "item_price": 445.0,
            "item_title": "Leaf Mushroom Burger",
            "product_id": 7248,
            "campaign_id": null,
            "cancel_note": null,
            "item_object": {
              "id": 7248,
              "price": [
                {"id": 41001, "price": 445.0, "is_default": false, "order_delivery_type_id": "TAKEOUT"},
                {"id": 41002, "price": 445.0, "is_default": true, "order_delivery_type_id": "TABLE"},
                {"id": 41003, "price": 445.0, "is_default": false, "order_delivery_type_id": "GETIN"},
              ],
              "images": null,
              "calorie": 0,
              "item_type": "PRODUCT",
              "make_time": 15,
              "product_name": "Leaf Mushroom Burger",
              "short_description": "Yarı brioche ekmek, burger eti, köz sarımsaklı el yapımı mayonez, terayağı ile pişmiş istiridye mantarı, cheddar peyniri. Churros patates kızartması ile",
            },
            "tax_percent": 10,
            "total_price": 890.0,
            "item_type_id": "PRODUCT",
            "payment_info": null,
            "cancel_reject": null,
            "order_main_id": 18912,
            "stock_unit_id": "1c2168e9-8aa8-429d-945b-7a9e1b9cd1e9",
            "transaction_id": null,
            "is_use_campaign": null,
            "revision_number": "5a90bbe9-60de-4004-a7ef-7b5e2da12c2d",
            "printer_old_count": null,
            "promotion_menu_id": null,
            "before_campaign_total": null,
            "cancel_reject_code_id": null,
            "manual_discount_value": 0.0,
            "item_price_without_kdv": 404.55,
            "manual_discount_amount": 890.0,
            "manual_discount_type_id": 3,
            "total_price_without_kdv": 809.1,
            "order_pay_status_type_id": null,
            "before_campaign_item_price": null,
            "after_manual_discount_total": 0.0,
            "after_manual_discount_item_price": 0.0,
            "after_manual_discount_total_without_kdv": 0.0,
            "after_manual_discount_item_price_without_kdv": 0.0,
          },
          {
            "id": 27736,
            "unit": {
              "id": "1c2168e9-8aa8-429d-945b-7a9e1b9cd1e9",
              "code": "ADET",
              "name": "Adet",
              "has_decimal": false,
            },
            "count": 1,
            "status": {"status_code": "INKITCHEN", "status_name": "Hazırlanıyor"},
            "is_gift": null,
            "options": [],
            "discounts": [
              {
                "id": 762,
                "source": "ITEM",
                "is_active": true,
                "locked_at": null,
                "created_at": "2026-10-13T06:54:22.090466",
                "order_item_id": 27736,
                "deactivated_at": null,
                "manual_discount_value": 0.0,
                "manual_discount_amount": 120.0,
                "manual_discount_type_id": 2,
              },
            ],
            "item_code": "P-IK-7251",
            "item_note": "",
            "status_id": "INKITCHEN",
            "item_price": 420.0,
            "item_title": "Cheeseburger",
            "product_id": 7251,
            "campaign_id": null,
            "cancel_note": null,
            "item_object": {
              "id": 7251,
              "price": [
                {"id": 41010, "price": 420.0, "is_default": false, "order_delivery_type_id": "TAKEOUT"},
                {"id": 41011, "price": 420.0, "is_default": true, "order_delivery_type_id": "TABLE"},
                {"id": 41012, "price": 420.0, "is_default": false, "order_delivery_type_id": "GETIN"},
              ],
              "images": [
                {
                  "image_url": "https://siparisimcdn2.s3.eu-central-1.amazonaws.com/icdn/mobile-detail-cheeseburger-0-2466792229329855.png",
                  "list_order": 5,
                  "image_size_id": "mobile_detail",
                },
                {
                  "image_url": "https://siparisimcdn2.s3.eu-central-1.amazonaws.com/icdn/mobile-list-cheeseburger-0-9335431553552354.png",
                  "list_order": 5,
                  "image_size_id": "mobile_list",
                },
                {
                  "image_url": "https://siparisimcdn2.s3.eu-central-1.amazonaws.com/icdn/mobile-list-col-cheeseburger-0-4741089529776982.png",
                  "list_order": 5,
                  "image_size_id": "mobile_list_col",
                },
              ],
              "calorie": 0,
              "item_type": "PRODUCT",
              "make_time": 15,
              "product_name": "Cheeseburger",
              "short_description": "Yarı brioche ekmek arasına; burger köftesi, cheddar peyniri, çubuk turşusu, isteğe göre özel sos. Patates kızartması ile",
            },
            "tax_percent": 10,
            "total_price": 420.0,
            "item_type_id": "PRODUCT",
            "payment_info": null,
            "cancel_reject": null,
            "order_main_id": 18912,
            "stock_unit_id": "1c2168e9-8aa8-429d-945b-7a9e1b9cd1e9",
            "transaction_id": null,
            "is_use_campaign": null,
            "revision_number": "77ef18ce-c1ce-47ae-bd8a-09912362b96d",
            "printer_old_count": null,
            "promotion_menu_id": null,
            "before_campaign_total": null,
            "cancel_reject_code_id": null,
            "manual_discount_value": 0.0,
            "item_price_without_kdv": 381.82,
            "manual_discount_amount": 120.0,
            "manual_discount_type_id": 2,
            "total_price_without_kdv": 381.82,
            "order_pay_status_type_id": null,
            "before_campaign_item_price": null,
            "after_manual_discount_total": 300.0,
            "after_manual_discount_item_price": 300.0,
            "after_manual_discount_total_without_kdv": 272.73,
            "after_manual_discount_item_price_without_kdv": 272.73,
          },
        ],
        "sso_id": null,
        "customer": {"id": null, "sessionId": null, "name_surname": " "},
        "campaigns": null,
        "dealer_id": 896,
        "discounts": [],
        "nick_name": "Diğer Misafir",
        "sessionId": "469229c8-5bcb-4b9b-b6bb-e2abee45e283",
        "order_note": "",
        "tip_amount": null,
        "cancel_note": null,
        "customer_id": null,
        "record_date": "2026-10-13T09:54:31.956",
        "courier_info": null,
        "order_number": "93f8ce13-41de-45a3-8bcf-7ea7d6afb9d6",
        "order_status": {
          "order_status_code": "IN_KITCHEN",
          "order_status_name": "Hazırlanıyor",
          "order_status_group_id": "KITCHEN",
        },
        "payment_info": null,
        "total_amount": 300.0,
        "cancel_reject": null,
        "delivery_date": null,
        "order_options": null,
        "order_point_id": "TABLE",
        "client_point_id": "MOBILE_APP",
        "is_use_campaign": false,
        "customer_address": null,
        "delivery_type_id": "TABLE",
        "session_point_id": "RESTOP",
        "table_service_id": 10388,
        "invoice_success_link": null,
        "before_campaign_total": 1310.0,
        "prefixed_order_number": "TBS-1",
        "tip_amount_without_kdv": null,
        "total_amount_without_kdv": 272.73,
      },
    ],
    "qr_code": null,
    "dealer_id": 896,
    "q_table_id": "JqeqQBvbzjcAXu6P",
    "service_id": 10388,
    "table_info": {
      "table_code": "JqeqQBvbzjcAXu6P",
      "table_name": "BAHCE-2",
      "station_code": "0NcLwX1vs8e7frtE",
      "station_name": "BAHCE",
    },
    "dealer_info": {
      "id": 896,
      "address": "Cevizli Mah.Zuhal Cad.Ritim İstanbul A3 Blok No:46/C D:135",
      "dealer_name": "Tezgah Burger",
    },
    "payment_type": null,
    "person_count": 1,
    "pleksi_number": null,
    "service_number": "980005e9-c404-4b44-ab72-f14919efb2cd",
    "pay_customer_id": null,
    "payment_type_id": null,
    "revision_number": "b8483b98-c9ec-449b-a73c-cbf84557b543",
    "payment_model_id": "POST",
    "total_tip_amount": 0.0,
    "number_of_service": null,
    "service_status_id": "IN_KITCHEN",
    "service_pay_type_id": null,
    "service_order_amount": 300.0,
    "service_total_amount": 300.0,
    "table_service_amount": 0,
    "service_delivery_type_id": "SS",
    "total_tip_amount_without_kdv": 0.0,
    "service_order_amount_without_kdv": 272.73,
    "service_total_amount_without_kdv": 272.73,
    "table_service_amount_without_kdv": 0,
  },
  "print_template_id": "TABLE",
  "paper_size": "mm80",
  "pos_station_printer_id": 261,
  "pos_station_id": 275,
  "printer_type_id": "USB",
  "ip_address": "{\"name\":\"XP-80C\",\"vendorId\":\"\",\"productId\":\"\",\"paperSize\":\"mm80\",\"type\":\"USB\"}",
  "port": null,
  "is_revision": false,
  "printer_name": "XP-80C",
  "payment_model_id": "POST",
  "is_payment_notification": false,
  "is_check_notification": false,
};
