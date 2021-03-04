import 'package:global_configuration/global_configuration.dart';
import 'package:saudaghar/src/models/address.dart';
import 'package:saudaghar/src/repository/food_repository.dart';
import 'package:mvc_pattern/mvc_pattern.dart';
import 'package:http/http.dart' as http;

import '../models/category.dart';
import '../models/item.dart';
import '../models/restaurant.dart';
import '../repository/category_repository.dart';
import '../repository/restaurant_repository.dart';
import '../repository/settings_repository.dart';

class SGHomeController extends ControllerMVC {
  Restaurant store;
  List<Category> categories = <Category>[];
  List<Category> subcategories = <Category>[];
  List<Item> searchedItems = <Item>[];
  List<Item> items = <Item>[];
  bool isLoading = false;

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
    stream.listen((Item _food) {
      setState(() => items.add(_food));
    }, onError: (a) {
    }, onDone: () {
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



}
