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
  List<Food> searchedItems = <Food>[];
  List<Food> allItems = <Food>[];
  bool allItemsLoaded = false;

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
    stream.listen((Food _food) {
      setState(() => foods.add(_food));

    }, onError: (a) {
      print(a);
    }, onDone: () {});
  }

  void listenForAllItems(String idRestaurant) async {
    if (!allItemsLoaded) {
      final Stream<Food> stream = await getFoodsOfRestaurant(idRestaurant);
      stream.listen((Food _food) {
        if (_food.ingredients != "<p>.</p>" && _food.ingredients != "0" && _food.ingredients != null) {
          var IDs = _food.ingredients.split('-');
          if (IDs.elementAt(0) == _food.id)
            setState(() => this.allItems.add(_food));
        } else {
            setState(() => this.allItems.add(_food));
        }

      }, onError: (a) {
        print(a);
      }, onDone: () {
        print("All items loaded: ${allItems.length}");
        setState(() => allItemsLoaded = true);


      });
    }
  }

  void listenForSearchedFoods({String idRestaurant, String search}) async {
    searchedItems.clear();
    Address _address = deliveryAddress.value;
      Stream<Food> initialStream = await searchFoods(search, _address, storeID: idRestaurant);
      initialStream.listen((Food _food) {
          setState(() => this.searchedItems.add(_food));
//          addItem(_food);
        }, onError: (a) {
          print(a);
        }, onDone: () async {
          print("-------- ${this.searchedItems.length.toString()} Items Searched--------");
        });
    }



  void listenForIncrementalItems({String idRestaurant, int limit}) async {
    if (allItemsLoaded && this.foods.length < allItems.length ){
      if (this.foods.length + limit < allItems.length) {
        setState(() => this.foods.addAll(List.from(allItems.sublist(this.foods.length, this.foods.length + limit))));
      } else {
        setState(() => this.foods.addAll(List.from(allItems.sublist(this.foods.length))));
      }
    } else {
      if (this.foods.isNotEmpty) {
        int lastItemID = int.parse(this.foods.last.id);
        String idRange = (lastItemID + 1).toString() + "-" + (lastItemID + limit).toString();
        Stream<Food> actualStream = await getStoreItems(idRestaurant, id: idRange);
        actualStream.listen((Food _food) {
          addItem(_food);

        }, onError: (a) {
          print(a);
        }, onDone: () async {
          print("-------- ${this.foods.length.toString()} Actual Items Added--------");
        });
      } else {

        Stream<Food> initialStream = await getStoreItems(idRestaurant, limit: limit.toString());
        initialStream.listen((Food _food) {
          addItem(_food);
        }, onError: (a) {
          print(a);
        }, onDone: () async {
          print("-------- ${this.foods.length.toString()} Initial Items Added--------");
        });
      }
    }
  }











  void addItem(Food _food) {
    if (_food.ingredients != "<p>.</p>" && _food.ingredients != "0" && _food.ingredients != null) {
      var IDs = _food.ingredients.split('-');
      if (IDs.elementAt(0) == _food.id)
        setState(() => this.foods.add(_food));
    } else {
      setState(() => this.foods.add(_food));
    }
  }



  Future<void> refreshSearch(search) async {
    setState(() {
      searchedItems = <Food>[];
    });
    await listenForSearchedFoods(search: search, idRestaurant: restaurant.id);
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
