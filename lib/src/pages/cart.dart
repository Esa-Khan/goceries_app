import 'package:flutter/material.dart';
import 'package:mvc_pattern/mvc_pattern.dart';

import '../../generated/l10n.dart';
import '../controllers/cart_controller.dart';
import '../elements/CartBottomDetailsWidget.dart';
import '../elements/CartItemWidget.dart';
import '../elements/EmptyCartWidget.dart';
import '../models/route_argument.dart';

class CartWidget extends StatefulWidget {
  final RouteArgument routeArgument;

  CartWidget({Key key, this.routeArgument}) : super(key: key);

  @override
  _CartWidgetState createState() => _CartWidgetState();
}

class _CartWidgetState extends StateMVC<CartWidget> {
  CartController _con;

  _CartWidgetState() : super(CartController()) {
    _con = controller;
  }

  @override
  void initState() {
    _con.listenForCarts();
    super.initState();
  }

  @override
  Widget build(BuildContext context) {
    return WillPopScope(
      onWillPop: () async => true,
      child: Scaffold(
        key: _con.scaffoldKey,
        bottomNavigationBar: CartBottomDetailsWidget(con: _con),
        appBar: AppBar(
          automaticallyImplyLeading: false,
          leading: IconButton(
            onPressed: () {
              if (widget.routeArgument.param == '/Food') {
                Navigator.of(context).pushReplacementNamed('/Food', arguments: RouteArgument(id: widget.routeArgument.id));
              } else if(widget.routeArgument.param == '/Details') {
                Navigator.pop(context);
              } else if(widget.routeArgument.param == '/StoreSelect') {
                Navigator.of(context).pushReplacementNamed('/StoreSelect');
              } else {
                Navigator.of(context).pushNamed('/Pages', arguments: 2);
              }
            },
            icon: Icon(Icons.arrow_back),
          ),
          centerTitle: true,
          title: Text(
            S.of(context).cart,
            style: Theme.of(context).textTheme.headline6.merge(TextStyle(letterSpacing: 1.3)),
          ),
        ),

        body: RefreshIndicator(
          onRefresh: _con.refreshCarts,
          child: _con.carts.isEmpty
              ? EmptyCartWidget()
              : Container(
                  child: ListView(
                    padding: EdgeInsets.only(bottom: 10),
                    children: <Widget>[
                      Padding(
                        padding: const EdgeInsets.only(left: 20, right: 10, top: 10),
                        child: ListTile(
                          leading: Icon(
                            Icons.shopping_cart,
                            color: Theme.of(context).hintColor,
                          ),
                          title: Container(
                            // padding: EdgeInsets.fromLTRB(0, 0, 20, 0),
                            child: Text(
                              'Verify your quantity or add any extra notes and click checkout\nSwipe item to remove',
                              maxLines: 5,
                              overflow: TextOverflow.ellipsis,
                              style: Theme.of(context).textTheme.bodyText1,
                            ),
                          ),
                        ),
                      ),
                      ListView.separated(
                        padding: EdgeInsets.symmetric(vertical: 15),
                        scrollDirection: Axis.vertical,
                        shrinkWrap: true,
                        primary: false,
                        itemCount: _con.carts.length,
                        separatorBuilder: (context, index) {
                          return SizedBox(height: 15);
                        },
                        itemBuilder: (context, index) {
                          return CartItemWidget(
                            cart: _con.carts.elementAt(index),
                            heroTag: 'cart',
                            increment: () {
                              _con.incrementQuantity(_con.carts.elementAt(index));
                            },
                            decrement: () {
                              _con.decrementQuantity(_con.carts.elementAt(index));
                            },
                            onDismissed: () {
                              _con.removeFromCart(_con.carts.elementAt(index));
                            },
                          );
                        },
                      ),
                    ],
                  ),
                ),
        ),
      ),
    );
  }
}
