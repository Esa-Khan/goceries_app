import 'package:flutter/material.dart';
import 'package:food_delivery_app/src/models/address.dart';
import 'package:food_delivery_app/src/models/category.dart';
import 'package:mvc_pattern/mvc_pattern.dart';

import '../../generated/l10n.dart';
import '../models/food.dart';
import '../models/gallery.dart';
import '../models/restaurant.dart';
import '../models/review.dart';
import '../repository/food_repository.dart';
import '../repository/gallery_repository.dart';
import '../repository/restaurant_repository.dart';
import '../repository/settings_repository.dart';
import '../models/category.dart';
import '../repository/category_repository.dart';


class RestaurantController extends ControllerMVC {
  Restaurant restaurant;
  List<Gallery> galleries = <Gallery>[];
  List<Food> foods = <Food>[];
  List<Category> aisles = <Category>[];
  List<Food> trendingFoods = <Food>[];
  List<Food> featuredFoods = <Food>[];
  List<Review> reviews = <Review>[];
  GlobalKey<ScaffoldState> scaffoldKey;

  RestaurantController() {
    this.scaffoldKey = new GlobalKey<ScaffoldState>();
  }

  void listenForRestaurant({String id, String message}) async {
    final Stream<Restaurant> stream = await getRestaurant(id, deliveryAddress.value);
    stream.listen((Restaurant _restaurant) {
      setState(() => restaurant = _restaurant);
    }, onError: (a) {
      print(a);
      scaffoldKey?.currentState?.showSnackBar(SnackBar(
        content: Text(S.of(context).verify_your_internet_connection),
      ));
    }, onDone: () {
      if (message != null) {
        scaffoldKey?.currentState?.showSnackBar(SnackBar(
          content: Text(message),
        ));
      }
    });
  }

  Future<void> listenForCategories() async {
    final Stream<Category> stream = await getCategories();
    stream.listen((Category _category) {
      setState(() => aisles.add(_category));
    }, onError: (a) {
      print(a);
    }, onDone: () {});
  }


  void listenForGalleries(String idRestaurant) async {
    final Stream<Gallery> stream = await getGalleries(idRestaurant);
    stream.listen((Gallery _gallery) {
      setState(() => galleries.add(_gallery));
    }, onError: (a) {}, onDone: () {});
  }

  void listenForRestaurantReviews({String id, String message}) async {
    final Stream<Review> stream = await getRestaurantReviews(id);
    stream.listen((Review _review) {
      setState(() => reviews.add(_review));
    }, onError: (a) {}, onDone: () {});
  }

  void listenForFoods(String idRestaurant) async {
    final Stream<Food> stream = await getFoodsOfRestaurant(idRestaurant);
    Food currFood;
    stream.listen((Food _food) {
      if (foods.isEmpty){
        setState(() => foods.add(_food));

      } else {
        for (int i = 0; i < foods.length; i++) {
          currFood = foods.elementAt(i);
          int temp = currFood.name.toString().compareTo(_food.name.toString());
          if (_food.name.toString().compareTo(currFood.name.toString()) < 0) {
            setState(() => foods.insert(i, _food));
            break;
          }
          if (i == foods.length - 1) {
            setState(() => foods.add(_food));
            break;
          }
        }
      }

    }, onError: (a) {
      print(a);
    }, onDone: () {});
  }

  void listenForSearchedFoods({String idRestaurant, String search}) async {
    Address _address = deliveryAddress.value;
    final Stream<Food> stream = await searchFoods(search, _address, storeID: idRestaurant);
    Food currFood;
    bool isOtherType = false;
    stream.listen((Food _food) {
      if (_food.ingredients != "<p>.</p>") {
        var IDs = _food.ingredients.split('-');
        isOtherType = (IDs.elementAt(0) != _food.id);
      }
      if (foods.isEmpty && !isOtherType){
        setState(() => foods.add(_food));
      } else if (!isOtherType){
        for (int i = 0; i < foods.length; i++) {
          currFood = foods.elementAt(i);
          int temp = currFood.name.toString().compareTo(_food.name.toString());
          if (_food.name.toString().compareTo(currFood.name.toString()) < 0) {
            setState(() => foods.insert(i, _food));
            break;
          }
          if (i == foods.length - 1) {
            setState(() => foods.add(_food));
            break;
          }
        }
      }
    }, onError: (a) {
      print(a);
    }, onDone: () {

    });
  }

  Future<void> refreshSearch(search) async {
    setState(() {
      foods = <Food>[];
    });
    listenForSearchedFoods(search: search, idRestaurant: restaurant.id);
  }

//  void listenForTrendingFoods(String idRestaurant) async {
//    final Stream<Food> stream = await getTrendingFoodsOfRestaurant(idRestaurant);
//    stream.listen((Food _food) {
//      setState(() => trendingFoods.add(_food));
//    }, onError: (a) {
//      print(a);
//    }, onDone: () {});
//  }

  void listenForFeaturedFoods(String idRestaurant) async {
    final Stream<Food> stream = await getFeaturedFoodsOfRestaurant(idRestaurant);
    stream.listen((Food _food) {
      setState(() => featuredFoods.add(_food));
    }, onError: (a) {
      print(a);
    }, onDone: () {});
  }

  Future<void> refreshRestaurant() async {
    var _id = restaurant.id;
    restaurant = new Restaurant();
    galleries.clear();
    reviews.clear();
    featuredFoods.clear();
    listenForRestaurant(id: _id, message: S.of(context).restaurant_refreshed_successfuly);
    listenForRestaurantReviews(id: _id);
    listenForGalleries(_id);
    listenForFeaturedFoods(_id);
  }
}
