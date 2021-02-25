import 'package:cached_network_image/cached_network_image.dart';
import 'package:flutter/material.dart';
import 'package:global_configuration/global_configuration.dart';
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

//void showPopup() async {
//  await showDialog(
//      context: context,
//      builder: (_) => ImageDialog()
//  );
//}

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
            leading: currentUser.value.apiToken == null
                ? const SizedBox()
                : InkWell(
                    onTap: () => Navigator.of(context).pushNamed('/Profile'),
                    child: Stack(
                      alignment: Alignment.topCenter,
                      children: [
                        IconButton(
                          icon: new Icon(Icons.perm_identity_rounded,
                              color: Theme.of(context).accentColor),
                          // onPressed: () => widget.parentScaffoldKey.currentState.openDrawer(),
                        ),
                        if (currentUser.value.points > 0)
                          Positioned(
                            bottom: 8,
                            child: Wrap(
                              direction: Axis.vertical,
                              children: [
                                Container(
                                  padding: EdgeInsets.symmetric(
                                      horizontal: 5, vertical: 2),
                                  decoration: BoxDecoration(
                                      color: Colors.orange,
                                      borderRadius: BorderRadius.all(
                                          Radius.circular(10))),
                                  child: Row(
                                    children: [
                                      Icon(
                                        Icons.account_balance_wallet,
                                        color: Theme.of(context).primaryColor,
                                        size: 10,
                                      ),
                                      Text(
                                        currentUser.value.points.toString(),
                                        textAlign: TextAlign.center,
                                        style: Theme.of(context)
                                            .textTheme
                                            .caption
                                            .merge(TextStyle(
                                                color: Theme.of(context)
                                                    .primaryColor,
                                                fontSize: 9)),
                                      ),
                                    ],
                                  ),
                                ),
                              ],
                            ),
                          )
                      ],
                    ),
                  ),
            title: Text(
              "Where to Shop?",
              style: Theme.of(context)
                  .textTheme
                  .headline6
                  .merge(TextStyle(letterSpacing: 1.5)),
            ),
            actions: <Widget>[
              new StoreSelectShoppingCartButtonWidget()],
          ),
          body: SafeArea(
            child: Center(
              child: Column(
                  mainAxisAlignment: MainAxisAlignment.center,
                  crossAxisAlignment: CrossAxisAlignment.center,
                  children: [
                    // LogoLoadingWidget(),
                    ClipRect(
                      child: Container(
                        child: Align(
                          alignment: Alignment(0, 0),
                          widthFactor: 1.0,
                          heightFactor: SizeConfig.HeightSize(1.15).clamp(0.1, 0.85).toDouble(),
                          child: FlatButton(
                            padding: EdgeInsets.all(0),
                            onPressed: () => nextPage(0),
                            child: Image.asset(
                              'assets/img/saudaghar.png',
                            ),
                          ),
                        ),
                      ),
                    ),
                    Divider(height: SizeConfig.blockSizeVertical*20),
                    ClipRect(
                      child: Container(
                        child: Align(
                          alignment: Alignment(0, -0.7),
                          widthFactor: 1.0,
                          heightFactor: SizeConfig.HeightSize(1.15).clamp(0.1, 0.85).toDouble(),
                          child: FlatButton(
                            padding: EdgeInsets.all(0),
                            onPressed: () => nextPage(1),
                            child: Image.asset(
                              'assets/img/fresh.png',
                            ),
                          ),
                        ),
                      ),
                    ),
                    Divider(height: SizeConfig.blockSizeVertical*20),
                    ClipRect(
                      child: Container(
                        child: Align(
                          alignment: Alignment(0, -0.7),
                          widthFactor: 1.0,
                          heightFactor: SizeConfig.HeightSize(1.15).clamp(0.1, 0.85).toDouble(),
                          child: FlatButton(
                            padding: EdgeInsets.all(0),
                            onPressed: () => nextPage(2),
                            child: Image.asset(
                              'assets/img/home.png',
                            ),
                          ),
                        ),
                      ),
                    ),
                  ]
              ),
            ),
          ),
        ));
  }

  void nextPage(int isStore) {
    settingsRepo.store_type.value = isStore;
    Navigator.of(context).pushNamed('/Pages', arguments: 1);
  }

  void showPopup() async {
    await showDialog(
        context: context,
        builder: (_) => ImageDialog()
    );
  }
}




class ImageDialog extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return Dialog(
      child: ClipRRect(
        borderRadius: BorderRadius.circular(30),
        child: CachedNetworkImage(
          height: MediaQuery.of(context).size.height / 1.8,
          width: MediaQuery.of(context).size.width / 1.3,
          fit: BoxFit.cover,
          imageUrl: "${GlobalConfiguration().getString('base_url')}storage/app/public/promotions.png",
          placeholder: (context, url) => Image.asset(
            'assets/img/loading.gif',
            fit: BoxFit.contain,
            width: double.infinity,
            height: 82,
          ),
          errorWidget: (context, url, error) => Image.asset(
            'assets/img/image_default.png',
            fit: BoxFit.cover,
            width: double.infinity,
            height: 150,
          ),
        ),
      ),
      elevation: 10,
      shape: const RoundedRectangleBorder(
          borderRadius: BorderRadius.all(Radius.circular(30.0))),
    );
  }


}
