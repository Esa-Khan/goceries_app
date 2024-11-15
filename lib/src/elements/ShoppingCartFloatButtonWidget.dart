import 'package:flutter/material.dart';
import 'package:mvc_pattern/mvc_pattern.dart';
import 'package:saudaghar/src/repository/cart_repository.dart';

import '../controllers/cart_controller.dart';
import '../models/item.dart';
import '../models/route_argument.dart';
import '../repository/user_repository.dart';

class ShoppingCartFloatButtonWidget extends StatefulWidget {
  const ShoppingCartFloatButtonWidget({
    this.iconColor,
    this.labelColor,
    this.food,
    Key key,
  }) : super(key: key);

  final Color iconColor;
  final Color labelColor;
  final Item food;

  @override
  _ShoppingCartFloatButtonWidgetState createState() => _ShoppingCartFloatButtonWidgetState();
}

class _ShoppingCartFloatButtonWidgetState extends StateMVC<ShoppingCartFloatButtonWidget> {
  CartController _con;

  _ShoppingCartFloatButtonWidgetState() : super(CartController()) {
    _con = controller;
  }

  @override
  void initState() {
    _con.listenForCartsCount();
    super.initState();
  }

  @override
  Widget build(BuildContext context) {
    return SizedBox(
      width: 60,
      height: 60,
      child: RaisedButton(
        padding: EdgeInsets.all(0),
        color: Theme.of(context).accentColor,
        shape: StadiumBorder(),
        onPressed: () {
          if (currentUser.value.apiToken != null) {
            Navigator.of(context).pushNamed('/Cart', arguments: RouteArgument(param: '/Details', heroTag: 'From food')).then((value) => this.setState(() { }));
//            Navigator.of(context).pushNamed('/Cart', arguments: RouteArgument(param: '/Item', id: widget.food.id));
          } else {
            Navigator.of(context).pushNamed('/Login');
          }
        },
        child: Stack(
          alignment: AlignmentDirectional.bottomEnd,
          children: <Widget>[
            Icon(
              Icons.shopping_cart,
              color: this.widget.iconColor,
              size: 28,
            ),
            Container(
              child: Center(
                child: _con.cartcount_isLoaded
                    ? Text(
                  cart_count.value.toString(),
                  textAlign: TextAlign.center,
                  style: Theme.of(context).textTheme.caption.merge(
                    TextStyle(color: Theme.of(context).primaryColor, fontSize: 9),
                  ),
                )
                    : SizedBox(width: 120, height: 120,
                    child: CircularProgressIndicator(strokeWidth: 2, backgroundColor: Theme.of(context).primaryColor)
                )
              ),
              padding: EdgeInsets.all(0),
              decoration: BoxDecoration(color: this.widget.labelColor, borderRadius: BorderRadius.all(Radius.circular(10))),
              constraints: BoxConstraints(minWidth: 15, maxWidth: 15, minHeight: 15, maxHeight: 15),
            ),
          ],
        ),
      ),
    );
  }
}
