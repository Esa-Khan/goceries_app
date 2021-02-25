import 'package:flutter/material.dart';
import 'package:mvc_pattern/mvc_pattern.dart';
import 'package:saudaghar/src/driver/elements/DrawerWidget.dart';
import 'package:saudaghar/src/elements/AislesItemWidget.dart';
import 'package:saudaghar/src/elements/EmptyItemSearchWidget.dart';
import 'package:saudaghar/src/elements/FoodItemWidget.dart';
import 'package:saudaghar/src/helpers/size_config.dart';
import 'package:saudaghar/src/models/item.dart';
import 'package:saudaghar/src/models/restaurant.dart';
import '../../src/models/route_argument.dart';
import '../../src/models/category.dart';

import '../controllers/sghome_controller.dart';
import '../elements/ShoppingCartButtonWidget.dart';
import '../repository/settings_repository.dart';
import '../repository/user_repository.dart';

class ItemsListWidget extends StatefulWidget {
  final GlobalKey<ScaffoldState> parentScaffoldKey;
  final Category subAisle;
  final Restaurant store;

  ItemsListWidget({Key key, this.parentScaffoldKey, this.subAisle, this.store}) : super(key: key);

  @override
  _ItemsListWidgetState createState() => _ItemsListWidgetState();
}

class _ItemsListWidgetState extends StateMVC<ItemsListWidget> {
  SGHomeController _con;
  var _searchBarController = TextEditingController();
  bool _isSearching = false, _isSearched = false;
  int animation_steps = 0;
  bool items_loaded = false;

  _ItemsListWidgetState() : super(SGHomeController()) {
    _con = controller;
  }

  @override
  void initState() {
    super.initState();
    _con.store = widget.store;
    _con.listenForFoodsByCategory(widget.subAisle.id);
  }



  @override
  Widget build(BuildContext context) {
    SizeConfig().init(context);
    return Scaffold(
      // drawer: DrawerWidget(),
      appBar: AppBar(
        leading: IconButton(
          icon: Icon(Icons.arrow_back_rounded, color: Theme.of(context).hintColor),
          onPressed: () => Navigator.of(context).pop(),
        ),
        automaticallyImplyLeading: false,
        centerTitle: true,
        title: ValueListenableBuilder(
          valueListenable: setting,
          builder: (context, value, child) {
            return Text( widget.subAisle.name,
              style: Theme.of(context).textTheme.headline6.merge(TextStyle(letterSpacing: 1.3)),
            );
          },
        ),
        actions: <Widget>[
          new ShoppingCartButtonWidget(iconColor: Theme.of(context).hintColor, labelColor: Theme.of(context).accentColor),
        ],
      ),
      body: _con.store == null
              ? const Center(child: SizedBox(width: 120, height: 120, child: CircularProgressIndicator(strokeWidth: 8)))
              : SingleChildScrollView(
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
                              : ItemListWidget(items: _con.items, onPressed: (Item item) => _con.addToCart(item))


                    ],
                  ),
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
            await _con.refreshSearchbyCategory("", widget.subAisle.id);
          } else {
            setState(() => _isSearching = true);
            await _con.refreshSearchbyCategory(text, widget.subAisle.id);
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
            await _con.refreshSearchbyCategory("", widget.subAisle.id);
          }
        },
        controller: _searchBarController,
        decoration: InputDecoration(
          hintText: 'Search for items in this category',
          hintStyle: Theme.of(context).textTheme.caption.merge(TextStyle(fontSize: SizeConfig.blockSizeHorizontal*35)),
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
              await _con.refreshSearchbyCategory("", widget.subAisle.id);
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
          return const SizedBox();
        }
      },
    );
  }


}


class ItemListWidget extends StatelessWidget {
  @required final List<Item> items;
  @required final Function(Item) onPressed;

  ItemListWidget({
    Key key,
    this.items,
    this.onPressed,
  }) : super(key: key);


  @override
  Widget build(BuildContext context) {
    return items == null || items.isEmpty
        ? Center(child: SizedBox(width: 120, height: 120, child: CircularProgressIndicator(strokeWidth: 8)))
        : ListView.separated(
            scrollDirection: Axis.vertical,
            shrinkWrap: true,
            primary: false,
            itemCount: items.length,
            separatorBuilder: (context, index) {
              return SizedBox(height: 10);
            },
            // ignore: missing_return
            itemBuilder: (context, index) {
              return FoodItemWidget(
                heroTag: 'menu_list',
                food: items.elementAt(index),
                onPressed: () => onPressed(items.elementAt(index)),
              );
            },
          );
  }
}





