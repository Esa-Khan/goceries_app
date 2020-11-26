import 'package:flutter/material.dart';
import 'package:mvc_pattern/mvc_pattern.dart';

import '../controllers/cart_controller.dart';
import '../models/route_argument.dart';
import '../repository/user_repository.dart';

class StoreSelectShoppingCartButtonWidget extends StatefulWidget {


  const StoreSelectShoppingCartButtonWidget({
    Key key,
  }) : super(key: key);

  @override
  _StoreSelectShoppingCartButtonWidgetState createState() => _StoreSelectShoppingCartButtonWidgetState();
}

class _StoreSelectShoppingCartButtonWidgetState extends StateMVC<StoreSelectShoppingCartButtonWidget> {
  CartController _con;

  _StoreSelectShoppingCartButtonWidgetState() : super(CartController()) {
    _con = controller;
  }

  @override
  void initState() {
    _con.listenForCartsCount();
    super.initState();
  }

  @override
  Widget build(BuildContext context) {
    return _con.cartCount == 0
      ? IconButton(
          padding: EdgeInsets.fromLTRB(0, 0, 20, 0),
          icon: currentUser.value.id == null
              ? Icon(Icons.login_sharp, color: Theme.of(context).accentColor)
              : Icon(Icons.home, color: Theme.of(context).accentColor),
          onPressed: () {
            if (currentUser.value.id == null)
              Navigator.of(context).pushNamed('/Login');
          }
        )
      : FlatButton(
      onPressed: () {
        if (currentUser.value.apiToken != null) {
          Navigator.of(context).pushNamed('/Cart',
              arguments: RouteArgument(param: '/StoreSelect'));
        } else {
          Navigator.of(context).pushNamed('/Login');
        }
      },
      child: Stack(
        alignment: AlignmentDirectional.bottomEnd,
        children: <Widget>[
          Icon(
            Icons.shopping_cart,
            color: Theme.of(context).hintColor,
            size: 28,
          ),
          Container(
            child: Text(
              _con.cartCount.toString(),
              textAlign: TextAlign.center,
              style: Theme.of(context).textTheme.caption.merge(
                    TextStyle(color: Theme.of(context).primaryColor, fontSize: 9),
                  ),
            ),
            padding: EdgeInsets.all(1.5),
            decoration: BoxDecoration(color: Theme.of(context).accentColor, borderRadius: BorderRadius.all(Radius.circular(10))),
            constraints: BoxConstraints(minWidth: 15, maxWidth: 15, minHeight: 15, maxHeight: 15),
          ),
        ],
      ),
      color: Colors.transparent,
    );
  }
}
