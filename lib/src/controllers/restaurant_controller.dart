import 'dart:collection';

import 'package:flutter/material.dart';
import '../models/address.dart';
import '../models/category.dart';
import 'package:mvc_pattern/mvc_pattern.dart';

import '../../generated/l10n.dart';
import '../models/item.dart';
import '../models/gallery.dart';
import '../models/restaurant.dart';
import '../models/review.dart';
import '../repository/food_repository.dart';
import '../repository/gallery_repository.dart';
import '../repository/restaurant_repository.dart';
import '../repository/settings_repository.dart';
import '../repository/category_repository.dart';


class RestaurantController extends ControllerMVC {
  Restaurant restaurant;
  List<Gallery> galleries = <Gallery>[];

  List<Item> foods = <Item>[];
  List<Item> searchedItems = <Item>[];
  List<Item> allItems = <Item>[];
  bool allItemsLoaded = false;
  bool isLoading = false;
  var listRange = [0, 0];

  List<Category> aisles = <Category>[];
  HashMap aisleItemsList = new HashMap<String, List<Item>>();
  HashMap isExpandedList = new HashMap<String, bool>();
  HashMap isAisleLoadedList = new HashMap<String, bool>();

  List<Item> trendingFoods = <Item>[];
  List<Item> featuredFoods = <Item>[];
  List<Review> reviews = <Review>[];
  GlobalKey<ScaffoldState> scaffoldKey;


  RestaurantController() {
    this.scaffoldKey = new GlobalKey<ScaffoldState>();
  }

  Future<void> listenForRestaurant({String id, String message}) async {
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
      if (_category.id.length < 3) {
        setState(() {
          aisles.add(_category);
          isExpandedList[_category.id] = false;
          isAisleLoadedList[_category.id] = false;
          aisleItemsList[_category.id] = new List<Item>();
        });
      }

    }, onError: (a) {
      print(a);
    }, onDone: () {});
  }

  void listenForFoodsByCategory({String id, String storeID, String message}) async {
    if (!this.isAisleLoadedList[id]) {
      final Stream<Item> stream = await getFoodsByCategory(id, storeID: storeID);
      stream.listen((Item _food) {
        addItemToAisle(_food, id);
      }, onError: (a) {
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
  }


  void addItemToAisle(Item _food, String aisleID) {
    if (_food.ingredients != "<p>.</p>" && _food.ingredients != "0" && _food.ingredients != null) {
      var IDs = _food.ingredients.split('-');
      if (IDs.elementAt(0) == _food.id)
        setState(() => aisleItemsList[aisleID].add(_food));

    } else {
      setState(() => aisleItemsList[aisleID].add(_food));
    }
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
    final Stream<Item> stream = await getFoodsOfRestaurant(idRestaurant);
    stream.listen((Item _food) {
      setState(() => foods.add(_food));

    }, onError: (a) {
      print(a);
    }, onDone: () {});
  }

  void listenForAllItems(String idRestaurant) async {
    if (!allItemsLoaded) {
      final Stream<Item> stream = await getFoodsOfRestaurant(idRestaurant);
      stream.listen((Item _food) {
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
        setState(() {
          allItemsLoaded = true;
          this.foods = this.allItems;
        });


      });
    }
  }

  void listenForSearchedFoods({String idRestaurant, String search}) async {
    searchedItems.clear();
    Address _address = deliveryAddress.value;
      Stream<Item> initialStream = await searchFoods(search, _address, storeID: idRestaurant);
      initialStream.listen((Item _food) {
          setState(() => this.searchedItems.add(_food));
        }, onError: (a) {
          print(a);
        }, onDone: () async {
          print("-------- ${this.searchedItems.length.toString()} Items Searched--------");
        });
    }



  void listenForIncrementalItems({String idRestaurant, int limit}) async {
      if (!this.isLoading) {
        setState(() => isLoading = true);
        if (this.foods.isNotEmpty) {
          int lastItemID = int.parse(this.foods.last.id);
          String idRange = (lastItemID + 1).toString() + "-" + (lastItemID + limit).toString();
          int oldItemListLen = this.listRange.elementAt(1);
          Stream<Item> actualStream;
          if (restaurant.information == 'S') {
            actualStream = await getFeaturedFoodsOfRestaurant(idRestaurant, id: idRange);
          } else {
            actualStream = await getStoreItems(idRestaurant, id: idRange);
          }
          actualStream.listen((Item _food) {
            if (int.parse(foods.last.id) < int.parse(_food.id)) {
              addItem(_food);
            }
          }, onError: (a) {
            print(a);
          }, onDone: () async {
            this.isLoading = false;
            if (oldItemListLen == this.listRange.elementAt(1)) {
              allItemsLoaded = true;
              print("-------- ${this.foods.length.toString()} DONE--------");
            } else {
              print("-------- ${this.foods.length.toString()} Actual Items Added--------");
            }

          });
      } else {
        Stream<Item> initialStream;
        if (restaurant.information == 'S') {
          initialStream = await getFeaturedFoodsOfRestaurant(idRestaurant, limit: limit.toString());
        } else {
          initialStream = await getStoreItems(idRestaurant, limit: limit.toString());
        }
        initialStream.listen((Item _food) {
          addItem(_food);
        }, onError: (a) {
          print(a);
        }, onDone: () async {
          this.isLoading = false;
          print("-------- ${this.foods.length.toString()} Initial Items Added--------");
        });
      }
    }
  }


  void addItem(Item _food) {
    listRange.insert(1, listRange.elementAt(1) + 1);
    if (_food.ingredients != "<p>.</p>" && _food.ingredients != "0" &&
        _food.ingredients != null) {
      var IDs = _food.ingredients.split('-');
      if (IDs.elementAt(0) == _food.id) {
        setState(() => this.foods.add(_food));
        allItems.add(_food);
      }
    } else {
      setState(() => this.foods.add(_food));
      allItems.add(_food);
    }
  }



  Future<void> refreshSearch(search) async {
    setState(() {
      searchedItems = <Item>[];
    });
    if (search != null)
      await listenForSearchedFoods(search: search, idRestaurant: restaurant.id);
  }

//  void listenForTrendingFoods(String idRestaurant) async {
//    final Stream<Item> stream = await getTrendingFoodsOfRestaurant(idRestaurant);
//    stream.listen((Item _food) {
//      setState(() => trendingFoods.add(_food));
//    }, onError: (a) {
//      print(a);
//    }, onDone: () {});
//  }

  void listenForFeaturedFoods(String idRestaurant) async {
    final Stream<Item> stream = await getFeaturedFoodsOfRestaurant(idRestaurant);
    stream.listen((Item _food) {
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
