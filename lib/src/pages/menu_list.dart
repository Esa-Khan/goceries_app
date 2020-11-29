import 'package:flutter/material.dart';
import 'package:saudaghar/src/elements/CategoryListWidget.dart';
import '../../generated/l10n.dart';
import '../elements/AislesItemWidget.dart';
import '../elements/FoodItemWidget.dart';
import '../models/restaurant.dart';
import '../models/category.dart';
import 'package:mvc_pattern/mvc_pattern.dart';
import 'dart:async';

import '../controllers/category_controller.dart';
import '../elements/DrawerWidget.dart';
import '../elements/ShoppingCartButtonWidget.dart';
import '../models/route_argument.dart';


class MenuWidget extends StatefulWidget {
  final RouteArgument routeArgument;

  MenuWidget({Key key, this.routeArgument}) : super(key: key);

  @override
  _MenuWidgetState createState() => _MenuWidgetState();
}

class _MenuWidgetState extends StateMVC<MenuWidget> {
  CategoryController _con;
  Restaurant store;
  var _searchBarController = TextEditingController();
  bool _isSearching = false, _isSearched = false, _searchBarTapped = false;

  _MenuWidgetState() : super(CategoryController()) {
    _con = controller;
    }

  @override
  void initState() {
    super.initState();
    _con.restaurant = widget.routeArgument.param;
    while (_con.restaurant.used_cats == null) {
      Timer(Duration(microseconds: 100), () {});
    }
    _con.listenForUsedCategories(_con.restaurant.id);
  }


  @override
  Widget build(BuildContext context) {
    return Scaffold(
      key: _con.scaffoldKey,
      drawer: DrawerWidget(),
      appBar: AppBar(
        backgroundColor: Colors.transparent,
        elevation: 0,
        centerTitle: true,
        title: Text(
          _con.restaurant == null ? "Store" : _con.restaurant.name,
//          _con.foods.isNotEmpty ? _con.foods[0].restaurant.name : '',
          overflow: TextOverflow.fade,
          softWrap: false,
          style: Theme.of(context).textTheme.headline6.merge(TextStyle(letterSpacing: 0)),
        ),
        leading: BackButton(
          color: Theme.of(context).accentColor,
        ),
        actions: <Widget>[
          new ShoppingCartButtonWidget(iconColor: Theme.of(context).hintColor, labelColor: Theme.of(context).accentColor),
        ],
      ),
      floatingActionButtonLocation: FloatingActionButtonLocation.endFloat,
      body: CategoryListWidget(store: _con.restaurant)
    );

  }

}
