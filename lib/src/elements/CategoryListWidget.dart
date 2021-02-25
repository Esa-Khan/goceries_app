import 'dart:async';

import 'package:flutter/material.dart';
import 'package:mvc_pattern/mvc_pattern.dart';
import 'package:saudaghar/src/elements/SearchBarWidget.dart';
import 'package:saudaghar/src/models/item.dart';
import 'package:saudaghar/src/models/restaurant.dart';
import 'package:saudaghar/src/repository/settings_repository.dart';
import '../controllers/sghome_controller.dart';
import '../helpers/size_config.dart';

import '../models/category.dart';
import 'AislesItemWidget.dart';
import 'EmptyItemSearchWidget.dart';
import 'FoodItemWidget.dart';

typedef updateIcon = void Function(bool);

class CategoryListWidget extends StatefulWidget {
  final Restaurant store;

  CategoryListWidget({Key key, this.store}) : super(key: key);

  @override
  _CategoryListState createState() => _CategoryListState();
}

class _CategoryListState extends StateMVC<CategoryListWidget> with SingleTickerProviderStateMixin {
  SGHomeController _con;
  var _searchBarController = TextEditingController();
  bool _isSearching = false, _isSearched = false;
  int animation_steps = 0;
  bool items_loaded = false;


  _CategoryListState() : super(SGHomeController()) {
    _con = controller;
  }

  @override
  void initState() {
    super.initState();
    _con.store = widget.store;
    _con.listenForCategories();
  }

  @override
  Widget build(BuildContext context) {
    SizeConfig().init(context);
    return SingleChildScrollView(
          padding: const EdgeInsets.only(top: 10, bottom: 50),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            mainAxisAlignment: MainAxisAlignment.start,
            mainAxisSize: MainAxisSize.max,
            children: <Widget>[
              const SizedBox(height: 10),
              SearchBarWidget(),
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
                  ? SearchResultsWidget()




                  : AnimatedSwitcher(
                      duration: const Duration(milliseconds: 200),
                      transitionBuilder: (Widget child, Animation<double> animation) {
                        final inAnimation = Tween<Offset>(begin: Offset(-1.0, 0.0), end: Offset(0.0, 0.0)).animate(animation);
                        final outAnimation = Tween<Offset>(begin: Offset(1.0, 0.0), end: Offset(0.0, 0.0)).animate(animation);
                        final noAnimation = Tween<Offset>(begin: Offset.zero, end: Offset.zero).animate(animation);
                        var offsetAnimation;

                        if (animation_steps > 0) {
                          if (animation_steps == 1) {
                            print('In Animation');
                            offsetAnimation = inAnimation;
                          } else {
                            print('Out Animation');
                            offsetAnimation = outAnimation;
                          }
                        } else {
                          print('No Animation');
                          offsetAnimation = noAnimation;
                        }

                        return SlideTransition(child: child, position: offsetAnimation);
                      },
                      child: Container(
                        key: ValueKey<int>(animation_steps),
                        child: animation_steps == 1
                            ? ItemListWidget()
                            : CategoryList(),
                      )
                    )


            ],
          ),
      );
  }



  Widget SearchBarWidget() {
    return Padding(
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
    );
  }

  Widget SearchResultsWidget() {
    return ListView.separated(
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
          );
  }

  Widget ItemListWidget() {
    return _con.items == null || _con.items.isEmpty
        ? Center(heightFactor: 2, child: const SizedBox(width: 60, height: 60,
                  child: CircularProgressIndicator(strokeWidth: 5)))
        : ListView.separated(
            scrollDirection: Axis.vertical,
            shrinkWrap: true,
            primary: false,
            itemCount: _con.items.length,
            separatorBuilder: (context, index) {
              return SizedBox(height: 10);
            },
            // ignore: missing_return
            itemBuilder: (context, index) {
              return FoodItemWidget(
                heroTag: 'menu_list',
                food: _con.items.elementAt(index),
              );
            },
          );
  }

  Widget CategoryList() {
    return _con.categories.isEmpty
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
            itemCount: _con.categories.length,
            separatorBuilder: (context, index) {
              return const SizedBox(height: 20);
            },
            itemBuilder: (context, index) {
              Category currAisle = _con.categories.elementAt(index);
              // Define a Aisle dropdown
              return AislesItemWidget(
                  aisle: currAisle,
                  store: widget.store,
                );
            }
        );
  }
}
