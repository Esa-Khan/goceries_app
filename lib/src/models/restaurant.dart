import '../helpers/custom_trace.dart';
import '../models/media.dart';

class Restaurant {
  String id;
  String name;
  Media image;
  String rate;
  String address;
  String used_cats;
  String description;
  String phone;
  String mobile;
  String information;
  double deliveryFee;
  double adminCommission;
  double defaultTax;
  String latitude;
  String longitude;
  bool closed;
  bool availableForDelivery;
  double deliveryRange;
  double distance;

  Restaurant();

  Restaurant.fromJSON(Map<String, dynamic> jsonMap) {
    try {
      id = jsonMap['id'].toString();
      name = jsonMap['name'];
      image = jsonMap['media'] != null && (jsonMap['media'] as List).length > 0 ? Media.fromJSON(jsonMap['media'][0]) : new Media();
      rate = jsonMap['rate'] ?? '0';
      deliveryFee = jsonMap['delivery_fee'] != null ? jsonMap['delivery_fee'].toDouble() : 0.0;
      adminCommission = jsonMap['admin_commission'] != null ? jsonMap['admin_commission'].toDouble() : 0.0;
      deliveryRange = jsonMap['delivery_range'] != null ? jsonMap['delivery_range'].toDouble() : 0.0;
      address = jsonMap['address'];
      used_cats = jsonMap['used_categories'] != null ? jsonMap['used_categories'] : null;
      description = jsonMap['description'];
      phone = jsonMap['phone'];
      mobile = jsonMap['mobile'];
      defaultTax = jsonMap['default_tax'] != null ? jsonMap['default_tax'].toDouble() : 0.0;
      information = jsonMap['information'] != null ? jsonMap['information'] : null;
      latitude = jsonMap['latitude'];
      longitude = jsonMap['longitude'];
      closed = isClosed(description);
      availableForDelivery = jsonMap['available_for_delivery'] ?? false;
      distance = jsonMap['distance'] != null ? double.parse(jsonMap['distance'].toString()) : 0.0;
    } catch (e) {
      id = '';
      name = '';
      image = new Media();
      rate = '0';
      deliveryFee = 0.0;
      adminCommission = 0.0;
      deliveryRange = 0.0;
      address = '';
      description = '';
      phone = '';
      mobile = '';
      defaultTax = 0.0;
      information = '';
      latitude = '0';
      longitude = '0';
      closed = false;
      availableForDelivery = false;
      distance = 0.0;
      print(CustomTrace(StackTrace.current, message: e));
    }
  }

  Map<String, dynamic> toMap() {
    return {
      'id': id,
      'name': name,
      'latitude': latitude,
      'longitude': longitude,
      'delivery_fee': deliveryFee,
      'distance': distance,
    };
  }

  bool isClosed(String desc){
    if (desc == null) {
      return true;
    } else if (desc == "24/7") {
      return true;
    }

    bool closed = true;
//    var now = new DateTime.now().hour + new DateTime.now().minute/100;
    var now = 12;
    var times = desc.toString().replaceAll(" ", "").replaceAll("m", "").replaceAll("<p>", "").replaceAll("</p>", "").split('-');
    var openTime_hour = -1, closeTime_hour = -1, openTime_min = 0, closeTime_min = 0;

    if (times[0].contains(":")) {
      openTime_min = int.parse(times[0].substring(times[0].indexOf(':') + 1, times[0].length-1));
      times[0] = times[0].replaceAll(":" + openTime_min.toString(), "");
    }

    if (times[0].endsWith('a') || (times[1].contains("12") && times[1].endsWith("p"))){
      openTime_hour = int.parse(times[0].replaceAll("p", "").replaceAll("a", ""));
    } else if (times[0].endsWith('p') || (times[1].contains("12") && times[1].endsWith("a"))) {
      openTime_hour = 12 + int.parse(times[0].replaceAll("p", "").replaceAll("a", ""));
    }


    if (times[1].contains(":")) {
      closeTime_min = int.parse(times[1].substring(times[1].indexOf(':') + 1, times[1].length-1));
      times[1] = times[1].replaceAll(":" + closeTime_min.toString(), "");
    }

    if (times[1].endsWith('p') || (times[1].contains("12") && times[1].endsWith("a"))){
      closeTime_hour = 12 + int.parse(times[1].replaceAll("p", "").replaceAll("a", ""));
    } else if ((times[1].endsWith('a') && int.parse(times[1].replaceAll("a", "")) > openTime_hour) || (times[1].contains("12") && times[1].endsWith("p"))) {
      closeTime_hour = int.parse(times[1].replaceAll("p", "").replaceAll("a", ""));
    } else if (times[1].endsWith("a") && int.parse(times[1].replaceAll("a", "")) < openTime_hour) {
      closeTime_hour = 24 + int.parse(times[1].replaceAll("a", ""));
    }

    if (now >= (openTime_hour + openTime_min/100) && now <= (closeTime_hour + closeTime_min/100))
      closed = false;


    return closed;
  }

}
