import 'package:flutter/material.dart';
import 'package:food_delivery_app/src/models/category.dart';
import 'package:food_delivery_app/src/repository/category_repository.dart';
import 'package:mvc_pattern/mvc_pattern.dart';

import '../../generated/l10n.dart';
import '../models/cart.dart';
import '../models/extra.dart';
import '../models/favorite.dart';
import '../models/food.dart';
import '../repository/cart_repository.dart';
import '../repository/food_repository.dart';

class FoodController extends ControllerMVC {
  Food food;
  Category aisle;
  List<Food> similarItems = new List<Food>();
  double quantity = 1;
  double total = 0;
  List<Cart> carts = [];
  Favorite favorite;
  bool loadCart = false;
  bool showMessage = true;
  GlobalKey<ScaffoldState> scaffoldKey;

  FoodController() {
    this.scaffoldKey = new GlobalKey<ScaffoldState>();
  }

  void listenForFood({String foodId, bool getAisle, String message}) async {
    final Stream<Food> stream = await getFood(foodId);
    stream.listen((Food _food) {
      setState(() => food = _food);
      if (_food.ingredients != "<p>.</p>") {
        var otherItems = _food.ingredients.split('-');
        otherItems.remove(_food.id);
        otherItems.forEach((element) async {
          final Stream<Food> currStream = await getFood(element);
          currStream.listen((Food _food) {
            setState(() => similarItems.add(_food));
          });
        });
      }
      if (getAisle) {
        listenForCategory(food.category);
      }
    }, onError: (a) {
      print(a);
      scaffoldKey.currentState?.showSnackBar(SnackBar(
        content: Text(S.of(context).verify_your_internet_connection),
      ));
    }, onDone: () {
      calculateTotal();
      if (message != null) {
        scaffoldKey.currentState?.showSnackBar(SnackBar(
          content: Text(message),
        ));
      }
    });
  }

  void listenForCategory(int id) async {
    final Stream<Category> stream = await getCategory(id.toString());
    stream.listen((Category _aisle) {
      setState(() => aisle = _aisle);
    }, onError: (a) {
    }, onDone: () {});
  }

  void listenForFavorite({String foodId}) async {
    final Stream<Favorite> stream = await isFavoriteFood(foodId);
    stream.listen((Favorite _favorite) {
      setState(() => favorite = _favorite);
    }, onError: (a) {
      print(a);
    });
  }

  void listenForCart() async {
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
    if (this.loadCart) {
      if (showMessage) {
        showMessage = false;
        scaffoldKey?.currentState?.showSnackBar(SnackBar(
          content: Text(S
              .of(context)
              .adding_food_to_cart_please_wait),
          duration: Duration(seconds: 1),
        ));
      }
    } else {
      showMessage = true;
      setState(() => this.loadCart = true);
      var _newCart = new Cart();
      _newCart.food = food;
      _newCart.extras = food.extras.where((element) => element.checked).toList();
      _newCart.quantity = this.quantity;
      // if food exist in the cart then increment quantity
      var _oldCart = isExistInCart(_newCart);
      if (_oldCart != null) {
        _oldCart.quantity += this.quantity;
        updateCart(_oldCart).whenComplete(() {
          setState(() {
            this.loadCart = false;
          });
          scaffoldKey?.currentState?.showSnackBar(SnackBar(
            content: Text(S.of(context).item_was_added_to_cart),
            duration: Duration(seconds: 1),
          ));
        });
      } else {
        // The food doesn't exist in the cart add new one
        addCart(_newCart, reset).whenComplete(() {
          setState(() {
            this.loadCart = false;
          });
          scaffoldKey?.currentState?.showSnackBar(SnackBar(
            content: Text(S.of(context).item_was_added_to_cart),
          ));
        });
      }
    }
  }

  Cart isExistInCart(Cart _cart) {
    return carts.firstWhere((Cart oldCart) => _cart.isSame(oldCart), orElse: () => null);
  }

  void addToFavorite(Food food) async {
    var _favorite = new Favorite();
    _favorite.food = food;
    _favorite.extras = food.extras.where((Extra _extra) {
      return _extra.checked;
    }).toList();
    addFavorite(_favorite).then((value) {
      setState(() {
        this.favorite = value;
      });
      scaffoldKey?.currentState?.showSnackBar(SnackBar(
        content: Text(S.of(context).thisFoodWasAddedToFavorite),
      ));
    });
  }

  void removeFromFavorite(Favorite _favorite) async {
    removeFavorite(_favorite).then((value) {
      setState(() {
        this.favorite = new Favorite();
      });
      scaffoldKey?.currentState?.showSnackBar(SnackBar(
        content: Text(S.of(context).thisFoodWasRemovedFromFavorites),
      ));
    });
  }

  Future<void> refreshFood() async {
    var _id = food.id;
    food = new Food();
    listenForFavorite(foodId: _id);
    listenForFood(foodId: _id, message: S.of(context).foodRefreshedSuccessfuly);
  }

  void calculateTotal() {
    total = food?.price ?? 0;
    food?.extras?.forEach((extra) {
      total += extra.checked ? extra.price : 0;
    });
    total *= quantity;
    setState(() {});
  }

  incrementQuantity() {
    if (this.quantity <= 99) {
      ++this.quantity;
      calculateTotal();
    }
  }

  decrementQuantity() {
    if (this.quantity > 1) {
      --this.quantity;
      calculateTotal();
    }
  }
}
