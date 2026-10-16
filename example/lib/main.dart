import 'dart:typed_data';

import 'package:flutter/material.dart';
import 'package:sip_models/ri_enum.dart';
import 'package:sip_models/ri_models.dart';
import 'package:sip_printer/sip_printer.dart';
import 'package:image/image.dart' as img show Image, encodePng;

void main() {
  runApp(const MyApp());
}

class MyApp extends StatefulWidget {
  const MyApp({super.key});

  @override
  State<MyApp> createState() => _MyAppState();
}

class _MyAppState extends State<MyApp> {
  @override
  void initState() {
    super.initState();
    SipPrinter.init(
      languageCode: 'tr',
      priceUnit: 'TL',
      headerTitle: 'Deneme İşletme',
      footerTitle: 'Deneme İşletme Adres',
    );
  }

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
  late Future<Uint8List> _future;
  bool _isLoading = false;

  @override
  void initState() {
    super.initState();
    _future = _createReceipt('cashRegister');
  }

  Future<Uint8List> _createReceipt(String type) async {
    final printerManager = await ThermalPrinterManager.instance();

    final order = PrinterQueueResponseModel().jsonParserByMap(orderMap);

    switch (type) {
      case 'table':
        final result = await printerManager.createReceiptForTable(PrinterPaperTypeEnum.mm80, order);
        return Uint8List.fromList(img.encodePng(result.$2));

      case 'getIn':
        final result = await printerManager.createReceiptForGetIn(PrinterPaperTypeEnum.mm80, order);
        return Uint8List.fromList(img.encodePng(result.$2));

      case 'takeout':
        final result = await printerManager.createReceiptForTakeout(PrinterPaperTypeEnum.mm80, order);
        return Uint8List.fromList(img.encodePng(result.$2));

      case 'cashRegister':
        final result = await printerManager.createReceiptForCashRegister(PrinterPaperTypeEnum.mm80, order);
        return Uint8List.fromList(img.encodePng(result.$2));

      case 'tableBill':
        final result = await printerManager.createReceiptForTableBill(PrinterPaperTypeEnum.mm80, order);
        return Uint8List.fromList(img.encodePng(result.$2));

      case 'kitchen':
        final result = await printerManager.createReceiptForKitchenOrder(PrinterPaperTypeEnum.mm80, order);
        return Uint8List.fromList(img.encodePng(result.$2));

      case 'test':
        final result = await printerManager.createReceiptForTest(PrinterPaperTypeEnum.mm80);
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
      // Hata FutureBuilder içerisinde gösterilecek.
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
              child: FutureBuilder<Uint8List>(
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
  "id": 15537,
  "trackid": "42d3f551-0095-4d11-8a07-bec316341fdc",
  "print_data": {
    "orders": [
      {
        "id": 18909,
        "items": [
          {
            "id": 27725,
            "unit": {
              "id": "1c2168e9-8aa8-429d-945b-7a9e1b9cd1e9",
              "code": "ADET",
              "name": "Adet",
              "has_decimal": false
            },
            "count": 1,
            "status": {
              "status_code": "INKITCHEN",
              "status_name": "HazÄ±rlanÄ±yor"
            },
            "is_gift": false,
            "options": [],
            "discounts": [],
            "item_code": "P-W-7713",
            "item_note": "",
            "status_id": "INKITCHEN",
            "item_price": 640.0,
            "item_title": "Test1 640 - 20kdv",
            "product_id": 7713,
            "campaign_id": 242,
            "cancel_note": null,
            "item_object": {
              "id": 7713,
              "price": [
                {
                  "id": 42513,
                  "price": 640.0,
                  "is_default": false,
                  "order_delivery_type_id": "TAKEOUT"
                },
                {
                  "id": 42514,
                  "price": 640.0,
                  "is_default": true,
                  "order_delivery_type_id": "TABLE"
                },
                {
                  "id": 42515,
                  "price": 640.0,
                  "is_default": false,
                  "order_delivery_type_id": "GETIN"
                }
              ],
              "images": null,
              "calorie": 0,
              "item_type": "PRODUCT",
              "make_time": 15,
              "product_name": "Test1 640 - 20kdv",
              "short_description": "Test2"
            },
            "tax_percent": 20,
            "total_price": 640.0,
            "item_type_id": "PRODUCT",
            "payment_info": {
              "name": "Nakit Ãdeme",
              "type": "CASH",
              "is_online_payment": false
            },
            "cancel_reject": null,
            "order_main_id": 18909,
            "stock_unit_id": "1c2168e9-8aa8-429d-945b-7a9e1b9cd1e9",
            "transaction_id": "58e04615-5801-4ce0-a3e9-f4074412d7bc",
            "is_use_campaign": true,
            "revision_number": "536cd0ee-f24a-4a0b-ad5d-6e5bc1cd935d",
            "printer_old_count": null,
            "promotion_menu_id": null,
            "before_campaign_total": 487.62,
            "cancel_reject_code_id": null,
            "manual_discount_value": 0.0,
            "item_price_without_kdv": 406.35,
            "manual_discount_amount": 7.62,
            "manual_discount_type_id": 2,
            "total_price_without_kdv": 406.35,
            "order_pay_status_type_id": "SUCCESS",
            "before_campaign_item_price": 487.62,
            "after_manual_discount_total": 480.0,
            "after_manual_discount_item_price": 480.0,
            "after_manual_discount_total_without_kdv": 400.0,
            "after_manual_discount_item_price_without_kdv": 400.0
          },
          {
            "id": 27726,
            "unit": {
              "id": "1c2168e9-8aa8-429d-945b-7a9e1b9cd1e9",
              "code": "ADET",
              "name": "Adet",
              "has_decimal": false
            },
            "count": 1,
            "status": {
              "status_code": "INKITCHEN",
              "status_name": "HazÄ±rlanÄ±yor"
            },
            "is_gift": false,
            "options": [],
            "discounts": [],
            "item_code": "P-W-7714",
            "item_note": "",
            "status_id": "INKITCHEN",
            "item_price": 50.0,
            "item_title": "Test1 50 - 10kdv",
            "product_id": 7714,
            "campaign_id": 242,
            "cancel_note": null,
            "item_object": {
              "id": 7714,
              "price": [
                {
                  "id": 42516,
                  "price": 50.0,
                  "is_default": false,
                  "order_delivery_type_id": "TAKEOUT"
                },
                {
                  "id": 42517,
                  "price": 50.0,
                  "is_default": true,
                  "order_delivery_type_id": "TABLE"
                },
                {
                  "id": 42518,
                  "price": 50.0,
                  "is_default": false,
                  "order_delivery_type_id": "GETIN"
                }
              ],
              "images": null,
              "calorie": 0,
              "item_type": "PRODUCT",
              "make_time": 15,
              "product_name": "Test1 50 - 10kdv",
              "short_description": "test3"
            },
            "tax_percent": 10,
            "total_price": 50.0,
            "item_type_id": "PRODUCT",
            "payment_info": {
              "name": "Nakit Ãdeme",
              "type": "CASH",
              "is_online_payment": false
            },
            "cancel_reject": null,
            "order_main_id": 18909,
            "stock_unit_id": "1c2168e9-8aa8-429d-945b-7a9e1b9cd1e9",
            "transaction_id": "58e04615-5801-4ce0-a3e9-f4074412d7bc",
            "is_use_campaign": true,
            "revision_number": "7cf070c9-ef9a-4218-9ba4-5ba0634523ce",
            "printer_old_count": null,
            "promotion_menu_id": null,
            "before_campaign_total": 38.1,
            "cancel_reject_code_id": null,
            "manual_discount_value": 0.0,
            "item_price_without_kdv": 34.64,
            "manual_discount_amount": 0.6,
            "manual_discount_type_id": 2,
            "total_price_without_kdv": 34.64,
            "order_pay_status_type_id": "SUCCESS",
            "before_campaign_item_price": 38.1,
            "after_manual_discount_total": 37.5,
            "after_manual_discount_item_price": 37.5,
            "after_manual_discount_total_without_kdv": 34.09,
            "after_manual_discount_item_price_without_kdv": 34.09
          },
          {
            "id": 27727,
            "unit": {
              "id": "1c2168e9-8aa8-429d-945b-7a9e1b9cd1e9",
              "code": "ADET",
              "name": "Adet",
              "has_decimal": false
            },
            "count": 1,
            "status": {
              "status_code": "INKITCHEN",
              "status_name": "HazÄ±rlanÄ±yor"
            },
            "is_gift": false,
            "options": [],
            "discounts": [],
            "item_code": "P-W-7715",
            "item_note": "",
            "status_id": "INKITCHEN",
            "item_price": 60.0,
            "item_title": "Test1 60 - 10kdv",
            "product_id": 7715,
            "campaign_id": 242,
            "cancel_note": null,
            "item_object": {
              "id": 7715,
              "price": [
                {
                  "id": 42519,
                  "price": 60.0,
                  "is_default": false,
                  "order_delivery_type_id": "TAKEOUT"
                },
                {
                  "id": 42520,
                  "price": 60.0,
                  "is_default": true,
                  "order_delivery_type_id": "TABLE"
                },
                {
                  "id": 42521,
                  "price": 60.0,
                  "is_default": false,
                  "order_delivery_type_id": "GETIN"
                }
              ],
              "images": null,
              "calorie": 0,
              "item_type": "PRODUCT",
              "make_time": 15,
              "product_name": "Test1 60 - 10kdv",
              "short_description": "Test1 60 - 10kdv"
            },
            "tax_percent": 10,
            "total_price": 60.0,
            "item_type_id": "PRODUCT",
            "payment_info": {
              "name": "Nakit Ãdeme",
              "type": "CASH",
              "is_online_payment": false
            },
            "cancel_reject": null,
            "order_main_id": 18909,
            "stock_unit_id": "1c2168e9-8aa8-429d-945b-7a9e1b9cd1e9",
            "transaction_id": "58e04615-5801-4ce0-a3e9-f4074412d7bc",
            "is_use_campaign": true,
            "revision_number": "3f2e36c4-e417-4be4-9aec-21d46ed3a6ba",
            "printer_old_count": null,
            "promotion_menu_id": null,
            "before_campaign_total": 45.71,
            "cancel_reject_code_id": null,
            "manual_discount_value": 0.0,
            "item_price_without_kdv": 41.55,
            "manual_discount_amount": 0.71,
            "manual_discount_type_id": 2,
            "total_price_without_kdv": 41.55,
            "order_pay_status_type_id": "SUCCESS",
            "before_campaign_item_price": 45.71,
            "after_manual_discount_total": 45.0,
            "after_manual_discount_item_price": 45.0,
            "after_manual_discount_total_without_kdv": 40.91,
            "after_manual_discount_item_price_without_kdv": 40.91
          },
          {
            "id": 27728,
            "unit": {
              "id": "1c2168e9-8aa8-429d-945b-7a9e1b9cd1e9",
              "code": "ADET",
              "name": "Adet",
              "has_decimal": false
            },
            "count": 2.4,
            "status": {
              "status_code": "INKITCHEN",
              "status_name": "HazÄ±rlanÄ±yor"
            },
            "is_gift": false,
            "options": [],
            "discounts": [],
            "item_code": "P-W-7716",
            "item_note": "",
            "status_id": "INKITCHEN",
            "item_price": 90,
            "item_title": "Test1 90 - 10kdv",
            "product_id": 7716,
            "campaign_id": 242,
            "cancel_note": null,
            "item_object": {
              "id": 7716,
              "price": [
                {
                  "id": 42522,
                  "price": 90.0,
                  "is_default": false,
                  "order_delivery_type_id": "TAKEOUT"
                },
                {
                  "id": 42523,
                  "price": 90.0,
                  "is_default": true,
                  "order_delivery_type_id": "TABLE"
                },
                {
                  "id": 42524,
                  "price": 90.0,
                  "is_default": false,
                  "order_delivery_type_id": "GETIN"
                }
              ],
              "images": null,
              "calorie": 0,
              "item_type": "PRODUCT",
              "make_time": 15,
              "product_name": "Test1 90 - 10kdv",
              "short_description": "Test1 90 - 10kdv"
            },
            "tax_percent": 10,
            "total_price": 9000.0,
            "item_type_id": "PRODUCT",
            "payment_info": {
              "name": "Nakit Ödeme",
              "type": "CASH",
              "is_online_payment": false
            },
            "cancel_reject": null,
            "order_main_id": 18909,
            "stock_unit_id": "1c2168e9-8aa8-429d-945b-7a9e1b9cd1e9",
            "transaction_id": "58e04615-5801-4ce0-a3e9-f4074412d7bc",
            "is_use_campaign": false,
            "revision_number": "e7aa9de2-4f29-40d2-9b95-161491f9c324",
            "printer_old_count": null,
            "promotion_menu_id": null,
            "before_campaign_total": 68.57,
            "cancel_reject_code_id": null,
            "manual_discount_value": 0.0,
            "item_price_without_kdv": 62.34,
            "manual_discount_amount": 1.07,
            "manual_discount_type_id": 2,
            "total_price_without_kdv": 62.34,
            "order_pay_status_type_id": "SUCCESS",
          }
        ],
        "sso_id": null,
        "customer": {
          "id": 15450,
          "sessionId": null,
          "name_surname": "Serhat O",
          "phone_number": null
        },
        "campaigns": [
          {
            "id": 242,
            "spot_title": "İlk Siparişe 200 TL İndirim!",
            "provider_name": "SipariÅim",
            "is_third_party": false,
            "campaign_amount": 200.0
          }
        ],
        "dealer_id": 675,
        "discounts": [
          {
            "id": 751,
            "source": "ORDER",
            "is_active": true,
            "locked_at": null,
            "created_at": "2026-10-12T15:40:20.107518",
            "order_item_id": null,
            "deactivated_at": null,
            "manual_discount_value": 0.0,
            "manual_discount_amount": 10.0,
            "manual_discount_type_id": 2
          }
        ],
        "nick_name": "DiÄer Misafir",
        "sessionId": "a6922311-8eeb-4d0f-b42b-6af90276ef30",
        "order_note": "",
        "tip_amount": null,
        "cancel_note": null,
        "customer_id": 15450,
        "record_date": "2026-10-12T18:40:55.559",
        "courier_info": null,
        "order_number": "fa6ab9a1-ca42-4374-bf3a-178537d952d5",
        "order_status": {
          "order_status_code": "OUT_KITCHEN",
          "order_status_name": "HazÄ±rlanÄ±yor",
          "order_status_group_id": "KITCHEN"
        },
        "payment_info": {
          "name": "Nakit Ödeme",
          "type": "CASH",
          "is_online_payment": false
        },
        "total_amount": 630.0,
        "cancel_reject": null,
        "delivery_date": null,
        "order_options": null,
        "order_point_id": "TAKEOUT",
        "client_point_id": "MOBILE_APP",
        "is_use_campaign": true,
        "customer_address": {
          "id": 8621,
          "floor": "",
          "latlng": null,
          "address": "sss",
          "city_id": 34,
          "city_name": "İSTANBUL",
          "district_id": 6,
          "flat_number": "",
          "address_name": "other",
          "address_route": "",
          "district_name": "BAHÇELİ EVLER",
          "building_number": "",
          "neighborhood_id": null,
          "neighborhood_name": null
        },
        "delivery_type_id": "TAKEOUT",
        "session_point_id": "RESTOP",
        "table_service_id": null,
        "before_campaign_total": 840.0,
        "prefixed_order_number": null,
        "tip_amount_without_kdv": null,
        "total_amount_without_kdv": 536.36
      }
    ],
    "qr_code": "",
    "dealer_id": 675,
    "q_table_id": "",
    "service_id": 18909,
    "table_info": {
      "table_code": "PAKET",
      "table_name": "Paket",
      "station_code": "Paket",
      "station_name": "Paket"
    },
    "dealer_info": {
      "id": 675,
      "address": "Hilltown Maltepe Test",
      "dealer_name": "Siparişim cafe"
    },
    "payment_type": "Nakit Ödeme",
    "person_count": 0,
    "service_number": null,
    "pay_customer_id": 15450,
    "payment_type_id": "CASH",
    "revision_number": "",
    "payment_model_id": "POST",
    "total_tip_amount": 0,
    "number_of_service": 0,
    "service_status_id": "",
    "service_pay_type_id": "",
    "service_order_amount": 630.0,
    "service_total_amount": 630.0,
    "table_service_amount": 0,
    "service_delivery_type_id": "TAKEOUT",
    "total_tip_amount_without_kdv": 0,
    "service_order_amount_without_kdv": 536.36,
    "service_total_amount_without_kdv": 536.36,
    "table_service_amount_without_kdv": 0
  },
  "print_template_id": "TAKEOUT",
  "paper_size": "mm80",
  "pos_station_printer_id": 220,
  "pos_station_id": 225,
  "printer_type_id": "NETWORK",
  "ip_address": "192.168.1.200",
  "port": 9100,
  "is_revision": false,
  "printer_name": "honor mto",
  "payment_model_id": "POST",
  "is_payment_notification": false,
  "is_check_notification": false
};
