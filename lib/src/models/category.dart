import '../helpers/custom_trace.dart';
import '../models/media.dart';

class Category {
  String id;
  String name;
  Media image;
  String aisleImage;

  Category();

  Category.fromJSON(Map<String, dynamic> jsonMap) {
    try {
      id = jsonMap['id'].toString();
      name = jsonMap['name'];
      image = jsonMap['media'] != null && (jsonMap['media'] as List).length > 0 ? Media.fromJSON(jsonMap['media'][0]) : new Media();
      aisleImage = getAisleImage(int.parse(id));
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
        aisleImage = "assets/img/aisles/baby.png";
        break;
      case (8):
        this.name = "Bakery Goods";
        aisleImage = "assets/img/aisles/bakery.png";
        break;
      case (9):
        this.name = "Beverages";
        aisleImage = "assets/img/aisles/beverages.png";
        break;
      case (10):
        this.name = "Breakfast";
        aisleImage = "assets/img/aisles/breakfast.png";
        break;
      case (12):
        this.name = "Canned";
        this.aisleImage = "assets/img/aisles/canned.png";
        break;
      case (14):
        this.name = "Cleaning";
        this.aisleImage = "assets/img/aisles/cleaning.png";
        break;
      case (16):
        this.name = "Condiments/Spices";
        this.aisleImage = "assets/img/aisles/spices.png";
        break;
      case (18):
        this.name = "Dairy";
        this.aisleImage = "assets/img/aisles/dairy.png";
        break;
      case (20):
        this.name = "Frozen Foods";
        this.aisleImage = "assets/img/aisles/frozen.png";
        break;
      case (22):
        this.name = "Fruits";
        this.aisleImage = "assets/img/aisles/fruits.png";
        break;
      case (24):
        this.name = "Grains & Pasta";
        this.aisleImage = "assets/img/aisles/grains.png";
        break;
      case (26):
        this.name = "Personal Care";
        this.aisleImage = "assets/img/aisles/personal.png";
        break;
      case (28):
        this.name = "Pets";
        this.aisleImage = "assets/img/aisles/pets.png";
        break;
      case (30):
        this.name = "Protien";
        this.aisleImage = "assets/img/aisles/protiens.png";
        break;
      case (32):
        this.name = "Vegetables";
        this.aisleImage = "assets/img/aisles/vegetables.png";
        break;
      default:
        this.name = null;
    }
  }
  String getAisleImage(int id){
    switch (id){
      case (7):
        return "assets/img/aisles/baby.png";
        break;
      case (8):
        return "assets/img/aisles/bakery.png";
        break;
      case (9):
        return "assets/img/aisles/beverages.png";
        break;
      case (10):
        return "assets/img/aisles/breakfast.png";
        break;
      case (12):
        return "assets/img/aisles/canned.png";
        break;
      case (14):
        return "assets/img/aisles/cleaning.png";
        break;
      case (16):
        return "assets/img/aisles/spices.png";
        break;
      case (18):
        return "assets/img/aisles/dairy.png";
        break;
      case (20):
        return "assets/img/aisles/frozen.png";
        break;
      case (22):
        return "assets/img/aisles/fruits.png";
        break;
      case (24):
        return "assets/img/aisles/grains.png";
        break;
      case (26):
        return "assets/img/aisles/personal.png";
        break;
      case (28):
        return "assets/img/aisles/pets.png";
        break;
      case (30):
        return "assets/img/aisles/protiens.png";
        break;
      case (32):
        return "assets/img/aisles/vegetables.png";
        break;
      default:
        this.name = null;
    }
  }


}
