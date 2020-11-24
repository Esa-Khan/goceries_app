import 'package:flutter/material.dart';
import 'package:mvc_pattern/mvc_pattern.dart';
import 'package:saudaghar/src/controllers/restaurant_controller.dart';
import 'package:saudaghar/src/elements/LogoLoadingWidget.dart';

import '../models/route_argument.dart';
import '../repository/settings_repository.dart' as settingsRepo;

class StoreSelectWidget extends StatefulWidget {
  final RouteArgument routeArgument;
  final GlobalKey<ScaffoldState> parentScaffoldKey;

  StoreSelectWidget({Key key, this.routeArgument, this.parentScaffoldKey})
      : super(key: key);

  @override
  _StoreSelectWidgetState createState() => _StoreSelectWidgetState();
}

class _StoreSelectWidgetState extends StateMVC<StoreSelectWidget> {
  _StoreSelectWidgetState() : super(RestaurantController()) {
  }

  @override
  Widget build(BuildContext context) {
    return WillPopScope(
        onWillPop: () async => false,
        child: Scaffold(
            appBar: AppBar(
              backgroundColor: Colors.transparent,
              elevation: 0,
              centerTitle: true,
              leading: const SizedBox(height: 0),
              title: Text(
                "Where to Shop?",
                style: Theme.of(context).textTheme.headline6.merge(TextStyle(letterSpacing: 1.5)),
              ),
              actions: <Widget>[
                IconButton(
                  padding: EdgeInsets.fromLTRB(0, 0, 20, 0),
                  icon: Icon(Icons.login, color: Theme.of(context).accentColor),
                  onPressed: () {
                    Navigator.of(context).pushNamed('/Login');
                  },
                )
              ],
            ),
            body: Center(
                child: ListView(shrinkWrap: true,
                    children: [
              Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  // LogoLoadingWidget(),
                  Container(
                      margin: const EdgeInsets.symmetric(
                          horizontal: 15, vertical: 20),
                      decoration: BoxDecoration(
                        border: Border.all(
                            color:
                                Theme.of(context).accentColor.withOpacity(0.9),
                            width: 2),
                        color: Theme.of(context).primaryColor.withOpacity(0.9),
                        boxShadow: [
                          BoxShadow(
                              color:
                                  Theme.of(context).focusColor.withOpacity(1),
                              blurRadius: 5,
                              offset: Offset(0, 2)),
                        ],
                      ),
                      child: ConstrainedBox(
                          constraints: BoxConstraints.tightFor(),
                          child: FlatButton(
                              padding: EdgeInsets.all(10.0),
                              onPressed: () => nextPage(0),
                              child: Row(
                                children: [
                                  Image.asset('assets/img/logo.png',
                                      height: settingsRepo.compact_view ? 80 : 130),
                                  const SizedBox(width: 20),
                                  Text(
                                    "saudaghar",
                                    style: TextStyle(fontSize: 20),
                                  )
                                ],
                              )))),
                  Text('OR',
                    style: Theme.of(context).textTheme.headline5,
                  ),
                  Container(
                      margin: const EdgeInsets.symmetric(
                          horizontal: 40, vertical: 10),
                      decoration: BoxDecoration(
                        border: Border.all(
                            color:
                                Theme.of(context).primaryColor.withOpacity(0.9),
                            width: 2),
                        color: Theme.of(context).primaryColor.withOpacity(0.9),
                        boxShadow: [
                          BoxShadow(
                              color:
                                  Theme.of(context).focusColor.withOpacity(1),
                              blurRadius: 5,
                              offset: Offset(0, 2)),
                        ],
                      ),
                      child: ConstrainedBox(
                          constraints: BoxConstraints.tightFor(),
                          child: FlatButton(
                              padding: EdgeInsets.all(10.0),
                              onPressed: () => nextPage(1),
                              child: Row(
                                children: [
                                  ClipRRect(
                                    borderRadius: BorderRadius.circular(8.0),
                                    child: Image.asset(
                                        'assets/img/other_stores.jpg',
                                        height: settingsRepo.compact_view
                                            ? 70
                                            : 90),
                                  ),
                                  const SizedBox(width: 20),
                                  Text(
                                    "Other Stores",
                                    style: settingsRepo.compact_view
                                        ? TextStyle(fontSize: 16)
                                        : TextStyle(fontSize: 20),
                                  )
                                ],
                              )))),
                  Container(
                      margin: const EdgeInsets.symmetric(
                          horizontal: 40, vertical: 5),
                      decoration: BoxDecoration(
                        border: Border.all(
                            color:
                                Theme.of(context).primaryColor.withOpacity(0.9),
                            width: 2),
                        color: Theme.of(context).primaryColor.withOpacity(0.9),
                        boxShadow: [
                          BoxShadow(
                              color:
                                  Theme.of(context).focusColor.withOpacity(1),
                              blurRadius: 5,
                              offset: Offset(0, 2)),
                        ],
                      ),
                      child: ConstrainedBox(
                          constraints: BoxConstraints.tightFor(),
                          child: FlatButton(
                              padding: EdgeInsets.all(10.0),
                              onPressed: () => nextPage(2),
                              child: Row(
                                children: [
                                  ClipRRect(
                                    borderRadius: BorderRadius.circular(8.0),
                                    child: Image.asset(
                                        'assets/img/restaurants.jpg',
                                        height: settingsRepo.compact_view
                                            ? 70
                                            : 90),
                                  ),
                                  const SizedBox(width: 20),
                                  Text(
                                    "Home Cooked",
                                    style: settingsRepo.compact_view
                                        ? TextStyle(fontSize: 16)
                                        : TextStyle(fontSize: 20),
                              )
                            ]))))
              ])
            ]))));
  }

  void nextPage(int isStore) {
    settingsRepo.isStore.value = isStore;
    Navigator.of(context).pushNamed('/Pages', arguments: 2);
  }
}
