import 'package:flutter/material.dart';
import 'package:mvc_pattern/mvc_pattern.dart';

import '../../src/elements/StoreSelectShoppingCartButtonWidget.dart';
import '../controllers/cart_controller.dart';
import '../controllers/restaurant_controller.dart';
import '../helpers/size_config.dart';
import '../models/route_argument.dart';
import '../repository/settings_repository.dart' as settingsRepo;
import '../repository/user_repository.dart';

class StoreSelectWidget extends StatefulWidget {
  final GlobalKey<ScaffoldState> parentScaffoldKey;
  final RouteArgument routeArgument;

  StoreSelectWidget({Key key, this.parentScaffoldKey, this.routeArgument})
      : super(key: key);

  @override
  _StoreSelectWidgetState createState() => _StoreSelectWidgetState();
}

class _StoreSelectWidgetState extends StateMVC<StoreSelectWidget> {
  CartController _con = new CartController();

  _StoreSelectWidgetState() : super(RestaurantController()) {}

  @override
  void initState() {
    super.initState();
    if (currentUser.value.apiToken != null) {
      _con.listenForCartsCount();
    }
  }

  @override
  Widget build(BuildContext context) {
    SizeConfig().init(context);
    return WillPopScope(
        onWillPop: () async => false,
        child: Scaffold(
          appBar: AppBar(
            backgroundColor: Colors.transparent,
            elevation: 0,
            centerTitle: true,
            leading: const SizedBox(),
            // new IconButton(
            //   icon: new Icon(Icons.sort, color: Theme.of(context).hintColor),
            //   onPressed: () => widget.parentScaffoldKey.currentState.openDrawer(),
            // ),
            title: Text(
              "Where to Shop?",
              style: Theme.of(context)
                  .textTheme
                  .headline6
                  .merge(TextStyle(letterSpacing: 1.5)),
            ),
            actions: <Widget>[new StoreSelectShoppingCartButtonWidget()],
          ),
          body: SafeArea(
            child: Center(
              child: Column(
                  mainAxisAlignment: MainAxisAlignment.center,
                  crossAxisAlignment: CrossAxisAlignment.center,
                  children: [
                    // LogoLoadingWidget(),
                    Container(
                      height: SizeConfig.blockSizeVertical*260,
                      child: FlatButton(
                                onPressed: () => nextPage(0),
                                child: Image.asset(
                                  'assets/img/saudaghar.png',
                                ),
                              ),
                    ),
                    Divider(height: SizeConfig.blockSizeVertical*30),
                    Container(
                      height: SizeConfig.blockSizeVertical*260,
                      child: FlatButton(
                        onPressed: () => nextPage(0),
                        child: Image.asset(
                          'assets/img/fresh.png',
                        ),
                      ),
                    ),
                    Divider(height: SizeConfig.blockSizeVertical*30),
                    Container(
                      height: SizeConfig.blockSizeVertical*260,
                      child: FlatButton(
                        onPressed: () => nextPage(0),
                        child: Image.asset(
                          'assets/img/home.png',
                        ),
                      ),
                    ),
                  ]
              ),
            ),
            // ]
            // ),
            // Positioned(
            //     bottom: 0,
            //     width: MediaQuery.of(context).size.width,
            //     child: SocialMediaOrdering()
            // ),
          ),
        ));
  }

  void nextPage(int isStore) {
    settingsRepo.isStore.value = isStore;
    Navigator.of(context).pushNamed('/Pages', arguments: 2);
  }
}
