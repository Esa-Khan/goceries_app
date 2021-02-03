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
  Restaurant store;

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
    });
  }
}
