import 'package:flutter/material.dart';
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

  List<Category> aisles = <Category>[];
  HashMap aisleToSubaisleMap = new HashMap<String, List<Category>>();
  HashMap subaisleToItemsMap = new HashMap<String, List<Food>>();
  HashMap isExpandedList = new HashMap<String, bool>();
  HashMap isAisleLoadedList = new HashMap<String, bool>();

  CategoryController() {
    this.scaffoldKey = new GlobalKey<ScaffoldState>();

  }


  Future<void> listenForCategories() async {
    final Stream<Category> stream = await getCategories();
    stream.listen((Category _category) {
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
    }, onDone: () {});
  }


//  Future<void> listenForSubCategories(String id) async {
//    final Stream<Category> stream = await getCategories();
//    stream.listen((Category _category) {
//      if (_category.id.length > 2) {
//        setState(() {
//          subCategory.add(_category);
//        });
//      }
//
//    }, onError: (a) {
//      print(a);
//    }, onDone: () {});
//  }


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

  void listenForItemsByCategory({String id, String storeID, String message}) async {
    if (!this.isAisleLoadedList[id]) {
      final Stream<Food> stream = await getFoodsByCategory(id, storeID: storeID);
      stream.listen((Food _food) {
        print("Loaded: ${_food.name}");
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

  void listenForCategory({String id, String message}) async {
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
    });
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
}
