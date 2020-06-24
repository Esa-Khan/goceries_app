import '../helpers/custom_trace.dart';
import '../models/media.dart';

class Category {
  String id;
  String name;
  Media image;

  Category();

  Category.fromJSON(Map<String, dynamic> jsonMap) {
    try {
      id = jsonMap['id'].toString();
      name = jsonMap['name'];
      image = jsonMap['media'] != null && (jsonMap['media'] as List).length > 0 ? Media.fromJSON(jsonMap['media'][0]) : new Media();
    } catch (e) {
      id = '';
      name = '';
      image = new Media();
      print(CustomTrace(StackTrace.current, message: e));
    }
  }
  // Get category from category_id in food model
  Category.fromID(int id){
    this.id = id.toString();
    switch (id){
      case (7):
        this.name = "Baby Products";
        break;
      case (8):
        this.name = "Bakery Goods";
        break;
      case (9):
        this.name = "Beverages";
        break;
      case (10):
        this.name = "Breakfast";
        break;
      case (12):
        this.name = "Canned";
        break;
      case (14):
        this.name = "Cleaning";
        break;
      case (16):
        this.name = "Condiments/Spices";
        break;
      case (18):
        this.name = "Dairy";
        break;
      case (20):
        this.name = "Frozen Foods";
        break;
      case (22):
        this.name = "Fruits";
        break;
      case (24):
        this.name = "Grains & Pasta";
        break;
      case (26):
        this.name = "Personal Care";
        break;
      case (28):
        this.name = "Pets";
        break;
      case (30):
        this.name = "Protien";
        break;
      case (32):
        this.name = "Vegetables";
        break;
      default:
        this.name = null;
    }


  }
}
