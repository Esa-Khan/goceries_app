import 'package:flutter/material.dart';
import 'package:mvc_pattern/mvc_pattern.dart';

import '../../generated/l10n.dart';
import '../models/cart.dart';
import '../models/category.dart';
import '../models/food.dart';
import '../repository/cart_repository.dart';
import '../repository/category_repository.dart';
import '../repository/food_repository.dart';

class CategoryController extends ControllerMVC {
  List<Food> foods = <Food>[];
  bool noItems = false;
  bool itemsLoaded = false;
  GlobalKey<ScaffoldState> scaffoldKey;
  Category category;
  bool loadCart = false;
  List<Cart> carts = [];

  CategoryController() {
    this.scaffoldKey = new GlobalKey<ScaffoldState>();
  }

  void listenForFoodsByCategory({String id, String storeID, String message}) async {
    print("Getting items in ${category.name}");
    final Stream<Food> stream = await getFoodsByCategory(id, storeID: storeID);
    stream.listen((Food _food) {
      foods.add(_food);
      addItem(_food);
    }, onError: (a) {
      scaffoldKey?.currentState?.showSnackBar(SnackBar(
        content: Text(S.of(context).verify_your_internet_connection),
      ));
    }, onDone: () {
      setState(() {
        itemsLoaded = true;
      });
      if (foods.isEmpty) {
          noItems = true;
        scaffoldKey?.currentState?.showSnackBar(SnackBar(
          content: Text("No items in ${category.name}"),
        ));
      }
      if (message != null) {
        scaffoldKey?.currentState?.showSnackBar(SnackBar(
          content: Text(message),
        ));
      }
    });
  }

  void addItem(Food _food) {
    if (_food.ingredients != "<p>.</p>" && _food.ingredients != "0" && _food.ingredients != null) {
      var IDs = _food.ingredients.split('-');
      if (IDs.elementAt(0) == _food.id) {
        setState(() => foods.add(_food));
      }
    } else {
      setState(() => foods.add(_food));
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
