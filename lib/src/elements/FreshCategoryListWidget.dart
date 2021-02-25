import 'dart:async';

import 'package:flutter/material.dart';
import 'package:mvc_pattern/mvc_pattern.dart';
import '../helpers/size_config.dart';
import '../../src/controllers/category_controller.dart';

import '../models/category.dart';
import '../models/restaurant.dart';
import 'EmptyItemSearchWidget.dart';
import 'AislesItemWidget.dart';
import 'FoodItemWidget.dart';

class FreshCategoryListWidget extends StatefulWidget {
  final Restaurant store;

  FreshCategoryListWidget({Key key, this.store}) : super(key: key);

  @override
  _FreshCategoryListState createState() => _FreshCategoryListState();
}

class _FreshCategoryListState extends StateMVC<FreshCategoryListWidget> {
  CategoryController _con;
  var _searchBarController = TextEditingController();
  bool _isSearching = false, _isSearched = false;
  //, _searchBarTapped = false;

  _FreshCategoryListState() : super(CategoryController()) {
    _con = controller;
  }

  @override
  void initState() {
    super.initState();
    _con.restaurant = widget.store;
    _con.listenForUsedCategories(widget.store.id);
  }

  @override
  Widget build(BuildContext context) {
    return SingleChildScrollView(
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
                if (text == "") {
                  setState(() => _isSearched = false);
                  _searchBarController.clear();
                  await _con.refreshSearch("");
                } else {
                  setState(() => _isSearching = true);
                  await _con.refreshSearch(text);
                  setState(() {
                    // _searchBarTapped = false;
                    _isSearching = false;
                    _isSearched = true;
                  });
                }
              },
              onChanged: (val) async {
                if (val == "") {
                  setState(() => _isSearched = false);
                  _searchBarController.clear();
                  await _con.refreshSearch("");
                }
              },
              onTap: () {
                // setState(() => _searchBarTapped = true);
              },
              controller: _searchBarController,
              decoration: InputDecoration(
                hintText: 'Search for items in this store',
                hintStyle: Theme.of(context).textTheme.caption.merge(TextStyle(fontSize: SizeConfig.blockSizeHorizontal*40)),
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
                ? EmptyItemSearchWidget(search_str: _searchBarController.text)
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
                            store: _con.restaurant,
                          );
                        }

                  })

        ],
      ),
    );

  }
}
