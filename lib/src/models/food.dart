import 'package:food_delivery_app/src/controllers/food_controller.dart';
import 'package:food_delivery_app/src/models/address.dart';
import 'package:food_delivery_app/src/repository/restaurant_repository.dart';

import '../helpers/custom_trace.dart';
import '../models/category.dart';
import '../models/extra.dart';
import '../models/extra_group.dart';
import '../models/media.dart';
import '../models/nutrition.dart';
import '../models/restaurant.dart';
import '../models/review.dart';
import '../controllers/food_controller.dart' as foodCon;


class Food {
  String id;
  String name;
  double price;
  double discountPrice;
  Media image;
  String description;
  String ingredients;
  String weight;
  String unit;
  String packageItemsCount;
  bool featured;
  bool deliverable;
  Restaurant restaurant;
  Category category;
  List<Extra> extras;
  List<ExtraGroup> extraGroups;
  List<Review> foodReviews;
  List<Nutrition> nutritions;

  Food();

  Food.fromJSON(Map<String, dynamic> jsonMap) {
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
      unit = jsonMap['unit'] != null ? jsonMap['unit'].toString() : '';
      packageItemsCount = jsonMap['package_items_count'].toString();
      featured = jsonMap['featured'] ?? false;
      deliverable = jsonMap['deliverable'] ?? false;
      restaurant = jsonMap['restaurant'] != null ? Restaurant.fromJSON(jsonMap['restaurant']) : Restaurant.fromJSON({});
      price = price*restaurant.defaultTax + price;
      try {
        category = jsonMap['category_id'] != null ? Category.fromJSON(jsonMap['category_id']) : Category.fromJSON({});
      } catch (e) {
        category = jsonMap['category_id'] != null ? Category.fromID(jsonMap['category_id']) : Category.fromJSON({});
      };
      image = jsonMap['media'] != null && (jsonMap['media'] as List).length > 0 ? Media.fromJSON(jsonMap['media'][0]) : new Media();
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
      packageItemsCount = '';
      featured = false;
      deliverable = false;
      restaurant = Restaurant.fromJSON({});
      category = Category.fromJSON({});
      image = new Media();
      extras = [];
      extraGroups = [];
      foodReviews = [];
      nutritions = [];
      print(CustomTrace(StackTrace.current, message: e));
    }
  }



  Food.fromID(int id) {
    try {
      FoodController _con = new FoodController();
      _con.listenForFood(foodId: id.toString());
      id = int.parse(_con.food.id);
      name = _con.food.name;
      price = _con.food.price;
      discountPrice = _con.food.discountPrice;
      description = _con.food.description;
      ingredients = _con.food.ingredients;
      weight = _con.food.weight;
      unit = _con.food.unit;
      packageItemsCount = _con.food.packageItemsCount;
      featured = _con.food.featured;
      deliverable = _con.food.deliverable;
      restaurant = _con.food.restaurant;
      category = _con.food.category;
      image = _con.food.image;
      extras = _con.food.extras;
      extraGroups = _con.food.extraGroups;
      foodReviews = _con.food.foodReviews;
      nutritions = _con.food.nutritions;
    } catch (e) {
      id = 0;
      name = '';
      price = 0.0;
      discountPrice = 0.0;
      description = '';
      weight = '';
      ingredients = '';
      unit = '';
      packageItemsCount = '';
      featured = false;
      deliverable = false;
      restaurant = Restaurant.fromJSON({});
      category = Category.fromJSON({});
      image = new Media();
      extras = [];
      extraGroups = [];
      foodReviews = [];
      nutritions = [];
      print(CustomTrace(StackTrace.current, message: e));
    }
  }


  Map toMap() {
    var map = new Map<String, dynamic>();
    map["id"] = id;
    map["name"] = name;
    map["price"] = price;
    map["discountPrice"] = discountPrice;
    map["description"] = description;
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
