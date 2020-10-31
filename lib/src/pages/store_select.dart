import 'package:flutter/material.dart';
import 'package:google_maps_flutter/google_maps_flutter.dart';
import 'package:mvc_pattern/mvc_pattern.dart';

import '../../generated/l10n.dart';
import '../controllers/map_controller.dart';
import '../elements/CardsCarouselWidget.dart';
import '../elements/CircularLoadingWidget.dart';
import '../models/restaurant.dart';
import '../models/route_argument.dart';

class StoreSelectWidget extends StatefulWidget {
  final RouteArgument routeArgument;
  final GlobalKey<ScaffoldState> parentScaffoldKey;

  StoreSelectWidget({Key key, this.routeArgument, this.parentScaffoldKey}) : super(key: key);

  @override
  _MapWidgetState createState() => _MapWidgetState();
}

class _MapWidgetState extends StateMVC<StoreSelectWidget> {
  MapController _con;

  _MapWidgetState() : super(MapController()) {
    _con = controller;
  }

  @override
  void initState() {
    _con.currentRestaurant = widget.routeArgument?.param as Restaurant;
    if (_con.currentRestaurant?.latitude != null) {
      // user select a restaurant
      _con.getRestaurantLocation();
      _con.getDirectionSteps();
    } else {
      _con.getCurrentLocation();
    }
    super.initState();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        backgroundColor: Colors.transparent,
        elevation: 0,
        centerTitle: true,
        // leading: _con.currentRestaurant?.latitude == null
        //     ? new IconButton(
        //         icon: new Icon(Icons.sort, color: Theme.of(context).hintColor),
        //         onPressed: () => widget.parentScaffoldKey.currentState.openDrawer(),
        //       )
        //     : IconButton(
        //         icon: new Icon(Icons.arrow_back, color: Theme.of(context).hintColor),
        //         onPressed: () => Navigator.of(context).pushNamed('/Pages', arguments: 2),
        //       ),
        title: Text(
          "Where to Shop?",
          style: Theme.of(context).textTheme.headline6.merge(TextStyle(letterSpacing: 1.3)),
        ),
        actions: <Widget>[
          // IconButton(
          //   icon: Icon(
          //     Icons.my_location,
          //     color: Theme.of(context).hintColor,
          //   ),
          //   onPressed: () {
          //     _con.goCurrentLocation();
          //   },
          // ),
          SizedBox(width: 10,)
//          IconButton(
//            icon: Icon(
//              Icons.filter_list,
//              color: Theme.of(context).hintColor,
//            ),
//            onPressed: () {
//              widget.parentScaffoldKey.currentState.openEndDrawer();
//            },
//          ),
        ],
      ),
        body: Column(
          mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Container(
                  margin: const EdgeInsets.all(15.0),
                  decoration: BoxDecoration(
                    border: Border.all(
                        color: Theme.of(context).accentColor.withOpacity(0.9),
                        width: 2),
                    color: Theme.of(context).primaryColor.withOpacity(0.9),
                    boxShadow: [
                      BoxShadow(
                          color: Theme.of(context).focusColor.withOpacity(1),
                          blurRadius: 5,
                          offset: Offset(0, 2)),
                    ],
                  ),
                  child: ConstrainedBox(
                      constraints: BoxConstraints.tightFor(),
                      child: FlatButton(
                          padding: EdgeInsets.all(10.0),
                          onPressed: () => print("SuadaGhar"),
                          child: Row(
                            children: [
                              Image.asset('assets/img/logo.png', height: 130),
                              Text(
                                "SaudaGhar Store",
                                style: TextStyle(fontSize: 20),
                              )
                            ],
                          )))),
              const Divider(height: 10),
              Container(
              margin: const EdgeInsets.symmetric(horizontal: 60, vertical: 15),
              decoration: BoxDecoration(
                border: Border.all(
                    color: Theme.of(context).primaryColor.withOpacity(0.9),
                    width: 2),
                color: Theme.of(context).primaryColor.withOpacity(0.9),
                boxShadow: [
                  BoxShadow(
                      color: Theme.of(context).focusColor.withOpacity(1),
                      blurRadius: 5,
                      offset: Offset(0, 2)),
                ],
              ),
              child: ConstrainedBox(
                  constraints: BoxConstraints.tightFor(),
                  child: FlatButton(
                      padding: EdgeInsets.all(10.0),
                      onPressed: () => print("SuadaGhar"),
                      child: Row(
                        children: [
                          ClipRRect(
                            borderRadius: BorderRadius.circular(8.0),
                            child: Image.asset('assets/img/other_stores.jpg', height: 110),
                          ),
                          const SizedBox(width: 10),
                          const Text(
                            "Other Stores",
                            style: TextStyle(fontSize: 20),
                          )
                        ],
                      )))),
          Container(
              margin: const EdgeInsets.symmetric(horizontal: 60, vertical: 5),
              decoration: BoxDecoration(
                border: Border.all(
                    color: Theme.of(context).primaryColor.withOpacity(0.9),
                    width: 2),
                color: Theme.of(context).primaryColor.withOpacity(0.9),
                boxShadow: [
                  BoxShadow(
                      color: Theme.of(context).focusColor.withOpacity(1),
                      blurRadius: 5,
                      offset: Offset(0, 2)),
                ],
              ),
              child: ConstrainedBox(
                  constraints: BoxConstraints.tightFor(),
                  child: FlatButton(
                      padding: EdgeInsets.all(10.0),
                      onPressed: () => print("Restaurants"),
                      child: Row(
                        children: [
                          ClipRRect(
                            borderRadius: BorderRadius.circular(8.0),
                            child: Image.asset('assets/img/restaurants.jpg',
                                height: 110),
                          ),
                          const SizedBox(width: 10),
                          const Text(
                            "Other Stores",
                            style: TextStyle(fontSize: 20),
                          )
                        ],
                      ))))
        ]));
  }
}
