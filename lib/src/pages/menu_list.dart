import 'package:flutter/material.dart';
import 'package:food_delivery_app/src/elements/AislesItemWidget.dart';
import 'package:food_delivery_app/src/models/food.dart';
import 'package:food_delivery_app/src/models/restaurant.dart';
import 'package:food_delivery_app/src/models/category.dart';
import 'package:mvc_pattern/mvc_pattern.dart';

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


  _MenuWidgetState() : super(CategoryController()) {
    _con = controller;
    }

  @override
  void initState() {
    super.initState();
    store = widget.routeArgument.param;
    _con.listenForCategories();
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
        padding: EdgeInsets.only(top: 10, bottom: 50),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          mainAxisAlignment: MainAxisAlignment.start,
          mainAxisSize: MainAxisSize.max,
          children: <Widget>[
//            _con.allItemsLoaded
//                ? SizedBox(height: 0)
//                :
//            Center(
//                child: SizedBox(
//                    width: 60,
//                    height: 60,
//                    child: CircularProgressIndicator(strokeWidth: 5))),
//            Padding(
//              padding: const EdgeInsets.symmetric(horizontal: 20),
//              child: SearchBarWidget(),
//            ),
//            ListTile(
//              dense: true,
//              contentPadding: EdgeInsets.symmetric(horizontal: 20, vertical: 10),
//              leading: Icon(
//                Icons.trending_up,
//                color: Theme.of(context).hintColor,
//              ),
//              title: Text(
//                S.of(context).trending_this_week,
//                style: Theme.of(context).textTheme.headline4,
//              ),
//              subtitle: Text(
//                S.of(context).clickOnTheFoodToGetMoreDetailsAboutIt,
//                style: Theme.of(context).textTheme.caption.merge(TextStyle(fontSize: 11)),
//              ),
//            ),
//            FoodsCarouselWidget(heroTag: 'menu_trending_food', foodsList: _con.trendingFoods),
//            ListTile(
//              dense: true,
//              contentPadding: EdgeInsets.symmetric(horizontal: 20, vertical: 10),
//              leading: Icon(
//                Icons.list,
//                color: Theme.of(context).hintColor,
//              ),
//              title: Text(
//                S.of(context).all_menu,
//                style: Theme.of(context).textTheme.headline4,
//              ),
//              subtitle: Text(
//                S.of(context).clickOnTheFoodToGetMoreDetailsAboutIt,
//                style: Theme.of(context).textTheme.caption.merge(TextStyle(fontSize: 11)),
//              ),
//            ),

        SizedBox(height: 10),

            _con.aisles.isEmpty
                ? CircularLoadingWidget(height: 250)
                : ListView.separated(
                    scrollDirection: Axis.vertical,
                    shrinkWrap: true,
                    primary: false,
                    itemCount: _con.aisles.length,
                    separatorBuilder: (context, index) {
                      return SizedBox(height: 20);
                    },
                    itemBuilder: (context, index) {
                      Category currAisle = _con.aisles.elementAt(index);
                      if (_con.aisleToSubaisleMap[currAisle.id] == null) {
                        return SizedBox(height: 10);
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

//  List<Food> getFoodsForAisle(String aisleID) {
//    List<Food> currFood = new List<Food>();
//    if (_con.foods != null) {
//      for (int i = 0; i < _con.foods.length; i++) {
//        if (_con.foods.elementAt(i).category.id == aisleID) {
//          currFood.add(_con.foods.elementAt(i));
////          _con.foods.removeAt(i);
//        }
//      }
//    }
//    return currFood;
//  }

}
