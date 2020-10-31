import 'package:flutter/material.dart';
import 'package:saudaghar/generated/l10n.dart';
import 'package:saudaghar/src/elements/AislesItemWidget.dart';
import 'package:saudaghar/src/elements/FoodItemWidget.dart';
import 'package:saudaghar/src/models/food.dart';
import 'package:saudaghar/src/models/restaurant.dart';
import 'package:saudaghar/src/models/category.dart';
import 'package:mvc_pattern/mvc_pattern.dart';
import 'dart:async';

import '../controllers/restaurant_controller.dart';
import '../controllers/category_controller.dart';
import '../elements/CircularLoadingWidget.dart';
import '../elements/DrawerWidget.dart';
import '../elements/ShoppingCartButtonWidget.dart';
import '../models/route_argument.dart';


class MenuWidget extends StatefulWidget {
  @override
  _MenuWidgetState createState() => _MenuWidgetState();
  final RouteArgument routeArgument;

  MenuWidget({Key key, this.routeArgument}) : super(key: key);
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
    store = widget.routeArgument.param;
    _con.restaurant = store;
    while (store.used_cats == null) {
      Future.delayed(Duration(microseconds: 100));
    }
    _con.listenForUsedCategories(store.used_cats);
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
          store == null ? "Store" : store.name,
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
      body: SingleChildScrollView(
        padding: const EdgeInsets.only(top: 10, bottom: 50),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          mainAxisAlignment: MainAxisAlignment.start,
          mainAxisSize: MainAxisSize.max,
          children: <Widget>[
            const SizedBox(height: 10),
            Padding(
              padding: const EdgeInsets.fromLTRB(12, 1, 12, 30),
              child: TextField(
                onSubmitted: (text) async {
                  setState(() => _isSearching = true);
                  await _con.refreshSearch(text);
                  setState(() {
                    _searchBarTapped = false;
                    _isSearching = false;
                    _isSearched = true;
                  });
                },
                onChanged: (val) async {
                  if (val == "") {
                    setState(() => _isSearched = false);
                    _searchBarController.clear();
                    await _con.refreshSearch("");
                  }
                },
                onTap: () {
                  setState(() => _searchBarTapped = true);
                },
                controller: _searchBarController,
                decoration: InputDecoration(
                  hintText: S.of(context).search_for_items_in_this_store,
                  hintStyle: Theme.of(context).textTheme.caption.merge(TextStyle(fontSize: 14)),
                  contentPadding: EdgeInsets.only(right: 12),
                  prefixIcon: Icon(Icons.search, color: Theme.of(context).accentColor),
                  suffixIcon: IconButton(
                    onPressed: () async {
                      FocusScopeNode currentFocus = FocusScope.of(context);
                      if (!currentFocus.hasPrimaryFocus) {
                        currentFocus.unfocus();
                      }
                      setState(() => _isSearched = false);
                      _searchBarController.clear();
                      await _con.refreshSearch("");
                    },
                    color: Theme.of(context).focusColor,
                    icon: Icon(Icons.clear, size: 30),
                  ),
                  border: OutlineInputBorder(borderSide: BorderSide(color: Theme.of(context).focusColor.withOpacity(0.3))),
                  focusedBorder: OutlineInputBorder(borderSide: BorderSide(color: Theme.of(context).focusColor.withOpacity(0.7))),
                  enabledBorder: OutlineInputBorder(borderSide: BorderSide(color: Theme.of(context).focusColor.withOpacity(0.3))),

                ),
              ),
            ),
            _isSearching
                ? Column(
              children: <Widget>[
                SizedBox(height: 50),
                Center(child: SizedBox(width: 120, height: 120, child: CircularProgressIndicator(strokeWidth: 8))),
              ],
            )
                : _isSearched && _con.searchedItems.isEmpty
                  ? SizedBox(height: 300)
                  : _con.searchedItems.isNotEmpty
                ? ListView.separated(
              padding: EdgeInsets.only(bottom: 40),
              scrollDirection: Axis.vertical,
              shrinkWrap: true,
              primary: false,
              itemCount: _con.searchedItems.length,
              separatorBuilder: (context, index) {
                return SizedBox(height: 10);
              },
              itemBuilder: (context, index) {
                if (index == _con.searchedItems.length - 1)
                  _con.isLoading = false;

                if (_con.searchedItems.isNotEmpty) {
                  return FoodItemWidget(
                    heroTag: 'store_search_list',
                    food: _con.searchedItems.elementAt(index),
                  );
                } else {
                  return SizedBox(height: 0);
                }
              },
            )

                : !_con.hasAislesLoaded
                    ? Padding(
                        padding: EdgeInsets.symmetric(vertical: 50),
                        child: Center(
                            child: SizedBox(
                                width: 120,
                                height: 120,
                                child: CircularProgressIndicator(strokeWidth: 8))),
                      )
                    : ListView.separated(
                        scrollDirection: Axis.vertical,
                        shrinkWrap: true,
                        primary: false,
                        itemCount: _con.aisles.length,
                        separatorBuilder: (context, index) {
                          Category currAisle = _con.aisles.elementAt(index);
                          if (_con.aisleToSubaisleMap[currAisle.id] == null) {
                            return const SizedBox();
                          } else {
                            return const SizedBox(height: 20);
                          }
                        },
                        itemBuilder: (context, index) {
                          Category currAisle = _con.aisles.elementAt(index);
                          if (_con.aisleToSubaisleMap[currAisle.id] == null) {
                            return const SizedBox();
                          } else {
                            // Define a Aisle dropdown
                            return AislesItemWidget(
                                aisle: currAisle,
                                store: store,
                                items: _con.subaisleToItemsMap,
                                subAisles: _con.aisleToSubaisleMap[currAisle.id],
                                onPressed: (aisleVal) async {
                                  _con.isExpandedList.forEach((key, value) {
                                    _con.isExpandedList[key] = false;
                                  });
                                  if (!_con.isExpandedList[aisleVal.id])
                                    _con.isExpandedList[aisleVal.id] = true;

                                  if (aisleVal.id.length > 2 &&
                                      !_con.isAisleLoadedList[aisleVal.id] &&
                                      _con.isExpandedList[aisleVal.id]) {
                                    print(aisleVal.name);
                                    await _con.listenForItemsByCategory(id: aisleVal.id, storeID: store.id);
                                    _con.isAisleLoadedList[aisleVal.id] = true;
                                  }
                                });
                          }

                        })

                      ],
                    ),
                  ),
                );
              }

}
