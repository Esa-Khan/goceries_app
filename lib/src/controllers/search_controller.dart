import 'package:mvc_pattern/mvc_pattern.dart';

import '../models/address.dart';
import '../models/item.dart';
import '../models/restaurant.dart';
import '../repository/food_repository.dart';
import '../repository/restaurant_repository.dart';
import '../repository/search_repository.dart';
import '../repository/settings_repository.dart';

class SearchController extends ControllerMVC {
  List<Restaurant> restaurants = <Restaurant>[];
  List<Item> foods = <Item>[];
  String storeID;

  SearchController({String storeID}) {
    this.storeID = storeID;
    if (storeID == null)
      listenForRestaurants();
    listenForFoods();

  }

  void listenForRestaurants({String search}) async {
    if (search == null) {
      search = await getRecentSearch();
    }
    Address _address = deliveryAddress.value;
    final Stream<Restaurant> stream = await searchRestaurants(search, _address);
    stream.listen((Restaurant _restaurant) {
      setState(() => restaurants.add(_restaurant));
    }, onError: (a) {
      print(a);
    }, onDone: () {});
  }

  Future<void> listenForFoods({String search}) async {
//    if (search == null && storeID == null) {
//      search = await getRecentSearch();
//    }
    Address _address = deliveryAddress.value;
    final Stream<Item> stream = await searchFoods(search, _address, storeID: storeID, isStore: false);
    stream.listen((Item _food) {
      setState(() => foods.add(_food));
    }, onError: (a) {
      print(a);
    }, onDone: () {

    });
  }


  Future<void> refreshSearch(search) async {
    setState(() {
      restaurants = <Restaurant>[];
      foods = <Item>[];
    });
    listenForRestaurants(search: search);
    listenForFoods(search: search);
  }

  void saveSearch(String search) {
    setRecentSearch(search);
  }
}
