import 'package:flutter/material.dart';
import 'package:mvc_pattern/mvc_pattern.dart';
import 'package:saudaghar/src/elements/StoreSelectShoppingCartButtonWidget.dart';
import '../controllers/restaurant_controller.dart';
import '../controllers/cart_controller.dart';
import '../elements/ShoppingCartButtonWidget.dart';
import '../repository/user_repository.dart';

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
  CartController _con = new CartController();
  _StoreSelectWidgetState() : super(RestaurantController()) {
  }

  @override
  void initState() {
    super.initState();
    if (currentUser.value.apiToken != null) {
      _con.listenForCartsCount();
    }
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
                new StoreSelectShoppingCartButtonWidget()
              ],
            ),
            body: Center(
                child: ListView(
                    shrinkWrap: true,
                    children: [
                      Column(
                        mainAxisAlignment: MainAxisAlignment.center,
                        children: [
                          // LogoLoadingWidget(),
                          FlatButton(
                              onPressed: () => nextPage(0),
                              child: Image.asset(
                                  'assets/img/saudaghar.png',
                              )
                          ),
                          Text(
                            "saudaghar",
                            style: Theme.of(context).textTheme.headline2.merge(TextStyle(fontSize: 30)),
                          ),
                          Text(
                            "Delivered in under 60 minutes",
                            style: TextStyle(fontSize: 16),
                          ),
                          const SizedBox(height: 20),
                          Text(
                            'OR',
                            style: TextStyle(fontSize: 30),
                          ),
                          const SizedBox(height: 20),
                          Text(
                            "Scheduled Delivery",
                            style: TextStyle(fontSize: 16),
                          ),
                          const SizedBox(height: 10),
                          Row(
                            mainAxisAlignment: MainAxisAlignment.center,
                            children: [
                              Column(
                                children: [
                                  Material(
                                    elevation: 14.0,
                                    shape: CircleBorder(),
                                    clipBehavior: Clip.hardEdge,
                                    color: Colors.transparent,
                                    child: Ink.image(
                                      image: AssetImage('assets/img/others.jpg'),
                                      fit: BoxFit.cover,
                                      width: 120.0,
                                      height: 120.0,
                                      child: InkWell(
                                        onTap: () => nextPage(1),
                                      ),
                                    ),
                                  ),
                                  const SizedBox(height: 5),
                                  Text(
                                    'Other Stores',
                                    style: TextStyle(fontSize: 16),
                                  ),
                                ],
                              ),
                              const SizedBox(width: 30),
                              Column(
                                children: [
                                  Material(
                                    elevation: 14.0,
                                    shape: CircleBorder(),
                                    clipBehavior: Clip.hardEdge,
                                    color: Colors.transparent,
                                    child: Ink.image(
                                      image: AssetImage('assets/img/resto.jpg'),
                                      fit: BoxFit.cover,
                                      width: 120.0,
                                      height: 120.0,
                                      child: InkWell(
                                        onTap: () => nextPage(2),
                                      ),
                                    ),
                                  ),
                                  const SizedBox(height: 5),
                                  Text(
                                    'Home Cooked',
                                    style: TextStyle(fontSize: 16),
                                  ),
                                ],
                              ),
                            ],
                          ),

                          // FlatButton(
                          //     onPressed: () => nextPage(0),
                          //     child: Image.asset(
                          //       'assets/img/resto.jpg',
                          //     )
                          // ),
                          // Container(
                          //     margin: const EdgeInsets.symmetric(
                          //         horizontal: 40, vertical: 10),
                          //     decoration: BoxDecoration(
                          //       border: Border.all(
                          //           color:
                          //               Theme.of(context).primaryColor.withOpacity(0.9),
                          //           width: 2),
                          //       color: Theme.of(context).primaryColor.withOpacity(0.9),
                          //       boxShadow: [
                          //         BoxShadow(
                          //             color:
                          //                 Theme.of(context).focusColor.withOpacity(1),
                          //             blurRadius: 5,
                          //             offset: Offset(0, 2)),
                          //       ],
                          //     ),
                          //     child: ConstrainedBox(
                          //         constraints: BoxConstraints.tightFor(),
                          //         child: FlatButton(
                          //             padding: EdgeInsets.all(10.0),
                          //             onPressed: () => nextPage(1),
                          //             child: Row(
                          //               children: [
                          //                 ClipRRect(
                          //                   borderRadius: BorderRadius.circular(8.0),
                          //                   child: Image.asset(
                          //                       'assets/img/other_stores.jpg',
                          //                       height: settingsRepo.compact_view
                          //                           ? 70
                          //                           : 90),
                          //                 ),
                          //                 const SizedBox(width: 20),
                          //                 Text(
                          //                   "Other Stores",
                          //                   style: settingsRepo.compact_view
                          //                       ? TextStyle(fontSize: 16)
                          //                       : TextStyle(fontSize: 20),
                          //                 )
                          //               ],
                          //             )))),
                          // Container(
                          //     margin: const EdgeInsets.symmetric(
                          //         horizontal: 40, vertical: 5),
                          //     decoration: BoxDecoration(
                          //       border: Border.all(
                          //           color:
                          //               Theme.of(context).primaryColor.withOpacity(0.9),
                          //           width: 2),
                          //       color: Theme.of(context).primaryColor.withOpacity(0.9),
                          //       boxShadow: [
                          //         BoxShadow(
                          //             color:
                          //                 Theme.of(context).focusColor.withOpacity(1),
                          //             blurRadius: 5,
                          //             offset: Offset(0, 2)),
                          //       ],
                          //     ),
                          //     child: ConstrainedBox(
                          //         constraints: BoxConstraints.tightFor(),
                          //         child: FlatButton(
                          //             padding: EdgeInsets.all(10.0),
                          //             onPressed: () => nextPage(2),
                          //             child: Row(
                          //               children: [
                          //                 ClipRRect(
                          //                   borderRadius: BorderRadius.circular(8.0),
                          //                   child: Image.asset(
                          //                       'assets/img/restaurants.jpg',
                          //                       height: settingsRepo.compact_view
                          //                           ? 70
                          //                           : 90),
                          //                 ),
                          //                 const SizedBox(width: 20),
                          //                 Text(
                          //                   "Home Cooked",
                          //                   style: settingsRepo.compact_view
                          //                       ? TextStyle(fontSize: 16)
                          //                       : TextStyle(fontSize: 20),
                          //             )
                          //           ]))))
              ])
            ]))));
  }

  void nextPage(int isStore) {
    settingsRepo.isStore.value = isStore;
    Navigator.of(context).pushNamed('/Pages', arguments: 2);
  }
}
