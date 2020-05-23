import 'package:flutter/material.dart';
import 'package:mvc_pattern/mvc_pattern.dart';

import '../../generated/i18n.dart';
import '../models/food.dart';
import '../models/gallery.dart';
import '../models/restaurant.dart';
import '../models/review.dart';
import '../repository/food_repository.dart';
import '../repository/gallery_repository.dart';
import '../repository/restaurant_repository.dart';

class RestaurantController extends ControllerMVC {
  Restaurant restaurant;
  List<Gallery> galleries = <Gallery>[];
  List<Food> foods = <Food>[];
  List<Food> trendingFoods = <Food>[];
  List<Food> storeItems = <Food>[];
  List<Review> reviews = <Review>[];
  GlobalKey<ScaffoldState> scaffoldKey;

  RestaurantController() {
    this.scaffoldKey = new GlobalKey<ScaffoldState>();
  }

  void listenForRestaurant({String id, String message}) async {
    final Stream<Restaurant> stream = await getRestaurant(id);
    stream.listen((Restaurant _restaurant) {
      setState(() => restaurant = _restaurant);
    }, onError: (a) {
      print(a);
      scaffoldKey.currentState.showSnackBar(SnackBar(
        content: Text(S.current.verify_your_internet_connection),
      ));
    }, onDone: () {
      if (message != null) {
        scaffoldKey.currentState.showSnackBar(SnackBar(
          content: Text(message),
        ));
      }
    });
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
    stream.listen((Food _food) {
      setState(() => foods.add(_food));
    }, onError: (a) {
      print(a);
    }, onDone: () {});
  }

  void listenForTrendingFoods(String idRestaurant) async {
    final Stream<Food> stream = await getTrendingFoodsOfRestaurant(idRestaurant);
    stream.listen((Food _food) {
      setState(() => trendingFoods.add(_food));
    }, onError: (a) {
      print(a);
    }, onDone: () {});
  }

  void listenForFeaturedFoods(String idRestaurant) async {
    final Stream<Food> stream = await getFeaturedFoodsOfRestaurant(idRestaurant);
    stream.listen((Food _food) {
      if (storeItems.length == 0) {
        setState(() => storeItems.add(_food));
      } else {
        // Alphabetically arrange items
        String currFood = _food.name.toLowerCase();
        for (int i = 0; i < storeItems.length; i++) {
          String temp = storeItems.elementAt(i).name.toLowerCase();
          if (!temp.compareTo(currFood).isNegative) {
            setState(() => storeItems.insert(i, _food));
            break;
          } else if(i == storeItems.length - 1){
            setState(() => storeItems.add(_food));
            break;
          }
        }

      }


    }, onError: (a) {
      print(a);
    }, onDone: () {});
  }


  Future<void> refreshRestaurant() async {
    var _id = restaurant.id;
    restaurant = new Restaurant();
    galleries.clear();
    reviews.clear();
    storeItems.clear();
    listenForRestaurant(id: _id, message: S.current.restaurant_refreshed_successfuly);
    listenForRestaurantReviews(id: _id);
    listenForGalleries(_id);
    listenForFeaturedFoods(_id);
  }
}
