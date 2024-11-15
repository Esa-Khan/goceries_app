import '../helpers/custom_trace.dart';
import '../models/media.dart';

class User {
  String id;
  String name;
  String email;
  String password;
  String confirm_password;
  String apiToken;
  String deviceToken;
  String phone;
  String address;
  String bio;
  Media image;
  bool isDriver = false;
  bool available = null;
  bool isManager = false;
  bool debugger = false;
  String work_hours;
  String store_ids;


  // used for indicate if client logged in or not
  bool auth;

//  String role;

  User();

  User.fromJSON(Map<String, dynamic> jsonMap) {
    try {
      id = jsonMap['id'].toString();
      name = jsonMap['name'] != null ? jsonMap['name'] : '';
      email = jsonMap['email'] != null ? jsonMap['email'] : '';
      apiToken = jsonMap['api_token'];
      deviceToken = jsonMap['device_token'];
      try {
        phone = jsonMap['custom_fields']['phone']['view'];
      } catch (e) {
        phone = "";
      }
      phone = jsonMap['number'];
      try {
        address = jsonMap['custom_fields']['address']['view'];
      } catch (e) {
        address = "";
      }
      try {
        bio = jsonMap['custom_fields']['bio']['view'];
      } catch (e) {
        bio = "";
      }
      image = jsonMap['media'] != null && (jsonMap['media'] as List).length > 0 ? Media.fromJSON(jsonMap['media'][0]) : new Media(isCat: false);
      isDriver = jsonMap['isDriver'] == 0 || jsonMap['isDriver'] == null ? false : true;
      isManager = jsonMap['isManager'] == 0 || jsonMap['isManager'] == null ? false : true;
      isDriver = isDriver || isManager;
      if (isDriver) {
        work_hours = jsonMap['work_hours'];
        store_ids = jsonMap['store_ids'];
        available = jsonMap['available'];
      }
      debugger = jsonMap['debugger'] == 1;
    } catch (e) {
      print(CustomTrace(StackTrace.current, message: e));
    }
  }

  Map toMap() {
    var map = new Map<String, dynamic>();
    map["id"] = id;
    map["email"] = email;
    map["name"] = name;
    map["password"] = password;
    map["api_token"] = apiToken;
    if (deviceToken != null) {
      map["device_token"] = deviceToken;
    }
    map["phone"] = phone;
    map["number"] = phone;
    map["address"] = address;
    map["bio"] = bio;
    map["media"] = image?.toMap();
    map["isDriver"] = isDriver;
    map["isManager"] = isManager;
    return map;
  }

  @override
  String toString() {
    var map = this.toMap();
    map["auth"] = this.auth;
    return map.toString();
  }

  bool profileCompleted() {
//    return address != null && address != '' && phone != null && phone != '';
    return phone != null && phone != '';
  }
}
