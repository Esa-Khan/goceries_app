import 'package:flutter/material.dart';
import 'package:flutter/rendering.dart';
import '../../src/models/item.dart';
import 'package:mvc_pattern/mvc_pattern.dart';
import 'package:url_launcher/url_launcher.dart';

import '../../generated/l10n.dart';
import '../controllers/restaurant_controller.dart';
import '../elements/FoodItemWidget.dart';
import '../elements/GalleryCarouselWidget.dart';
import '../elements/ShoppingCartFloatButtonWidget.dart';
import '../helpers/helper.dart';
import '../models/route_argument.dart';
import '../repository/settings_repository.dart';

class DetailsWidget extends StatefulWidget {
  final RouteArgument routeArgument;
  final GlobalKey<ScaffoldState> parentScaffoldKey;

  DetailsWidget({Key key, this.routeArgument, this.parentScaffoldKey}) : super(key: key);

  @override
  _DetailsWidgetState createState() {
    return _DetailsWidgetState();
  }
}

class _DetailsWidgetState extends StateMVC<DetailsWidget> {
  RestaurantController _con;
  var _searchBarController = TextEditingController();

  final ScrollController _scrollController = ScrollController();
  List<Item> itemList = new List<Item>();
  bool _hasMore = true, _initialLoading = true, _isSearching = false, _isSearched = false, _searchBarTapped = false;
  int numOfItemsToAdd = 50;

  _DetailsWidgetState() : super(RestaurantController()) {
    _con = controller;
  }

  @override
  void initState() {
    super.initState();
    _con.listenForRestaurant(id: widget.routeArgument.id);
    _con.listenForGalleries(widget.routeArgument.id);
//    _con.listenForAllItems(widget.routeArgument.id);
//    _con.listenForRestaurantReviews(id: widget.routeArgument.id);
    _scrollController.addListener(loadMore);

  }

  @override
  void dispose() {
    super.dispose();
    _scrollController.dispose();
    _searchBarController.dispose();
  }

  int oldNumOfItems = 0;
  loadMore() async {
    if (!_isSearched && _scrollController.hasClients &&
        !_con.isLoading &&
        _scrollController.position?.extentAfter < 30 &&
        _hasMore &&
        _con.foods.isNotEmpty &&
        !_con.allItemsLoaded) {

        await _con.listenForIncrementalItems(idRestaurant: widget.routeArgument.id, limit: (numOfItemsToAdd).floor());

        if (_con.allItemsLoaded) {
          setState(() {
            _hasMore = false;
            print("-----DONE-----");
          });
        }
    }
  }

  @override
  Widget build(BuildContext context) {
    if (_initialLoading && _con.foods.isNotEmpty) {
      _initialLoading = false;
    } else if (_initialLoading && _con.restaurant != null) {
      _con.listenForIncrementalItems(idRestaurant: widget.routeArgument.id, limit: numOfItemsToAdd);
    }


    return Scaffold(
      appBar: AppBar(
        leading: BackButton(
          color: Theme.of(context).accentColor,
        ),
        backgroundColor: Colors.transparent,
        elevation: 0,
        centerTitle: true,
        title: Text(
            _con.restaurant?.name ?? '',
          style: Theme.of(context).textTheme.headline6.merge(TextStyle(letterSpacing: 1.3)),
        ),
      ),
        key: _con.scaffoldKey,
        floatingActionButton: _con.restaurant == null || _con.restaurant.information == "" || _con.restaurant.information == null ||
                                  (_con.restaurant?.information != null && _con.restaurant?.information == 'R') || _searchBarTapped
        ? const SizedBox()
        : FloatingActionButton.extended(
          onPressed: () {
            Navigator.of(context).pushNamed('/Menu', arguments: new RouteArgument(id: widget.routeArgument.id, param: _con.restaurant));
          },
          isExtended: true,
          materialTapTargetSize: MaterialTapTargetSize.shrinkWrap,
          icon: Icon(
            Icons.category,
            color: Theme.of(context).primaryColor,
          ),
          label: Text(
            S.of(context).aisles,
            style: TextStyle(color: Theme.of(context).primaryColor),
          ),
        ),
        floatingActionButtonLocation: FloatingActionButtonLocation.endFloat,
        body: RefreshIndicator(
          onRefresh: _con.refreshRestaurant,
          child: _con.restaurant == null
//              ? CircularLoadingWidget(height: 500)
              ? Center(child: SizedBox(width: 120, height: 120, child: CircularProgressIndicator(strokeWidth: 8)))
              : Stack(
                  fit: StackFit.expand,
                  children: <Widget>[
                    CustomScrollView(
                      controller: _scrollController,
//                      primary: true,
                      shrinkWrap: true,
                      slivers: <Widget>[
                        SliverToBoxAdapter(
                          child: Flex(
                            direction: Axis.vertical,
                            mainAxisSize: MainAxisSize.min,
                            children: [
                              Row(
                                children: <Widget>[
                                  SizedBox(width: 20, height: 50),
                                  Container(
                                    padding: EdgeInsets.symmetric(horizontal: 12, vertical: 3),
                                    decoration:
                                        BoxDecoration(color: (_con.restaurant != null && _con.restaurant?.closed == null && _con.restaurant?.closed)
                                            ? Colors.red
                                            : Colors.green, borderRadius: BorderRadius.circular(24)),
                                    child: _con.restaurant != null && _con.restaurant.closed
                                        ? Text(
                                            S.of(context).closed,
                                            style: Theme.of(context).textTheme.caption.merge(TextStyle(color: Theme.of(context).primaryColor)),
                                          )
                                        : Text(
                                            S.of(context).open,
                                            style: Theme.of(context).textTheme.caption.merge(TextStyle(color: Theme.of(context).primaryColor)),
                                          ),
                                  ),
                                  SizedBox(width: 10),
                                  Container(
                                    padding: EdgeInsets.symmetric(horizontal: 12, vertical: 3),
                                    decoration: BoxDecoration(
                                        color: Helper.canDelivery(_con.restaurant) ? Colors.green : Colors.grey, borderRadius: BorderRadius.circular(24)),
                                    child: Text(
                                      Helper.getDistance(_con.restaurant.distance, Helper.of(context).trans(setting.value.distanceUnit)),
                                      style: Theme.of(context).textTheme.caption.merge(TextStyle(color: Theme.of(context).primaryColor)),
                                    ),
                                  ),
                                  SizedBox(width: 10),
                                  SizedBox(
                                    height: 32,
                                    child: Chip(
                                      padding: EdgeInsets.all(0),
                                      label: Row(
                                        mainAxisAlignment: MainAxisAlignment.center,
                                        children: <Widget>[
                                          Text(_con.restaurant.rate,
                                              style: Theme.of(context).textTheme.bodyText1.merge(TextStyle(color: Theme.of(context).primaryColor))),
                                          Icon(
                                            Icons.star_border,
                                            color: Theme.of(context).primaryColor,
                                            size: 16,
                                          ),
                                        ],
                                      ),
                                      backgroundColor: Theme.of(context).accentColor.withOpacity(0.9),
                                      shape: StadiumBorder(),
                                    ),
                                  ),
                                ],
                              ),
                              Padding(
                                padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 12),
                                child: Helper.applyHtml(context, _con.restaurant.description),
                              ),
                              ImageThumbCarouselWidget(galleriesList: _con.galleries),
//                              Padding(
//                                padding: const EdgeInsets.symmetric(horizontal: 20),
//                                child: ListTile(
//                                  dense: true,
//                                  contentPadding: EdgeInsets.symmetric(vertical: 0),
//                                  leading: Icon(
//                                    Icons.stars,
//                                    color: Theme.of(context).hintColor,
//                                  ),
//                                  title: Text(
//                                    S.of(context).information,
//                                    style: Theme.of(context).textTheme.headline4,
//                                  ),
//                                ),
//                              ),
//                              Padding(
//                                padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 12),
//                                child: Helper.applyHtml(context, _con.restaurant.information),
//                              ),
                              Container(
                                padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 20),
                                margin: const EdgeInsets.symmetric(vertical: 5),
                                color: Theme.of(context).primaryColor,
                                child: Row(
//                                  crossAxisAlignment: CrossAxisAlignment.start,
                                  crossAxisAlignment: CrossAxisAlignment.center,
                                  children: <Widget>[
                                    Expanded(
                                      child: Text(
                                        _con.restaurant.address ?? '',
                                          overflow: TextOverflow.ellipsis,
                                        maxLines: 2,
                                        style: Theme.of(context).textTheme.bodyText1,
                                      ),
                                    ),
                                    SizedBox(width: 10),
                                    SizedBox(
                                      width: 42,
                                      height: 42,
                                      child: FlatButton(
                                        padding: EdgeInsets.all(0),
                                        onPressed: () {
                                          Navigator.of(context).pushNamed('/Pages', arguments: new RouteArgument(id: '1', param: _con.restaurant));
                                        },
                                        child: Icon(
                                          Icons.directions,
                                          color: Theme.of(context).primaryColor,
                                          size: 24,
                                        ),
                                        color: Theme.of(context).accentColor.withOpacity(0.9),
                                        shape: StadiumBorder(),
                                      ),
                                    ),
                                  ],
                                ),
                              ),
                              Container(
                                padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 10),
                                margin: const EdgeInsets.symmetric(vertical: 1),
                                color: Theme.of(context).primaryColor,
                                child: Row(
                                  crossAxisAlignment: CrossAxisAlignment.center,
                                  children: <Widget>[
                                    Expanded(
                                      child: Text(
//                                        '${_con.restaurant.phone}',
                                        'Need help with your order?',
                                        overflow: TextOverflow.ellipsis,
                                        style: Theme.of(context).textTheme.bodyText1,
                                      ),
                                    ),
                                    SizedBox(width: 10),
                                    SizedBox(
                                      width: 42,
                                      height: 42,
                                      child: FlatButton(
                                        padding: EdgeInsets.all(0),
                                        onPressed: () {
//                                          launch("tel:${_con.restaurant.phone}");
                                          launch("tel:${setting.value.phone_number}");
                                        },
                                        child: Icon(
                                          Icons.call,
                                          color: Theme.of(context).primaryColor,
                                          size: 24,
                                        ),
                                        color: Theme.of(context).accentColor.withOpacity(0.9),
                                        shape: StadiumBorder(),
                                      ),
                                    ),
                                  ],
                                ),
                              ),


                              Padding(
                                padding: const EdgeInsets.symmetric(horizontal: 20),
                                child: ListTile(
                                  dense: true,
                                  contentPadding: EdgeInsets.symmetric(vertical: 0),
                                  leading: Icon(
                                    Icons.store,
                                    size: 35,
                                    color: Theme.of(context).hintColor,
                                  ),
                                  title: Text(
                                    S.of(context).store,
                                    style: Theme.of(context).textTheme.headline4,
                                  ),
                                  subtitle: _isSearched
                                                    ? Text(
                                                        "Search Results",
                                                        style: Theme.of(context).textTheme.caption)
                                                    : Text(
                                                        "Featured Items and Discounts.",
                                                    style: Theme.of(context).textTheme.caption),
                                ),
                              ),

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
                                  Center(child: SizedBox(width: 60, height: 60, child: CircularProgressIndicator(strokeWidth: 5))),
                                  SizedBox(height: 30)
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

                              : _con.foods.isEmpty
//                                  ? CircularLoadingWidget(height: 100)
                                  ? Column (
                                children: <Widget>[
                                  Center(heightFactor: 2,
                                      child: SizedBox( width: 60, height: 60, child: CircularProgressIndicator(strokeWidth: 5))),
                                      SizedBox(height: 300)
                                ],
                              )
                                  : ListView.separated(
                                      padding: EdgeInsets.only(bottom: 40),
                                      scrollDirection: Axis.vertical,
                                      shrinkWrap: true,
                                      primary: false,
                                      itemCount: _con.foods.length,
                                      separatorBuilder: (context, index) {
                                        return SizedBox(height: 10);
                                      },
                                      itemBuilder: (context, index) {
                                        if (index == _con.foods.length - 1)
                                          _con.isLoading = false;

                                        if (_con.foods.isNotEmpty) {

                                          return FoodItemWidget(
                                            heroTag: 'store_list',
                                            food: _con.foods.elementAt(index),
                                          );
                                        } else {
                                          return SizedBox(height: 0);
                                        }

                                      },
                                    ),

                              !_initialLoading && _con.isLoading && _hasMore && !_isSearching
                                  ? Center(child: SizedBox(width: 60, height: 60, child: CircularProgressIndicator(strokeWidth: 5)))
                                  : SizedBox(height: 0),
                              SizedBox(height: 30)
                            ],
                          ),
                        ),

//                              _con.foods.isEmpty
//                                  ? CircularLoadingWidget(height: 500)
//                                  : ListView.separated(
////                                      padding: EdgeInsets.symmetric(vertical: 10),
//                                      padding:
//                                          EdgeInsets.only(top: 10, bottom: 90),
//                                      scrollDirection: Axis.vertical,
//                                      shrinkWrap: true,
//                                      primary: false,
//                                      itemCount: _con.foods.length,
//                                      separatorBuilder: (context, index) {
//                                        return SizedBox(height: 10);
//                                      },
//                                      itemBuilder: (context, index) {
//                                        return FoodItemWidget(
//                                          heroTag: 'details_featured_food',
//                                          food: _con.foods.elementAt(index),
//                                        );
//                                      },
//                                    ),

//                              SizedBox(height: 100),
//                              _con.reviews.isEmpty
//                                  ? SizedBox(height: 5)
//                                  : Padding(
//                                      padding: const EdgeInsets.symmetric(vertical: 10, horizontal: 20),
//                                      child: ListTile(
//                                        dense: true,
//                                        contentPadding: EdgeInsets.symmetric(vertical: 0),
//                                        leading: Icon(
//                                          Icons.recent_actors,
//                                          color: Theme.of(context).hintColor,
//                                        ),
//                                        title: Text(
//                                          S.of(context).what_they_say,
//                                          style: Theme.of(context).textTheme.headline4,
//                                        ),
//                                      ),
//                                    ),
//                              _con.reviews.isEmpty
//                                  ? SizedBox(height: 5)
//                                  : Padding(
//                                      padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 10),
//                                      child: ReviewsListWidget(reviewsList: _con.reviews),
//                                    ),
                      ],
                    ),
                    Positioned(
                      top: 15,
                      right: 20,
                      child: ShoppingCartFloatButtonWidget(
                              iconColor: Theme.of(context).primaryColor,
                              labelColor: Theme.of(context).hintColor,
                            ),
                    ),
                  ],
                ),
        )
    );
  }
}
