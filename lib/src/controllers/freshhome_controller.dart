import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import '../../src/repository/user_repository.dart';
import 'package:mvc_pattern/mvc_pattern.dart';

import '../helpers/helper.dart';
import '../models/category.dart';
import '../models/item.dart';
import '../models/restaurant.dart';
import '../models/review.dart';
import '../repository/category_repository.dart';
import '../repository/restaurant_repository.dart';
import '../repository/settings_repository.dart';
import '../repository/settings_repository.dart' as settingsRepo;

class FreshHomeController extends ControllerMVC {
  List<Category> categories = <Category>[];
  List<Restaurant> closestStores = <Restaurant>[];
  Restaurant store;
  List<Restaurant> popularRestaurants = <Restaurant>[];
  List<Review> recentReviews = <Review>[];
  List<Item> trendingFoods = <Item>[];

  FreshHomeController() {
  }

  Future<void> listenForCategories() async {
    final Stream<Category> stream = await getCategories();
    stream.listen((Category _category) {
      if (_category.id.length > 2 && _category.name != 'Misc.') {
        setState(() {
          categories.add(_category);
        });
      }
    }, onError: (a) {
      print(a);
    }, onDone: () {});
  }

  Future<void> listenForGeneralCategories() async {
    List<String> category_list = ['22', '30', '36'];
    category_list.forEach((element) async {
      final Stream<Category> stream = await getCategory(element);
      stream.listen((Category _category) {
        if (_category.id.length > 2 && _category.name != 'Misc.' && _category.isGeneralCat) {
          setState(() {
            categories.add(_category);
          });
        }
      }, onError: (a) {
        print(a);
      }, onDone: () {});
    });
  }

  Future<void> listenForClosestStores() async {
    final Stream<Restaurant> stream = await getNearStores(deliveryAddress.value, deliveryAddress.value, isStore: settingsRepo.isStore.value == 1);
    stream.listen((Restaurant _restaurant) {
      if (_restaurant.distance < _restaurant.deliveryRange)
        setState(() => closestStores.add(_restaurant));
    }, onError: (a) {}, onDone: () {});
  }

  Future<void> listenForClosestRestaurants() async {
    final Stream<Restaurant> stream = await getNearStores(deliveryAddress.value, deliveryAddress.value, isStore: false);
    stream.listen((Restaurant _restaurant) {
      if (_restaurant.distance < _restaurant.deliveryRange)
        setState(() => closestStores.add(_restaurant));
    }, onError: (a) {}, onDone: () {});
  }

//  Future<void> listenForPopularRestaurants() async {
//    final Stream<Restaurant> stream = await getPopularRestaurants(deliveryAddress.value);
//    stream.listen((Restaurant _restaurant) {
//      setState(() => popularRestaurants.add(_restaurant));
//    }, onError: (a) {}, onDone: () {});
//  }

  Future<void> listenForRecentReviews() async {
    final Stream<Review> stream = await getRecentReviews();
    stream.listen((Review _review) {
      setState(() => recentReviews.add(_review));
    }, onError: (a) {}, onDone: () {});
  }

//  Future<void> listenForTrendingFoods() async {
//    final Stream<Item> stream = await getTrendingFoods(deliveryAddress.value);
//    stream.listen((Item _food) {
//      setState(() => trendingFoods.add(_food));
//    }, onError: (a) {
//      print(a);
//    }, onDone: () {});
//  }

  void requestForCurrentLocation(BuildContext context) {
    OverlayEntry loader = Helper.overlayLoader(context);
    Overlay.of(context).insert(loader);
    setCurrentLocation().then((_address) async {
      setState(() => deliveryAddress.value = _address);
      if (currentUser.value.apiToken != null) {
        currentUser.value.address = _address.address;
      }
      //      currentUser.value.address = _address.address;
      await refreshHome();
      loader.remove();
    }).catchError((e) {
      loader.remove();
    });
  }

  Future<void> getStore() async {
    final Stream<Restaurant> stream = await getRestaurant('1', deliveryAddress.value);
    stream.listen((Restaurant _restaurant) {
      setState(() => store = _restaurant);
    }, onError: (a) {
      print(a);
    });
  }


  Future<void> refreshHome() async {
    setState(() {
      categories = <Category>[];
      closestStores = <Restaurant>[];
//      popularRestaurants = <Restaurant>[];
      recentReviews = <Review>[];
//      trendingFoods = <Item>[];
    });
    await listenForClosestStores();
//    await listenForTrendingFoods();
    await listenForCategories();
//    await listenForPopularRestaurants();
    await listenForRecentReviews();
  }
}
