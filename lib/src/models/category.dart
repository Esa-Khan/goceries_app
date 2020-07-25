import '../helpers/custom_trace.dart';
import '../models/media.dart';

class Category {
  String id;
  String name;
  Media image;
  String aisleImage;
  var IDtoCategoryMap = {
    '7': {"Baby Products", "https://goceries.org/storage/app/public/aisles/baby.png"},
    '8': {"Bakery Goods", "https://goceries.org/storage/app/public/aisles/bakery.png"},
    '9': {"Beverages", "https://goceries.org/storage/app/public/aisles/beverages.png"},
    '10': {"Breakfast", "https://goceries.org/storage/app/public/aisles/breakfast.png"},
    '12': {"Canned", "https://goceries.org/storage/app/public/aisles/canned.png"},
    '14': {"Cleaning", "https://goceries.org/storage/app/public/aisles/cleaning.png"},
    '16': {"Condiments/Spices", "https://goceries.org/storage/app/public/aisles/spices.png"},
    '17': {"Cooking", "https://goceries.org/storage/app/public/aisles/cooking.jpg"},
    '18': {"Dairy", "https://goceries.org/storage/app/public/aisles/dairy.png"},
    '20': {"Frozen Foods", "https://goceries.org/storage/app/public/aisles/frozen.png"},
    '22': {"Fruits", "https://goceries.org/storage/app/public/aisles/fruits.png"},
    '24': {"Grains & Pasta", "https://goceries.org/storage/app/public/aisles/grains.png"},
    '25': {"Misc.", "https://goceries.org/storage/app/public/aisles/misc.png"},
    '26': {"Personal Care", "https://goceries.org/storage/app/public/aisles/personal.png"},
    '28': {"Pets", "https://goceries.org/storage/app/public/aisles/pets.png"},
    '30': {"Protien", "https://goceries.org/storage/app/public/aisles/protiens.png"},
    '31': {"Snacks", "https://goceries.org/storage/app/public/aisles/snacks.png"},
    '32': {"Vegetables", "https://goceries.org/storage/app/public/aisles/vegetables.png"},
    };

  Category();

  Category.fromJSON(Map<String, dynamic> jsonMap) {
    try {
      id = jsonMap['id'].toString();
      name = jsonMap['name'];
      image = jsonMap['media'] != null && (jsonMap['media'] as List).length > 0 ? Media.fromJSON(jsonMap['media'][0]) : new Media();
      aisleImage = IDtoCategoryMap[id].elementAt(1);
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
    this.name = IDtoCategoryMap[this.id].elementAt(0);
    this.aisleImage = IDtoCategoryMap[this.id].elementAt(1);
  }


}
