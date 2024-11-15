import 'package:flutter/material.dart';
import 'package:mvc_pattern/mvc_pattern.dart';
import 'package:saudaghar/src/repository/cart_repository.dart';

import '../controllers/cart_controller.dart';
import '../models/route_argument.dart';
import '../repository/user_repository.dart';

class ShoppingCartButtonWidget extends StatefulWidget {
  const ShoppingCartButtonWidget({
    this.iconColor,
    this.labelColor,
    Key key,
  }) : super(key: key);

  final Color iconColor;
  final Color labelColor;

  @override
  _ShoppingCartButtonWidgetState createState() => _ShoppingCartButtonWidgetState();
}

class _ShoppingCartButtonWidgetState extends StateMVC<ShoppingCartButtonWidget> {
  CartController _con;

  _ShoppingCartButtonWidgetState() : super(CartController()) {
    _con = controller;
  }

  @override
  void initState() {
    cart_count.addListener(() => setState(() => cart_count));
    _con.listenForCartsCount();
    super.initState();
  }

  @override
  Widget build(BuildContext context) {
    return FlatButton(
      onPressed: () {
        if (currentUser.value.apiToken != null) {
          Navigator.of(context).pushNamed('/Cart',
              arguments: RouteArgument(
                  param: '/Pages',
                  id: '2'
              ));
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
            child: _con.cartcount_isLoaded
              ?   Text(
                    cart_count.value.toString(),
                    textAlign: TextAlign.center,
                    style: Theme.of(context).textTheme.caption.merge(
                          TextStyle(color: Theme.of(context).primaryColor, fontSize: 9),
                        ),
                  )
              : Center(
                  child: SizedBox(width: 7, height: 7,
                      child: CircularProgressIndicator(strokeWidth: 1, backgroundColor: Theme.of(context).primaryColor)
                  )
            ),
            padding: EdgeInsets.all(1.5),
            decoration: BoxDecoration(color: this.widget.labelColor, borderRadius: BorderRadius.all(Radius.circular(10))),
            constraints: BoxConstraints(minWidth: 15, maxWidth: 15, minHeight: 15, maxHeight: 15),
          ),
        ],
      ),
      color: Colors.transparent,
    );
  }
}
