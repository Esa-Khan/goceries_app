import 'package:flutter/material.dart';
import 'package:mvc_pattern/mvc_pattern.dart';

import '../../generated/l10n.dart';
import '../controllers/search_controller.dart';
import '../elements/CardWidget.dart';
import '../elements/CircularLoadingWidget.dart';
import '../elements/FoodItemWidget.dart';
import '../models/route_argument.dart';
import 'EmptyItemSearchWidget.dart';

class SearchResultWidget extends StatefulWidget {
  final String heroTag;

  SearchResultWidget({Key key, this.heroTag}) : super(key: key);

  @override
  _SearchResultWidgetState createState() => _SearchResultWidgetState();
}

class _SearchResultWidgetState extends StateMVC<SearchResultWidget> {
  SearchController _con;
  bool timed_out = false;

  _SearchResultWidgetState() : super(SearchController()) {
    _con = controller;
  }

  @override
  void initState() {
    super.initState();
  }

  @override
  Widget build(BuildContext context) {
    return Container(
      color: Theme.of(context).scaffoldBackgroundColor,
      child: Column(
        mainAxisSize: MainAxisSize.max,
        children: <Widget>[
          Padding(
            padding: const EdgeInsets.only(top: 15, left: 20, right: 20),
            child: ListTile(
              dense: true,
              contentPadding: EdgeInsets.symmetric(vertical: 0),
              trailing: IconButton(
                icon: Icon(Icons.close),
                color: Theme.of(context).hintColor,
                onPressed: () {
                  Navigator.pop(context);
                },
              ),
              title: Text(
                S.of(context).search,
                style: Theme.of(context).textTheme.headline4,
              ),
              subtitle: Text(
                S.of(context).ordered_by_nearby_first,
                style: Theme.of(context).textTheme.caption,
              ),
            ),
          ),
          Padding(
            padding: const EdgeInsets.all(20),
            child: TextField(
              onSubmitted: (text) async {
                await _con.refreshSearch(text);
//                _con.saveSearch(text);
              },
              autofocus: true,
              decoration: InputDecoration(
                contentPadding: EdgeInsets.all(12),
                hintText: S.of(context).search_for_stores_or_items,
                hintStyle: Theme.of(context).textTheme.caption.merge(TextStyle(fontSize: 14)),
                prefixIcon: Icon(Icons.search, color: Theme.of(context).accentColor),
                border: OutlineInputBorder(borderSide: BorderSide(color: Theme.of(context).focusColor.withOpacity(0.1))),
                focusedBorder: OutlineInputBorder(borderSide: BorderSide(color: Theme.of(context).focusColor.withOpacity(0.3))),
                enabledBorder: OutlineInputBorder(borderSide: BorderSide(color: Theme.of(context).focusColor.withOpacity(0.1))),
              ),
            ),
          ),
          _con.restaurants.isEmpty && _con.foods.isEmpty
              ? CircularLoadingWidget(height: 288)
              : Expanded(
                  child: ListView(
                    children: <Widget>[
                      _con.restaurants.isEmpty ? const SizedBox(height: 0) :
                      Padding(
                        padding: const EdgeInsets.only(top: 20, left: 20, right: 20),
                        child: ListTile(
                          dense: true,
                          contentPadding: EdgeInsets.symmetric(vertical: 0),
                          title: Text(
                            S.of(context).store_results,
                            style: Theme.of(context).textTheme.subtitle1,
                          ),
                        ),
                      ),
                      _con.restaurants.isEmpty ? const SizedBox(height: 0) :
                      ListView.builder(
                        shrinkWrap: true,
                        primary: false,
                        itemCount: _con.restaurants.length,
                        itemBuilder: (context, index) {
                          return GestureDetector(
                            onTap: () {
                              Navigator.of(context).pushNamed('/Details',
                                  arguments: RouteArgument(
                                    id: _con.restaurants.elementAt(index).id,
                                    heroTag: widget.heroTag,
                                  ));
                            },
                            child: CardWidget(restaurant: _con.restaurants.elementAt(index), heroTag: widget.heroTag),
                          );
                        },
                      ),

                      _con.foods.isEmpty
                          ? Center(child: SizedBox(width: 120, height: 120, child: CircularProgressIndicator(strokeWidth: 8)))
                          : Padding(
                              padding: const EdgeInsets.only(left: 20, right: 20),
                              child: ListTile(
                                dense: true,
                                contentPadding: EdgeInsets.symmetric(vertical: 0),
                                title: Text(
                                  S.of(context).item_results,
                                  style: Theme.of(context).textTheme.subtitle1,
                                ),
                              ),
                            ),
                      _con.foods.isEmpty
                          ? timed_out
                            ? EmptyItemSearchWidget()
                            :  Center(child: SizedBox(width: 120, height: 120, child: CircularProgressIndicator(strokeWidth: 8)))
                          : ListView.separated(
                              scrollDirection: Axis.vertical,
                              shrinkWrap: true,
                              primary: false,
                              itemCount: _con.foods.length,
                              separatorBuilder: (context, index) {
                                return const SizedBox(height: 10);
                              },
                              itemBuilder: (context, index) {
                                return FoodItemWidget(
                                  heroTag: 'search_list',
                                  food: _con.foods.elementAt(index),
                                );
                              },
                            ),
                    ],
                  ),
                ),
          const SizedBox(height: 20),
        ],
      ),
    );
  }

  Future<void> search_timeout() async {
    if (mounted && !timed_out) {
      Future.delayed(Duration(seconds: 1)).whenComplete(() {
        if (mounted) {
          print("---------TIMEDOUT----------");
          setState(() => timed_out = true);
        }
      });
    }
  }
}
