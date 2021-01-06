import 'package:flutter/material.dart';
import 'package:mvc_pattern/mvc_pattern.dart';
import 'package:saudaghar/src/elements/SocialMediaOrdering.dart';
import '../../src/elements/StoreSelectShoppingCartButtonWidget.dart';
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
              leading: const SizedBox(),
              title: Text(
                "Where to Shop?",
                style: Theme.of(context).textTheme.headline6.merge(TextStyle(letterSpacing: 1.5)),
              ),
              actions: <Widget>[
                new StoreSelectShoppingCartButtonWidget()
              ],
            ),
            body: Stack(
              children: [
                Column(
                    children: [
                      Center(
                        child:
                        Column(
                            mainAxisAlignment: MainAxisAlignment.center,
                            children: [
                              // LogoLoadingWidget(),
                              Container(
                                padding: EdgeInsets.symmetric(horizontal: 40),
                                child: FlatButton(
                                  onPressed: () => nextPage(0),
                                  child: Image.asset(
                                    'assets/img/saudaghar.png',
                                  ),
                                ),
                              ),
                              Text(
                                "Shop at saudaghar",
                                style: Theme.of(context).textTheme.headline2.merge(TextStyle(fontSize: settingsRepo.compact_view_vertical ? 20 : 22)),
                              ),
                              Text(
                                "Delivered in under 60 minutes",
                                style: TextStyle(fontSize: settingsRepo.compact_view_vertical ? 12 : 16),
                              ),
                              SizedBox(height: settingsRepo.compact_view_vertical ? 5 : 20),
                              Text(
                                'OR',
                                style: TextStyle(fontSize: settingsRepo.compact_view_vertical ? 20 : 30),
                              ),
                              SizedBox(height: settingsRepo.compact_view_vertical ? 5 : 20),
                              Text(
                                "Scheduled Delivery",
                                style: TextStyle(fontSize: settingsRepo.compact_view_vertical ? 12 : 16),
                              ),
                              const SizedBox(height: 10),
                              Row(
                                mainAxisAlignment: MainAxisAlignment.center,
                                children: [
                                  Expanded(
                                    child: Column(
                                      children: [
                                        Material(
                                          elevation: 14.0,
                                          shape: CircleBorder(),
                                          clipBehavior: Clip.hardEdge,
                                          color: Colors.transparent,
                                          child: Ink.image(
                                            image: AssetImage('assets/img/others.jpg'),
                                            fit: BoxFit.cover,
                                            width: settingsRepo.compact_view_vertical ? 80 : 120.0,
                                            height: settingsRepo.compact_view_vertical ? 80 : 120.0,
                                            child: InkWell(
                                              onTap: () => nextPage(1),
                                            ),
                                          ),
                                        ),
                                        const SizedBox(height: 10),
                                        Text(
                                          'Other Stores',
                                          style: Theme.of(context).textTheme.headline5,
                                        ),
                                      ],
                                    ),
                                  ),
                                  Expanded(
                                    child: Column(
                                        children: [
                                          Material(
                                            elevation: 14.0,
                                            shape: CircleBorder(),
                                            clipBehavior: Clip.hardEdge,
                                            color: Colors.transparent,
                                            child: Ink.image(
                                              image: AssetImage('assets/img/resto.jpg'),
                                              fit: BoxFit.cover,
                                              width: settingsRepo.compact_view_vertical ? 80 : 120.0,
                                              height: settingsRepo.compact_view_vertical ? 80 : 120.0,
                                              child: InkWell(
                                                onTap: () => nextPage(2),
                                              ),
                                            ),
                                          ),
                                          const SizedBox(height: 10),
                                          Text(
                                            'Home Cooked',
                                            style: Theme.of(context).textTheme.headline5,
                                          ),
                                        ]),
                                  ),
                                ],
                              ),
                              SizedBox(height: settingsRepo.compact_view_vertical ? 10 : 20),
                            ]
                        ),
                      ),
                    ]
                ),
                Positioned(
                  bottom: 0,
                  width: MediaQuery.of(context).size.width,
                  child: SocialMediaOrdering()
                ),
              ],
            )
        )
    );
  }

  void nextPage(int isStore) {
    settingsRepo.isStore.value = isStore;
    Navigator.of(context).pushNamed('/Pages', arguments: 2);
  }
}
