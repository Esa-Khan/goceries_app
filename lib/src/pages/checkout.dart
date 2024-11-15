import 'package:flutter/material.dart';
import 'package:mvc_pattern/mvc_pattern.dart';
import 'package:saudaghar/src/repository/cart_repository.dart';

import '../../generated/l10n.dart';
import '../controllers/checkout_controller.dart';
import '../elements/CircularLoadingWidget.dart';
import '../elements/CreditCardsWidget.dart';
import '../helpers/helper.dart';
import '../models/route_argument.dart';
import '../repository/settings_repository.dart';
import '../models/payment_method.dart';

class CheckoutWidget extends StatefulWidget {
  final String cardType;
  CheckoutWidget({Key key, @required this.cardType}) : super(key: key);

//  RouteArgument routeArgument;
//  CheckoutWidget({Key key, this.routeArgument}) : super(key: key);
  @override
//  _CheckoutWidgetState createState() => _CheckoutWidgetState();
  _CheckoutWidgetState createState() => _CheckoutWidgetState(cardType);
}

class _CheckoutWidgetState extends StateMVC<CheckoutWidget> {
  CheckoutController _con;
  final String cardType;

//  _CheckoutWidgetState() : super(CheckoutController()) {
    _CheckoutWidgetState(this.cardType) : super(CheckoutController()) {
    _con = controller;
  }
  @override
  void initState() {
    _con.listenForCarts();
    super.initState();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      key: _con.scaffoldKey,
      resizeToAvoidBottomInset: false,
      appBar: AppBar(
        backgroundColor: Colors.transparent,
        elevation: 0,
        centerTitle: true,
        title: Text(
          S.of(context).checkout,
          style: Theme.of(context).textTheme.headline6.merge(TextStyle(letterSpacing: 1.3)),
        ),
      ),
      body: _con.carts.isEmpty
          ? Center(heightFactor: 3.5, child: SizedBox(width: 120, height: 120, child: CircularProgressIndicator(strokeWidth: 8)))
          : Stack(
              fit: StackFit.expand,
              children: <Widget>[
                Padding(
                  padding: const EdgeInsets.only(bottom: 1),
                  child: SingleChildScrollView(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.center,
                      mainAxisSize: MainAxisSize.min,
                      children: <Widget>[
                        Padding(
                          padding: const EdgeInsets.only(left: 20, right: 10),
                          child: ListTile(
                            contentPadding: EdgeInsets.symmetric(vertical: 0),
                            leading: Icon(
                              Icons.payment,
                              color: Theme.of(context).hintColor,
                            ),
                            title: Text(
                              S.of(context).payment_mode,
                              maxLines: 1,
                              overflow: TextOverflow.ellipsis,
                              style: Theme.of(context).textTheme.headline4,
                            ),
//                            subtitle: Text(
//                              S.of(context).select_your_preferred_payment_mode,
//                              maxLines: 1,
//                              overflow: TextOverflow.ellipsis,
//                              style: Theme.of(context).textTheme.caption,
//                            ),
                          ),
                        ),
                        SizedBox(height: 20),
                        new CreditCardsWidget (
                            creditCard: _con.creditCard,
                            onChanged: (creditCard) {
                              _con.updateCreditCard(creditCard);
                            },
                        cardType: cardType),
                        SizedBox(height: 40),
//                        setting.value.payPalEnabled
//                            ? Text(
//                                S.of(context).or_checkout_with,
//                                style: Theme.of(context).textTheme.caption,
//                              )
//                            : SizedBox(height: 0),
//                        SizedBox(height: 40),
//                        setting.value.payPalEnabled
//                            ? SizedBox(
//                                width: 320,
//                                child: FlatButton(
//                                  onPressed: () {
//                                    Navigator.of(context).pushReplacementNamed('/PayPal');
//                                  },
//                                  padding: EdgeInsets.symmetric(vertical: 12),
//                                  color: Theme.of(context).focusColor.withOpacity(0.2),
//                                  shape: StadiumBorder(),
//                                  child: Image.asset(
//                                    'assets/img/paypal2.png',
//                                    height: 28,
//                                  ),
//                                ),
//                              )
//                            : SizedBox(height: 0),
//                        SizedBox(height: 20),
                      ],
                    ),
                  ),
                ),
                Positioned(
                  bottom: 0,
                  child: Container(
                    padding: EdgeInsets.symmetric(horizontal: 20, vertical: 15),
                    decoration: BoxDecoration(
                        color: Theme.of(context).primaryColor,
                        borderRadius: BorderRadius.only(topRight: Radius.circular(40), topLeft: Radius.circular(40)),
                        boxShadow: [BoxShadow(color: Theme.of(context).focusColor.withOpacity(0.15), offset: Offset(0, -2), blurRadius: 5.0)]),
                    child: SizedBox(
                      width: MediaQuery.of(context).size.width - 40,
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.center,
                        mainAxisSize: MainAxisSize.max,
                        children: <Widget>[
                          Row(
                            children: <Widget>[
                              Expanded(
                                child: Text(
                                  S.of(context).subtotal,
                                  style: Theme.of(context).textTheme.bodyText1,
                                ),
                              ),
                              Helper.getPrice(_con.subTotal, context, style: Theme.of(context).textTheme.subtitle1)
                            ],
                          ),
                          const SizedBox(height: 3),
                          Row(
                            children: <Widget>[
                              Expanded(
                                child: Text(
                                  S.of(context).delivery_fee,
                                  style: Theme.of(context).textTheme.bodyText1,
                                ),
                              ),
                              _con.subTotal < setting.value.deliveryFeeLimit
                                  ? Helper.getPrice(_con.carts[0].food.restaurant.deliveryFee, context, style: Theme.of(context).textTheme.subtitle1)
                                  : Helper.getPrice(0, context, style: Theme.of(context).textTheme.subtitle1)

                            ],
                          ),
//                          Row(
//                            children: <Widget>[
//                              Expanded(
//                                child: Text(
//                                  "${S.of(context).tax} (${_con.carts[0].food.restaurant.defaultTax}%)",
//                                  style: Theme.of(context).textTheme.bodyText1,
//                                ),
//                              ),
//                              Helper.getPrice(_con.taxAmount, context, style: Theme.of(context).textTheme.subtitle1)
//                            ],
//                          ),
                          const Divider(height: 10),
                          Row(
                            children: <Widget>[
                              Expanded(
                                child: Text(
                                  S.of(context).total,
                                  style: Theme.of(context).textTheme.headline6,
                                ),
                              ),
                              Helper.getPrice(_con.total, context, style: Theme.of(context).textTheme.headline6)
                            ],
                          ),
                          const Divider(height: 10),
                          SizedBox(
                            width: MediaQuery.of(context).size.width - 40,
                            height: MediaQuery.of(context).size.height/12,
                            child: FlatButton(
                              onPressed: () {
                                if (_con.creditCard.validated()) {
                                  Navigator.of(context).pushNamed('/OrderSuccess', arguments: new RouteArgument(param: 'Credit Card (Stripe Gateway)'));
                                } else {
                                  _con.scaffoldKey?.currentState?.showSnackBar(SnackBar(
                                    content: Text(S.of(context).your_credit_card_not_valid),
                                  ));
                                }
                              },
                              padding: EdgeInsets.symmetric(vertical: 14),
                              color: Theme.of(context).accentColor,
                              shape: const StadiumBorder(),
                              child: Text(
                                'Next',
                                textAlign: TextAlign.start,
                                style: TextStyle(color: Theme.of(context).primaryColor, fontSize: 20),
                              ),
                            ),
                          ),
                          const SizedBox(height: 10),
                        ],
                      ),
                    ),
                  ),
                ),
              ],
            ),
    );
  }
}
