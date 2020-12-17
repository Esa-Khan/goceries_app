import 'package:flutter/material.dart';
import '../models/address.dart';
import '../models/restaurant.dart';
import '../repository/settings_repository.dart';
import 'package:mvc_pattern/mvc_pattern.dart';

import '../../generated/l10n.dart';
import '../models/cart.dart';
import '../models/category.dart';
import '../models/food.dart';
import '../repository/cart_repository.dart';
import '../repository/category_repository.dart';
import '../repository/food_repository.dart';
import 'dart:collection';

class CategoryController extends ControllerMVC {
  List<Food> foods = <Food>[];
  bool noItems = false;
  GlobalKey<ScaffoldState> scaffoldKey;
  Category category;
  bool loadCart = false;
  List<Cart> carts = [];
  List<Food> searchedItems = <Food>[];
  bool isLoading = false;
  Restaurant restaurant;

  List<Category> aisles = <Category>[];
  bool hasAislesLoaded = false;
  HashMap aisleToSubaisleMap = new HashMap<String, List<Category>>();
  HashMap subaisleToItemsMap = new HashMap<String, List<Food>>();
  HashMap isExpandedList = new HashMap<String, bool>();
  HashMap isAisleLoadedList = new HashMap<String, bool>();
  List<String> loadedSubaisles = <String>[];

  CategoryController() {
    this.scaffoldKey = new GlobalKey<ScaffoldState>();

  }


  Future<void> listenForCategories() async {
    final Stream<Category> stream = await getCategories();
    stream.listen((Category _aisle) {
      if (_aisle.id.length > 2) {
        String mainAisleID = _aisle.id.substring(_aisle.id.length - 2, _aisle.id.length);
        mainAisleID = (int.parse(mainAisleID)).toString();
        if (aisleToSubaisleMap[mainAisleID] == null) {
          aisleToSubaisleMap[mainAisleID] = new List<Category>();
          setState(() => aisleToSubaisleMap[mainAisleID].add(_aisle));
        } else {
          setState(() => aisleToSubaisleMap[mainAisleID].add(_aisle));
        }
        setState(() => subaisleToItemsMap[_aisle.id] = new List<Food>());
      } else {
        setState(() => aisles.add(_aisle));
      }
        setState(() {
          isExpandedList[_aisle.id] = false;
          isAisleLoadedList[_aisle.id] = false;
        });
    }, onError: (a) {
      print(a);
    }, onDone: () {
      setState(() => hasAislesLoaded = true);
    });
  }


  Future<void> listenForUsedCategories(String storeID) async {
    final Stream<Category> stream = await getUsedCategories(storeID);
    stream.listen((Category _category) async {
        if (_category.id.length > 2) {
          String mainAisleID = _category.id.substring(_category.id.length - 2, _category.id.length);
          mainAisleID = (int.parse(mainAisleID)).toString();
          if (aisleToSubaisleMap[mainAisleID] == null) {
            aisleToSubaisleMap[mainAisleID] = new List<Category>();
            setState(() => aisleToSubaisleMap[mainAisleID].add(_category));
          } else {
            setState(() => aisleToSubaisleMap[mainAisleID].add(_category));
          }
          setState(() => subaisleToItemsMap[_category.id] = new List<Food>());


        } else {
          setState(() => aisles.add(_category));
        }

        setState(() {
          isExpandedList[_category.id] = false;
          isAisleLoadedList[_category.id] = false;
        });
    }, onError: (a) {
      print(a);
    }, onDone: () {
      setState(() => hasAislesLoaded = true);
    });
  }



  void listenForFoodsByCategory({String id, String message}) async {
      final Stream<Food> stream = await getFoodsByCategory(id);
      stream.listen((Food _food) {
        setState(() => this.foods.add(_food));
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

  void listenForItemsByCategory(String id, {String storeID, String message}) async {
    if (!this.isAisleLoadedList[id]) {
      final Stream<Food> stream = await getFoodsByCategory(id, storeID: storeID);
      stream.listen((Food _food) {
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


  void addItemToAisle(Food _food, String aisleID) {
    if (this.subaisleToItemsMap[aisleID] == null)
      this.subaisleToItemsMap[aisleID] = new List<Food>();

    if (_food.ingredients != "<p>.</p>" &&
        _food.ingredients != "0" &&
        _food.ingredients != null) {
      var IDs = _food.ingredients.split('-');
      if (IDs.elementAt(0) == _food.id)
        setState(() => this.subaisleToItemsMap[aisleID].add(_food));
//        subaisleToItemsMap[aisleID].add(_food);
    } else {
      setState(() => this.subaisleToItemsMap[aisleID].add(_food));
//      subaisleToItemsMap[aisleID].add(_food);
    }
  }

  Future<Category> listenForCategory({String id, String message}) async {
    final Stream<Category> stream = await getCategory(id);
    stream.listen((Category _category) {
      setState(() => category = _category);
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
      return category;
    });
    return null;
  }

  Future<void> listenForCart() async {
    final Stream<Cart> stream = await getCart();
    stream.listen((Cart _cart) {
      carts.add(_cart);
    });
  }

  bool isSameRestaurants(Food food) {
    if (carts.isNotEmpty) {
      return carts[0].food?.restaurant?.id == food.restaurant?.id;
    }
    return true;
  }

  void addToCart(Food food, {bool reset = false}) async {
    setState(() {
      this.loadCart = true;
    });
    var _newCart = new Cart();
    _newCart.food = food;
    _newCart.extras = [];
    _newCart.quantity = 1;
    // if food exist in the cart then increment quantity
    var _oldCart = isExistInCart(_newCart);
    if (_oldCart != null) {
      _oldCart.quantity++;
      updateCart(_oldCart).then((value) {
        setState(() {
          this.loadCart = false;
        });
      }).whenComplete(() {
        scaffoldKey?.currentState?.showSnackBar(SnackBar(
          content: Text(S.of(context).item_was_added_to_cart),
        ));
      });
    } else {
      // the food doesnt exist in the cart add new one
      addCart(_newCart, reset).then((value) {
        setState(() {
          this.loadCart = false;
        });
      }).whenComplete(() {
        if (reset) carts.clear();
        carts.add(_newCart);
        scaffoldKey?.currentState?.showSnackBar(SnackBar(
          content: Text(S.of(context).item_was_added_to_cart),
        ));
      });
    }
  }

  Cart isExistInCart(Cart _cart) {
    return carts.firstWhere((Cart oldCart) => _cart.isSame(oldCart), orElse: () => null);
  }

  Future<void> refreshCategory() async {
    foods.clear();
    category = new Category();
    listenForFoodsByCategory(message: S.of(context).category_refreshed_successfuly);
    listenForCategory(message: S.of(context).category_refreshed_successfuly);
  }

  Future<void> refreshSearch(search) async {
    setState(() {
      searchedItems = <Food>[];
    });
    if (search != null && search.toString().replaceAll(" ", "") != "")
      await listenForSearchedFoods(search: search, idRestaurant: restaurant.id);
  }

  void listenForSearchedFoods({String idRestaurant, String search}) async {
    searchedItems.clear();
    Address _address = deliveryAddress.value;
    Stream<Food> initialStream = await searchFoods(search, _address, storeID: idRestaurant);
    initialStream.listen((Food _food) {
      setState(() => this.searchedItems.add(_food));
    }, onError: (a) {
      print(a);
    }, onDone: () async {
      print("-------- ${this.searchedItems.length.toString()} Items Searched--------");
    });
  }

}
