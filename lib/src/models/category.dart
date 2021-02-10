import 'package:global_configuration/global_configuration.dart';

import '../helpers/custom_trace.dart';
import '../models/media.dart';

class Category {
  String id;
  String name;
  String desc;
  Media image;
  String aisleImage;
  bool isGeneralCat = false;

  Category();

  Category.fromJSON(Map<String, dynamic> jsonMap) {
    try {
      id = jsonMap['id'].toString();
      name = jsonMap['name'];
      image = jsonMap['media'] != null && (jsonMap['media'] as List).length > 0 ? Media.fromJSON(jsonMap['media'][0]) : new Media(isCat: true);
      isGeneralCat = jsonMap['isGeneralCat'] == 0 ? false : true;
//      aisleImage = IDtoCategoryMap[id].elementAt(1);
      aisleImage = jsonMap['description'] == "" || jsonMap['description'] == null
          ? '${GlobalConfiguration().getString('base_url')}storage/app/public/aisles/misc.jpg'
          : '${GlobalConfiguration().getString('base_url')}storage/app/public/aisles/${jsonMap['description']}';
    } catch (e) {
      id = '';
      name = '';
      image = new Media();
      isGeneralCat = false;
      print(CustomTrace(StackTrace.current, message: e));
    }
  }

}
