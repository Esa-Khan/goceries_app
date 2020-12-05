import 'package:global_configuration/global_configuration.dart';

import '../helpers/custom_trace.dart';
import 'package:http/http.dart' as http;

class Media {
  String id;
  String name;
  String url;
  String thumb;
  String icon;
  String size;

  Media({bool isCat}) {
    if (isCat == null) {
      url = "${GlobalConfiguration().getString('base_url')}images/image_default.png";
      thumb = "${GlobalConfiguration().getString('base_url')}images/image_default.png";
      icon = "${GlobalConfiguration().getString('base_url')}images/image_default.png";
    } else if(!isCat) {
      url = "${GlobalConfiguration().getString('base_url')}images/avatar_default.png";
      thumb = "${GlobalConfiguration().getString('base_url')}images/avatar_default.png";
      icon = "${GlobalConfiguration().getString('base_url')}images/avatar_default.png";
    } else {
      url = 'assets/img/misc.svg';
      thumb = 'assets/img/misc.svg';
      icon = 'assets/img/misc.svg';
    }
  }



  Media.fromURL (String image_url) {
        try {
          url = image_url;
          thumb = image_url;
          icon = image_url;
        } catch (e) {
          url = "${GlobalConfiguration().getString('base_url')}images/image_default.png";
          thumb = "${GlobalConfiguration().getString('base_url')}images/image_default.png";
          icon = "${GlobalConfiguration().getString('base_url')}images/image_default.png";
          print(CustomTrace(StackTrace.current, message: e));
        }
  }

  Media.fromJSON(Map<String, dynamic> jsonMap) {
    try {
      id = jsonMap['id'].toString();
      name = jsonMap['name'];
      url = jsonMap['url'];
      thumb = jsonMap['thumb'];
      icon = jsonMap['icon'];
      size = jsonMap['formated_size'];
    } catch (e) {
      url = "${GlobalConfiguration().getString('base_url')}images/image_default.png";
      thumb = "${GlobalConfiguration().getString('base_url')}images/image_default.png";
      icon = "${GlobalConfiguration().getString('base_url')}images/image_default.png";
      print(CustomTrace(StackTrace.current, message: e));
    }
  }

  Map toMap() {
    var map = new Map<String, dynamic>();
    map["id"] = id;
    map["name"] = name;
    map["url"] = url;
    map["thumb"] = thumb;
    map["icon"] = icon;
    map["formated_size"] = size;
    return map;
  }

  @override
  String toString() {
    return this.toMap().toString();
  }
}
