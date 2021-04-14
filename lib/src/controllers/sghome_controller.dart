import 'package:flutter/material.dart';
import 'package:global_configuration/global_configuration.dart';
import 'package:saudaghar/src/helpers/helper.dart';
import 'package:saudaghar/src/models/address.dart';
import 'package:saudaghar/src/repository/food_repository.dart';
import 'package:mvc_pattern/mvc_pattern.dart';
import 'package:http/http.dart' as http;
import 'package:saudaghar/src/repository/user_repository.dart';

import '../models/category.dart';
import '../models/item.dart';
import '../models/restaurant.dart';
import '../repository/category_repository.dart';
import '../repository/restaurant_repository.dart';
import '../repository/settings_repository.dart';
import '../elements/AddToCartAlertDialog.dart';
import '../../src/models/category.dart';
import '../../src/repository/category_repository.dart';
import '../../generated/l10n.dart';
import '../models/cart.dart';
import '../models/extra.dart';
import '../models/favorite.dart';
import '../repository/cart_repository.dart';
import '../repository/food_repository.dart';
import '../repository/food_repository.dart' as foodRepo;


class SGHomeController extends ControllerMVC {
  Restaurant store;
  List<Category> categories = <Category>[];
  List<Category> subcategories = <Category>[];
  List<Item> searchedItems = <Item>[];
  List<Item> items = <Item>[];
  bool isLoading = false;
  bool loadCart = false;
  List<Cart> carts = [];


  Future<void> getStore(String id) async {
    final Stream<Restaurant> stream = await getRestaurant(id, deliveryAddress.value);
    stream.listen((Restaurant _restaurant) {
      setState(() => store = _restaurant);
    }, onError: (a) {
      print(a);
    }, onDone: () {
      listenForCategories();
    });
  }


  Future<void> listenForCategories() async {
    categories.clear();
    final Stream<Category> stream = await getUsedCategories(store.id);
    stream.listen((Category _category) async {
      if (int.tryParse(_category.id) < 100) {
        setState(() => categories.add(_category));
      }
    }, onError: (a) {
      print(a);
    }, onDone: () {
    });
  }

  Future<void> listenForSubCategories(String storeID, {String getSubCat}) async {
    final Stream<Category> stream = await getUsedSubcategories(storeID, getSubCat);
    stream.listen((Category _category) {
      setState(() => subcategories.add(_category));
    }, onError: (a) {
      print(a);
    }, onDone: () {
    });
  }

  Future<void> listenForFoodsByCategory(String id) async {
    final Stream<Item> stream = await getFoodsByCategory(id, storeID: store.id);
    stream.listen((Item _item) {
      if (_item.listing_order == 0 || items.isEmpty) {
        setState(() => items.add(_item));
      } else {
        for (int i = 0; i < items.length; i++) {
          if (_item.listing_order < items[i].listing_order) {
            setState(() => items.insert(i, _item));
            break;
          }
        }
      }
    }, onError: (a) {
    });
  }



  Future<void> refreshSearch(search) async {
    setState(() {
      searchedItems = <Item>[];
    });
    if (search != null && search.toString().replaceAll(" ", "") != "")
      await listenForSearchedFoods(search: search, idRestaurant: store.id);
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


  Future<void> refreshSearchbyCategory(String search, String categoryID) async {
    setState(() {
      searchedItems = <Item>[];
    });
    if (search != null && search.toString().replaceAll(" ", "") != "")
      await listenForSearchedItemsByCategory(search: search, categoryID: categoryID);
  }

  void listenForSearchedItemsByCategory({String categoryID, String search}) async {
    searchedItems.clear();
    Stream<Item> initialStream = await searchItemsInSubcategory(search: search, subcategoryID: categoryID);
    initialStream.listen((Item _food) {
      setState(() => this.searchedItems.add(_food));
    }, onError: (a) {
      print(a);
    }, onDone: () async {
      print("-------- ${this.searchedItems.length.toString()} Items Searched--------");
    });
  }



  bool showAddtocartSnack = false;
  void addToCart(Item item) async {
    if (currentUser.value.apiToken == null) {
      Navigator.of(context).pushNamed("/Login");
    } else {
      OverlayEntry loader = Helper.overlayLoader(context);
      Overlay.of(context).insert(loader);
      setState(() => loadCart = true);
      var _newCart = new Cart();
      _newCart.food = item;
      _newCart.quantity = 1;
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
        setState(() => loadCart = false);
        loader.remove();
      }).catchError((e) async {
        if (e.toString() == 'Exception: Different Store') {
          carts = <Cart>[];
          final Stream<Cart> stream = await getCart();
          stream.listen((Cart _cart) {
            setState(() => carts.add(_cart));
          }, onDone: () {
            print("carts loaded");
            showDialog(
              context: context,
              builder: (BuildContext context) {
                // return object of type Dialog
                try {
                  loader.remove();
                  return AddToCartAlertDialogWidget(
                      oldFood: carts.elementAt(0)?.food,
                      newFood: item,
                      onPressed: (item, {reset: true}) async {
                        await clearCart();
                        setState(() => cart_count.value = 0);
                        carts.clear();
                        return addToCart(item);
                      });
                } catch (e) {
                  loader.remove();
                  return const SizedBox();
                }
              },
            );
          });
        }
      });
    }
  }



}
