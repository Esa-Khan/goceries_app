import 'package:global_configuration/global_configuration.dart';
import '../helpers/custom_trace.dart';
import '../models/extra.dart';
import '../models/extra_group.dart';
import '../models/media.dart';
import '../models/nutrition.dart';
import '../models/restaurant.dart';
import '../models/review.dart';


class Item {
  String id;
  String name;
  double price;
  double discountPrice;
  Media image;
  String image_url;
  String description;
  String ingredients;
  String weight;
  int listing_order;
  String unit;
  int quantity;
  bool featured;
  bool deliverable;
  Restaurant restaurant;
  int category;
  List<Extra> extras;
  List<ExtraGroup> extraGroups;
  List<Review> foodReviews;
  List<Nutrition> nutritions;

  Item();

  Item.fromJSON(Map<String, dynamic> jsonMap) {
    if (jsonMap.isNotEmpty){
      try {
        id = jsonMap['id'].toString();
        name = jsonMap['name'];
        price = jsonMap['price'] != null ? jsonMap['price'].toDouble() : 0.0;
        discountPrice = jsonMap['discount_price'] != null ? jsonMap['discount_price'].toDouble() : 0.0;
        price = discountPrice != 0 ? discountPrice : price;
        discountPrice = discountPrice == 0 ? discountPrice : jsonMap['price'] != null ? jsonMap['price'].toDouble() : 0.0;
        description = jsonMap['description'] == "<p>.</p>" ? '' : jsonMap['description'];
        ingredients = jsonMap['ingredients'];
        weight = jsonMap['weight'] != null ? jsonMap['weight'].toString() : '';
        listing_order = jsonMap['listing_order'] != null ? jsonMap['listing_order'].toInt() : 0;
        unit = jsonMap['unit'] != null ? jsonMap['unit'].toString() : '';
        quantity = jsonMap['quantity'] == null ? 999 : jsonMap['quantity'];
        featured = jsonMap['featured'] ?? false;
        deliverable = jsonMap['deliverable'] ?? false;
        restaurant = jsonMap['restaurant'] != null ? Restaurant.fromJSON(jsonMap['restaurant']) : Restaurant.fromJSON({});
        price = price*restaurant.defaultTax + price;
        category = jsonMap['category_id'] != null ? jsonMap['category_id'] : 0;
        // image_url = jsonMap['image_url'] != null && jsonMap['image_url'] != "NULL" ? jsonMap['image_url'] : null;
        // if (jsonMap['image_url'] == null || jsonMap['image_url'].toString().substring(0, 7) == 'storage' || jsonMap['image_url'].toString().substring(0, 6) == 'images') {
        if (jsonMap['image_url'] == null) {
          image_url = '${GlobalConfiguration().getString('base_url')}storage/app/public/foods/${id}.jpg';
        } else {
          image_url = jsonMap['image_url'];
        }
        image = jsonMap['media'] != null && (jsonMap['media'] as List).length > 0 ? Media.fromJSON(jsonMap['media'][0])
            : image_url != null ? Media.fromURL(image_url): new Media(isCat: true);
        extras = jsonMap['extras'] != null && (jsonMap['extras'] as List).length > 0
            ? List.from(jsonMap['extras']).map((element) => Extra.fromJSON(element)).toSet().toList()
            : [];
        extraGroups = jsonMap['extra_groups'] != null && (jsonMap['extra_groups'] as List).length > 0
            ? List.from(jsonMap['extra_groups']).map((element) => ExtraGroup.fromJSON(element)).toSet().toList()
            : [];
        foodReviews = jsonMap['food_reviews'] != null && (jsonMap['food_reviews'] as List).length > 0
            ? List.from(jsonMap['food_reviews']).map((element) => Review.fromJSON(element)).toSet().toList()
            : [];
        nutritions = jsonMap['nutrition'] != null && (jsonMap['nutrition'] as List).length > 0
            ? List.from(jsonMap['nutrition']).map((element) => Nutrition.fromJSON(element)).toSet().toList()
            : [];
      } catch (e) {
        id = '';
        name = '';
        price = 0.0;
        discountPrice = 0.0;
        description = '';
        weight = '';
        ingredients = '';
        unit = '';
        quantity = 0;
        featured = false;
        deliverable = false;
        restaurant = Restaurant.fromJSON({});
//      category = Category.fromJSON({});
        category = 0;
        image = new Media();
        extras = [];
        extraGroups = [];
        foodReviews = [];
        nutritions = [];
        print(CustomTrace(StackTrace.current, message: e));
      }
    }
  }


  Map toMap() {
    var map = new Map<String, dynamic>();
    map["id"] = id;
    map["name"] = name;
    map["price"] = price;
    map["discount_price"] = discountPrice;
    map["description"] = description;
    map["quantity"] = quantity;
    map["ingredients"] = ingredients;
    map["weight"] = weight;
    return map;
  }

  @override
  bool operator ==(dynamic other) {
    return other.id == this.id;
  }

  @override
  int get hashCode => this.id.hashCode;
}
