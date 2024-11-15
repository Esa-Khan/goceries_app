import 'dart:io' show Platform;
import 'package:flutter/material.dart';

import '../helpers/custom_trace.dart';

class Setting {
  String appName = '';
  double defaultTax;
  String defaultCurrency;
  String distanceUnit;
  bool currencyRight = false;
  int currencyDecimalDigits = 2;
  bool payPalEnabled = true;
  bool stripeEnabled = true;
  bool razorPayEnabled = true;
  String mainColor;
  String mainDarkColor;
  String secondColor;
  String secondDarkColor;
  String accentColor;
  String accentDarkColor;
  String scaffoldDarkColor;
  String scaffoldColor;
  String googleMapsKey;
  String whatsapp_number;
  String facebook_url;
  String instagram_url;
  String phone_number;
  ValueNotifier<Locale> mobileLanguage = new ValueNotifier(Locale('en', ''));
  String appVersion;
  bool enableVersion = true;
  double deliveryFeeLimit;
  Map<String, double> promo;
  String debug_url;

  ValueNotifier<Brightness> brightness = new ValueNotifier(Brightness.light);

  Setting();

  Setting.fromJSON(Map<String, dynamic> jsonMap) {
    try {
      appName = jsonMap['app_name'] ?? null;
      mainColor = jsonMap['main_color'] ?? null;
      mainDarkColor = jsonMap['main_dark_color'] ?? '';
      secondColor = jsonMap['second_color'] ?? '';
      secondDarkColor = jsonMap['second_dark_color'] ?? '';
      accentColor = jsonMap['accent_color'] ?? '';
      accentDarkColor = jsonMap['accent_dark_color'] ?? '';
      scaffoldDarkColor = jsonMap['scaffold_dark_color'] ?? '';
      scaffoldColor = jsonMap['scaffold_color'] ?? '';
      googleMapsKey = jsonMap['google_maps_key'] ?? null;
      mobileLanguage.value = Locale(jsonMap['mobile_language'] ?? "en", '');
      appVersion = jsonMap['app_version'] ?? '';
      distanceUnit = jsonMap['distance_unit'] ?? 'km';
      enableVersion = jsonMap['enable_version'] == null || jsonMap['enable_version'] == '0' ? false : true;
      defaultTax = double.tryParse(jsonMap['default_tax']) ?? 0.0; //double.parse(jsonMap['default_tax'].toString());
      defaultCurrency = jsonMap['default_currency'] ?? '';
      currencyDecimalDigits = int.tryParse(jsonMap['default_currency_decimal_digits']) ?? 2;
      currencyRight = jsonMap['currency_right'] == null || jsonMap['currency_right'] == '0' ? false : true;
      payPalEnabled = jsonMap['enable_paypal'] == null || jsonMap['enable_paypal'] == '0' ? false : true;
      stripeEnabled = jsonMap['enable_stripe'] == null || jsonMap['enable_stripe'] == '0' ? false : true;
      razorPayEnabled = jsonMap['enable_razorpay'] == null || jsonMap['enable_razorpay'] == '0' ? false : true;
      whatsapp_number = jsonMap['whatsapp_number'];
      facebook_url = jsonMap['facebook_url'];
      instagram_url = Platform.isIOS ? jsonMap['instagram_url_ios'] : jsonMap['instagram_url_android'];
      phone_number = jsonMap['phone_number'];
      promo = jsonMap['promo'] == null ? null : getPromos(jsonMap['promo']);
      try {
        deliveryFeeLimit = double.parse(jsonMap['delivery_fee_limit']);
      } catch (e) {
        deliveryFeeLimit = double.maxFinite;
      }
      debug_url = jsonMap['debug_url'] == null ? null : jsonMap['debug_url'];
    } catch (e) {
      print(CustomTrace(StackTrace.current, message: e));
    }
  }

  Map toMap() {
    var map = new Map<String, dynamic>();
    map["app_name"] = appName;
    map["default_tax"] = defaultTax;
    map["default_currency"] = defaultCurrency;
    map["default_currency_decimal_digits"] = currencyDecimalDigits;
    map["currency_right"] = currencyRight;
    map["enable_paypal"] = payPalEnabled;
    map["enable_stripe"] = stripeEnabled;
    map["enable_razorpay"] = razorPayEnabled;
    map["mobile_language"] = mobileLanguage.value.languageCode;
    return map;
  }



  Map<String, double> getPromos(String val) {
    List<String> promos_str = val.split('-');
    Map<String, double> promos = new Map<String, double>();
    promos_str.forEach((element) {
      promos[element.split('_')[0]] = double.parse(element.split('_')[1]);
    });
    return promos;
  }
}
