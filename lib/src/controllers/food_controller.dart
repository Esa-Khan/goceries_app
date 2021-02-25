import 'package:flutter/material.dart';
import 'package:saudaghar/src/elements/AddToCartAlertDialog.dart';
import 'package:saudaghar/src/repository/user_repository.dart';
import '../../src/models/category.dart';
import '../../src/repository/category_repository.dart';
import 'package:mvc_pattern/mvc_pattern.dart';

import '../../generated/l10n.dart';
import '../models/cart.dart';
import '../models/extra.dart';
import '../models/favorite.dart';
import '../models/item.dart';
import '../repository/cart_repository.dart';
import '../repository/food_repository.dart';
import '../repository/food_repository.dart' as foodRepo;

class FoodController extends ControllerMVC {
  Item item;
  Category aisle;
  List<Item> similarItems = new List<Item>();
  bool loaded_similaritems = false;
  int quantity = 1;
  double total = 0;
  List<Cart> carts = [];
  Favorite favorite;
  bool loadCart = false;
  GlobalKey<ScaffoldState> scaffoldKey;

  FoodController() {
    this.scaffoldKey = new GlobalKey<ScaffoldState>();
  }

  Future<void> listenForFood({String foodId, bool getAisle = false, String message}) async {
    setState(() => loaded_similaritems = false);
    final Stream<Item> stream = await getFood(foodId);
    stream.listen((Item _food) async {
      setState(() => item = _food);
      if (getAisle) {
        listenForCategory(item.category);
      }
    }, onError: (a) {
      print(a);
      scaffoldKey.currentState?.showSnackBar(SnackBar(
        content: Text(S.of(context).verify_your_internet_connection),
      ));
    }, onDone: () {
      calculateTotal();
      loadSimilarItems();
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


  bool showAddtocartSnack = false;
  void addToCart() async {
    if (currentUser.value.apiToken == null) {
      Navigator.of(context).pushNamed("/Login");
    } else {
      setState(() => loadCart = true);
      var _newCart = new Cart();
      _newCart.food = item;
      _newCart.quantity = this.quantity;
      addCart(_newCart).then((_cart) {
        bool item_in_cart = false;
        for (int i = 0; i < carts.length; i++) {
          if (carts.elementAt(i).food.id == _cart.food.id) {
            carts.elementAt(i).quantity += _cart.quantity;
            item_in_cart = true;
          }
        }
        if (!item_in_cart) {
          carts.add(_cart);
          setState(() => cart_count.value += _cart.quantity);
          cart_count.notifyListeners();
        }
        scaffoldKey?.currentState?.showSnackBar(SnackBar(
          content: Text(S.of(context).item_was_added_to_cart, textAlign: TextAlign.center,),
          duration: Duration(milliseconds: 500),
        ));
        setState(() => loadCart = false);
      }).catchError((e) {
        print(e.toString());
        if (e.toString() == 'Exception: Different Store') {
          showDialog(
            context: context,
            builder: (BuildContext context) {
              // return object of type Dialog
              return AddToCartAlertDialogWidget(
                  oldFood: carts.elementAt(0)?.food,
                  newFood: item,
                  onPressed: (item, {reset: true}) {
                    carts.clear();
                    return addToCart();
                  });
            },
          );
        }
      });

    }
  }

  void addToFavorite(Item item) async {
    var _favorite = new Favorite();
    _favorite.food = item;
    _favorite.extras = item.extras.where((Extra _extra) {
      return _extra.checked;
    }).toList();
    addFavorite(_favorite).then((value) {
      setState(() {
        this.favorite = value;
      });
      scaffoldKey?.currentState?.showSnackBar(SnackBar(
        content: Text(S.of(context).thisFoodWasAddedToFavorite),
        duration: Duration(seconds: 1),
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
        duration: Duration(seconds: 1),
      ));
    });
  }

  Future<void> refreshFood() async {
    var _id = item.id;
    item = new Item();
    similarItems = new List<Item>();
    listenForFavorite(foodId: _id);
    listenForFood(foodId: _id, message: S.of(context).foodRefreshedSuccessfuly);
  }

  calculateTotal() {
    total = item?.price ?? 0;
    item?.extras?.forEach((extra) {
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

  loadSimilarItems() async {
    setState(() => loaded_similaritems = false);
    final Stream<Item> stream = await getSimilarItems(item.id);
    stream.listen((Item _food) async {
      bool repeated_item = false;
      for (int i = 0; i < similarItems.length; i++) {
        if (_food.id == similarItems.elementAt(i)) {
          repeated_item = true;
          break;
        }
      }
      if (!repeated_item) {
        setState(() => similarItems.add(_food));
      }

    },
    onDone: () {
      setState(() => loaded_similaritems = true);
    });
  }


  updateItem(Item new_item) async {
    final Item updated_item = await foodRepo.updateItem(item);
    setState(() => item = updated_item);
  }

}
