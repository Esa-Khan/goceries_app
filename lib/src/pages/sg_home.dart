import 'package:flutter/material.dart';
import 'package:mvc_pattern/mvc_pattern.dart';
import 'package:saudaghar/src/elements/AislesItemWidget.dart';
import 'package:saudaghar/src/elements/EmptyItemSearchWidget.dart';
import 'package:saudaghar/src/elements/FoodItemWidget.dart';
import 'package:saudaghar/src/helpers/size_config.dart';

import '../../src/models/category.dart';
import '../../src/models/route_argument.dart';
import '../controllers/sghome_controller.dart';
import '../elements/ShoppingCartButtonWidget.dart';
import '../repository/settings_repository.dart';
import '../repository/user_repository.dart';

class SGHomeWidget extends StatefulWidget {
  final GlobalKey<ScaffoldState> parentScaffoldKey;
  final RouteArgument routeArgument;

  SGHomeWidget({Key key, this.parentScaffoldKey, this.routeArgument}) : super(key: key);

  @override
  _SGHomeWidgetState createState() => _SGHomeWidgetState();
}

class _SGHomeWidgetState extends StateMVC<SGHomeWidget> {
  SGHomeController _con;
  var _searchBarController = TextEditingController();
  bool first_load = true, _isSearching = false, _isSearched = false;

  _SGHomeWidgetState() : super(SGHomeController()) {
    _con = controller;
  }

  @override
  void initState() {
    super.initState();
    if (first_load) {
      first_load = false;
      _con.getStore(store_type.value.toString());
    }
  }


  @override
  Widget build(BuildContext context) {
    SizeConfig().init(context);
    return Scaffold(
          appBar: AppBar(
            leading: IconButton(
                  icon: Icon(Icons.sort, color: Theme.of(context).hintColor),
                  onPressed: () => widget.parentScaffoldKey.currentState.openDrawer(),
                ),
            automaticallyImplyLeading: false,
            centerTitle: true,
            title: ValueListenableBuilder(
              valueListenable: setting,
              builder: (context, value, child) {
                return Text(
                  currentUser.value.name == null || currentUser.value.name.contains('null') || currentUser.value.name.trim().length == 0
                      ? value.appName
                      : "Welcome " + currentUser.value.name?.split(" ")[0] + "!",
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
                    : CategoryList()


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
                    store: _con.store,
                );
              }
    );
  }



}




